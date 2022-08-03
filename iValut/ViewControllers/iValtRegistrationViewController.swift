import UIKit
import MaterialComponents.MaterialTextControls_OutlinedTextFields

protocol iValtRegistrationViewControllerDelegate: class
{
    func onSuccess()
    func didFailWithError(_ message: String)
}

protocol iValtRegistrationDelegate {
    func resendOtp(_ userNumber: String)
}

var registrationViewControllerDelegate: iValtRegistrationDelegate?

public struct Country: Equatable {
    public let name: String
    public let code: String
    public let phoneCode: String
    public func localizedName(_ locale: Locale = Locale.current) -> String? {
        return locale.localizedString(forRegionCode: code)
    }
    public var flag: UIImage {
        return UIImage(named: "\(code.uppercased())")!
    }
}

class iValtRegistrationViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnDropdown: UIButton!
    @IBOutlet weak var txtPhone: MDCOutlinedTextField!
    @IBOutlet weak var txtName: MDCOutlinedTextField!
    @IBOutlet weak var txtEmail: MDCOutlinedTextField!
    @IBOutlet weak var lblPrivacyPolicy: UILabel!
    
    var countryCode = ""
    var isSelected = false
    var name = ""
    var email = ""
    var supplierId = ""
    var supplier = ""
    var deviceToken = ""
    var countries = [Country]()
    weak var delegate: iValtRegistrationViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        registrationViewControllerDelegate = self
        
        setupMDCOutlinedTextField()
        setupCounrties()
        
        txtName.text = name
        txtEmail.text = email
        
        lblPrivacyPolicy.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleTap(_:))))
        setupNotificationManager()
    }
    
    func setupNotificationManager() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(onSuccess(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_SUCCESS), object: nil)
        notificationCenter.addObserver(self, selector: #selector(didFailWithError(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_FAILURE), object: nil)
    }
    
    func setupMDCOutlinedTextField() {
        txtPhone.label.text = "Phone"
        txtName.label.text = "Name"
        txtEmail.label.text = "Email"
        
        txtPhone.leadingViewMode = .always
        txtPhone.setOutlineColor(iVaultColors.WEBCARD_LIGHT_GRAY, for: MDCTextControlState.normal)
        txtPhone.setFloatingLabelColor(iVaultColors.WEBCARD_LIGHT_GRAY, for: MDCTextControlState.normal)
        txtPhone.setNormalLabelColor(iVaultColors.WEBCARD_LIGHT_GRAY, for: MDCTextControlState.normal)
        txtPhone.setOutlineColor(iVaultColors.WEBCARD_LIGHT_GRAY, for: MDCTextControlState.editing)
        txtPhone.setFloatingLabelColor(iVaultColors.WEBCARD_LIGHT_GRAY, for: MDCTextControlState.editing)
        txtPhone.setNormalLabelColor(iVaultColors.WEBCARD_LIGHT_GRAY, for: MDCTextControlState.editing)
        
        txtName.leadingView = UIImageView(image: UIImage(named: "ic_name"))
        txtName.leadingViewMode = .always
        txtName.setOutlineColor(iVaultColors.WEBCARD_LIGHT_GRAY, for: MDCTextControlState.normal)
        txtName.setFloatingLabelColor(iVaultColors.WEBCARD_LIGHT_GRAY, for: MDCTextControlState.normal)
        txtName.setNormalLabelColor(iVaultColors.WEBCARD_LIGHT_GRAY, for: MDCTextControlState.normal)
        txtName.setOutlineColor(iVaultColors.WEBCARD_LIGHT_GRAY, for: MDCTextControlState.editing)
        txtName.setFloatingLabelColor(iVaultColors.WEBCARD_LIGHT_GRAY, for: MDCTextControlState.editing)
        txtName.setNormalLabelColor(iVaultColors.WEBCARD_LIGHT_GRAY, for: MDCTextControlState.editing)
        
        txtEmail.leadingView = UIImageView(image: UIImage(named: "ic_mail"))
        txtEmail.leadingViewMode = .always
        txtEmail.setOutlineColor(iVaultColors.WEBCARD_LIGHT_GRAY, for: MDCTextControlState.normal)
        txtEmail.setFloatingLabelColor(iVaultColors.WEBCARD_LIGHT_GRAY, for: MDCTextControlState.normal)
        txtEmail.setNormalLabelColor(iVaultColors.WEBCARD_LIGHT_GRAY, for: MDCTextControlState.normal)
        txtEmail.setOutlineColor(iVaultColors.WEBCARD_LIGHT_GRAY, for: MDCTextControlState.editing)
        txtEmail.setFloatingLabelColor(iVaultColors.WEBCARD_LIGHT_GRAY, for: MDCTextControlState.editing)
        txtEmail.setNormalLabelColor(iVaultColors.WEBCARD_LIGHT_GRAY, for: MDCTextControlState.editing)
    }
    
    func setupCounrties() {
        guard let jsonPath = Bundle.main.path(forResource: "CountryCodes", ofType: "json"),
            let jsonData = try? Data(contentsOf: URL(fileURLWithPath: jsonPath)) else {
                return
        }
        
        if let jsonObjects = (try? JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization
            .ReadingOptions.allowFragments)) as? Array<Any> {
            
            for jsonObject in jsonObjects {
                guard let countryObj = jsonObject as? Dictionary<String, Any> else {
                    continue
                }
                
                guard let name = countryObj["name"] as? String,
                    let code = countryObj["code"] as? String,
                    let phoneCode = countryObj["dial_code"] as? String else {
                        continue
                }
                
                let country = Country(name: name, code: code, phoneCode: phoneCode)
                countries.append(country)
                
                let locale = Locale.current
                if code == locale.regionCode {
                    self.countryCode = "      \(country.phoneCode) "
                    txtPhone.leadingView = UIImageView(image: country.flag)
                    txtPhone.text = self.countryCode
                }
            }
            
            self.tableView.reloadData()
        }
    }
    
    @objc func onSuccess(_ notification: Notification) {
        self.delegate?.onSuccess()
    }
    
    @objc func didFailWithError(_ notification: Notification) {
        if let notificationUserInfo = notification.userInfo {
            if let message = notificationUserInfo[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String {
                self.delegate?.didFailWithError(message)
            }
        }
    }
}

