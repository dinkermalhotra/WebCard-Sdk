import Foundation

class CheckBiometricStatus: NSObject {
    @objc static func checkStatus(_ supplierId: String, completion:@escaping (_ isSuccess: Bool, _ message: String, _ userDetails: [[String: AnyObject]])->()) {
        do {
            let deviceId = try KeychainWrapper.init().getDeviceId()
            
            let params: [String: AnyObject] = [WSRequestParams.WS_REQS_PARAM_IMEI: deviceId as AnyObject,
                                               WSRequestParams.WS_REQS_PARAM_SUPPLIER_ID: supplierId as AnyObject]
            WSManager.wsCallCheckBiometricStatus(params) { isSuccess, message, userDetails in
                completion(isSuccess, message, userDetails)
            }
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
}
