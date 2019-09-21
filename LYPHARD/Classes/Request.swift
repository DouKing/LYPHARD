import Foundation
import Alamofire

public enum RequestError: Error {
    case networkError(String)
    case JSONError(String)
    case serverError(String)
}

public typealias Response<T> = (
    _ success: Bool,
    _ error: RequestError?,
    _ json: Any?,
    _ model: T?,
    _ response: DataResponse<Any>
) -> Void

public protocol Request {
    associatedtype DecodableType: Decodable

    var baseURL: URL { get }
    var path: String { get }
    var method: Alamofire.HTTPMethod { get }
    var parameters: Alamofire.Parameters? { get }
    var parameterEncoding: Alamofire.ParameterEncoding { get }
    var headers: [String: String]? { get }
    var acceptableContentTypes: [String]? { get }
    var defaultRequestErrorMessage: String { get }

    var decodPath: String? { get }
    var usingJSONDecoder: JSONDecoder { get }
    var validate: ((_ data: Any) -> Swift.Result<[AnyHashable: Any], RequestError>)? { get }

    @discardableResult
    func start(callback: @escaping Response<DecodableType>) -> DataRequest
}

public struct NoDecodableType: Decodable {}

public extension Request {
    var method: Alamofire.HTTPMethod {
        return .get
    }

    var parameters: Parameters? {
        return nil
    }

    var parameterEncoding: Alamofire.ParameterEncoding {
        return URLEncoding.default
    }

    var usingJSONDecoder: JSONDecoder {
        return JSONDecoder()
    }

    var url: URL {
        return self.path.isEmpty ? self.baseURL : self.baseURL.appendingPathComponent(self.path)
    }

    @discardableResult
    func start(callback: @escaping Response<DecodableType>) -> DataRequest {
        return Alamofire.request(
                self.url,
                method: self.method,
                parameters: self.parameters,
                encoding: self.parameterEncoding,
                headers: self.headers
            ).responseJSON { (response: DataResponse<Any>) in
                guard let json = response.value else {
                    //没有值，失败
                    callback(false, .networkError(self.defaultRequestErrorMessage), nil, nil, response)
                    return
                }

                debugPrint(self.url)
                debugPrint(self.parameters ?? "")

                var jsonObject: Any? = json
                if let validate = self.validate {
                    let result: Swift.Result<[AnyHashable: Any], RequestError> = validate(json)
                    switch result {
                    case let .success(value):
                        //获取验证后数据
                        jsonObject = value
                    case let .failure(error):
                        debugPrint(error)
                        //接口返回数据不正确，失败
                        callback(false, error, nil, nil, response)
                        return
                    }
                }

                if let keyPath = self.decodPath {
                    jsonObject = (jsonObject as? NSDictionary)?.value(forKeyPath: keyPath)
                }

                guard jsonObject != nil,
                    JSONSerialization.isValidJSONObject(jsonObject!),
                    let data = try? JSONSerialization.data(withJSONObject: jsonObject!) else {
                        callback(false, .JSONError(self.defaultRequestErrorMessage), jsonObject, nil, response)
                    return
                }

                debugPrint(jsonObject!)

                if let model = try? self.usingJSONDecoder.decode(DecodableType.self, from: data) {
                    callback(true, nil, jsonObject, model, response)
                } else {
                    callback(true, nil, jsonObject, nil, response)
                }
        }
    }
}

public extension Request {
    var validate: ((_ data: Any) -> Swift.Result<[AnyHashable: Any], RequestError>)? {
        return { data in
            guard let dic = data as? [AnyHashable: Any] else {
                return .failure(.JSONError(self.defaultRequestErrorMessage))
            }
            guard let retCode = dic["code"],
                let intCode = retCode as? Int,
                intCode == 0 else {
                    let msg = dic["msg"] as? String
                    return Swift.Result.failure(.JSONError(msg ?? self.defaultRequestErrorMessage))
            }

            return Swift.Result.success(dic)
        }
    }

    var decodPath: String? {
        return "data"
    }

    var defaultRequestErrorMessage: String {
        return "网络请求失败"
    }

    var acceptableContentTypes: [String]? {
        return ["application/json", "text/json", "text/javascript", "text/plain", "text/html"]
    }

    var headers: [String: String]? {
        var header = [
            "Content-type": "application/json",
            "Accept-Encoding": "gzip"
        ]
        if let acceptContentTypes = self.acceptableContentTypes {
            header["Accept"] = acceptContentTypes.joined(separator: ",")
        }
        return header
    }
}
