//
//  Global.swift
//  dancontrol
//
//  Created by Ertuğrul Üngör on 15.12.2017.
//  Copyright © 2017 Dancontrol. All rights reserved.
//

class Global {
    static let baseUrl = "http://192.168.207.23/shopbackend/"
    static let imageUrl = "http://192.168.207.23/shopbackend/"
//    static let baseUrl = "http://the-work-kw.com/shopbackend/"
//    static let imageUrl = "http://the-work-kw.com/shopbackend/"
    static let languageSet = ["En", "Fr", "Ch"]
    static func validateImg(signString:String?,max:Int) -> Int {
        var temp = 0
        if signString != "" && signString != nil {
            temp = Int(signString!)!
        }
        if temp < 0 || temp > max {
            temp = 0
        }
        return temp	
    }
}
