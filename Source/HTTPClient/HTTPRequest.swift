import Foundation
import Alamofire

public typealias HTTPMethod = Alamofire.HTTPMethod
public typealias Parameters = Alamofire.Parameters
public typealias ParameterEncoding = Alamofire.ParameterEncoding
public typealias HTTPHeaders = Alamofire.HTTPHeaders

public struct UnDecode: Decodable {}

public protocol HTTPRequest {
    var baseURL: URL? { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
    var parameterEncoding: ParameterEncoding? { get }
    var headers: HTTPHeaders? { get }
    
    associatedtype DecodableType: Decodable
    var decodePath: String? { get }
}

public extension HTTPRequest {
    var baseURL: URL? { return nil }
    var method: HTTPMethod { return .get }
    var parameters: Parameters? { return nil }
    var parameterEncoding: ParameterEncoding? { return nil }
    var headers: HTTPHeaders? { return nil }
    var decodePath: String? { return nil }
}
