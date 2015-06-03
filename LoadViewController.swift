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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let dataManager = DataManager.sharedInstance
        progress = 0
        
        if (self.isRotating == false) {
            
            self.loadingLogo.fadeIn()
            self.loadingImage.rotate360Degrees(completionDelegate: self)
            self.isRotating = true
        }
        
        var timer = Timer(duration: 3.0, completionHandler: {
            self.getProgress()
        })
        
        timer.start()
    }
    
    func getProgress() {
        
        let dataManager = DataManager.sharedInstance
        var timeouts = dataManager.getNumTimeouts()
        
        while (self.progress < 1.0) {
            dataManager.updateProgress()
            self.progress = dataManager.getProgress()
            timeouts = dataManager.getNumTimeouts()
        }
        
        var timer = Timer(duration: 2.0, completionHandler: {
            self.view.window?.rootViewController?.dismissViewControllerAnimated(false, completion: nil)
        })
        
        timer.start()
    }
    
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
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
