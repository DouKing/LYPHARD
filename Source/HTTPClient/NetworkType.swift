//
// Farm
// NetworkType.swift
//
// Created by wuyikai on 2019/8/17.
// Copyright © 2019 wuyikai. All rights reserved.
// 

import CoreTelephony
import Alamofire

public enum NetworkType: Int {
    public typealias RawValue = Int

    case unknown            = 0
    case notReachable       = 1
    case viaWiFi            = 2
    case viaWWAN            = 3
    case via2G              = 4
    case via3G              = 5
    case via4G              = 6

    static var current: NetworkType {
        guard let status = NetworkReachabilityManager()?.status else {
            return .unknown
        }
        switch status {
        case .notReachable: return .notReachable
        case .unknown: return .unknown
        case .reachable(let type):
            switch type {
            case .ethernetOrWiFi: return .viaWiFi
            case .cellular:
                guard let technology = CTTelephonyNetworkInfo().currentRadioAccessTechnology else {
                    return .via4G
                }
                return self.map[technology] ?? .via4G
            }
        }
    }

    static var carrier: String {
        guard let carrier = CTTelephonyNetworkInfo().subscriberCellularProvider,
            carrier.isoCountryCode != nil else {
            return "n/?"
        }
        var country = carrier.mobileCountryCode ?? "n"
        var mobile = carrier.mobileNetworkCode ?? "?"
        if country == "460" {
            country = "中国"
            switch mobile {
            case "00", "02", "07", "08": mobile = "移动"
            case "01", "06", "09": mobile = "联通"
            case "03", "05", "11": mobile = "电信"
            default: break
            }
        }
        return "\(country)/\(mobile)"
    }
}

extension NetworkType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknown:
            return "Unknown"
        case .notReachable:
            return "Unknown"
        case .viaWiFi:
            return "Wifi"
        case .viaWWAN:
            return "WWAN"
        case .via2G:
            return "2G"
        case .via3G:
            return "3G"
        case .via4G:
            return "4G"
        }
    }
}

extension NetworkType {
    private static let map: [String: NetworkType] = [
        CTRadioAccessTechnologyGPRS: .via2G,
        CTRadioAccessTechnologyEdge: .via2G,
        CTRadioAccessTechnologyWCDMA: .via3G,
        CTRadioAccessTechnologyHSDPA: .via3G,
        CTRadioAccessTechnologyHSUPA: .via3G,
        CTRadioAccessTechnologyCDMA1x: .via3G,
        CTRadioAccessTechnologyCDMAEVDORev0: .via3G,
        CTRadioAccessTechnologyCDMAEVDORevA: .via3G,
        CTRadioAccessTechnologyCDMAEVDORevB: .via3G,
        CTRadioAccessTechnologyeHRPD: .via3G,
        CTRadioAccessTechnologyLTE: .via4G
    ]
}
