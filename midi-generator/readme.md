# Audio Separator

This project is an audio separation tool using the Open-Unmix model. It processes audio files and separates them into stems, including vocals, drums, bass, and others. The tool supports model selection, allowing users to use higher-quality models for improved separation results.

---

## Features

- Converts `.mp3` files to `.wav` if needed.
- Supports model selection, such as `umxhq`, for enhanced audio separation quality.
- Easy setup with dependencies managed via `requirements.txt`.

---

## Getting Started

### Prerequisites

1. **Python 3.7+**: Ensure that Python is installed on your system.
2. **Git LFS**: For handling large files, install [Git LFS](https://git-lfs.github.com/).

### Setup Instructions

1. **Clone the Repository**
   Clone the repository and navigate to the project directory:

   ```bash
   git clone https://github.com/username/audio-separator.git
   cd audio-separator
   ```
2. **Install Dependencies**
   Set up a virtual environment and install the required packages:

   ```bash
   python -m venv env
   source env/bin/activate  # On Windows, use env\Scripts\activate
   pip install -r requirements.txt
   ```

### Example

Separate an audio file using at the high-quality umxhq model:

```bash
python separator.py --input_file audio/my_song.mp3 --output_dir separated_stems --sample_rate 44100 --model_name umxhq
```
