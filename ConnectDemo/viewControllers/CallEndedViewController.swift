import UIKit

class CallEndedViewController: UIViewController {

    @IBAction func newCallBtnPressed(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}
