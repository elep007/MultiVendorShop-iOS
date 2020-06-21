import Foundation

struct Defaults {
    static let USERID_KEY = "USERID_ARRAY"
    static let USERNAME_KEY = "USERNAME_ARRAY"
    static let USERPASSWORD_KEY = "USERPASSWORD_ARRAY"
    static let USEREMAIL_KEY = "USEREMAIL_ARRAY"
    static let USERMOBILE_KEY = "USERMOBILE_ARRAY"
    
    static let LOCATION_KEY = "LOCATION_ARRAY"
    static let ADDRESS_KEY = "ADDRESS_KEY"
    
    
    static let PRODUCTID_KEY = "PRODUCTID_ARRAY"
    static let PRODUCTSHOPID_KEY = "PRODUCTSHOPID_ARRAY"
    static let PRODUCTNAME_KEY = "PRODUCTNAME_ARRAY"
    static let PRODUCTPRICE_KEY = "PRODUCTPRICE_ARRAY"
    static let PRODUCTIMAGE_KEY = "PRODUCTIMAGE_ARRAY"
    static let PRODUCTFAV_KEY = "PRODUCTFAV_ARRAY"
    static let PRODUCTDES_KEY = "PRODUCTDES_ARRAY"
    
    static let SHOPID_KEY = "SHOPID_ARRAY"
    static let SHOPNAME_KEY = "SHOPNAME_ARRAY"
    static let SHOPEMAIL_KEY = "SHOPEMAIL_ARRAY"
    static let SHOPMOBILE_KEY = "SHOPMOBILE_ARRAY"
    static let SHOPADDRESS_KEY = "SHOPADDRESS_ARRAY"
    static let SHOPLOCATION_KEY = "SHOPLOCATION_ARRAY"
    static let SHOPIMG_KEY = "SHOPIMG_ARRAY"
    static let SHOPFAV_KEY = "SHOPFAV_ARRAY"
    
    static func save(_ value: String, with key: String){
        UserDefaults.standard.set(value, forKey: key)
    }
    
    static func getNameAndValue(_ key: String)-> String {
        return (UserDefaults.standard.value(forKey: key) as? String) ?? ""
    }
    static func clearUserData(_ key: String){
        UserDefaults.standard.removeObject(forKey: key)
    }
}
