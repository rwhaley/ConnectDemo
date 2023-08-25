import UIKit

class CallEndedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.viewControllerOrientation = UIInterfaceOrientationMask.portrait
    }

    @IBAction func newCallBtnPressed(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}
