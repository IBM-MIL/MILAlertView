/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var blueView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController?.navigationBar.backgroundColor = UIColor.whiteColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func tappedAlert() {
        print("MILAlertView callback!")
    }

    @IBAction func tappedShowAlert(sender: AnyObject) {
        // Classic alert
        MILAlertViewManager.sharedInstance.show(.Classic, text: "MILAlertView Test!", backgroundColor: UIColor.purpleColor(), inView: self.view, underView: nil, toHeight: 44, callback: tappedAlert)
        
        // Classic alert under greyView
        //MILAlertViewManager.sharedInstance.show(.Classic, text: "MILAlertView Test!", backgroundColor: UIColor.greenColor(), inView: self.view, underView: self.blueView, toHeight: 88, callback: tappedAlert)
        
        // Classic alert with minimum required fields (default)
        //MILAlertViewManager.sharedInstance.show(nil, text: nil, callback: nil)
    }

    @IBAction func tappedShowFake(sender: AnyObject) {
        // Fake Message alert, auto dismiss after 2 seconds
        MILAlertViewManager.sharedInstance.show(.FakeMessage, text: "MILAlertView Test!", forSeconds: 2, callback: nil)
        
        // Fake Message alert with callback
        //MILAlertViewManager.sharedInstance.show(.FakeMessage, text: "MILAlertView Test!", callback: tappedAlert)
    }
    
    @IBAction func tappedHide(sender: AnyObject) {
        MILAlertViewManager.sharedInstance.hide()
    }
    
}

