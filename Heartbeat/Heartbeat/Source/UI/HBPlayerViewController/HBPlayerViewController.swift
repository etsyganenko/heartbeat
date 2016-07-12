//
//  HBPlayerViewController.swift
//  Heartbit
//
//  Created by Genek on 6/13/16.
//  Copyright © 2016 IDAP. All rights reserved.
//

import UIKit
import AudioKit
import MediaPlayer

enum HBAudioOutput: Int {
    case HBAudioOutputEar = 0
    case HBAudioOutputSpeaker
}

class HBPlayerViewController: UIViewController,
                                UITableViewDataSource,
                                UITableViewDelegate,
                                AVAudioPlayerDelegate,
                                UICollectionViewDelegate,
                                UICollectionViewDataSource,
                                UICollectionViewDelegateFlowLayout
{
    
    // MARK: - Accessors
    
    var mainView: HBPlayerView? {
        guard let view = self.view else {
            return nil
        }
        
        return view as? HBPlayerView
    }
    
    lazy var audioFileNames: NSArray? = {
        if let path = NSBundle.mainBundle().pathForResource("AudioFiles", ofType: "plist") as String? {
            if let audioFilesDictionary = NSDictionary(contentsOfFile: path) as NSDictionary? {
                if let audioFilesArray = audioFilesDictionary["Files"] as? NSArray {
                    return audioFilesArray
                }
            }
        }
        
        return nil
    }()
    
    lazy var filterDictionaries: NSArray? = {
        if let path = NSBundle.mainBundle().pathForResource("Filters", ofType: "plist") as String? {
            if let filtersDictionary = NSDictionary(contentsOfFile: path) as NSDictionary? {
                if let filtersArray = filtersDictionary["Filters"] as? NSArray {
                    return filtersArray
                }
            }
        }
        
        return nil
    }()
    
    lazy var audioKitFilters: NSArray? = {
        return NSArray(objects: self.bandPassFilter!,
                                self.booster!,
                                self.lowPassFilter!,
                                self.highPassFilter!)
    }()
    
    var audioKitPlayer: AKAudioPlayer?
    var recorder: AKMicrophoneRecorder?
    var nodeRecorder: AKNodeRecorder?
    var microphone: AKMicrophone?
    var player: AVAudioPlayer?
    
    lazy var booster: AKBooster? = {
        let filter = AKBooster(self.bandPassFilter!,
                               gain: kHBGainDefaultValue)
        filter.start()
        
        return filter
    }()
    
    lazy var bandPassFilter: AKBandPassFilter? = {
        let filter = AKBandPassFilter(self.microphone!,
                                      centerFrequency: kHBCenterFrequencyDefaultValue,
                                      bandwidth: kHBBandwidthDefaultValue)
        filter.start()
        
        return filter
    }()
    
    lazy var lowPassFilter: AKLowPassFilter? = {
        let filter = AKLowPassFilter(self.booster!,
                                     cutoffFrequency: kHBCutoffFrequencyDefaultValue,
                                     resonance: kHBResonanceDefaultValue)
        
        filter.start()
        
        return filter
    }()
    
    lazy var highPassFilter: AKHighPassFilter? = {
        let filter = AKHighPassFilter(self.lowPassFilter!,
                                      cutoffFrequency: kHBCutoffFrequencyDefaultValue,
                                      resonance: kHBResonanceDefaultValue)
        
        filter.start()
        
        return filter
    }()
    
    lazy var pitchShifter: AKPitchShifter? = {
        let filter = AKPitchShifter(self.booster!,
                                    shift: kHBPitchShiftDefaultValue,
                                    windowSize: kHBWindowSizeDefaultValue,
                                    crossfade: kHBCrossfadeDefaultValue)
        
        filter.start()
        
        return filter
    }()
    
    lazy var filterModels: NSArray? = {
        let mutableFilterModels = NSMutableArray()
        let audioKitFilters = self.audioKitFilters as NSArray?
        let filterDictionaries = self.filterDictionaries as NSArray?
        
        for audioKitFilter in audioKitFilters! {
            let index = audioKitFilters?.indexOfObject(audioKitFilter)
            let filterDictionary = filterDictionaries?[index!] as! NSDictionary
            let enabled = filterDictionary[kHBKeyEnabled] as! Bool
            
            if enabled {
                let filterModel = HBFilter.filterFromDictionary(filterDictionary) as HBFilter?
                filterModel!.audioKitFilter = audioKitFilter
            
                mutableFilterModels.addObject(filterModel!)
            }
        }
        
        return mutableFilterModels
    }()

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.setupAudioKitPlayer()
        
        self.setupMicrophone()
        self.setupAudioKit()
        
        self.setupCollectionView()
        
        self.mainView?.playButton?.enabled = false
        
        self.title = "Heartbeat"
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch {}
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {}
        
        do {
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.None)
        } catch {}
        
