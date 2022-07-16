import UIKit
import Foundation
import LocalAuthentication

class PushNotification: NSObject {
    @objc static func notificationReceived(_ userInfo: [AnyHashable: Any]) {
        let mobile = userInfo["mobile"] as? String ?? ""
        let website = userInfo["website"] as? String ?? ""
        let token = userInfo["token"] as? String ?? ""
        let requestFor = userInfo["request_for"] as? String ?? ""
        let type = userInfo["type"] as? String ?? ""
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            faceAuthentication(mobile, requestFor, token, type, website)
        })
    }
    
    @objc private static func faceAuthentication(_ mobile: String, _ requestFor: String, _ token: String, _ type: String, _ webSite: String) {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                            if type == Strings.GLOBAL {
                                globalUser(mobile, true)
                            } else {
                                if type == Strings.WORDPRESS && requestFor == Strings.LOGIN {
                                    loginUser(mobile, token, webSite)
                                } else {
                                    uploadRegister(mobile, token, webSite)
                                }
                            }
                        })
                    } else {
                        globalUser(mobile, false)
                    }
                }
            }
        } else {
            globalUser(mobile, false)
        }
    }
    
    @objc private static func globalUser(_ mobile: String, _ value: Bool) {
        if WSManager.isConnectedToInternet() {
            let params: [String: AnyObject] = [WSRequestParams.WS_REQS_PARAM_MOBILE: mobile as AnyObject,
                                               WSResponseParams.WS_RESP_PARAM_STATUS: value as AnyObject,
                                               WSRequestParams.WS_REQS_PARAM_COUNTRY_CODE: Helper.getPREF(UserDefaultsConstants.PREF_COUNTRY_CODE) as AnyObject]
            WSManager.wsCallGlobalAuthentication(params, completion: { (isSuccess, message) in
                print(isSuccess)
            })
        } else {
            
        }
    }
    
    @objc private static func uploadRegister(_ mobile: String, _ token: String, _ webSite: String) {
        if WSManager.isConnectedToInternet() {
            let params: [String: AnyObject] = [WSRequestParams.WS_REQS_PARAM_MOBILE: mobile as AnyObject,
                                               WSRequestParams.WS_REQS_PARAM_TOKEN: token as AnyObject,
                                               WSRequestParams.WS_REQS_PARAM_DOMAIN: webSite as AnyObject]
            WSManager.wsCallRegisterConfirmation(params, completion: { (isSuccess, message) in
                if isSuccess {
                    
                }
            })
        } else {
            
        }
    }
    
    @objc private static func loginUser(_ mobile: String, _ token: String, _ webSite: String) {
        if WSManager.isConnectedToInternet() {
            let params: [String: AnyObject] = [WSRequestParams.WS_REQS_PARAM_MOBILE: mobile as AnyObject,
                                                WSRequestParams.WS_REQS_PARAM_TOKEN: token as AnyObject,
                                                WSRequestParams.WS_REQS_PARAM_DOMAIN: webSite as AnyObject]
            WSManager.wsCallLoginConfirmation(params, completion: { (isSuccess, message) in
                if isSuccess {
                    
                }
            })
        } else {
                
        }
    }
}
