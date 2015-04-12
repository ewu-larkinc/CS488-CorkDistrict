//
//  LoadingViewController.swift
//  TheCorkDistrict
//
//  Created by Chris Larkin on 4/11/15.
//  Copyright (c) 2015 Chris Larkin. All rights reserved.
//
import Foundation
import UIKit

class LoadingViewController: UIViewController {
    
    @IBOutlet weak var loadingLogo: UIImageView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var loadingImage: UIButton!
    
    var isRotating = false
    var shouldStopRotating = false
    var timer: Timer!
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.hidden = true
        let dataManager = DataManager.sharedInstance
        dataManager.loadData()
        
        let items = dataManager.fetchEntitiesFromCoreData("Parking")
        if (items!.count == 0) {
            self.loadingImage.alpha = 1.0
            self.loadingLogo.alpha = 1.0
            
            if (self.isRotating == false) {
                
                self.animateLoadingLabel()
                
                self.loadingImage.rotate360Degrees(completionDelegate: self)
                // Perhaps start a process which will refresh the UI...
                self.timer = Timer(duration: 10.0, completionHandler: {
                    self.shouldStopRotating = true
                })
                self.timer.start()
                self.isRotating = true
            }
        } else {
            performSegueWithIdentifier("introSegue", sender: self)
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
                                        self.loadingLabel.fadeIn()
                            })
                        })
                    })
                })
        
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
        performSegueWithIdentifier("introSegue", sender: nil)
    }
}