//        let volumeView = MPVolumeView(frame: (self.mainView?.volumeViewHolder!.bounds)!)
//        
//        self.mainView?.volumeViewHolder!.addSubview(volumeView)
    }
    
    // MARK: - Interface Handling
    
    @IBAction func onMicrophone(sender: UIButton) {
        guard let microphone = self.microphone as AKMicrophone? else {
            return
        }
        
        if microphone.isStarted {
            self.microphone?.stop()
            self.recorder?.stop()
//            self.nodeRecorder?.stop()
            
            self.mainView?.playButton?.enabled = true
            sender.setBackgroundImage(UIImage(named: "Record"), forState: UIControlState.Normal)
        } else {
            self.microphone?.start()
            self.recordToFileNamed("Record.wav")
            
            self.mainView?.playButton?.enabled = false
            sender.setBackgroundImage(UIImage(named: "StopRecording"), forState: UIControlState.Normal)
        }
    }
    
    @IBAction func onPlay(sender: UIButton) {
        var player = self.player as AVAudioPlayer?
        if nil == player {
            let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first! as NSString
            let filePath = documentDirectoryPath.stringByAppendingPathComponent("Record.wav") as String
            
            do {
                player = try AVAudioPlayer(contentsOfURL: NSURL.fileURLWithPath(filePath))
                player!.delegate = self
                self.player = player
            } catch { }
        }
        
        if player!.playing {
            player!.stop()
            player?.currentTime = 0
            sender.setBackgroundImage(UIImage(named: "Process"), forState: UIControlState.Normal)
        } else {
            if player!.play() {
                sender.setBackgroundImage(UIImage(named: "StopProcessing"), forState: UIControlState.Normal)
            }
        }
    }
    
    @IBAction func changeAudioPort(sender: UISegmentedControl) {
        let audioPort = HBAudioOutput.HBAudioOutputEar.rawValue == sender.selectedSegmentIndex
                                                                    ? AVAudioSessionPortOverride.None
                                                                    : AVAudioSessionPortOverride.Speaker
        do {
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(audioPort)
        } catch {}
    }
    
    // MARK: - Public
    
    // MARK: - AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        let button = (self.mainView?.playButton)! as UIButton
        
        button.setBackgroundImage(UIImage(named: "Process"), forState: UIControlState.Normal)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        guard let audioFileNames = self.audioFileNames! as NSArray? else {
//            return 0
//        }
//        
//        return audioFileNames.count
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("HBPlayerCell") as! HBPlayerCell
        let audioFileNames = self.audioFileNames! as NSArray
        
        cell.audioFileName = audioFileNames[indexPath.row] as? NSString
        cell.titleLabel?.text = cell.audioFileName as? String

        cell.processButtonHandler = { (button: UIButton, fileName: String, filePath: String) -> Void in
            if let player = self.audioKitPlayer as AKAudioPlayer? {
                if player.isPlaying {
                    player.stop()
                    self.recorder?.stop()
//                    self.nodeRecorder?.stop()
                    
                    button.setBackgroundImage(UIImage(named: "Process"), forState: UIControlState.Normal)
                } else {
                    player.replaceFile(filePath)
                    player.play()
                    
                    self.recordToFileNamed(fileName.stringByAppendingString("_processed.wav"))
                    
                    button.setBackgroundImage(UIImage(named: "StopProcessing"), forState: UIControlState.Normal)
                }
            }
        }
        
        cell.playButtonHandler = { (button: UIButton, filePath: String) -> Void in
            if let player = self.player as AVAudioPlayer? {
                if player.playing {
                    player.stop()
                    button.setBackgroundImage(UIImage(named: "Play"), forState: UIControlState.Normal)
                    return
                }
            }
            
            do {
                let player = try AVAudioPlayer(contentsOfURL: NSURL.fileURLWithPath(filePath))
                player.delegate = self
                self.player = player
                
                player.play()
                
                button.setBackgroundImage(UIImage(named: "Stop"), forState: UIControlState.Normal)
            } catch {
                
            }
        }
        
        return cell
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let filters = self.filterModels as NSArray? else {
            return 0
        }
        
        return filters.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("HBFilterCell", forIndexPath: indexPath) as! HBFilterCell
        
        let filterModel = self.filterModels![indexPath.row] as! HBFilter
        
        cell.fillWithModel(filterModel)

        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let mainView = self.mainView as HBPlayerView?
        let collectionView = mainView?.collectionView as UICollectionView?
        
        return CGSizeMake((mainView?.frame.width)!, (collectionView?.frame.height)!)
    }
    
    // MARK: - Private
    
    private func setupAudioKit() {
        var delay = AKDelay(self.highPassFilter!)
        delay.time = 1.0
        
//        AudioKit.output = self.highPassFilter
        AudioKit.output = delay
        
        AudioKit.start()
    }
    
    private func setupMicrophone() {
        let microphone = AKMicrophone()
        
        microphone.stop()
        
        self.microphone = microphone
    }
    
//    private func setupAudioKitPlayer() {
//        let audioFileNames = self.audioFileNames! as NSArray
//        let fileName = audioFileNames.firstObject as! String?
//        let filePath = NSBundle.mainBundle().pathForResource(fileName, ofType:"wav")!
//        let player = AKAudioPlayer(filePath, completionHandler: { () -> () in
//            
//        })
//
//        self.audioKitPlayer = player
//        player.looping = true
//    }
    
    private func recordToFileNamed(fileName: String) {
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first! as NSString
        let filePath = documentDirectoryPath.stringByAppendingPathComponent(fileName)
        
        let recorder = AKMicrophoneRecorder(filePath)
        self.recorder = recorder
        recorder.record()
        
//        let nodeRecorder = AKNodeRecorder(filePath, node: self.bandPassFilter!)
//        self.nodeRecorder = nodeRecorder
//        nodeRecorder.record()
    }
    
    private func setupCollectionView() {
        mainView?.collectionView?.registerNib(UINib(nibName: "HBFilterCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "HBFilterCell")
    }
}
