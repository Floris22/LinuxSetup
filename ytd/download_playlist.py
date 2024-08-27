from pytubefix import YouTube, Playlist
import re
import os

url = "https://www.youtube.com/playlist?list=PLuahu4XjwI79pakf8EfLFC4cqjaeVbly-"

def download_playlist(url):
    pl = Playlist(url)
    for video in pl.videos:
        try:
            file_name = video.title.replace("   ", "_").replace("  ", "_").replace(" ", "_")
            file_name = re.sub(r"[^a-zA-Z0-9_]+", "", file_name).lower().replace("__", "_")

            if not os.path.exists(f"/home/flo/Videos/youtube_downloads/chris_en_co/{file_name}.mp4"):
                video.streams.get_highest_resolution().download('/home/flo/Videos/youtube_downloads/chris_en_co/', filename=file_name+".mp4")
            else:
                print(f"Video {video.title} already exists. Skipping...")
        except Exception as e:
            print(f"Error downloading video {video.title}: {e}")

download_playlist(url)


