# Assembly-Music-Boilerplate

A small Linux x86-64 assembly program that synthesizes a simple melody as raw 8-bit mono audio. It does not create a MIDI file or use a MIDI device: the program writes audio samples directly to standard output. The repository includes a reusable engine in `template.asm` and a song example in `lilb.asm`.

## Requirements

- Linux on x86-64
- NASM
- GNU `ld`
- ALSA `aplay` for playback (optional)

## Build

From the repository directory, assemble and link either source file:

```sh
nasm -f elf64 lilb.asm -o lilb.o
ld -o lilb lilb.o
```

To build the starter template instead, replace `lilb.asm`/`lilb` with `template.asm`/`template`.

## Play

The song bytes go to standard output, while the introductory text is written to standard error. Pipe standard output to `aplay` and specify the raw audio format:

```sh
./lilb | aplay -t raw -f U8 -r 8000 -c 1
```

The sample rate affects both perceived pitch and playback duration. The note constants are periods measured in samples: smaller periods produce higher tones, and the sample rate determines how quickly those samples are played. Adjust `-r` to experiment. The program itself does not configure or negotiate an audio format, so use a raw-audio player with matching format options.

## How it works

1. `song_data` is a sequence of 16-bit pairs: `dw pitch, duration`. The duration is a number of output samples, not milliseconds. A pitch value of zero represents a rest.
2. `_play_song` walks through the table four bytes at a time and loads each pitch and duration into registers.
3. `_connect_speaker` generates a square wave for pitched notes. It alternates sample values `0x3F` and `0x00`; the pitch value controls the number of samples in each wave cycle. For a rest, `_silence_speaker` writes zero-valued samples for the requested duration.
4. `_write_sample` uses the Linux `write` system call to send one byte at a time to standard output. Once the song table ends, the program exits.

To write a melody, edit the note and duration constants and the `song_data` table. Keep each entry in the form `dw pitch, duration`, and define `song_end` immediately after the final entry. `template.asm` contains a short example table; `lilb.asm` contains a longer example by a personal favorite.
