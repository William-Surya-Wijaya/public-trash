import os
import torch
import torchaudio
from pydub import AudioSegment
from openunmix import predict

def convert_mp3_to_wav(input_file):
    """Converts an MP3 file to WAV format."""
    if input_file.endswith(".mp3"):
        wav_file = input_file.replace(".mp3", ".wav")
        audio = AudioSegment.from_mp3(input_file)
        audio.export(wav_file, format="wav")
        print(f"Converted MP3 to WAV: {wav_file}")
        return wav_file
    return input_file

def separate_audio(input_file, output_dir="separated_tracks", rate=44100):
    """
    Separates an audio file into stems using Open-Unmix (UMX) and saves them in the specified output directory.

    Parameters:
    - input_file (str): Path to the input audio file (e.g., .mp3 or .wav).
    - output_dir (str): Directory where the separated audio files will be saved.
    - rate (int): Sample rate for the audio processing (e.g., 44100).
    """
    # Convert MP3 to WAV if necessary
    input_file = convert_mp3_to_wav(input_file)

    # Check if the input file exists
    if not os.path.isfile(input_file):
        print(f"Error: File '{input_file}' not found.")
        return

    # Create the output directory if it doesn't exist
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    print(f"Separating '{input_file}'...")

    # Load the audio file with torchaudio
    audio, sample_rate = torchaudio.load(input_file)
    audio = audio.clone().detach().float()  # Ensure it's a float32 tensor without gradients

    # Resample if necessary
    if sample_rate != rate:
        print("Resampling audio...")
        resampler = torchaudio.transforms.Resample(orig_freq=sample_rate, new_freq=rate)
        audio = resampler(audio)
        sample_rate = rate

    # Separate the audio using UMX and get the stems
    print("Starting separation process...")
    stems = predict.separate(audio, rate=sample_rate)

    # Save each separated stem (vocals, drums, bass, others) in the output directory
    for stem_name, audio_data in stems.items():
        # Ensure it's a 2D tensor in the format (channels, samples)
        audio_array = audio_data.squeeze()  # Removes extra dimensions, if any

        # If mono, reshape to (1, samples) for torchaudio compatibility
        if audio_array.ndim == 1:
            audio_array = audio_array.unsqueeze(0)  # Make it (1, samples)

        output_path = os.path.join(output_dir, f"{stem_name}.wav")
        
        # Save using torchaudio with explicit format settings
        torchaudio.save(output_path, audio_array, sample_rate, format="wav")
        print(f"Saved {stem_name} to {output_path}")

    print(f"Separation complete! Separated tracks are saved in: {output_dir}")

if __name__ == "__main__":
    # Example usage
    input_file = "otonoke.mp3"  # Replace with the path to your audio file
    output_dir = "separated_tracks"  # Change output directory if desired
    sample_rate = 44100  # Set the appropriate sample rate

    separate_audio(input_file, output_dir, rate=sample_rate)
