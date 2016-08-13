//
//  ViewController.swift
//  SimpleCamera
//
//  Created by Simon Ng on 25/11/14.
//  Copyright (c) 2014 AppCoda. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit



class ViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    let captureSession = AVCaptureSession()
    var currentDevice: AVCaptureDevice?
    var videoFileOutput: AVCaptureMovieFileOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var isRecording = false
    
    @IBOutlet weak var cameraButton:UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // preset the session for taking photos in full resolution
        
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        // get the available devices capable of taking video
        
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) as! [AVCaptureDevice]
        
        // set the rear-facing camera for taking video
        
        for device in devices {
            if device.position == AVCaptureDevicePosition.Back {
                currentDevice = device
            }
        }
        
        let captureDeviceInput: AVCaptureDeviceInput
        do {
            captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice)
        } catch {
            print(error)
            return
        }
        
        // configure the session with the output for configuring video
        
        videoFileOutput = AVCaptureMovieFileOutput()
        
        // configre the session with the input and output devices
        
        captureSession.addInput(captureDeviceInput)
        captureSession.addOutput(videoFileOutput)
        
        // provide a camera preview
        
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(cameraPreviewLayer!)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        cameraPreviewLayer?.frame = view.layer.frame
        
        // bring the camera button to front
        
        view.bringSubviewToFront(cameraButton)
        captureSession.startRunning()
        

    }

    @IBAction func unwindToCamera(segue:UIStoryboardSegue) {
        
    }
    
    @IBAction func capture(sender: AnyObject) {
        if !isRecording {
            isRecording = true
            
            UIView.animateWithDuration(0.5, delay: 0.0, options: [.Repeat, .Autoreverse, .AllowUserInteraction], animations: { () -> Void in
                self.cameraButton.transform = CGAffineTransformMakeScale(0.5, 0.5)
                }, completion: nil)
            
            let outputPath = NSTemporaryDirectory() + "output.mov"
            let outputFileURL = NSURL(fileURLWithPath: outputPath)
            videoFileOutput?.startRecordingToOutputFileURL(outputFileURL, recordingDelegate: self)
        } else {
            isRecording = false
            
            UIView.animateWithDuration(0.5, delay: 1.0, options: [], animations: { () -> Void in
                self.cameraButton.transform = CGAffineTransformMakeScale(1.0, 1.0)
                }, completion: nil)
            cameraButton.layer.removeAllAnimations()
            videoFileOutput?.stopRecording()
        }
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        if error != nil {
            print(error)
            return
        }
        
        performSegueWithIdentifier("playVideo", sender: outputFileURL)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "playVideo" {
            let videoPlayerViewController = segue.destinationViewController as! AVPlayerViewController
            let videoFileURL = sender as! NSURL
            videoPlayerViewController.player = AVPlayer(URL: videoFileURL)
        }
    }
    
}

    