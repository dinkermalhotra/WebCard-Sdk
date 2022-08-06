import UIKit
import Foundation
import LocalAuthentication

protocol iValtLoginViewControllerDelegate: class
{
    func onSuccess(_ message: String, _ userDetails: [String: AnyObject])
    func didFailWithError(_ message: String)
}

class iValtLoginViewController: UIViewController {

    weak var delegate: iValtLoginViewControllerDelegate?
    var deviceToken = ""
    
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
                        do {
                            let deviceId = try KeychainWrapper.init().getDeviceId()
                            
                            self?.loginUser(deviceId)
                        }
                        catch let error {
                            self?.delegate?.didFailWithError(error.localizedDescription)
                        }
                    } else {
                        self?.delegate?.didFailWithError(error?.localizedDescription ?? "")
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
extension iValtLoginViewController {
    func loginUser(_ deviceId: String) {
        let params: [String: AnyObject] = [WSRequestParams.WS_REQS_PARAM_IMEI: deviceId as AnyObject]
        WSManager.wsCallRegisterUserDetails(params) { (isSuccess, message, userDetails) in
            if isSuccess {
                if let mobile = userDetails[WSRequestParams.WS_REQS_PARAM_MOBILE] as? String, let countryCode = userDetails[WSRequestParams.WS_REQS_PARAM_COUNTRY_CODE] as? String {
                    Helper.setPREF(mobile, key: UserDefaultsConstants.PREF_MOBILE)
                    Helper.setPREF(countryCode, key: UserDefaultsConstants.PREF_COUNTRY_CODE)
                    
                    self.updateToken(mobile, deviceId)
                }
                
                self.delegate?.onSuccess(message, userDetails)
            }
            else {
                self.delegate?.didFailWithError(message)
            }
        }
    }
    
    func updateToken(_ mobile: String, _ deviceId: String) {
        let params: [String: AnyObject] = [WSRequestParams.WS_REQS_PARAM_MOBILE: mobile as AnyObject,
                                           WSRequestParams.WS_REQS_PARAM_TOKEN: deviceToken as AnyObject,
                                           WSRequestParams.WS_REQS_PARAM_IMEI: deviceId as AnyObject]
        WSManager.wsCallUpdateToken(params)
    }
}
