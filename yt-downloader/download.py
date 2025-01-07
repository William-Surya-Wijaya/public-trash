import yt_dlp

def download_youtube_video(video_url, save_path="."):
    try:
        ydl_opts = {
            "outtmpl": f"{save_path}/%(title)s.%(ext)s",
            "format": "best",
        }
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            ydl.download([video_url])
        print(f"Download completed! Video saved to: {save_path}")
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    # Ask the user for the YouTube video URL
    video_url = 'https://www.youtube.com/watch?v=ovj5dzMxzmc'

    # Optional: Ask the user for the save path
    save_path = './downloads/'

    if not save_path:
        save_path = "."

    # Call the function to download the video
    download_youtube_video(video_url, save_path)
