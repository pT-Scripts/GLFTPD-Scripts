# pT-mediainfo by Petabyte

## Overview

The `pT-mediainfo` script automates the extraction and processing of media file information within a specified directory structure. It gathers detailed metadata about media files, formats the information, and uploads it to an FTP server. This script is ideal for maintaining a well-organized media library or catalog.

## Features

- **Search Directories**: Configurable to search either in the incoming directory only or in both main and incoming directories.
- **MediaInfo Extraction**: Extracts comprehensive video and audio details from `.mkv` and `.mp4` files.
- **FTP Upload**: Uploads the extracted media information to a designated FTP server.
- **Parallel Processing**: Processes multiple media files simultaneously to enhance performance.
- **Debug Mode**: Optional debug output for tracing script execution.

## Configuration

install mediainfo

sudo apt update
sudo apt install mediainfo


### FTP Configuration

Set the following variables for FTP server details:

- **FTP_HOST**: The hostname or IP address of the FTP server.
- **FTP_PORT**: The port for FTP server (default is 21).
- **FTP_USER**: The FTP username.
- **FTP_PASS**: The FTP password.
- **REMOTE_BASE_DIR**: The directory on the FTP server where files will be uploaded.

### Search Configuration

- **SEARCH_INCOMING_ONLY**: Set to `true` to search only in the incoming directory, or `false` to search in both main and incoming directories.

### Debug Mode

- **DEBUG**: Set to `true` to enable debug output for tracing script execution.

## Usage

### Prepare the Environment

Ensure the script has execute permissions:

```bash
chmod +x script.sh
Ensure that mediainfo and ftp commands are installed and accessible.

Run the Script
Execute the script with the following command:

./script.sh [SECTION] [RELEASE]
[SECTION]: The section within the directory structure where the media files are located (e.g., MOVIES, TV-SHOWS).
[RELEASE]: The name of the release to search for (e.g., Terminator.Salvation.2009.THEATRICAL.1080p.BluRay.x264-FLAME).

Example:
./script.sh MOVIES Terminator.Salvation.2009.THEATRICAL.1080p.BluRay.x264-FLAME


Check Logs
Media information and processing logs are saved to:

/glftpd/ftp-data/logs/mediainfo.log

