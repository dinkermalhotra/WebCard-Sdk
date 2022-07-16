import UIKit

class iValtOtpViewController: UIViewController {

    @IBOutlet weak var txtOne: UITextField!
    @IBOutlet weak var txtTwo: UITextField!
    @IBOutlet weak var txtThree: UITextField!
    @IBOutlet weak var txtFour: UITextField!
    @IBOutlet weak var lblAlert: UILabel!
    @IBOutlet weak var lblVerificationCode: UILabel!
    
    var deviceToken = ""
    var strCode: String?
    var strNumber: String?
    var supplierId = ""
    var supplier = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        let mainString = "We have send you the verification code on \(Helper.getPREF(UserDefaultsConstants.PREF_MOBILE_NUMBER) ?? "")"
        let range = (mainString as NSString).range(of: Helper.getPREF(UserDefaultsConstants.PREF_MOBILE_NUMBER) ?? "")

        let mutableAttributedString = NSMutableAttributedString.init(string: mainString)
        mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: iVaultColors.WEBCARD_BLUE, range: range)
        lblVerificationCode.attributedText = mutableAttributedString
        
        txtOne.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        txtTwo.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        txtThree.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        txtFour.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let text = textField.text
        
        if (text?.count ?? 0) >= 1 {
            switch textField {
            case txtOne:
                txtTwo.becomeFirstResponder()
            case txtTwo:
                txtThree.becomeFirstResponder()
            case txtThree:
                txtFour.becomeFirstResponder()
            case txtFour:
                txtFour.resignFirstResponder()
            default:
                txtOne.becomeFirstResponder()
            }
        }
    }
    
    func initiateTimer(_ message: String) {
        self.lblAlert.isHidden = false
        self.lblAlert.text = message
        self.txtOne.borderColor = iVaultColors.WEBCARD_RED
        self.txtTwo.borderColor = iVaultColors.WEBCARD_RED
        self.txtThree.borderColor = iVaultColors.WEBCARD_RED
        self.txtFour.borderColor = iVaultColors.WEBCARD_RED
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
            self.lblAlert.isHidden = true
            self.txtOne.borderColor = iVaultColors.WEBCARD_LIGHT_GRAY
            self.txtTwo.borderColor = iVaultColors.WEBCARD_LIGHT_GRAY
            self.txtThree.borderColor = iVaultColors.WEBCARD_LIGHT_GRAY
            self.txtFour.borderColor = iVaultColors.WEBCARD_LIGHT_GRAY
        })
    }
}

// MARK: - UIBUTTON ACTIONS
extension iValtOtpViewController {
    @IBAction func backClicked(_ sender: UIButton) {
        if self.presentingViewController != nil {
            self.dismiss(animated: true, completion: nil)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func resendCodeClicked(_ sender: UIButton) {
        registrationViewControllerDelegate?.resendOtp(Helper.getPREF(UserDefaultsConstants.PREF_MOBILE_NUMBER) ?? "")
    }
    
    @IBAction func btn_submit(_ sender: UIButton) {
        if (txtOne.text?.isEmpty ?? true) || (txtTwo.text?.isEmpty ?? true) || (txtThree.text?.isEmpty ?? true) || (txtFour.text?.isEmpty ?? true) {
            self.initiateTimer(AlertMessages.VALID_OTP)
        } else {
            do {
                try KeychainWrapper.init().storeDeviceIdFor(deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "")
                let deviceId = try KeychainWrapper.init().getDeviceId()
                
                userRegistration(deviceId)
            }
            catch let error {
                var data: [AnyHashable: Any] = [:]
                data[WSResponseParams.WS_RESP_PARAM_MESSAGE] = error.localizedDescription
                NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATION_FAILURE), object: nil, userInfo: data)
            }
        }
    }
}

// MARK: - UITEXTFIELD DELEGATE
extension iValtOtpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - API CALL
extension iValtOtpViewController {
    func userRegistration(_ deviceId: String) {
        if WSManager.isConnectedToInternet() {
            let params: [String: AnyObject] = [WSRequestParams.WS_REQS_PARAM_MOBILE: strNumber as AnyObject,
                                               WSRequestParams.WS_REQS_PARAM_COUNTRY_CODE: strCode as AnyObject,
                                               WSRequestParams.WS_REQS_PARAM_USER_CODE: "\(txtOne.text ?? "")\(txtTwo.text ?? "")\(txtThree.text ?? "")\(txtFour.text ?? "")" as AnyObject,
                                               WSRequestParams.WS_REQS_PARAM_DEVICE_TOKEN: deviceToken as AnyObject,
                                               WSRequestParams.WS_REQS_PARAM_PLATFORM: "iOS" as AnyObject,
                                               WSRequestParams.WS_REQS_PARAM_EMAIL: Helper.getPREF(UserDefaultsConstants.PREF_EMAIL) as AnyObject,
                                               WSRequestParams.WS_REQS_PARAM_NAME: Helper.getPREF(UserDefaultsConstants.PREF_NAME) as AnyObject,
                                               WSRequestParams.WS_REQS_PARAM_IMEI: deviceId as AnyObject,
                                               WSRequestParams.WS_REQS_PARAM_SUPPLIER_ID: supplierId as AnyObject,
                                               WSRequestParams.WS_REQS_PARAM_SUPPLIER: supplier as AnyObject]
            WSManager.wsCallRegister(params, completion: { (isSuccess, message) in
                if isSuccess {
                    if let vc = ViewControllerHelper.getViewController(ofType: .iValtMainViewController) as? iValtMainViewController {
                        vc.supplierId = self.supplierId
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                } else {
                    self.initiateTimer(message)
                    
                    var data: [AnyHashable: Any] = [:]
                    data[WSResponseParams.WS_RESP_PARAM_MESSAGE] = message
                    NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATION_FAILURE), object: nil, userInfo: data)
                }
            })
        } else {
            
        }
    }
}
