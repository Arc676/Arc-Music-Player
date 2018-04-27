//
//  ViewController.swift
//  MusicPlayer
//
//  Created by Alessandro Vinciguerra on 10/6/15.
//	<alesvinciguerra@gmail.com>
//Copyright (C) 2015-8 Arc676/Alessandro Vinciguerra

//This program is free software: you can redistribute it and/or modify
//it under the terms of the GNU General Public License as published by
//the Free Software Foundation (version 3)
//This program is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU General Public License for more details.

//You should have received a copy of the GNU General Public License
//along with this program.  If not, see <http://www.gnu.org/licenses/>.
//See README and LICENSE for more details

import Cocoa

class ViewController: NSViewController, NSSoundDelegate {

	//data
	@IBOutlet weak var playlistPopup: NSPopUpButton!
	@IBOutlet weak var savePlayerState: NSButton!
	//playback
	@IBOutlet weak var songProgress: NSSlider!
	@IBOutlet weak var songTime: NSTextField!
	@IBOutlet weak var volumeSlider: NSSlider!
	//shuffle
	@IBOutlet weak var shuffleSongs: NSButton!
	//repeat
	@IBOutlet weak var repeatMode: NSSegmentedControl!
	//interface
	@IBOutlet weak var showFullPath: NSButton!
	override var acceptsFirstResponder: Bool { return true }

	//songs
	var playlist: [URL]?
	var currentSongIndex: Int = -1
	var song: NSSound!
	var isPlaying: Bool = false

	var songDuration: String = "0:00"

	var updateTimer: Timer!

	override func viewDidLoad() {
		super.viewDidLoad()
		playlist = []
		songProgress.minValue = 0
		self.view.window?.title = "Arc Music Player"
		NotificationCenter.default.addObserver(self,
											   selector: #selector(mediaKeyPressed(_:)),
											   name: NSNotification.Name("MediaKeyPressed"),
											   object: NSApplication.shared.delegate as! AppDelegate)
	}

	@objc func mediaKeyPressed(_ notif: Notification) {
		let fKey: String = notif.userInfo!["fKey"]! as! String
		if fKey == "F7" {
			prevSong(NSNull())
		}else if fKey == "F8" {
			playPause(NSNull())
		}else if fKey == "F9" {
			nextSong(NSNull())
		}
	}

	func updatePlaylist() {
		playlistPopup.removeAllItems()
		for url in playlist! {
			var path = url.absoluteString
			if showFullPath.integerValue == 0 {
				path = url.lastPathComponent.replacingOccurrences(of: "%20", with: " ")
			}
			playlistPopup.addItem(withTitle: path)
		}
		playlistPopup.selectItem(at: currentSongIndex)
	}

	@IBAction func changeShowFullPathMode(_ sender: AnyObject) {
		updatePlaylist()
	}

	func showNotif() {
		let notif = NSUserNotification()
		notif.subtitle = "Arc Music Player"
		notif.title = playlistPopup.itemTitle(at: currentSongIndex)
		NSUserNotificationCenter.default.deliver(notif)
	}

	//delegating and stuff
	func sound(_ sound: NSSound, didFinishPlaying aBool: Bool) {
		nextSong(NSNull())
	}

	@objc func updateTimeData(_ timer: Timer) {
		if song == nil {
			return
		}
		let time = Float(song.currentTime)
		songProgress.floatValue = time
		let minutes = Int(time / 60)
		var seconds = String(Int(time.truncatingRemainder(dividingBy: 60)))
		if (seconds as NSString).length != 2 {
			seconds = "0" + seconds
		}
		songTime.stringValue = String(minutes) + ":" + seconds + "/" + songDuration
	}

	func playSong() {
		song = NSSound(contentsOf: playlist![currentSongIndex], byReference: false)
		song.delegate = self
		songProgress.maxValue = Double(song.duration)
		playPause(NSNull())
		let minutes = Int(song.duration / 60)
		var seconds = String(Int(song.duration.truncatingRemainder(dividingBy: 60)))
		if (seconds as NSString).length < 2 {
			seconds = "0" + seconds
		}
		songDuration = String(minutes) + ":" + seconds
		updatePlaylist()
	}

	func stopSong() {
		if song != nil {
			song.delegate = nil
			song.stop()
			isPlaying = false
		}
	}

	func stopUpTimer() {
		if updateTimer == nil {
			return
		}
		updateTimer.invalidate()
		updateTimer = nil
	}

	func startUpTimer() {
		updateTimer = Timer.scheduledTimer(
			timeInterval: 0.25,
			target: self,
			selector: #selector(updateTimeData(_:)),
			userInfo: nil,
			repeats: true)
	}

	//playback
	@IBAction func rewind30s(_ sender: AnyObject) {
		if song != nil {
			song.currentTime -= 30
		}
	}

	@IBAction func rewind10s(_ sender: AnyObject) {
		if song != nil{
			song.currentTime -= 10
		}
	}

	@IBAction func ff10s(_ sender: AnyObject) {
		if song != nil{
			song.currentTime += 10
		}
	}

	@IBAction func ff30s(_ sender: AnyObject) {
		if song != nil{
			song.currentTime += 30
		}
	}

	@IBAction func changeSongVolume(_ sender: NSSlider) {
		if song != nil {
			song.volume = sender.floatValue
		}
	}

