//
//  ViewController.swift
//  EZAudioSampleSwift
//
//  Created by N on 2015/05/27.
//  Copyright (c) 2015年 Nakama. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate, EZMicrophoneDelegate{
    

    @IBOutlet var audioPlot:EZAudioPlotGL!

    var isRecording:Bool?
    
    var microphone:EZMicrophone!

    var recorder:EZRecorder?
    
    var audioPlayer:AVAudioPlayer?
    @IBOutlet var recordButton:UIButton!
    @IBOutlet var playButton:UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        println(kAudioFilePath)
        
        microphone = EZMicrophone(microphoneDelegate: self)
        
        audioPlot?.frame = self.view.frame;
        audioPlot?.backgroundColor = UIColor(red: 0.984, green: 0.71, blue: 0.365, alpha: 1.0)
        audioPlot?.color           = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha:1.0)
        audioPlot?.plotType = EZPlotType.Rolling
        audioPlot?.shouldFill      = true
        audioPlot?.shouldMirror    = true
        
        //microphone.startFetchingAudio()
        
        self.isRecording = false
    }
    
    @IBAction func play(){
        audioPlot?.backgroundColor = UIColor(red: 0.569, green: 0.82, blue: 0.478, alpha: 1.0)
        if(isRecording == true){
            isRecording = false
            microphone.stopFetchingAudio()
            recorder?.closeAudioFile()
            recordButton.setTitle("Record Start", forState:UIControlState.Normal)
        }
        if (audioPlayer?.playing != nil){
            audioPlayer?.stop()
        }else{
            audioPlayer = nil
        }
        var err:NSError?
        audioPlayer = AVAudioPlayer(contentsOfURL: self.testFilePathURL(), error:&err)
        audioPlayer?.delegate = self
        audioPlayer?.play()
    }
    
    @IBAction func record(){
        if (audioPlayer?.playing != nil){
            audioPlayer?.stop()
        }
        if (isRecording == true){
            isRecording = false
            audioPlot?.backgroundColor = UIColor(red: 0.984, green: 0.71, blue: 0.365, alpha: 1.0)
            microphone.stopFetchingAudio()
            recorder?.closeAudioFile()
            recordButton.setTitle("Record Start", forState:UIControlState.Normal)
        }else{
            isRecording = true
            audioPlot?.backgroundColor = UIColor(red: 0.984, green: 0.471, blue: 0.525, alpha: 1.0)
            microphone.startFetchingAudio()
            recordButton.setTitle("Record Stop", forState:UIControlState.Normal)

            recorder = EZRecorder(destinationURL: self.testFilePathURL(),
                sourceFormat: microphone.audioStreamBasicDescription(),
                destinationFileType: EZRecorderFileType.M4A)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //EZMicrophoneDelegate
    func microphone(microphone: EZMicrophone!,
        hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>,
        withBufferSize bufferSize: UInt32,
        withNumberOfChannels numberOfChannels: UInt32) {
            dispatch_async(dispatch_get_main_queue()) {
                self.audioPlot.updateBuffer(buffer.memory, withBufferSize: bufferSize)
            }
    }
    
    func microphone(microphone: EZMicrophone!, hasBufferList bufferList: UnsafeMutablePointer<AudioBufferList>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        if ((isRecording) != nil){
            recorder?.appendDataFromBufferList(bufferList, withBufferSize: bufferSize)
        }
    }
    
    //AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        audioPlot?.backgroundColor = UIColor(red: 0.984, green: 0.71, blue: 0.365, alpha: 1.0)
        audioPlayer = nil
    }
    
    //Utility
    func testFilePathURL() -> NSURL{
        var paths:NSArray = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        var basePath:String
        if (paths.count>0){
            basePath = paths.objectAtIndex(0) as! String
        }else{
            basePath = ""
        }
        var url:String = String(format:"%@/%@",basePath,kAudioFilePath)
        var testFilePathURL:NSURL = NSURL.fileURLWithPath(url)!
        return testFilePathURL
    }

}
