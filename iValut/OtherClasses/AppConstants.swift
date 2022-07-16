import UIKit
import Foundation

let NOTIFICATION_SUCCESS = "NOTIFICATION_SUCCESS"
let NOTIFICATION_FAILURE = "NOTIFICATION_FAILURE"

// App constants
struct AppConstants {
    static let APP_DELEGATE = UIApplication.shared.delegate as! AppDelegate
    static let PORTRAIT_SCREEN_WIDTH  = UIScreen.main.bounds.size.width
    static let PORTRAIT_SCREEN_HEIGHT = UIScreen.main.bounds.size.height
    static let CURRENT_IOS_VERSION = UIDevice.current.systemVersion
    static let errSomethingWentWrong  = NSError(domain: Alert.ALERT_SOMETHING_WENT_WRONG, code: 0, userInfo: nil)
}

enum FaceID {
    static let appleId = "appleId"
}

struct iValtFonts {
    static let FONT_RUBIK_REGULAR_15 = UIFont.init(name: "Rubik-Regular", size: 15)
}

// Color Constants
struct iVaultColors {
    static let WEBCARD_BLUE                 = UIColor.init(hex: "021633")
    static let WEBCARD_RED                  = UIColor.init(hex: "E83328")
    static let WEBCARD_LIGHT_GRAY           = UIColor.init(hex: "ABB4C2")
}

// Font Constants
struct iVaultFonts {
    static let FONT_LATO_REGULAR_10         = UIFont.init(name: "Lato-Regular", size: 10)
}

struct Strings {
    static let ADD_MORE_URL                 = "0"
    static let WORDPRESS                    = "wordpress"
    static let LOGIN                        = "login"
    static let GLOBAL                       = "global"
    static let HOME                         = "HOME"
    static let LINKED                       = "LINKED"
    static let SELF_TEST                    = "SELF TEST"
    static let PROFILE                      = "PROFILE"
    static let ABOUT                        = "About"
    static let FAQ                          = "FAQ"
    static let SUCCESS                      = "success"
    static let CONTACT_US                   = "Contact Us"
    static let REGISTER                     = "Click here to register"
    static let PHONE_REGISTERED             = "You are registered with iVALT® using phone number"
    static let SUCCESSFULLY_REGISTERED      = "Successfully registered with iVALT®"
    static let FACE_AUTHENTICATION          = "Click here for Face Authentication"
}

struct Alert {
    static let OK                           = "Ok"
    static let ERROR                        = "Error"
    static let FAILED                       = "Authentication failed"
    static let SUCCESS                      = "Success"
    static let ALERT                        = "Alert"
    static let THANK_YOU                    = "Thank You"
    static let CONFIRMATION                 = "Confirmation"
    static let PROPOSAL_SENT                = "Proposal Sent"
    static let CANCEL                       = "Cancel"
    static let DONE                         = "Done"
    static let INFO                         = "Info"
    static let LIVENESS                     = "Liveness Check"
    static let AUTHENTICATE                 = "Authenticate"
    static let ALERT_SOMETHING_WENT_WRONG   = "Whoops, something went wrong. Please refresh and try again."
}
