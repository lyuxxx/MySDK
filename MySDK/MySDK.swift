//
//  MySDK.swift
//  MySDK
//
//  Created by yxliu on 2019/1/7.
//  Copyright © 2019 cusc. All rights reserved.
//

import Foundation
import Alamofire

public class MySDK {
    public class func logToConsole(msg: String) {
        print(msg)
        Alamofire.request("www.baidu.com").responseJSON { (resonse) in
            print("\(resonse)")
        }
    }
}
