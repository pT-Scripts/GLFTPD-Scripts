#!/bin/bash

# ==============================================================================
#                             pT-gtop - ADDPRE Stats Script
# ==============================================================================
# 
# Overview
# This script processes a log file to generate statistics about various groups.
# It tracks total, weekly, and monthly counts of "ADDPRE" and provides
# a summary of groups with no activity. The script also includes a section for 
# reporting on groups that have not appeared in the log yet.
# 
# Features
# - **Total ADDPRE:** Displays the total number of entries per group.
# - **Weekly Stats:** Shows the number of entries in the past week.
# - **Monthly Stats:** Displays the number of entries in the past month.
# - **Groups with No Activity:** Lists groups that have not had any activity 
#   in the past week or since their creation.
# - **Exempted Groups:** Groups specified in the `exempted_groups` list are 
#   excluded from the statistics.
# 
# Usage
# 1. Save the script to a file named `pT-gtop.sh`.
# 2. Make the script executable: `chmod +x pT-gtop.sh`.
# 3. Run the script: `./pT-gtop.sh`.
# 
# ANNOUNCE TO IRC:
# 1. Save `pT-gtop.tcl` into the `eggdrop/scripts` directory.
# 2. Load the script in the Eggdrop config file with the command:
#    `source scripts/pT-gtop.tcl`
# 3. Remember to rehash the Eggdrop bot with the command:
#    `rehash`
# 4. Usage in mIRC:
#    Use the command `!gtop` in your IRC channel to get the latest ADDPRE statistics.
# 
# GitHub Repository
# For more details and updates, visit the [GitHub repository](https://github.com/pT-Scripts).
# 
# Coded by: Petabyte
# ==============================================================================

# Initialize associative arrays to store group stats
declare -A group_stats_total
declare -A group_stats_weekly
declare -A group_stats_monthly
declare -A group_first_release

# Path to the log file
log_file="/glftpd/ftp-data/logs/foo-pre.log"
# Path to groups directory
groups_dir="/glftpd/ftp-data/groups"
# List of exempted groups (replace with actual exempted group names)
exempted_groups=("Admin" "FRiENDS" "FAiLED" "Friends" "iND" "NoGroup" "NUKERS" "SiteOP" "VACATION" "default.group" "glftpd")

