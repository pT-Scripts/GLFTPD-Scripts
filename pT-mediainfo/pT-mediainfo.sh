#!/bin/bash

VER=1.8

# Configuration
GLROOT="/glftpd"
TMP="/glftpd/tmp"
COLOR1="7"   # Orange
COLOR2="14"  # Dark grey
COLOR3="4"   # Red

# FTP Configuration
FTP_HOST="127.0.0.1"
FTP_PORT=21
FTP_USER="ftpuser"
FTP_PASS="somepass"
REMOTE_BASE_DIR="/var/www/html/media"

# Search Configuration
SEARCH_INCOMING_ONLY=true  # Set to true to search only in incoming, false to search in both main and incoming

# Help message
HELP="${COLOR2}Please enter full releasename i.e. ${COLOR3}Terminator.Salvation.2009.THEATRICAL.1080p.BluRay.x264-FLAME\n"

# Debug mode (true or false)
DEBUG=false

# Function to print debug messages
debug_print() {
    if [ "$DEBUG" = true ]; then
        echo "[DEBUG] $1"
    fi
}

# Function to skip sections and halt execution
skip_sections() {
    local section="$1"
    case "$section" in
        APPS|GAMES-PC|GAMES-NSW|PS5)
            exit 0
            ;;
    esac
}

# Check if input is provided correctly
if [ $# -ne 2 ]; then
    echo -e "$HELP"
    exit 1
fi

# Extract parameters
SECTION="$1"
RELEASE="$2"

# Remove /Sample from RELEASE if present
RELEASE="${RELEASE%%/[Ss]ample}"

# Call skip_sections function to check section and potentially halt execution
skip_sections "$SECTION"

# Function to find release in specified directories
find_release() {
    local section="$1"
    local release="$2"
    local found_release=""

    if [ "$SEARCH_INCOMING_ONLY" = true ]; then
        if [ -d "$GLROOT/site/incoming/$section/$release" ]; then
            found_release="$GLROOT/site/incoming/$section/$release"
        fi
    else
        if [ -d "$GLROOT/site/$section/$release" ]; then
            found_release="$GLROOT/site/$section/$release"
        fi
        if [ -z "$found_release" ] && [ -d "$GLROOT/site/incoming/$section/$release" ]; then
            found_release="$GLROOT/site/incoming/$section/$release"
        fi
    fi

    echo "$found_release"
}

# Function to retrieve media information and format output
retrieve_media_info() {
    local media_file="$1"
    local md5_filename=$(md5sum "$media_file" | cut -d ' ' -f 1).mediainfo
    local tmp_mediainfo_file="$TMP/$md5_filename"

    # Run mediainfo tool and save output to temporary file
    mediainfo "$media_file" > "$tmp_mediainfo_file"

    local output
    output=$( {
        local video_info
        video_info=$(mediainfo --Inform="Video;%CodecID%,%FrameRate%,%Width%,%Height%,%AspectRatio/String%" "$media_file")
        local audio_info
        audio_info=$(mediainfo --Inform="Audio;%CodecID%,%BitRate%,%SamplingRate%,%Channels%" "$media_file" | head -n 1)
        
        # Extract information
        local video_codec_id=$(echo "$video_info" | cut -d',' -f1)
        local frame_rate=$(echo "$video_info" | cut -d',' -f2)
        local width=$(echo "$video_info" | cut -d',' -f3)
        local height=$(echo "$video_info" | cut -d',' -f4)
        local aspect_ratio=$(echo "$video_info" | cut -d',' -f5)
        local audio_codec_id=$(echo "$audio_info" | cut -d',' -f1)
        local audio_bitrate_bps=$(echo "$audio_info" | cut -d',' -f2)
        local sampling_rate=$(echo "$audio_info" | cut -d',' -f3)
        local audio_channels=$(echo "$audio_info" | cut -d',' -f4)

        local video_codec=$(get_codec_name "$video_codec_id")
        local audio_codec=$(get_codec_name "$audio_codec_id")
        local audio_bitrate=$((audio_bitrate_bps / 1000))

        # Formatting output lines
        echo -e "${COLOR2}VIDEO-INFO: ${RELEASE} ${video_codec} ${frame_rate} ${width}x${height} ${aspect_ratio} ${audio_codec} ${audio_bitrate} ${sampling_rate} ${audio_channels}"
        echo -e "${COLOR1}SAMPLE-DATA: ${RELEASE} https://predb.ws/media/${md5_filename} ${media_file##*/} $(stat --printf="%s" "$media_file")"
    })

    # FTP upload .mediainfo file to /var/www/html/media/
    debug_print "Uploading .mediainfo file ($md5_filename) to FTP server..."
    ftp -inv <<EOF >/dev/null
open $FTP_HOST $FTP_PORT
user $FTP_USER $FTP_PASS
cd $REMOTE_BASE_DIR
put "$tmp_mediainfo_file" "$md5_filename"
bye
EOF

    if [ $? -eq 0 ]; then
        debug_print "FTP upload successful"
        rm "$tmp_mediainfo_file"
    else
        debug_print "FTP upload failed"
        output+="\nFTP upload failed. Check debug output for more details."
        [ -f "$tmp_mediainfo_file" ] && rm "$tmp_mediainfo_file"
    fi

    echo -e "$output"
    echo -e "$output" >> /glftpd/ftp-data/logs/mediainfo.log
}

# Function to get human-readable codec name based on codec ID
get_codec_name() {
    local codec_id="$1"
    case "$codec_id" in
        V_MPEG4/ISO/AVC)   echo "H.264" ;;
        V_MPEGH/ISO/HEVC)  echo "H.265" ;;
        A_EAC3)            echo "E-AC3" ;;
        A_AAC)             echo "AAC" ;;
        A_MP3)             echo "MP3" ;;
        V_VP9)             echo "VP9" ;;
        V_AV1)             echo "AV1" ;;
        A_OPUS)            echo "Opus" ;;
        V_VP8)             echo "VP8" ;;
        V_MPEG2)           echo "MPEG-2" ;;
        A_AC3)             echo "AC-3" ;;
        A_PCM)             echo "PCM" ;;
        A_WAVPACK)         echo "WavPack" ;;
        V_THEORA)          echo "Theora" ;;
        V_SNOW)            echo "Snow" ;;
        A_FLAC)            echo "FLAC" ;;
        *)                 echo "$codec_id" ;;
    esac
}