// MARK: - UIBUTTON ACTION
extension iValtRegistrationViewController {
    @objc func btnDoneOfToolBarPressed() {
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let text = self.lblPrivacyPolicy.text ?? ""
        let range = (text as NSString).range(of: "Terms and Conditions")
        if sender.didTapAttributedTextInLabel(label: self.lblPrivacyPolicy, inRange: range) {
            print("terms")
            guard let url = URL(string: WebService.privacyPolicy) else { return }
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        let currentText = self.countryCode
        
        sender.text = sender.text?.replacingOccurrences(of: self.countryCode, with: "")
        sender.text = "\(currentText)\(sender.text ?? "")"
    }
    
    @IBAction func countryPickerClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        self.tableView.isHidden = !self.tableView.isHidden
        
        if self.tableView.isHidden {
            self.btnDropdown.setImage(UIImage.init(named: "ic_dropdown") , for: UIControl.State())
        }
        else {
            self.btnDropdown.setImage(UIImage.init(named: "ic_dropdown_up") , for: UIControl.State())
        }
    }
    
    @IBAction func btnPrivacyPressed(_ sender: UIButton) {
        if isSelected {
            sender.setImage(#imageLiteral(resourceName: "ic_uncheck"), for: UIControl.State())
            isSelected = false
        } else {
            sender.setImage(#imageLiteral(resourceName: "ic_check"), for: UIControl.State())
            isSelected = true
        }
    }
    
    @IBAction func nextClicked(_ sender: UIButton) {
        let emailRegEx = "[a-zA-Z0-9._-]+@[a-z?-]+\\.+[a-z]+"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        if countryCode.isEmpty {
            Helper.showOKAlert(onVC: self, title: Alert.ERROR, message: AlertMessages.ENTER_COUNTRY_CODE)
        }
        else if(txtPhone.text?.replacingOccurrences(of: countryCode, with: "").count == 0) {
            Helper.showOKAlert(onVC: self, title: Alert.ERROR, message: AlertMessages.ENTER_MOBILE_NUMBER)
        }
        else if !isSelected {
            Helper.showOKAlert(onVC: self, title: Alert.ALERT, message: AlertMessages.ACCEPT_PRIVACY)
        }
        else if txtName.text?.isEmpty ?? true {
            Helper.showOKAlert(onVC: self, title: Alert.ALERT, message: AlertMessages.NAME_REQUIRED)
        }
        else if txtEmail.text?.isEmpty ?? true {
            Helper.showOKAlert(onVC: self, title: Alert.ALERT, message: AlertMessages.EMAIL_REQUIRED)
        }
        else if (emailTest.evaluate(with: self.txtEmail.text?.lowercased()) == false) {
            Helper.showOKAlert(onVC: self, title: Alert.ALERT, message: AlertMessages.ENTER_VALID_EMAIL)
        }
        else {
            userRegistration(txtPhone.text?.replacingOccurrences(of: " ", with: "") ?? "")
        }
    }
}

// MARK: - UITEXTFIELD DELEGATE
extension iValtRegistrationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textFieldCount = textField.text?.count ?? 0
        let newTextCount = textFieldCount + string.count - range.length
        
        if newTextCount < self.countryCode.count {
            return false
        }
        
        return true
    }
}

