
import Foundation
import Alamofire

class WSManager {
    
    class func isConnectedToInternet() -> Bool {
        return NetworkReachabilityManager()!.isReachable
    }
    
    static let header: HTTPHeaders = ["x-api-key": "rZxaNHhPbU4lyJk985d7D5ECy4L2RUu55FNK0ZM5"]
    
    // MARK: LOGIN USER
    class func wsCallLogin(_ requestParams: [String: AnyObject], completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        Alamofire.request(WebService.sendSMS, method: .post, parameters: requestParams, encoding: JSONEncoding.default, headers: header).responseJSON(completionHandler: {(responseData) -> Void in
            print(responseData.result)
            if let responseValue = responseData.result.value as? [String: AnyObject] {
                print(responseValue)
                if let error = responseValue[WSResponseParams.WS_RESP_PARAM_ERROR] as? [String: AnyObject] {
                    completion(false, error[WSResponseParams.WS_RESP_PARAM_DETAIL] as? String ?? "")
                }
                else {
                    if let data = responseValue[WSResponseParams.WS_RESP_PARAM_DATA] as? [String: AnyObject] {
                        if let status = data[WSResponseParams.WS_RESP_PARAM_STATUS] as? Bool {
                            if status {
                                completion(true, "")
                            }
                            else {
                                completion(false, data[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                            }
                        }
                    }
                }
            } else {
                completion(false, "No parameters found")
            }
        })
    }
    
    // MARK: REGISTER USER
    class func wsCallRegister(_ requestParams: [String: AnyObject], completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        Alamofire.request(WebService.register, method: .post, parameters: requestParams, encoding: JSONEncoding.default, headers: header).responseJSON(completionHandler: {(responseData) -> Void in
            print(responseData.result)
            if let responseValue = responseData.result.value as? [String: AnyObject] {
                print(responseValue)
                if let error = responseValue[WSResponseParams.WS_RESP_PARAM_ERROR] as? [String: AnyObject] {
                    completion(false, error[WSResponseParams.WS_RESP_PARAM_DETAIL] as? String ?? "")
                }
                else {
                    if let data = responseValue[WSResponseParams.WS_RESP_PARAM_DATA] as? [String: AnyObject] {
                        if let status = data[WSResponseParams.WS_RESP_PARAM_STATUS] as? Bool {
                            if status {
                                if let details = data[WSResponseParams.WS_RESP_PARAM_DETAILS] as? [String: AnyObject] {
                                    if let userId = details[WSResponseParams.WS_RESP_PARAM_ID] as? Int {
                                        Helper.setIntPREF(userId, key: UserDefaultsConstants.PREF_USERID)
                                    }
                                    
                                    completion(true, "")
                                }
                            }
                            else {
                                completion(false, data[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                            }
                        }
                    }
                }
            } else {
                completion(false, "No parameters found")
            }
        })
    }
    
    // MARK: REGISTER FOR WORDPRESS
    class func wsCallRegisterConfirmation(_ requestParams: [String: AnyObject], completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        Alamofire.request(WebService.registerConfirmation, method: .post, parameters: requestParams, encoding: JSONEncoding.default, headers: header).responseJSON(completionHandler: {(responseData) -> Void in
            print(responseData.result)
            if let responseValue = responseData.result.value as? [String: AnyObject] {
                print(responseValue)
            }
        })
    }
    
    // MARK: LOGIN FOR WORDPRESS
    class func wsCallLoginConfirmation(_ requestParams: [String: AnyObject], completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        Alamofire.request(WebService.loginConfirmation, method: .post, parameters: requestParams, encoding: JSONEncoding.default, headers: header).responseJSON(completionHandler: {(responseData) -> Void in
            print(responseData.result)
            if let responseValue = responseData.result.value as? [String: AnyObject] {
                print(responseValue)
            }
        })
    }
    
    // MARK: GLOBAL AUTHENTICATION
    class func wsCallGlobalAuthentication(_ requestParams: [String: Any], completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        Alamofire.request(WebService.global, method: .post, parameters: requestParams, encoding: JSONEncoding.default, headers: header).responseJSON(completionHandler: {(responseData) -> Void in
            print(responseData.result)
            if let responseValue = responseData.result.value as? [String: AnyObject] {
                print(responseValue)
                if responseValue[WSResponseParams.WS_RESP_PARAM_ERROR] is [String: AnyObject] {
                    completion(false, "")
                }
                else {
                    if let data = responseValue[WSResponseParams.WS_RESP_PARAM_DATA] as? [String: AnyObject] {
                        if let status = data[WSResponseParams.WS_RESP_PARAM_STATUS] as? Bool {
                            if status {
                                completion(true, "")
                            }
                            else {
                                completion(false, "")
                            }
                        }
                    }
                }
            } else {
                completion(false, "")
            }
        })
    }
    
    // MARK: REGISTER USER DETAILS
    class func wsCallRegisterUserDetails(_ requestParams: [String: AnyObject], completion:@escaping (_ isSuccess: Bool, _ message: String, _ userDetails: [String: AnyObject])->()) {
        Alamofire.request(WebService.registeredUserDetail, method: .post, parameters: requestParams, encoding: JSONEncoding.default, headers: header).responseJSON(completionHandler: {(responseData) -> Void in
            print(responseData.result)
            if let responseValue = responseData.result.value as? [String: AnyObject] {
                print(responseValue)
                if let error = responseValue[WSResponseParams.WS_RESP_PARAM_ERROR] as? [String: AnyObject] {
                    completion(false, error[WSResponseParams.WS_RESP_PARAM_DETAIL] as? String ?? "", [:])
                }
                else {
                    if let data = responseValue[WSResponseParams.WS_RESP_PARAM_DATA] as? [String: AnyObject] {
                        if let status = data[WSResponseParams.WS_RESP_PARAM_STATUS] as? Bool {
                            if status {
                                if let details = data[WSResponseParams.WS_RESP_PARAM_DETAILS] as? [String: AnyObject] {
                                    if let userDetails = details[WSResponseParams.WS_RESP_PARAM_USER] as? [String: AnyObject] {
                                        completion(true, "", userDetails)
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                completion(false, "No parameters found", [:])
            }
        })
    }
    
    // MARK: UPDATE TOKEN
    class func wsCallUpdateToken(_ requestParams: [String: AnyObject]) {
        Alamofire.request(WebService.updateToken, method: .post, parameters: requestParams, encoding: JSONEncoding.default, headers: header).responseJSON(completionHandler: {(responseData) -> Void in
            print(responseData.result)
            if let responseValue = responseData.result.value as? [String: AnyObject] {
                print(responseValue)
            }
        })
    }
    
    // MARK: DELETE USER
    class func wsCallDeleteUser(_ requestParams: [String: AnyObject], completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        Alamofire.request(WebService.deleteUser, method: .post, parameters: requestParams, encoding: JSONEncoding.default, headers: header).responseJSON(completionHandler: {(responseData) -> Void in
            print(responseData.result)
            if let responseValue = responseData.result.value as? [String: AnyObject] {
                print(responseValue)
                if responseValue[WSResponseParams.WS_RESP_PARAM_ERROR] is [String: AnyObject] {
                    completion(false, "")
                }
                else {
                    if let data = responseValue[WSResponseParams.WS_RESP_PARAM_DATA] as? [String: AnyObject] {
                        if let status = data[WSResponseParams.WS_RESP_PARAM_STATUS] as? Bool {
                            if status {
                                completion(true, "")
                            }
                            else {
                                completion(false, "")
                            }
                        }
                    }
                }
            } else {
                completion(false, "No parameters found")
            }
        })
    }
    
    // MARK: CHECK BIOMETRIC STATUS
    class func wsCallCheckBiometricStatus(_ requestParams: [String: AnyObject], completion:@escaping (_ isSuccess: Bool, _ message: String, _ userDetails: [String: AnyObject])->()) {
        Alamofire.request(WebService.checkStatus, method: .post, parameters: requestParams, encoding: JSONEncoding.default, headers: header).responseJSON(completionHandler: {(responseData) -> Void in
            print(responseData.result)
            if let responseValue = responseData.result.value as? [String: AnyObject] {
                print(responseValue)
                if let error = responseValue[WSResponseParams.WS_RESP_PARAM_ERROR] as? [String: AnyObject] {
                    completion(false, error[WSResponseParams.WS_RESP_PARAM_DETAIL] as? String ?? "", [:])
                }
                else {
                    if let data = responseValue[WSResponseParams.WS_RESP_PARAM_DATA] as? [String: AnyObject] {
                        if let status = data[WSResponseParams.WS_RESP_PARAM_STATUS] as? Bool {
                            if status {
                                if let details = data[WSResponseParams.WS_RESP_PARAM_DETAILS] as? [String: AnyObject] {
                                    if let userDetails = details[WSResponseParams.WS_RESP_PARAM_USER] as? [String: AnyObject] {
                                        completion(true, "", userDetails)
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                completion(false, "No parameters found", [:])
            }
        })
    }
    
    // MARK: SET ENROLLMENT STATUS
    class func wsCallSetEnrollment(_ requestParam: [String: AnyObject], completion:@escaping (_ isSuccess: Bool)->()) {
        Alamofire.request(WebService.setEnrollment, method: .post, parameters: requestParam, encoding: JSONEncoding.default, headers: header).responseJSON(completionHandler: {(responseData) -> Void in
            print(responseData.result)
            if let responseValue = responseData.result.value as? [String: AnyObject] {
                if responseValue[WSResponseParams.WS_RESP_PARAM_ERROR] is [String: AnyObject] {
                    completion(false)
                }
                else {
                    if let data = responseValue[WSResponseParams.WS_RESP_PARAM_DATA] as? [String: AnyObject] {
                        if let status = data[WSResponseParams.WS_RESP_PARAM_STATUS] as? Bool {
                            if status {
                                completion(true)
                            }
                            else {
                                completion(false)
                            }
                        }
                    }
                }
            } else {
                completion(false)
            }
        })
    }
}
