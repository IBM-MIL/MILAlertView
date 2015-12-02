/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/**
*  Class that manages the creation, display, hiding, and deletion of the MILAlertView
*/
public class MILAlertViewManager: NSObject {
    /// sharedInstance of MILAlertViewManager
    static let sharedInstance = MILAlertViewManager()
    /// The MILAlertView. Private to just this class
    private var milAlertView : MILAlertView!
    /// Height at which to place the bottom of the MILAlertView
    var bottomHeight: CGFloat! = 0
    /// Timer to auto hide alert after a certain amount of time
    var autoHideTimer: NSTimer? = nil
    
    
    /**
    Method that builds and displays an MILAlertView
    
    :param: alertType       AlertType of MILAlertView to display. If nil, default alertType is .Classic (required)
    :param: text            Body text to display on the MILAlertView. If nil, default text is "MILAlertView" (required)
    :param: textColor       Color of body text to display
    :param: textFont        Font of body text to display
    :param: backgroundColor Background color of the MILAlertView
    :param: reloadImage     Reload button image (MILAlertView Classic style only with a non-nil callback)
    :param: inView          View in which to add alert as a subview. If inView is nil or not set, alert is added to UIApplication.sharedApplication().keyWindow!
    :param: underView       Alert view will be presented a layer beneath underView within inView. If underView is nil or not set, alert is added at the top of inView
    :param: toHeight        Height of how far down the top of the alert will animate to when showing within inView. If toHeight is nil or not set, toHeight will default to 0 and alert will show at top of inView
    :param: forSeconds      NSTimeInterval (Double) for how many seconds the MILAlertView should stay shown before hiding, but only if callback is nil. If callback is nil, the alert will auto-hide after forSeconds seconds. If callback is not nil, forSeconds will be overwritten and the alert will not hide until tapped. If forSeconds is nil or not set (and callback is nil), the alert will also not hide until tapped.
    :param: callback        Callback method to execute when the MILAlertView or its reload button is tapped (required). If callback is nil, reloadButton will be hidden (and alert will hide on tap)
    */
    func show(alertType: MILAlertView.AlertType!, text: String!, textColor: UIColor? = nil, textFont: UIFont? = nil, backgroundColor: UIColor? = nil, reloadImage: UIImage? = nil, inView: UIView? = nil, underView: UIView? = nil, toHeight: CGFloat? = nil, forSeconds: NSTimeInterval? = nil, callback: (()->())!) {
        
        self.resetAlert()
        
        self.milAlertView = MILAlertView.buildAlert(alertType, text: text, textColor: textColor, textFont: textFont, backgroundColor: backgroundColor, reloadImage: reloadImage, inView: inView, underView: underView, toHeight: toHeight, callback: callback)
        
        //animate showing alert view
        UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.milAlertView.frame.origin.y = (self.milAlertView.frame.size.height + self.bottomHeight) - self.milAlertView.frame.size.height
            }, completion: { finished -> Void in
                if finished{
                    self.setAutoHide(forSeconds)
                    if let alertview = self.milAlertView {
                        alertview.userInteractionEnabled = true    //now allow user to touch after done animating
                    }
                }
        })
        
    }
    
    /**
    Method to remove the MILAlertView from its superview and set it to nil, and reset MILAlertViewManager properties
    */
    private func resetAlert() {
        // reset values in case any alerts are currently shown
        if let alert = self.milAlertView {
            alert.userInteractionEnabled = false
            alert.removeFromSuperview()
            if let timer = self.autoHideTimer {
                timer.invalidate()
                self.autoHideTimer = nil
            }
            self.bottomHeight = 0
            self.milAlertView = nil
        }
    }
    
    
    /**
    Method to auto-hide alert after a designated number of seconds (forSeconds) if callback is nil and forSeconds is not nil. If callback is not nil or forSeconds is nil, the alert will stay shown until tapped.
    
    :param: forSeconds NSTimeInterval (Double) for how long the alert should stay shown before hiding
    */
    private func setAutoHide(forSeconds: NSTimeInterval?) {
        if let cb = self.milAlertView.callback { //callback exists, so keep alert up until tapped (no auto hide timer)
            if let timer = self.autoHideTimer {
                timer.invalidate()
                self.autoHideTimer = nil
            }
        } else { //no callback, so hide after a time if given
            if let time = forSeconds {
                self.autoHideTimer = NSTimer.scheduledTimerWithTimeInterval(time, target: self, selector: "hide", userInfo: nil, repeats: false)
            } else { //no time given, so keep alert up until tapped
                if let timer = self.autoHideTimer {
                    timer.invalidate()
                    self.autoHideTimer = nil
                }
            }
        }
    }
    

    
    /**
    Hides the MILAlertView with an animation
    */
    func hide() {
        if let alert = self.milAlertView{
            alert.userInteractionEnabled = false
            UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.milAlertView.frame.origin.y = self.bottomHeight - self.milAlertView.frame.size.height
                }, completion: { finished -> Void in
                    if finished {
                        self.remove()
                    }
            })
        }
        
    }
    
    /**
    Removes the MILAlertView from its superview and sets it to nil
    */
    private func remove(){
        if let alert = self.milAlertView {
            alert.removeFromSuperview()
            self.milAlertView = nil
        }
    }
    
    /**
    Reload function that fires when the MILALertView is tapped
    */
    @IBAction func reload(){
        self.milAlertView.callback()
        hide()
    }
    
}
