/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/**
*  The view presented when an alert is triggered
*/
public class MILAlertView : UIView {
    
    //// Label of the alert
    @IBOutlet weak var alertLabel : UILabel!
    /// Reload button that may or may not be shown
    @IBOutlet weak var reloadButton: UIButton!
    /// Callback of the Alert
    var callback : (()->())!
    /// Small tab view on bottom of MILFakeMessageAlertView only
    @IBOutlet weak var pullDownView: UIView?
    /// Type of alert to show
    var alertType: AlertType?
    /**
    Enum for type of Alert to show
    
    - Classic:     Classic alert with a refresh button
    - FakeMessage: Fake Message alert
    */
    enum AlertType {
        case Classic
        case FakeMessage
    }
    
    /**
    Initializer for MILAlertView
    
    :returns: And instance of MILAlertView
    */
    private class func classicAlertFromNib() -> MILAlertView {
        return UINib(nibName: "MILAlertView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! MILAlertView
    }
    
    /**
    Initializer for MILFakeMessageAlertView
    
    :returns: And instance of MILFakeMessageAlertView
    */
    private class func fakeMessageAlertFromNib() -> MILAlertView {
        return UINib(nibName: "MILFakeMessageAlertView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! MILAlertView
    }
    
    /**
    Builds an MILAlertView that is initialized with the appropriate data
    
    :param: alertType       AlertType of MILAlertView to display. If nil, default alertType is .Classic (required)
    :param: text            Body text to display on the MILAlertView. If nil, default text is "MILAlertView" (required)
    :param: textColor       Color of body text to display
    :param: textFont        Font of body text to display
    :param: backgroundColor Background color of the MILAlertView
    :param: reloadImage     Reload button image (MILAlertView .Classic style only with a non-nil callback)
    :param: inView          View in which to add alert as a subview. If inView is nil or not set, alert is added to UIApplication.sharedApplication().keyWindow!
    :param: underView       Alert view will be presented a layer beneath underView within inView. If underView is nil or not set, alert is added at the top of inView
    :param: toHeight        Height of how far down the top of the alert will animate to when showing within inView. If toHeight is nil or not set, toHeight will default to 0 and alert will show at top of inView
    :param: callback        Callback method to execute when the MILAlertView or its reload button is tapped (required). If callback is nil, reloadButton will be hidden (and alert will hide on tap)
    
    :returns: An initialized MILAlertView
    */
    class func buildAlert(alertType: AlertType!, text: String!, textColor: UIColor? = nil, textFont: UIFont? = nil, backgroundColor: UIColor? = nil, reloadImage: UIImage? = nil, inView: UIView? = nil, underView: UIView? = nil, toHeight: CGFloat? = nil, callback: (()->())!)-> MILAlertView{
        var milAlert : MILAlertView!
        if let _ = toHeight {
            MILAlertViewManager.sharedInstance.bottomHeight = toHeight
        } else { //height = 0 if not set
            MILAlertViewManager.sharedInstance.bottomHeight = 0
        }
        
        //build alert with correct type
        var typeOfAlert: AlertType
        if let type = alertType {
            typeOfAlert = type
        } else { //if nil, default is .Classic
            typeOfAlert = .Classic
        }
        
        switch typeOfAlert {
        case .Classic:
            milAlert = MILAlertView.classicAlertFromNib() as MILAlertView
        case .FakeMessage:
            milAlert = MILAlertView.fakeMessageAlertFromNib() as MILAlertView
            milAlert.pullDownView!.layer.cornerRadius = 2
        }
        milAlert.alertType = typeOfAlert
        
        //temporarily disable user interaction while building and showing alert
        milAlert.userInteractionEnabled = false
        
        // setup text
        if let txt = text {
            milAlert.alertLabel.text = txt
        }
        if let newTextColor = textColor {
            milAlert.alertLabel.textColor = newTextColor
        }
        if let newTextFont = textFont {
            milAlert.alertLabel.font = newTextFont
        }
        
        // setup background color
        if let newColor = backgroundColor {
            milAlert.backgroundColor = newColor
        }
        
        // setup reload button image
        if let image = reloadImage {
            if milAlert.alertType == .Classic { //change reload image only if classic type
                milAlert.reloadButton.setImage(image, forState: UIControlState.Normal)
            }
        }
        
        // setup which view alert is in and/or under
        var onView: UIView
        if let view = inView {
            onView = view
        } else {
            onView = UIApplication.sharedApplication().keyWindow!
        }
        
        if let under = underView {
            onView.insertSubview(milAlert, belowSubview: under)
        } else {
            onView.addSubview(milAlert)
        }
        
        //set origin, width, and bottom
        milAlert.frame.origin = CGPointMake(0, milAlert.frame.origin.y)
        milAlert.frame.size.width = UIScreen.mainScreen().bounds.width
        milAlert.frame.origin.y = MILAlertViewManager.sharedInstance.bottomHeight - milAlert.frame.size.height
        
        
        milAlert.setCallbackFunc(callback)
        
        return milAlert
    }
    
    
    /**
    Sets the callback for the MILAlertView and reloadButton to either hide (if callback is nil) or reload (call callback) in the MILAlertViewManager
    
    :param: callback The callback function that is to be executed when the MILAlertView or reload button is tapped
    */
    private func setCallbackFunc(callback:(()->())!){
        var tapGesture = UITapGestureRecognizer(target: MILAlertViewManager.sharedInstance, action: "hide") //hide if no callback
        if let cb = callback {
            self.reloadButton.hidden = false
            self.callback = cb
            tapGesture = UITapGestureRecognizer(target: MILAlertViewManager.sharedInstance, action: "reload") //reload then hide if callback
            self.reloadButton.addTarget(MILAlertViewManager.sharedInstance, action: "reload", forControlEvents: UIControlEvents.TouchUpInside)
        }else{
            self.reloadButton.hidden = true
        }
        self.addGestureRecognizer(tapGesture)
    }
    
    
}
