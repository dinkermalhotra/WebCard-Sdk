struct ViewControllerIdentifiers {
    
    static let iValtLoginViewController                     = "iValtLoginViewController"
    static let iValtMainViewController                      = "iValtMainViewController"
    static let iValtOtpViewController                       = "iValtOtpViewController"
    static let iValtRegistrationCompletedViewController     = "iValtRegistrationCompletedViewController"
    static let iValtRegistrationViewController              = "iValtRegistrationViewController"
}

import UIKit

enum ViewControllerType {
    case iValtLoginViewController
    case iValtMainViewController
    case iValtOtpViewController
    case iValtRegistrationCompletedViewController
    case iValtRegistrationViewController
}

class ViewControllerHelper: NSObject {
    
    // This is used to retirve view controller and intents to reutilize the common code.
    
    class func getViewController(ofType viewControllerType: ViewControllerType) -> UIViewController {
        var viewController: UIViewController?
        let storyboard = UIStoryboard(name: "iValt", bundle: nil)
        
        if viewControllerType == .iValtLoginViewController {
            viewController = storyboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.iValtLoginViewController) as! iValtLoginViewController
        }
        else if viewControllerType == .iValtMainViewController {
            viewController = storyboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.iValtMainViewController) as! iValtMainViewController
        }
        else if viewControllerType == .iValtOtpViewController {
            viewController = storyboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.iValtOtpViewController) as! iValtOtpViewController
        }
        else if viewControllerType == .iValtRegistrationCompletedViewController {
            viewController = storyboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.iValtRegistrationCompletedViewController) as! iValtRegistrationCompletedViewController
        }
        else if viewControllerType == .iValtRegistrationViewController {
            viewController = storyboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.iValtRegistrationViewController) as! iValtRegistrationViewController
        }
        else {
            print("Unknown view controller type")
        }
        
        if let vc = viewController {
            return vc
        } else {
            return UIViewController()
        }
    }
}
