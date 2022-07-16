import UIKit

class iValtRegistrationCompletedViewController: UIViewController {

    @IBOutlet weak var btnStatus: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

// MARK: - UIBUTTON ACTIONS
extension iValtRegistrationCompletedViewController {
    @IBAction func doneClicked(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATION_SUCCESS), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
}
