//
//  ViewController.swift
//  MusicPlayer
//
//  Created by Alessandro Vinciguerra on 10/6/15.
//  Copyright © 2015 Arc676. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSSoundDelegate {
    
    //data
    @IBOutlet weak var playlistPopup: NSPopUpButton!
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
    var playlist: NSMutableArray!
    var currentSongIndex: Int = -1
    var song: NSSound!
    var isPlaying: Bool = false
    
    var songDuration: String = "0:00"
    
    var updateTimer: NSTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playlist = NSMutableArray()
        songProgress.minValue = 0
        self.view.window?.title = "Arc Music Player"
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "mediaKeyPressed:",
            name: "MediaKeyPressed",
            object: NSApplication.sharedApplication().delegate as! AppDelegate)
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func mediaKeyPressed(notif: NSNotification) {
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
        for (url) in playlist {
            var path = (url.absoluteString as NSString).mutableCopy() as! NSMutableString
            if showFullPath.integerValue == 0 {
                path = (path.substringFromIndex(path.rangeOfString("/", options: NSStringCompareOptions.BackwardsSearch).location + 1) as NSString).mutableCopy() as! NSMutableString
                path.replaceOccurrencesOfString("%20", withString: " ", options: NSStringCompareOptions.CaseInsensitiveSearch, range: NSMakeRange(0, path.length))
            }
            playlistPopup.addItemWithTitle(path as String)
        }
        playlistPopup.selectItemAtIndex(currentSongIndex)
    }
    
    @IBAction func changeShowFullPathMode(sender: AnyObject) {
        updatePlaylist()
    }
    
    func showNotif() {
        let notif = NSUserNotification()
        notif.subtitle = "Arc Music Player"
        notif.title = playlistPopup.itemTitleAtIndex(currentSongIndex)
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notif)
    }
    
    //delegating and stuff
    func sound(sound: NSSound, didFinishPlaying aBool: Bool) {
        nextSong(NSNull())
    }
    
    func updateTimeData(timer: NSTimer) {
        if song == nil {
            return
        }
        let time = Float(song.currentTime)
        songProgress.floatValue = time
        let minutes = Int(time / 60)
        var seconds = String(Int(time % 60))
        if (seconds as NSString).length != 2 {
            seconds = "0" + seconds
        }
        songTime.stringValue = String(minutes) + ":" + seconds + "/" + songDuration
    }
    
    func playSong() {
        song = NSSound(contentsOfURL: playlist[currentSongIndex] as! NSURL, byReference: false)
        song.delegate = self
        songProgress.maxValue = Double(song.duration)
        playPause(NSNull())
        let minutes = Int(song.duration / 60)
        var seconds = String(Int(song.duration % 60))
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
        updateTimer = NSTimer.scheduledTimerWithTimeInterval(0.25, target: self, selector: "updateTimeData:", userInfo: nil, repeats: true)
    }
    
    //playback
    @IBAction func rewind30s(sender: AnyObject) {
        if song != nil {
            song.currentTime -= 30
        }
    }
    
    @IBAction func rewind10s(sender: AnyObject) {
        if song != nil{
            song.currentTime -= 10
        }
    }
    
    @IBAction func ff10s(sender: AnyObject) {
        if song != nil{
            song.currentTime += 10
        }
    }
    
    @IBAction func ff30s(sender: AnyObject) {
        if song != nil{
            song.currentTime += 30
        }
    }
    
    @IBAction func changeSongVolume(sender: NSSlider) {
        if song != nil {
            song.volume = sender.floatValue
        }
    }
    
    @IBAction func goToLocationInSong(sender: NSSlider) {
        if song == nil {
            return
        }
        song.pause()
        stopUpTimer()
        song.currentTime = sender.doubleValue
        startUpTimer()
        song.resume()
    }
    
    @IBAction func playPause(sender: AnyObject) {
        if song == nil {
            return
        }
        if isPlaying {
            isPlaying = false
            song.pause()
            stopUpTimer()
        }else{
            isPlaying = true
            if !song.play() {
                song.resume()
            }
            startUpTimer()
        }
        song.volume = volumeSlider.floatValue
    }
    
    @IBAction func prevSong(sender: AnyObject) {
        stopSong()
        if playlist.count <= 0 {
            return
        }
        if shuffleSongs.integerValue == 0 {
            currentSongIndex--
            if currentSongIndex < 0 {
                currentSongIndex = 0
                return
            }
            playSong()
        }
        showNotif()
    }
    
    @IBAction func nextSong(sender: AnyObject) {
        stopSong()
        if playlist.count <= 0 {
            return
        }
        if shuffleSongs.integerValue == 0 {
            if playlist.count > currentSongIndex + 1 || repeatMode.selectedSegment == 1 {
                if repeatMode.selectedSegment != 1 {
                    currentSongIndex++
                }
            }else{
                currentSongIndex = 0
                if repeatMode.selectedSegment == 0 {
                    return
                }
            }
        }else{
            playlist.removeObjectAtIndex(currentSongIndex)
            if playlist.count <= 0 {
                currentSongIndex = 0
                updatePlaylist()
                return
            }
            currentSongIndex = Int(arc4random_uniform(UInt32(playlist.count)))
        }
        playSong()
        showNotif()
    }
    
    @IBAction func userChoseSongFromPlaylist(sender: NSPopUpButton) {
        stopSong()
        currentSongIndex = sender.indexOfSelectedItem
        playSong()
    }
    
    //song loading
    @IBAction func loadSong(sender: AnyObject) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = true
        panel.allowedFileTypes = NSSound.soundUnfilteredTypes()
        panel.allowsOtherFileTypes = false
        if panel.runModal() == NSFileHandlingPanelOKButton {
            for url in panel.URLs {
                playlist.addObject(url)
            }
            currentSongIndex = 0
        }
        updatePlaylist()
    }
    
    @IBAction func loadPlaylistFromFile(sender: AnyObject) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = true
        panel.allowedFileTypes = ["plist"]
        panel.allowsOtherFileTypes = false
        if panel.runModal() == NSFileHandlingPanelOKButton {
            for url in panel.URLs {
                let array = NSArray(contentsOfURL: url)!
                for item in array {
                    let songurl = item as! String
                    playlist.addObject(NSURL(string: songurl)!)
                }
            }
            updatePlaylist()
        }
    }
    
    @IBAction func writePlaylistToFile(sender: AnyObject) {
        let panel = NSSavePanel()
        panel.allowedFileTypes = ["plist"]
        panel.allowsOtherFileTypes = false
        if panel.runModal() == NSFileHandlingPanelOKButton {
            let paths = NSMutableArray()
            for url in playlist {
                paths.addObject(url.absoluteString!)
            }
            paths.writeToURL(panel.URL!, atomically: true)
        }
    }
    
    @IBAction func unloadSong(sender: AnyObject) {
    }
    
    @IBAction func clearSongs(sender: AnyObject) {
        stopUpTimer()
        stopSong()
        song = nil
        playlist.removeAllObjects()
        currentSongIndex = -1
        updatePlaylist()
    }
    
}