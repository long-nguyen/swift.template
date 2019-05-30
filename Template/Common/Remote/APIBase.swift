//
//  APIConf.swift
//  Template
//
//  Created by Nguyen Tien LONG on 5/29/19.
//  Copyright © 2019 Active User Co.,LTD. All rights reserved.
//

import Foundation
import Alamofire

let kMessage = "message"
let kError = "error"
let kCode = "code"
let kData = "data"

#if DEBUG
let API_BASE_URL = "https://weatherapp.activeuser.co/v1/api/"
#else
let API_BASE_URL = ""
#endif

struct ErrorMessage {
    static let unknown = LSTR("err_unknown")
    static let invalidParam = LSTR("err_invalid")
}

struct ErrorCode {
    static let unknown = 0
    static let invalidParam = 400
    static let unauthorize = 401
    static let forbidden = 403
    static let notfound = 404
    static let serverError = 500
}

struct APIPath {
    static let config = "config"
    static let other  = "other"
}

typealias APICompletionHandler = ([String: Any]?, NSError?) -> Void

class APIBase {
    private let validateStatusCode: Int = 300
    private let defaultUnknownError = NSError(domain: NSURLErrorDomain, code: ErrorCode.unknown, userInfo: [kMessage:ErrorMessage.unknown])

    func executeRequest(_ method: HTTPMethod, _ path: String?, _ params: [String: Any]? = nil, _ headers: [String: String]? = nil, _ completion: APICompletionHandler? = nil) {
        
        let encoding: ParameterEncoding = (method == .get ? URLEncoding.default : JSONEncoding.default)
        
        let request = Alamofire.request(self.buildUrl(path), method: method, parameters: params, encoding: encoding, headers: headers)
            .validate()
            .responseJSON { (response) in
                switch response.result {
                case .success(let resultData) :
                    self.processResponse(data: resultData, completion: completion)
                case .failure(let error):
                    self.processNetworkError(error: error, completion: completion)
                }
        }
        #if DEBUG
        debugPrint(request)
        #endif
    }
    
    private func processResponse(data: Any, completion: APICompletionHandler?) {
        if let dictionary = data as? [String:Any] {
            if let dataObj = dictionary[kData] as? [String: Any]{
                completion?(dataObj, nil)
            } else if let errObj = dictionary[kError] as? [String: Any]{
                self.processErrorResponse(error: errObj, completion: completion)
            } else {
                completion?(nil, defaultUnknownError)
            }
        }
    }
    
    private func processErrorResponse(error: [String:Any], completion: APICompletionHandler?) {
        var msg = error[kMessage] as? String
        let errCode = error[kCode] as? Int
        switch errCode {
        case 999:
            msg = "A special error"
        default:
            break
        }
        completion?(nil, NSError(domain: NSURLErrorDomain, code: errCode ?? ErrorCode.unknown, userInfo: [kMessage: msg ?? ErrorMessage.unknown]))
    }
    
    private func processNetworkError(error: Error, completion: APICompletionHandler?) {
        guard let mError = error as NSError? else {
            completion?(nil, defaultUnknownError)
        }
        let code = mError.code
        var message = mError.localizedDescription
        switch code {
        case ErrorCode.invalidParam:
            message = ErrorMessage.invalidParam
        default:
            message = ErrorMessage.unknown
        }
        completion?(nil, NSError(domain: NSURLErrorDomain, code: code, userInfo: [kMessage: message]))
    }
    
    private func buildUrl(_ path:String?) ->String {
        if let p = path {
            guard !p.lowercased().hasPrefix("http://"), !p.lowercased().hasPrefix("https://") else {
                return p
            }
            
            if let url = URL(string: API_BASE_URL)?.appendingPathComponent(p) {
                return url.absoluteString
            } else {
                return API_BASE_URL + "/" + p
            }
        }
        return API_BASE_URL
    }
}

extension Error {
    var nsError: NSError { return self as NSError }
    
    var domain: String { return nsError.domain }
    var code: Int { return nsError.code }
    var userInfo: [String: Any] { return nsError.userInfo }
    
    var isUnauthorizedError: Bool { return self.code == ErrorCode.unauthorize }
    var isForbidden: Bool { return self.code == ErrorCode.forbidden }
    var isNotFound: Bool { return  self.code == ErrorCode.notfound }
    var isForbiddenOrNotFound: Bool { return self.isForbidden || self.isNotFound }
}
