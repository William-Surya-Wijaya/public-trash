import os
import librosa
import pretty_midi
import numpy as np
from scipy.ndimage import median_filter
from tqdm import tqdm

# Load the separated track (e.g., bass or melody)
audio_path = 'separated_tracks/vocals.wav'  # Change to the isolated track you want to transcribe
output_midi_path = 'midi_output/vocals.mid'
os.makedirs(os.path.dirname(output_midi_path), exist_ok=True)

print("Loading audio file...")
y, sr = librosa.load(audio_path, sr=None)

# Isolate harmonic components to reduce percussive noise
print("Isolating harmonic components...")
y_harmonic = librosa.effects.harmonic(y)

# Detect onsets with tuned parameters
print("Detecting onsets...")
onsets = librosa.onset.onset_detect(y=y_harmonic, sr=sr, units='time', hop_length=512, backtrack=True)

# Use YIN for pitch detection with median filtering for stabilization
print("Detecting pitches...")
pitches, magnitudes = librosa.core.piptrack(y=y_harmonic, sr=sr)

# Function to convert pitch frequency to MIDI note number
def pitch_to_midi(pitch):
    return int(69 + 12 * np.log2(pitch / 440.0))

# List to hold MIDI notes
notes = []
magnitude_threshold = 0.2  # Set to reduce low-confidence noise

# Process each onset and detect dominant pitches at that point
print("Processing onsets and applying median filtering...")
for onset in tqdm(onsets, desc="Processing onsets"):
    idx = librosa.time_to_frames([onset], sr=sr)
    pitch_slice = pitches[:, idx].flatten()
    mag_slice = magnitudes[:, idx].flatten()

    # Keep only pitches with magnitude above the threshold
    valid_pitches = pitch_slice[mag_slice > magnitude_threshold]
    
    # Apply median filtering to reduce rapid pitch jumps
    if len(valid_pitches) > 0:
        # Use median filtering on detected pitches to stabilize
        pitch = np.median(valid_pitches)
        midi_note = pitch_to_midi(pitch)
        notes.append((midi_note, onset))

# Create a PrettyMIDI object and add notes
print("Generating MIDI file...")
midi = pretty_midi.PrettyMIDI()
instrument = pretty_midi.Instrument(program=32)  # Program 32 is an acoustic bass

# Dynamically set note durations based on subsequent onsets or a fixed value
for i, (note_num, onset) in enumerate(notes):
    if i < len(notes) - 1:
        duration = notes[i + 1][1] - onset  # Duration until next onset
    else:
        duration = 0.5  # Default duration for the last note
    duration = max(duration, 0.1)  # Enforce a minimum note duration
    note = pretty_midi.Note(velocity=100, pitch=note_num, start=onset, end=onset + duration)
    instrument.notes.append(note)

midi.instruments.append(instrument)

# Save the result as a MIDI file
print("Saving MIDI file...")
midi.write(output_midi_path)
print("MIDI file generated successfully at:", output_midi_path)
