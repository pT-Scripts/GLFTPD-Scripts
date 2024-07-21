#!/bin/bash

# Function to extract show name, season, and episode or movie name and year from release name
extract_info_from_release() {
    release_name="$1"

    # Regex pattern to extract show name, season, and episode for TV shows
    if [[ $release_name =~ ^(.+)\.S([0-9]+)E([0-9]+) ]]; then
        show_name="${BASH_REMATCH[1]//./ }"  # Replace dots with spaces
        season="${BASH_REMATCH[2]}"
        episode="${BASH_REMATCH[3]}"
        type="tv"
    # Regex pattern to extract movie name and year
    elif [[ $release_name =~ ^(.+)\.([0-9]{4}) ]]; then
        show_name="${BASH_REMATCH[1]//./ }"  # Replace dots with spaces
        year="${BASH_REMATCH[2]}"
        type="movie"
    else
        echo "Error: Could not extract show name, season, and episode or movie name and year from release name."
        exit 1
    fi
}

# Function to fetch TMDB information based on show name or movie name
fetch_tmdb_info() {
    api_key="putyourtmdbapikeyhere"
    local show_name="$1"
    local type="$2"

    # Replace spaces with %20 (URL encoding)
    encoded_query=$(echo "$show_name" | sed 's/ /%20/g')

    # Determine the correct TMDB endpoint
    if [ "$type" == "tv" ]; then
        endpoint="search/tv"
    else
        endpoint="search/movie"
    fi

    # Make API request
    response=$(curl -s "https://api.themoviedb.org/3/$endpoint?api_key=$api_key&query=$encoded_query")

    # Check if there are results
    total_results=$(echo "$response" | jq -r '.total_results')
    if [ "$total_results" -eq 0 ]; then
        echo "Error: No results found for '$show_name' in TMDb."
        exit 1
    fi

    # Extract and print detailed information about the first result
    title=$(echo "$response" | jq -r '.results[0].name // .results[0].title')
    release_date=$(echo "$response" | jq -r '.results[0].first_air_date // .results[0].release_date')
    vote_average=$(echo "$response" | jq -r '.results[0].vote_average')
    genre_ids=$(echo "$response" | jq -r '.results[0].genre_ids | map(. | tostring) | join(", ")')
    popularity=$(echo "$response" | jq -r '.results[0].popularity')
    original_language=$(echo "$response" | jq -r '.results[0].original_language')
    poster_path=$(echo "$response" | jq -r '.results[0].poster_path')
    backdrop_path=$(echo "$response" | jq -r '.results[0].backdrop_path')
    tmdb_id=$(echo "$response" | jq -r '.results[0].id')

    # Function to convert language code to full name
    convert_language_code_to_name() {
        case "$1" in
            "en") echo "English" ;;
            "fr") echo "French" ;;
            "es") echo "Spanish" ;;
            "de") echo "German" ;;
            "it") echo "Italian" ;;
            "pt") echo "Portuguese" ;;
            "ru") echo "Russian" ;;
            "ja") echo "Japanese" ;;
            "zh") echo "Chinese" ;;
            "ko") echo "Korean" ;;
            "ar") echo "Arabic" ;;
            "hi") echo "Hindi" ;;
            "tr") echo "Turkish" ;;
            "nl") echo "Dutch" ;;
            "pl") echo "Polish" ;;
            "sv") echo "Swedish" ;;
            "da") echo "Danish" ;;
            "fi") echo "Finnish" ;;
            "no") echo "Norwegian" ;;
            "el") echo "Greek" ;;
            "he") echo "Hebrew" ;;
            "cs") echo "Czech" ;;
            "hu") echo "Hungarian" ;;
            "ro") echo "Romanian" ;;
            "vi") echo "Vietnamese" ;;
            "th") echo "Thai" ;;
            "id") echo "Indonesian" ;;
            "ms") echo "Malay" ;;
            "bn") echo "Bengali" ;;
            "ta") echo "Tamil" ;;
            "ka") echo "Georgian" ;;
            *) echo "$1" ;;  # Default to the code itself if no match found
        esac
    }

    # Convert original_language to full name
    full_language_name=$(convert_language_code_to_name "$original_language")

    # Format the release_date to be more human-readable
    formatted_release_date=$(date -d "$release_date" +"%d %B %Y")

    # Construct TMDB URL
    tmdb_url="https://www.themoviedb.org/$type/$tmdb_id"

    # Output all information in one line
    echo "$title - AiRED: $formatted_release_date - VOTES: $vote_average - LANGUAGE: $full_language_name - URL: $tmdb_url"
}

# Main script starts here

# Ensure an argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <release_name>"
    exit 1
fi

# Extract show name, season, and episode or movie name and year from release name
extract_info_from_release "$1"

# Fetch TMDB information based on show name or movie name
fetch_tmdb_info "$show_name" "$type"
