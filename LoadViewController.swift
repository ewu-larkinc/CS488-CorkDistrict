//
//  LoadViewController.swift
//  TheCorkDistrict
//
//


import UIKit
import QuartzCore

class LoadViewController : UIViewController {
    
    @IBOutlet weak var loadingLogo: UIImageView!
    @IBOutlet weak var loadingImage: UIButton!
    
    var isRotating = false
    var shouldStopRotating = false
    var timer: Timer!
    var progress = Float()
    var timedOut = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        progress = 0
        
        if (self.isRotating == false) {
            
            self.loadingLogo.fadeIn()
            self.loadingImage.rotate360Degrees(completionDelegate: self)
            self.isRotating = true
        }
        
        let timer = Timer(duration: 3.0, completionHandler: {
            self.getProgress()
        })
        
        timer.start()
    }
    
    func getProgress() {
        
        let dataManager = DataManager.sharedInstance
        //var timeouts = dataManager.getNumTimeouts()
        let startTime = NSDate()
        var curTime : NSDate
        var elapsedTime = Double()
        
        while (progress < 1.0) {
            dataManager.updateProgress()
            self.progress = dataManager.getProgress()
            curTime = NSDate()
            elapsedTime = curTime.timeIntervalSinceDate(startTime)
            
            if elapsedTime > 25 {
                progress = 1.0
                timedOut = true
            }
        }
        
        if timedOut {
            
            dataManager.fetchAllEntitiesFromCoreData()
            
            let alertMessage = UIAlertController(title: "Connection Timed Out!", message: "The data connection timed out. The server may be performing routine maintenance, or the network connection on your device may be unavailable. Please check your network settings, or try again later.", preferredStyle: .Alert)
            
            alertMessage.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(alertMessage, animated: true, completion: nil)
        }
        
        let timer = Timer(duration: 2.0, completionHandler: {
            self.view.window?.rootViewController?.dismissViewControllerAnimated(false, completion: nil)
        })
        
        timer.start()
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if self.shouldStopRotating == false {
            self.loadingImage.rotate360Degrees(completionDelegate: self)
        } else {
            self.reset()
        }
    }
    
    func reset() {
        self.isRotating = false
        self.shouldStopRotating = false
        self.view.window?.rootViewController?.dismissViewControllerAnimated(false, completion: nil)
    }

    
    

}
