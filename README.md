# Arc-Music-Player
A simple music player

The Arc Music Player is path-based rather than library-based music player. Save your music library in a file that just contains the paths to the sound files without actually having to copy those files to a separate directory.

Arc Music Player includes just the most basic playback commands:
- Loading a number of songs into a list that will be played
- Picking any song from that list
- Skipping to next/going back to previous song
- Pausing and resuming
- Moving to a different point in the song
- Jumping forwards/backwards 10 or 30 seconds
- Volume control (separate from system volume)
- Saving/loading/clearing song list
- Saving player state
- Shuffle
- Repeat on song or whole list

### Playlist format

Saving the playlist creates a plain text file that contains a list of paths to the sound files that were in the playlist at the time of saving.

If the player state is saved with the playlist, information regarding the player's state will be stored at the beginning of the text file. This information is delimited by `[StateInfo]` and `[EndStateInfo]`. Between these markers are the player volume, shuffle setting, repeat setting, and full path display setting, encoded as integers. If the state is not saved, this section is omitted.

Example:

```
[StateInfo]
64
0
0
0
[EndStateInfo]
/path/to/file.mp3
/other/path/to/other/file.ogg
```

### Legal

Project available under GPLv3 except linking Apple libraries is allowed to the extent to which this is necessary for compilation. See `LICENSE` for full GPL text.
