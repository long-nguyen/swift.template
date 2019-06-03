//
//  APIConf.swift
//  Template
//
//  Created by Nguyen Tien LONG on 5/29/19.
//  Copyright © 2019 Active User Co.,LTD. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

let kMessage = "message"
let kError = "error"
let kCode = "code"
let kData = "data"

#if DEBUG
let API_BASE_URL = "http://weather.local/api/"
#else
let API_BASE_URL = ""
#endif
struct APIPath {
    static let config = "config"
    static let other  = "other"
}

fileprivate struct ErrorMessage {
    static let unknown = "err_unknown".localized
    static let invalidParam = "err_invalid".localized
    static let network = "err_network".localized
    static let notfound = "err_notfound".localized
}

fileprivate struct ErrorCode {
    static let unknown = 0
    static let invalidParam = 400
    static let unauthorize = 401
    static let forbidden = 403
    static let notfound = 404
    static let serverError = 500
}

struct APIError {
    var code: Int?
    var message: String?
}

typealias APICompletionHandler = (JSON?, APIError?) -> Void

class APIBase {
    private let validateStatusCode: Int = 300
    private let defaultUnknownError = APIError(code: ErrorCode.unknown, message: ErrorMessage.unknown)
    private let defaultNetworkError = APIError(code: ErrorCode.unknown, message: ErrorMessage.network)

    func executeRequest(_ method: HTTPMethod, _ path: String?, _ params: [String: Any]? = nil, _ headers: [String: String]? = nil, _ completion: APICompletionHandler? = nil) {
        
        //Network
        if NetworkReachabilityManager()?.networkReachabilityStatus == .notReachable {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotiConst.NO_NETWORK), object: nil)
            completion?(nil, defaultNetworkError)
            return
        }
        
        //Header & Encoding
        let preparedHeaders = self.mergeHeaders(headers)
        let encoding: ParameterEncoding = (method == .get ? URLEncoding.default : JSONEncoding.default)
        
        //request
        let request = Alamofire.request(self.buildUrl(path), method: method, parameters: params, encoding: encoding, headers: preparedHeaders)
            .validate()
            .responseJSON {[weak self] (response) in
                switch response.result {
                case .success(let resultData) :
                    self?.processResponse(JSON(resultData), completion: completion)
                case .failure:
                    self?.processNetworkError(response, completion: completion)
                }
        }
        #if DEBUG
        debugPrint(request)
        #endif
    }
    
    
    private func mergeHeaders(_ headers: [String:String]?) -> [String:String] {
        var returnHeaders: [String: String] = ["Content-Type": "application/json", "Accept": "application/json"]
         //Add token if needed
        //headers["X-AuthToken"] = UserInfo.shared.accessToken
        if let addHeaders = headers {
            addHeaders.forEach({ (key, value) in
                returnHeaders[key] = value
            })
        }
        return returnHeaders
    }
    
    /*
     This function process succees response, with format
     {
     "data":{...}
     }
     or
     {
     "error":{..}
     }
     */
    private func processResponse(_ data: JSON, completion: APICompletionHandler?) {
        if data[kError].exists() {
            self.processErrorResponse(data[kError], completion: completion)
        } else if data[kData].exists() {
            completion?(data[kData], nil)
        } else {
            completion?(nil, defaultUnknownError)
        }
    }
    
    /*
     This function is used to process server returned error code(status code = 200)
     Return localized errorr message
     */
    private func processErrorResponse(_ error: JSON, completion: APICompletionHandler?) {
        var msg = error[kMessage].string
        let errCode = error[kCode].int
        switch errCode {
        case 999:
            msg = "A special error"
        default:
            break
        }
        completion?(nil, APIError(code: errCode ?? ErrorCode.unknown,  message: msg ?? ErrorMessage.unknown))
    }
    
    /*
     This function is used to process network error(status code != 200)
     If the system can not return localized error message, this function will convert to localized message
    */
    private func processNetworkError(_ response: DataResponse<Any>, completion: APICompletionHandler?) {
        var errorMessage = ErrorMessage.unknown
        if let data = response.data {
            if let responseJSON = try? JSON(data: data) {
                errorMessage = responseJSON["error"]["message"].stringValue
            }
        }
        
        let code = response.response?.statusCode
        
        switch code {
        case ErrorCode.invalidParam:
            errorMessage = ErrorMessage.invalidParam
        case ErrorCode.notfound:
            errorMessage = ErrorMessage.network
        default:
            break
        }
        completion?(nil, APIError(code: code, message: errorMessage))
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