# Find release in specified directories
found_release=$(find_release "$SECTION" "$RELEASE")

# Check if release was found
if [ -z "$found_release" ]; then
    echo "Release not found in section $SECTION"
    echo "Release not found in section $SECTION" >> /glftpd/ftp-data/logs/mediainfo.log
    exit 1
fi

# Directory to search for media info
release_dir="$found_release"

# Print debug information if DEBUG is true
debug_print "Debug mode enabled. Searching in directory: $release_dir"

# Find and process .mkv, .mp4 files, announcing skipped .m2ts files
find "$release_dir" -type f \( -iname "*.mkv" -o -iname "*.mp4" -o -iname "*.m2ts" \) -print0 | while IFS= read -r -d '' media_file; do
    # Skip directories
    [ -d "$media_file" ] && continue

    case "$media_file" in
        *.m2ts)
            echo "Skipped .m2ts file: $media_file"
            echo "Skipped .m2ts file: $media_file" >> /glftpd/ftp-data/logs/mediainfo.log
            ;;
        *.mkv|*.mp4)
            # Process media files in parallel to speed up processing
            {
                retrieve_media_info "$media_file"
            } &
            # Limit the number of parallel processes to avoid overwhelming the system
            if [ $(jobs -r -p | wc -l) -ge 4 ]; then
                wait -n
            fi
            ;;
    esac

done

# Wait for all background jobs to finish
wait

# End of script