	@IBAction func goToLocationInSong(_ sender: NSSlider) {
		if song == nil {
			return
		}
		song.pause()
		stopUpTimer()
		song.currentTime = sender.doubleValue
		startUpTimer()
		if isPlaying {
			song.resume()
		}
	}

	@IBAction func playPause(_ sender: AnyObject) {
		if song == nil {
			return
		}
		if isPlaying {
			isPlaying = false
			song.pause()
			stopUpTimer()
		} else {
			isPlaying = true
			if !song.play() {
				song.resume()
			}
			startUpTimer()
		}
		song.volume = volumeSlider.floatValue
	}

	@IBAction func prevSong(_ sender: AnyObject) {
		stopSong()
		if playlist!.count <= 0 {
			return
		}
		if song.currentTime < 10 {
			song.currentTime = 0
			playSong()
			return
		}
		if shuffleSongs.integerValue == 0 {
			currentSongIndex -= 1
			if currentSongIndex < 0 {
				currentSongIndex = 0
				return
			}
			playSong()
		}
		showNotif()
	}

	@IBAction func nextSong(_ sender: AnyObject) {
		stopSong()
		if playlist!.count <= 0 {
			return
		}
		if shuffleSongs.integerValue == 0 {
			if playlist!.count > currentSongIndex + 1 || repeatMode.selectedSegment == 1 {
				if repeatMode.selectedSegment != 1 {
					currentSongIndex += 1
				}
			} else {
				currentSongIndex = 0
				if repeatMode.selectedSegment == 0 {
					return
				}
			}
		} else {
			playlist!.remove(at: currentSongIndex)
			if playlist!.count <= 0 {
				currentSongIndex = 0
				updatePlaylist()
				return
			}
			currentSongIndex = Int(arc4random_uniform(UInt32(playlist!.count)))
		}
		playSong()
		showNotif()
	}

	@IBAction func userChoseSongFromPlaylist(_ sender: NSPopUpButton) {
		stopSong()
		currentSongIndex = sender.indexOfSelectedItem
		playSong()
	}

	//song loading
	@IBAction func loadSong(_ sender: AnyObject) {
		let panel = NSOpenPanel()
		panel.canChooseDirectories = true
		panel.allowsMultipleSelection = true
		panel.allowedFileTypes = NSSound.soundUnfilteredTypes
		panel.allowsOtherFileTypes = false
		let extensions = ["mp4","mp3","m4a","aiff","wav"]
		if panel.runModal().rawValue == NSFileHandlingPanelOKButton {
			let fm = FileManager()
			for url in panel.urls {
				if url.hasDirectoryPath {
					for file in fm.enumerator(at: url, includingPropertiesForKeys: [])! {
						let fileURL = file as! URL
						if fileURL.isFileURL && extensions.contains(fileURL.pathExtension) {
							playlist!.append(fileURL)
						}
					}
				} else {
					playlist!.append(url)
				}
			}
			currentSongIndex = 0
		}
		updatePlaylist()
	}

	@IBAction func loadPlaylistFromFile(_ sender: AnyObject) {
		let panel = NSOpenPanel()
		panel.canChooseDirectories = false
		panel.allowsMultipleSelection = true
		panel.allowedFileTypes = ["plist"]
		panel.allowsOtherFileTypes = false
		if panel.runModal().rawValue == NSFileHandlingPanelOKButton {
			for url in panel.urls {
				do {
					var data = try String(contentsOf: url).components(separatedBy: "\n")
					if data[0] == "[StateInfo]" {
						let vol = Float(data.removeFirst())!
						let shuf = Int(data.removeFirst())!
						let rep = Int(data.removeFirst())!
						let path = Int(data.removeFirst())!
						if data.removeFirst() != "[EndStateInfo]" {
							continue
						}
						volumeSlider.floatValue = vol
						shuffleSongs.integerValue = shuf
						repeatMode.selectSegment(withTag: rep)
						showFullPath.integerValue = path
					}
					for path in data {
						playlist!.append(URL(string: path)!)
					}
				} catch {}
			}
			updatePlaylist()
		}
	}

	@IBAction func writePlaylistToFile(_ sender: AnyObject) {
		let panel = NSSavePanel()
		panel.allowedFileTypes = ["plist"]
		panel.allowsOtherFileTypes = false
		if panel.runModal().rawValue == NSFileHandlingPanelOKButton {
			let paths = NSMutableArray()
			for url in playlist! {
				paths.add(url.absoluteString)
			}
			var data = ""
			if savePlayerState.integerValue == NSControl.StateValue.on.rawValue {
				data.append("[StateInfo]\n\(volumeSlider.floatValue)\n\(shuffleSongs.integerValue)\n")
				data.append("\(repeatMode.indexOfSelectedItem)\n\(showFullPath.integerValue)\n[EndStateInfo]\n")
			}
			data.append(paths.componentsJoined(by: "\n"))
			do {
				try data.write(to: panel.url!, atomically: true, encoding: String.Encoding.utf8)
			} catch {}
		}
	}

	@IBAction func unloadSong(_ sender: AnyObject) {
	}

	@IBAction func clearSongs(_ sender: AnyObject) {
		stopUpTimer()
		stopSong()
		song = nil
		playlist!.removeAll()
		currentSongIndex = -1
		updatePlaylist()
	}
	
}
