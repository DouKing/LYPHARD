//
//  LaunchActivityRequest.swift
//  LYPHARD_Example
//
//  Created by DouKing on 2019/9/21.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import LYPHARD

struct LaunchActivityModel: Codable {
    var imgUrl: String
    var redirectUrl: String
}

struct LaunchActivityRequest: Request {
    typealias DecodableType = LaunchActivityModel

    var baseURL: URL {
        return URL(string: "http://10.0.254.184:8080")!
    }

    var path: String {
        return "base/appBanner"
    }
}
