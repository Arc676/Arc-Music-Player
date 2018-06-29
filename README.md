# Arc Music Player
The Arc Music Player is a minimalist music player. Save your music library in a file that just contains the paths to the sound files and optionally information about the your playback preferences.

Arc Music Player includes just the most basic playback commands:
- Loading a number of songs into a list that will be played
- Removing songs from the playlist
- Picking any song from the playlist
- Skipping to next/going back to previous song
- Pausing and resuming
- Moving to a different point in the song
- Jumping forwards/backwards 10 or 30 seconds
- Volume control (separate from system volume)
- Writing and reading playlist and player state to and from disk
- Shuffle, song repeat, playlist repeat

### Playlist format

Saving the playlist creates a plain text file that contains a list of paths to the sound files that were in the playlist at the time of saving. The format is the same as the one used by the [Linux version](https://github.com/Arc676/Arc-Music-Player-Gtk). The same playlist file can be used on both platforms, as long as the path to the files remains the same. This can easily be done if the files are located on an external drive and mounted at the same path on both operating systems.

If the player state is saved with the playlist, information regarding the player's state will be stored at the beginning of the text file. This information is delimited by `[StateInfo]` and `[EndStateInfo]`. Between these markers are the player volume (between 0 and 1024), shuffle setting, repeat setting, and full path display setting, encoded as integers. If the state is not saved, this section is omitted.

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

Project available under GPLv3 except linking Apple libraries is allowed to the extent to which this is necessary for compilation. See `LICENSE` for full GPL text. Image icon by [Nuno Jesus](https://github.com/nunojesus/graphic-design-portfolio) available under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).
