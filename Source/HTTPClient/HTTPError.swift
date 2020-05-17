//
// SecooLive
// HTTPError.swift
//
// Created by WuYikai on 2020/4/19.
// Copyright © 2020 Secoo. All rights reserved.
// 

import Foundation
import Alamofire

public enum HTTPError: Error {
    public enum ResponseError: Error {
        case JSONError(String)
        case serverError(String)
        case decodeError(String)
    }
    
    case invalidDataRequest(dataRequest: DataRequest)
}
