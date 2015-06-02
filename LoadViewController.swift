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
        
        while (self.progress < 1.0) {
            dataManager.updateProgress()
            self.progress = dataManager.getProgress()
        }
        
        var timer = Timer(duration: 2.0, completionHandler: {
            self.view.window?.rootViewController?.dismissViewControllerAnimated(false, completion: nil)
        })
        
        timer.start()
    }
    
    /*func startCount() {
        
        let dataManager = DataManager.sharedInstance
        var barProgress : Float = 0
        var ctr2 = 0
        var ctr = 0
        for i in 0..<250 {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                sleep(2)
                if (barProgress < dataManager.getProgress()) {
                    barProgress = dataManager.getProgress()
                    println("Progress is \(self.progress)")
                    self.progressView.setProgress(barProgress, animated: true)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    barProgress += 0.004
                    self.progressView.setProgress(barProgress, animated: true)
                    return
                })
            })
        }
    }*/
    
    /*var ctr: Int = 0 {
        didSet {
            let fractionalProgress = Float(ctr)/250.0
            let animated = ctr != 0
            
            progressView.setProgress(fractionalProgress, animated: animated)
        }
    }*/
    
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
