from pytubefix import YouTube, Playlist
import argparse
import os
import re


SAVE_DIR_AUDIO = "/home/flo/Music/youtube_downloads"
SAVE_DIR_VIDEO = "/home/flo/Videos/youtube_downloads"


def convert_frequency(input_file, output_dir, pitch_ratio):
    os.system(f"ffmpeg -v quiet -i {input_file} -af rubberband=pitch={pitch_ratio} {output_dir}")


def bass_boost(input_file, output_file, boost_level):
    os.system(f"ffmpeg -v quiet -i {input_file} -af \"bass=g={boost_level},acompressor,alimiter\" {output_file}")
    print(f"Bass boost applied to {output_file}")


def download_yt(url, audio_only=False, change_frequency=False, bass_boost_level=None):
    # Get video from URL
    try:
        yt = YouTube(url)
    except Exception as e:
        print(f"Connection Error: {e}")
        return

    # Create directories if they don't exist
    if not os.path.exists(SAVE_DIR_AUDIO):
        os.makedirs(SAVE_DIR_AUDIO)
    if not os.path.exists(SAVE_DIR_VIDEO):
        os.makedirs(SAVE_DIR_VIDEO)

    DIR_432 = os.path.join(SAVE_DIR_AUDIO, "432")
    if not os.path.exists(DIR_432):
        os.makedirs(DIR_432)
    
    DIR_444 = os.path.join(SAVE_DIR_AUDIO, "444")
    if not os.path.exists(DIR_444):
        os.makedirs(DIR_444)

    # Get video title and format it
    file_name = yt.title.replace("   ", "_").replace("  ", "_").replace(" ", "_")
    file_name = re.sub(r"[^a-zA-Z0-9_]+", "", file_name).lower().replace("__", "_")

    # Download audio if not exists
    if audio_only:
        if os.path.exists(f"{SAVE_DIR_AUDIO}/{file_name}.mp3"):
            print(f"File ({file_name}.mp3) already exists! Skipping download...")
        else:
            print(f"Downloading audio: {yt.title}")
            yt.streams.get_audio_only().download(SAVE_DIR_AUDIO, filename=file_name, mp3=True)

        # Change frequencies if required
        if change_frequency:
            print(f"Converting frequency of {yt.title}...")
            pcrt432 = 432 / 440 # pitch change relative to 440hz
            pcrt444 = 444 / 440 # pitch change relative to 440hz

            convert_frequency(f"{SAVE_DIR_AUDIO}/{file_name}.mp3", f"{DIR_432}/{file_name}_432hz.mp3", pcrt432)
            convert_frequency(f"{SAVE_DIR_AUDIO}/{file_name}.mp3", f"{DIR_444}/{file_name}_444hz.mp3", pcrt444)

            # Remove non-frequency changed version
            os.remove(f"{SAVE_DIR_AUDIO}/{file_name}.mp3")

            # Apply bass boost if required
            if bass_boost_level is not None:
                print(f"Applying bass boost to {yt.title}...")
                bass_boost(f"{DIR_432}/{file_name}_432hz.mp3", f"{DIR_432}/{file_name}_432hz_bass_boosted.mp3", bass_boost_level)
                bass_boost(f"{DIR_444}/{file_name}_444hz.mp3", f"{DIR_444}/{file_name}_444hz_bass_boosted.mp3", bass_boost_level)
                
                # # Remove non-bass boosted versions
                # os.remove(f"{DIR_432}/{file_name}_432hz.mp3")
                # os.remove(f"{DIR_444}/{file_name}_444hz.mp3")

    # Download video if not exists and audio_only is False
    else:
        if os.path.exists(f"{SAVE_DIR_VIDEO}/{file_name}.mp4"):
            print(f"File ({file_name}.mp4) already exists! Skipping download...")
        else:
            print(f"Downloading video: {yt.title}")
            yt.streams.get_highest_resolution().download(SAVE_DIR_VIDEO, filename=file_name+".mp4")

    print("Download complete!")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Download YouTube videos and audio with optional frequency conversion and bass boost")
    parser.add_argument("url", help="URL of the YouTube video")
    parser.add_argument("--audio", "-a", action="store_true", help="Download audio only")
    parser.add_argument("--change_frequency", "-f", action="store_true", help="Change the frequency of the audio")
    parser.add_argument("--bass_boost", "-b", type=int, choices=range(1, 21), metavar="LEVEL", help="Apply bass boost to the audio (1-20)")
    args = parser.parse_args()

    download_yt(args.url, args.audio, args.change_frequency, args.bass_boost)