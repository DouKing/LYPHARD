//
// SecooLive
// HTTPClient.swift
//
// Created by WuYikai on 2020/4/19.
// Copyright © 2020 Secoo. All rights reserved.
// 

import Foundation
import Alamofire

public typealias Result = Swift.Result
public typealias Response = (_ model: Decodable?, _ error: Error?, _ response: AFDataResponse<Any>) -> Void

public protocol HTTPClient {
    var baseURL: URL { get }
    var defaultHttpHeaders: HTTPHeaders { get }
    var defaultParameters: Parameters { get }
    var parameterEncoding: ParameterEncoding { get }
    
    var validate: ((_ data: Any) -> Result<Any, HTTPError.ResponseError>)? { get }
    var decodePath: String? { get }
    
    @discardableResult
    func request<T: HTTPRequest>(_ http: T, completionHandler: Response?) -> DataRequest
    
    //    @discardableResult
    //    func download() -> DownloadRequest
}

//--------------------------------------------------------------------------------
// MARK: -
//--------------------------------------------------------------------------------

extension HTTPClient {
    var defaultHttpHeaders: HTTPHeaders { return [:] }
    var defaultParameters: Parameters { return [:] }
    var parameterEncoding: ParameterEncoding { return URLEncoding.default }
    var decodePath: String? { return nil }

    var validate: ((_ data: Any) -> Result<Any, HTTPError.ResponseError>)? {
        return { (data) in
            guard let dic = data as? [AnyHashable: Any] else {
                return .failure(.JSONError(""))
            }
            guard let retCode = dic["retCode"],
                let intCode = retCode as? Int, intCode == 0
                else {
                    let msg = dic["retMsg"] as? String
                    return Result.failure(.JSONError(msg ?? ""))
            }
            return Result.success(dic)
        }
    }
    
    @discardableResult
    func request<T: HTTPRequest>(_ http: T, completionHandler: Response? = nil) -> DataRequest {
        var headers: HTTPHeaders = self.defaultHttpHeaders
        var parameters: Parameters = self.defaultParameters
        
        http.headers?.dictionary.forEach({ (key: String, value: String) in
            headers.add(name: key, value: value)
        })
        
        http.parameters?.forEach({ (key: String, value: Any) in
            parameters[key] = value
        })
        
        let baseURL = http.baseURL ?? self.baseURL
        let url = { () -> URL in
            if http.path.isEmpty {
                return baseURL
            }
            return baseURL.appendingPathComponent(http.path)
        }()
        
        let parameterEncoding = http.parameterEncoding ?? self.parameterEncoding
        
        let dataRequest = AF.request(
            url,
            method: http.method,
            parameters: parameters,
            encoding: parameterEncoding,
            headers: headers
        )
        
        let decodePath = http.decodePath ?? self.decodePath
        
        guard let completionHandler = completionHandler else { return dataRequest }
        
        dataRequest.responseJSON { (response: AFDataResponse<Any>) in
            guard let value = response.value, response.error == nil else {
                completionHandler(nil, response.error!, response)
                return
            }
            
            var jsonObject = value
            if let validate = self.validate {
                let result = validate(value)
                switch result {
                case .failure(let error):
                    completionHandler(nil, error, response)
                case .success(let dic):
                    jsonObject = dic
                }
            }
            
            if let decodeKeyPath = decodePath {
                jsonObject = (jsonObject as? NSDictionary)?.value(forKeyPath: decodeKeyPath) ?? [:]
            }
            
            guard JSONSerialization.isValidJSONObject(jsonObject),
                let data = try? JSONSerialization.data(withJSONObject: jsonObject)
                else
            {
                completionHandler(nil, HTTPError.ResponseError.decodeError("解析失败"), response)
                return
            }
            
            if type(of: T.DecodableType.self) == type(of: UnDecode.self) {
                completionHandler(nil, nil, response)
                return
            }
            
            do {
                let model = try JSONDecoder().decode(T.DecodableType.self, from: data)
                completionHandler(model, nil, response)
            } catch {
                completionHandler(nil, HTTPError.ResponseError.decodeError("解析失败"), response)
            }
        }
        
        return dataRequest
    }
}
