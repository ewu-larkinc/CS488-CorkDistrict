//
//  LoadViewController.swift
//  TheCorkDistrict
//
//


import UIKit

class LoadViewController : UIViewController {
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var loadingLabel: UILabel!
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
        
        progressView.setProgress(0, animated: true)
        startCount()
        
        if (self.isRotating == false) {
            
            self.animateLoadingLabel()
            self.animateLoadingLogo()
            self.loadingImage.rotate360Degrees(completionDelegate: self)
            
            self.timer = Timer(duration: 12.0, completionHandler: {
                self.shouldStopRotating = true
            })
            self.timer.start()
            self.isRotating = true
        }
    }
    
    func animateLoadingLabel() -> Void {
        
        self.loadingLabel.fadeIn(completion: {
            
            (finished: Bool) -> Void in
            self.loadingLabel.fadeOut(completion: {
                
                (finished: Bool) -> Void in
                self.loadingLabel.fadeIn(completion: {
                    
                    (finished: Bool) -> Void in
                    self.loadingLabel.fadeOut(completion: {
                        
                        (finished: Bool) -> Void in
                        self.loadingLabel.fadeIn(completion: {
                            
                            (finished: Bool) -> Void in
                            self.loadingLabel.fadeOut(completion: {
                                
                                (finished: Bool) -> Void in
                                self.loadingLabel.fadeIn(completion: {
                                    
                                    (finished: Bool) -> Void in
                                    self.loadingLabel.fadeOut(completion: {
                                      
                                        (finished: Bool) -> Void in
                                        self.loadingLabel.fadeIn()
                                    })
                                })
                            })
                        })
                    })
                })
            })
        })
        
    }
    
    func animateLoadingLogo() -> Void {
        
        self.loadingLogo.fadeIn(completion: {
            
            (finished: Bool) -> Void in
            self.loadingLogo.fadeOut(completion: {
                
                (finished: Bool) -> Void in
                self.loadingLogo.fadeIn(completion: {
                    
                    (finished: Bool) -> Void in
                    self.loadingLogo.fadeOut(completion: {
                        
                        (finished: Bool) -> Void in
                        self.loadingLogo.fadeIn(completion: {
                            
                            (finished: Bool) -> Void in
                            self.loadingLogo.fadeOut(completion: {
                                
                                (finished: Bool) -> Void in
                                self.loadingLogo.fadeIn(completion: {
                                    
                                    (finished: Bool) -> Void in
                                    self.loadingLogo.fadeOut(completion: {
                                        
                                        (finished: Bool) -> Void in
                                        self.loadingLogo.fadeIn()
                                    })
                                })
                            })
                        })
                    })
                })
            })
        })
        
    }
    
    func startCount() {
        
        let dataManager = DataManager.sharedInstance
        progress = 0
        var ctr2 = 0
        var ctr = 0
        for i in 0..<250 {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                sleep(2)
                if (self.progress < dataManager.getProgress()) {
                    self.progress = dataManager.getProgress()
                    println("Progress is \(self.progress)")
                    self.progressView.setProgress(self.progress, animated: true)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.progress += 0.004
                    self.progressView.setProgress(self.progress, animated: true)
                    return
                })
            })
        }
    }
    
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
