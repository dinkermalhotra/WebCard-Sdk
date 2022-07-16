import Foundation

class DeleteUser: NSObject {
    @objc static func deleteUser(_ supplierId: String, completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        let params: [String: AnyObject] = [WSRequestParams.WS_REQS_PARAM_SUPPLIER_ID: supplierId as AnyObject]
        WSManager.wsCallDeleteUser(params) { isSuccess, message in
            completion(isSuccess, message)
        }
    }
}
