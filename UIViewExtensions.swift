//
//  UIViewExtensions.swift
//  TheCorkDistrict
//
//
import UIKit

extension UIView {
    
    
    func rotate360Degrees(duration: CFTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(M_PI * 2.0)
        rotateAnimation.duration = duration
        //rotateAnimation.repeatCount = 50
        
        if let delegate: AnyObject = completionDelegate {
            rotateAnimation.delegate = delegate
        }
        self.layer.addAnimation(rotateAnimation, forKey: nil)
    }
    
    func fadeIn(duration: NSTimeInterval = 2.0, delay: NSTimeInterval = 0.0) {
            UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.alpha = 1.0
                }, completion: {(finished: Bool) -> Void in
                    self.fadeOut()
            })
    }
    
    func fadeOut(duration: NSTimeInterval = 2.0, delay: NSTimeInterval = 0.0) {
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.alpha = 0.0
            }, completion: {(finished: Bool) -> Void in
                self.fadeIn()
        })
    }
}