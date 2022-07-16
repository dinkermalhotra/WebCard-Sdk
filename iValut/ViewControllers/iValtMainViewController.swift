import UIKit
import Foundation
import LocalAuthentication

class iValtMainViewController: UIViewController {
    
    var supplierId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        faceAuthentication()
    }
    
    func faceAuthentication() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [weak self] success, authenticationError in

                DispatchQueue.main.async {
                    if success {
                        Helper.setBoolPREF(true, key: UserDefaultsConstants.PREF_IS_FACE_SCANNED)
                        self?.setEnrollment()
                    } else {
                        var data: [AnyHashable: Any] = [:]
                        data[WSResponseParams.WS_RESP_PARAM_MESSAGE] = error?.localizedDescription ?? AlertMessages.PASSCODE_NOT_ALLOWED
                        NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATION_FAILURE), object: nil, userInfo: data)
                    }
                }
            }
        } else {
            Helper.showOKCancelAlertWithCompletion(onVC: self, title: Alert.ERROR, message: AlertMessages.FACE_ID_NOT_CONFIGURED, btnOkTitle: "Settings", btnCancelTitle: "Cancel", onOk: {
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }

                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            })
        }
    }
}

// MARK: - API CALL
extension iValtMainViewController {
    func setEnrollment() {
        let params: [String: AnyObject] = [WSRequestParams.WS_REQS_PARAM_MOBILE: Helper.getPREF(UserDefaultsConstants.PREF_MOBILE) as AnyObject,
                                           WSRequestParams.WS_REQS_PARAM_SUPPLIER_ID: supplierId as AnyObject]
        WSManager.wsCallSetEnrollment(params) { (isSuccess) in
            if isSuccess {
                if let vc = ViewControllerHelper.getViewController(ofType: .iValtRegistrationCompletedViewController) as? iValtRegistrationCompletedViewController {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
}
