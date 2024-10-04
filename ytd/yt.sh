#!/bin/bash

# Function to display usage
display_usage() {
    echo # Empty line
    echo "Info: Script to download YouTube music and/or video."
    echo # Empty line
    echo "Usage: $0 [YouTube link] [Options]"
    echo # Empty line
    echo "Options:"
    echo "  -f  to convert the frequency of the audio to 432hz and 444hz (444=528hz on C)."
    echo "  -a  to download only audio."
    echo "  -b [1-20]  to apply bass boost (level 1-20)."
}

# Check what the base path is for this script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Script is located in  $DIR"

# Check if a YouTube link is provided
if [ -z "$1" ]; then
    echo "Error: No YouTube link provided."
    display_usage
    exit 1
fi

# Define variables for the options
youtube_link="$1"
shift
freq_option=""
audio_option=""
bass_boost_option=""

# Parse the options
while [[ $# -gt 0 ]]; do
    case $1 in
        -f)
            freq_option="--change_frequency"
            ;;
        -a)
            audio_option="--audio"
            ;;
        -b)
            if [[ $2 =~ ^[1-9]$|^1[0-9]$|^20$ ]]; then
                bass_boost_option="--bass_boost $2"
                shift
            else
                echo "Error: Bass boost level must be between 1 and 20."
                display_usage
                exit 1
            fi
            ;;
        *)
            echo "Error: Unexpected argument $1"
            display_usage
            exit 1
            ;;
    esac
    shift
done

# Activate virtual environment
source "$DIR/.venv/bin/activate"

# Check if the activation was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to activate virtual environment."
    exit 1
fi

# Run the Python script with the provided YouTube link and options
python3 "$DIR/main.py" "$youtube_link" $audio_option $freq_option $bass_boost_option

# Check if the Python script executed successfully
if [ $? -ne 0 ]; then
    echo "Error: Failed to run the Python script."
    deactivate
    exit 1
fi

# Deactivate virtual environment
deactivate

echo "Script executed successfully."