// MARK: - UITABLEVIEW METHODS
extension iValtRegistrationViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let country = countries[indexPath.row]
        
        cell.textLabel?.text = country.name
        cell.detailTextLabel?.text = country.phoneCode
        cell.imageView?.image = country.flag
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.isHidden = true
        let country = countries[indexPath.row]
        
        var replaceString = txtPhone.text ?? ""
        replaceString = replaceString.replacingOccurrences(of: self.countryCode, with: "      \(country.phoneCode) ")
        
        txtPhone.leadingView = UIImageView(image: country.flag)
        txtPhone.text = replaceString
        
        self.countryCode = "      \(country.phoneCode) "
    }
}

// MARK: - CUSTOM DELEGATE
extension iValtRegistrationViewController: iValtRegistrationDelegate {
    func resendOtp(_ userNumber: String) {
        if WSManager.isConnectedToInternet() {
            let params: [String: AnyObject] = [WSRequestParams.WS_REQS_PARAM_MOBILE: userNumber as AnyObject]
            WSManager.wsCallLogin(params, completion: { (isSuccess, message) in
                if !isSuccess {
                    var data: [AnyHashable: Any] = [:]
                    data[WSResponseParams.WS_RESP_PARAM_MESSAGE] = message
                    NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATION_FAILURE), object: nil, userInfo: data)
                }
            })
        } else {
            
        }
    }
}

// MARK: - API CALL
extension iValtRegistrationViewController {
    func userRegistration(_ userNumber: String) {
        if WSManager.isConnectedToInternet() {
            let params: [String: AnyObject] = [WSRequestParams.WS_REQS_PARAM_MOBILE: userNumber as AnyObject]
            WSManager.wsCallLogin(params, completion: { (isSuccess, message) in
                if isSuccess {
                    if let vc = ViewControllerHelper.getViewController(ofType: .iValtOtpViewController) as? iValtOtpViewController {
                        vc.strCode = self.countryCode.replacingOccurrences(of: " ", with: "")
                        vc.strNumber = self.txtPhone.text?.replacingOccurrences(of: self.countryCode, with: "") ?? ""
                        vc.supplier = self.supplier
                        vc.supplierId = self.supplierId
                        vc.deviceToken = self.deviceToken
                        Helper.setPREF(self.txtEmail.text ?? "", key: UserDefaultsConstants.PREF_EMAIL)
                        Helper.setPREF(userNumber, key: UserDefaultsConstants.PREF_MOBILE_NUMBER)
                        Helper.setPREF(self.txtPhone.text?.replacingOccurrences(of: self.countryCode, with: "") ?? "", key: UserDefaultsConstants.PREF_MOBILE)
                        Helper.setPREF(self.txtName.text ?? "", key: UserDefaultsConstants.PREF_NAME)
                        Helper.setPREF(self.countryCode, key: UserDefaultsConstants.PREF_COUNTRY_CODE)
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                } else {
                    var data: [AnyHashable: Any] = [:]
                    data[WSResponseParams.WS_RESP_PARAM_MESSAGE] = message
                    NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATION_FAILURE), object: nil, userInfo: data)
                }
            })
        } else {
            
        }
    }
}
