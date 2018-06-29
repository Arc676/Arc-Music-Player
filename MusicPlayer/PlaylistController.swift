//
//  PlaylistController.swift
//  ArcMusicPlayer
//
//  Created by Alessandro Vinciguerra on 2018/06/29.
//	<alesvinciguerra@gmail.com>
//Copyright (C) 2018 Arc676/Alessandro Vinciguerra

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

class PlaylistController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

	@IBOutlet weak var savePlayerState: NSButton!
	@IBOutlet weak var playlistTable: NSTableView!

	let panel = NSOpenPanel()
	let extensions = ["mp4","mp3","m4a","aiff","wav"]

	override func awakeFromNib() {
		panel.canChooseDirectories = true
		panel.allowsMultipleSelection = true
		panel.allowedFileTypes = NSSound.soundUnfilteredTypes
		panel.allowsOtherFileTypes = false
	}

	override func viewDidLoad() {
		playlistTable.reloadData()
	}

	func reload() {
		ViewController.shouldUpdatePlaylist()
		playlistTable.reloadData()
	}

	func numberOfRows(in tableView: NSTableView) -> Int {
		return ViewController.getPlaylist()!.count
	}

	func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
		return ViewController.getPlaylist()![row]
	}

	@IBAction func loadSong(_ sender: AnyObject) {
		if panel.runModal().rawValue == NSFileHandlingPanelOKButton {
			let fm = FileManager()
			for url in panel.urls {
				if url.hasDirectoryPath {
					for file in fm.enumerator(at: url, includingPropertiesForKeys: [])! {
						let fileURL = file as! URL
						if fileURL.isFileURL && extensions.contains(fileURL.pathExtension) {
							ViewController.addToPlaylist(fileURL)
						}
					}
				} else {
					ViewController.addToPlaylist(url)
				}
			}
		}
		reload()
	}

	@IBAction func unloadSong(_ sender: AnyObject) {
		var removed = 0
		let count = ViewController.getPlaylist()!.count
		for i in 0..<count {
			if playlistTable.isRowSelected(i) {
				ViewController.removeFromPlaylist(at: i - removed)
				removed += 1
			}
		}
		reload()
	}

	@IBAction func clearSongs(_ sender: AnyObject) {
		ViewController.clearSongs()
		playlistTable.reloadData()
	}

	@IBAction func loadPlaylistFromFile(_ sender: AnyObject) {
		let panel = NSOpenPanel()
		panel.canChooseDirectories = false
		panel.allowsMultipleSelection = true
		panel.allowsOtherFileTypes = false
		if panel.runModal().rawValue == NSFileHandlingPanelOKButton {
			for url in panel.urls {
				do {
					var data = try String(contentsOf: url).components(separatedBy: "\n")
					if data[0] == "[StateInfo]" {
						data.removeFirst()
						let vol = Float(data.removeFirst())!
						let shuf = Int(data.removeFirst())!
						let rep = Int(data.removeFirst())!
						let path = Int(data.removeFirst())!
						if data.removeFirst() != "[EndStateInfo]" {
							continue
						}
						let state: [String : Any] = [
							"Volume" : vol / 128,
							"Shuffle" : shuf,
							"Repeat" : rep,
							"ShowPaths" : path
						]
						ViewController.loadPlayerState(state)
					}
					for path in data {
						ViewController.addToPlaylist(URL(fileURLWithPath: path))
					}
				} catch {}
			}
			reload()
		}
	}

	@IBAction func writePlaylistToFile(_ sender: AnyObject) {
		let panel = NSSavePanel()
		panel.allowsOtherFileTypes = false
		if panel.runModal().rawValue == NSFileHandlingPanelOKButton {
			let paths = NSMutableArray()
			for url in ViewController.getPlaylist()! {
				paths.add(url.path)
			}
			var data = ""
			if savePlayerState.state == .on {
				let state = ViewController.getPlayerState()
				let vol = state["Volume"] as! Int
				data.append("[StateInfo]\n\(vol)\n\(state["Shuffle"]!)\n")
				data.append("\(state["Repeat"]!)\n\(state["ShowPaths"]!)\n[EndStateInfo]\n")
			}
			data.append(paths.componentsJoined(by: "\n"))
			do {
				try data.write(to: panel.url!, atomically: true, encoding: String.Encoding.utf8)
			} catch {}
		}
	}
	
}