# Function to read groups from directory and count
count_groups() {
  local count=0
  # Loop through all files in groups directory
  for file_path in "$groups_dir"/*; do
    if [[ -f "$file_path" ]]; then
      # Extract group name from file path
      group=$(basename "$file_path")
      # Check if group should be counted (not exempted)
      if ! [[ " ${exempted_groups[@]} " =~ " $group " ]]; then
        (( count++ ))
        # Initialize group stats if not already initialized
        if [[ -z ${group_stats_total["$group"]} ]]; then
          group_stats_total["$group"]=0
          group_stats_weekly["$group"]=0
          group_stats_monthly["$group"]=0
          group_first_release["$group"]=0
        fi
      fi
    fi
  done
  echo "$count"
}

# Function to calculate time since creation in a readable format
calculate_time_since() {
  local creation_timestamp=$1
  local current_timestamp=$(date +%s)
  
  local seconds=$((current_timestamp - creation_timestamp))
  local minutes=$((seconds / 60))
  local hours=$((minutes / 60))
  local days=$((hours / 24))
  local months=$((days / 30))
  
  local months_remainder=$((months % 12))
  local years=$((months / 12))

  # Determine the exact age description
  if [[ $years -gt 0 ]]; then
    if [[ $months_remainder -gt 0 ]]; then
      echo "$years years $months_remainder months ago"
    else
      echo "$years years ago"
    fi
  elif [[ $months -gt 0 ]]; then
    if [[ $months -eq 1 ]]; then
      echo "1 month ago"
    else
      echo "$months months ago"
    fi
  elif [[ $days -gt 0 ]]; then
    if [[ $days -eq 1 ]]; then
      echo "1 day ago"
    else
      echo "$days days ago"
    fi
  else
    echo "less than a day ago"
  fi
}

# Calculate current timestamp and dates for comparison
current_timestamp=$(date +%s)
weekly_cutoff=$(date -d '7 days ago' +%s)
monthly_cutoff=$(date -d '30 days ago' +%s)

# Read the log file line by line
while IFS= read -r line; do
  # Check if the line contains "DONE:"
  if [[ "$line" =~ DONE ]]; then
    # Extract the group from the line
    group=$(echo "$line" | awk -F'"' '{print $4}')
    
    # Skip processing if the group is exempted
    if [[ " ${exempted_groups[@]} " =~ " $group " ]]; then
      continue
    fi
    
    # Extract the date and time from the log entry
    log_date=$(echo "$line" | awk '{print $1 " " $2}')
    log_timestamp=$(date -d "$log_date" +%s)

    # Increment the total count for the group
    group_stats_total["$group"]=$((group_stats_total["$group"] + 1))

    # Set the first release timestamp if not already set
    if [[ ${group_first_release["$group"]} -eq 0 ]]; then
      group_first_release["$group"]=$log_timestamp
    fi

    # Increment the weekly count for the group
    if [[ $log_timestamp -gt $weekly_cutoff ]]; then
      group_stats_weekly["$group"]=$((group_stats_weekly["$group"] + 1))
    fi

    # Increment the monthly count for the group
    if [[ $log_timestamp -gt $monthly_cutoff ]]; then
      group_stats_monthly["$group"]=$((group_stats_monthly["$group"] + 1))
    fi
  fi
done < "$log_file"

# Function to sort and rank the groups
rank_groups() {
  declare -A total_stats
  declare -A weekly_stats
  declare -A monthly_stats
  declare -A first_release_stats
  
  no_addpre_this_week=()  # Array to store groups with no ADDPRE this week
  no_addpre_yet=()        # Array to store groups with no ADDPRE yet

  total_addpre=0
  
  for group in "${!group_stats_total[@]}"; do
    # Skip processing if the group is exempted
    if [[ " ${exempted_groups[@]} " =~ " $group " ]]; then
      continue
    fi
    
    total_stats["$group"]=${group_stats_total[$group]}
    weekly_stats["$group"]=${group_stats_weekly[$group]}
    monthly_stats["$group"]=${group_stats_monthly[$group]}
    first_release_stats["$group"]=${group_first_release[$group]}
    
    total_addpre=$((total_addpre + ${group_stats_total[$group]}))
    
    # Check if the group has no ADDPRE this week
    if [[ ${group_stats_weekly[$group]} -eq 0 ]]; then
      no_addpre_this_week+=("$group")
    fi
    
    # Check if the group has no ADDPRE yet
    if [[ ${group_stats_total[$group]} -eq 0 ]]; then
      no_addpre_yet+=("$group")
    fi
  done
  
  # Sort and rank the groups by total ADDPRE
  rank=1
  
  # Output detailed stats for each group
  for group in $(for key in "${!total_stats[@]}"; do echo "$key ${total_stats[$key]}"; done | sort -k2 -nr | awk '{print $1}'); do
    total_addpre=${total_stats[$group]}
    # Ensure weekly ADDPRE are displayed as 0 if there are none
    weekly_addpre=${weekly_stats[$group]}
    if [[ -z $weekly_addpre ]]; then
      weekly_addpre=0
    fi
    monthly_addpre=${monthly_stats[$group]}
    first_release=$(date -d "@${first_release_stats[$group]}" +"%F %T")
    
    echo "[11#$rank] 07 $group  ::09 ${total_addpre} 14TOTAL ::03 ${weekly_addpre} 14this WEEK ::08 ${monthly_addpre} 14this MONTH"
    rank=$((rank + 1))
  done
  
  # Output groups with no ADDPRE this week
  if [[ ${#no_addpre_this_week[@]} -gt 0 ]]; then
    echo "07We had no 04ADDPRE 07this week from:07 ${no_addpre_this_week[*]}"
  fi
  
  # Output groups that are in groups directory but have not appeared in the log
  echo "05No ADDPRE yet from:"
  for file_path in "$groups_dir"/*; do
    if [[ -f "$file_path" ]]; then
      group=$(basename "$file_path")
      if ! [[ " ${!group_stats_total[@]} " =~ " $group " ]]; then
        # Skip exempted groups from this list
        if [[ ! " ${exempted_groups[@]} " =~ " $group " ]]; then
          # Calculate time since creation
          creation_timestamp=$(date -r "$file_path" +%s)
          time_since=$(calculate_time_since $creation_timestamp)
          echo "07 $group  :: 14 Affiliated $time_since"
        fi
      fi
    fi
  done
}

# Calculate total and today's ADDPRE
total_addpre=0
today_addpre=0

for count in "${group_stats_total[@]}"; do
  total_addpre=$((total_addpre + count))
done

# Calculate today's ADDPRE based on current date
today_date=$(date +%Y-%m-%d)
for line in $(grep "$today_date" "$log_file" | grep DONE | awk -F'"' '{print $4}'); do
  group="$line"
  if [[ ! " ${exempted_groups[@]} " =~ " $group " ]]; then
    today_addpre=$((today_addpre + 1))
  fi
done

# Output the total count of groups
total_groups=$(count_groups)
echo "[!#] 09-AFFiL PRE STATS- :: Thanks to09 $total_groups affils we have a Total 04ADDPRE PRED:09 $total_addpre :: Today's ADDPRE PRED:09 $today_addpre"

# Output the results with ranking
rank_groups
