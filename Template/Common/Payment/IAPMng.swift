//
//  StoreManager.swift
//  Template
//
//  Created by Nguyen Tien LONG on 5/28/19.
//  Copyright © 2019 Active User Co.,LTD. All rights reserved.
//

import Foundation
import StoreKit

let STORE_LOADED_EVENT = "co.au.WeatherAssistantWidget.storeLoadedEvent";
let PURCHASE_CANCELLED_EVENT = "cancelled"

struct ProductIds {
    static let PRO_VERSION = "co.au.sample.proversion"
    static let PURCHASE1 = "co.au.sample.purchase1"
}

typealias RequestProductsCompletionHandler = (Bool, [String: SKProduct]?) -> Void
typealias PurchaseCompletionHandler = (Bool, Any?, String?) -> Void

class IAPMng:NSObject {
    
    static let instance = IAPMng()
    var _products: [String: SKProduct] = [:]
    var _requestProductCompletion:RequestProductsCompletionHandler?
    var _purchaseCompletion:PurchaseCompletionHandler?

    private override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    func canMakePayment() ->Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    func fetchProducts(completion: RequestProductsCompletionHandler?) {
        _requestProductCompletion = completion
        let productIdentifiers = Set([ProductIds.PRO_VERSION, ProductIds.PURCHASE1])
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
    }
    
    func buyProduct(productId: String, completion: PurchaseCompletionHandler?) {
        if !self.canMakePayment() {
            completion?(false, nil, LSTR("err_purchase"))
        }
        _purchaseCompletion = completion
        LOG("Buying \(productId)")
        if let product = _products[productId] {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        } else {
            _purchaseCompletion?(false, nil, LSTR("err_product_not_avai"))
        }
    }
    
    func restore(completion:PurchaseCompletionHandler?) {
        _purchaseCompletion = completion
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
}

extension IAPMng: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        LOG("Loaded list of products...")
        _requestProductCompletion = nil
        _products.removeAll()
        response.products.forEach { product in
            LOG("Found product: \(product)")
            _products[product.productIdentifier] = product
        }
        _requestProductCompletion?(true, _products)
        _requestProductCompletion = nil
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        LOG("Error for request: \(error.localizedDescription)")
        _requestProductCompletion?(false, nil)
        _requestProductCompletion = nil
    }
    
}

extension IAPMng: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .failed:
                self.onFailedTransaction(transaction)
            case .purchased, .restored:
                self.onCompleteTransaction(transaction)
            case .deferred, .purchasing:
                LOG("Transaction in progress: \(transaction)")
            default:
                break
            }
            
        }
    }
    
    func checkTransaction(_ transaction: SKPaymentTransaction) {
        
        
        let receiptFileURL = Bundle.main.appStoreReceiptURL
        let receiptData = try? Data(contentsOf: receiptFileURL!)
        let receiptString = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        let jsonDict: [String: AnyObject] = ["receipt-data" : receiptString! as AnyObject, "password" : "ee70188badc24b1fa8c78f1ddb4cbb3a" as AnyObject]
        
        self.validateReceipt(receiptJson: jsonDict) { result in
            //TODO
        }

    }
    
    func validateReceipt(receiptJson: [String: AnyObject], completion: @escaping (Bool) -> Void) {
        #if DEBUG
        let verifyURL = "https://sandbox.itunes.apple.com/verifyReceipt"
        #else
        let verifyURL = "https://buy.itunes.apple.com/verifyReceipt"
        #endif
        do {
            let requestData = try JSONSerialization.data(withJSONObject: receiptJson, options: JSONSerialization.WritingOptions.prettyPrinted)
            let storeURL = URL(string: verifyURL)!
            var storeRequest = URLRequest(url: storeURL)
            storeRequest.httpMethod = "POST"
            storeRequest.httpBody = requestData
            
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let task = session.dataTask(with: storeRequest, completionHandler: { [weak self] (data, response, error) in
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                    print("=======>",jsonResponse)
                    if let date = self?.getExpirationDateFromResponse(jsonResponse as! NSDictionary) {
                        print(date)
                    }
                } catch let parseError {
                    print(parseError)
                }
            })
            task.resume()
        } catch let parseError {
            print(parseError)
        }
    }
    
    //Used for subscription
    func getExpirationDateFromResponse(_ jsonResponse: NSDictionary) -> Date? {
        if let receiptInfo: NSArray = jsonResponse["latest_receipt_info"] as? NSArray {
            let lastReceipt = receiptInfo.lastObject as! NSDictionary
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
            if let expiresDate = lastReceipt["expires_date"] as? String {
                return formatter.date(from: expiresDate)
            }
            
            return nil
        }
        else {
            return nil
        }
    }
    
    func onCompleteTransaction(_ transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
        self.checkTransaction(transaction)
    }
    
    func onFailedTransaction(_ transaction: SKPaymentTransaction) {
        if transaction.error?.code == SKError.paymentCancelled.rawValue {
            _purchaseCompletion?(false, nil, LSTR("err_payment_cancelled"))
        } else {
            _purchaseCompletion?(false, nil, transaction.error?.localizedDescription)
        }

        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    func onRestoreTransaction(_ transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
        self.checkTransaction(transaction)
    }
    
}
