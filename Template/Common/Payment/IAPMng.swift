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

class IAPMng: NSObject {
    
    static let instance = IAPMng()
    var _products: [String: SKProduct] = [:]
    var _requestProductCompletion: RequestProductsCompletionHandler?
    var _purchaseCompletion: PurchaseCompletionHandler?

    private override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    //MARK: common functions ------------------------------------------

    func fetchProducts(completion: RequestProductsCompletionHandler?) {
        _requestProductCompletion = completion
        let productIdentifiers = Set([ProductIds.PRO_VERSION, ProductIds.PURCHASE1])
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
    }
    
    func buyProduct(productId: String, completion: PurchaseCompletionHandler?) {
        if !SKPaymentQueue.canMakePayments() {
            completion?(false, nil, "err_purchase".localized)
        }
        _purchaseCompletion = completion
        LOG("Buying \(productId)")
        if let product = _products[productId] {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        } else {
            _purchaseCompletion?(false, nil, "err_product_not_avai".localized)
        }
    }
    
    //Attention: This function is only to restore non-consumable & auto-reneweable subscription. For other restore, you should use a server or icloud to store user's purchase data
    func restore(completion:PurchaseCompletionHandler?) {
        _purchaseCompletion = completion
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    
    //MARK: Process observer result ------------------------------------------
    fileprivate func failedTransaction(_ transaction: SKPaymentTransaction) {
        if (transaction.error as? SKError)?.code == .paymentCancelled {
            self._purchaseCompletion?(false, nil, "err_payment_cancelled".localized)
        } else {
            self._purchaseCompletion?(false, nil, transaction.error?.localizedDescription)
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    fileprivate func successTransaction(_ transaction: SKPaymentTransaction) {
        self.validateReceipt() { result, data, errMessage in
            if result {
                //Do some action, like getting purchase date, time, expire date..
                //transaction.payment.productIdentifier
                self._purchaseCompletion?(true, data, errMessage)
                SKPaymentQueue.default().finishTransaction(transaction)
            } else {
                self._purchaseCompletion?(false, nil, "error_validate_purchase".localized)
            }
        }
    }
    
    fileprivate func restoredTransaction(_ transaction: SKPaymentTransaction) {
        
    }
    
    fileprivate func validateReceipt(completion: @escaping (Bool, Any?, String?) -> Void) {
        guard let receiptFileURL = Bundle.main.appStoreReceiptURL else {
            completion(false, nil, "error_system".localized)
            return
        }
        do {
            let receiptData = try Data(contentsOf: receiptFileURL)
            let receiptString = receiptData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            let requestContent = ["receipt-data" : receiptString]
            let requestData = try JSONSerialization.data(withJSONObject: requestContent, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            #if DEBUG
            let verifyURL = "https://sandbox.itunes.apple.com/verifyReceipt"
            #else
            let verifyURL = "https://buy.itunes.apple.com/verifyReceipt"
            #endif
            
            let storeURL = URL(string: verifyURL)!
            var storeRequest = URLRequest(url: storeURL)
            storeRequest.httpMethod = "POST"
            storeRequest.httpBody = requestData
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let task = session.dataTask(with: storeRequest, completionHandler: { data, response, error in
                if let err = error {
                    completion(false, nil, err.localizedDescription)
                } else {
                    do {
                        let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                        let status = jsonResponse["status"] as! Int
                        if (status == 0) {
                            completion(true, nil, nil)
                        } else {
                            completion(false, nil, nil)
                        }
                    } catch let parseError {
                        completion(false, nil, parseError.localizedDescription)
                    }
                }
            })
            task.resume()
        } catch let parseError {
            LOG(parseError)
            completion(false, nil, parseError.localizedDescription)
        }
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
                self.failedTransaction(transaction)
            case .purchased:
                self.successTransaction(transaction)
            case .restored:
                self.restoredTransaction(transaction)
            case .deferred, .purchasing:
                LOG("Transaction in progress: \(transaction)")
            default:
                break
            }
        }
    }
    
    /// Logs all transactions that have been removed from the payment queue.
    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            LOG("\(transaction.payment.productIdentifier) Removed")
        }
    }
    
    /// Called when an error occur while restoring purchases. Notify the user about the error.
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        if let error = error as? SKError, error.code != .paymentCancelled {
            //TODO
            LOG("Error while restoreing, send message")
        }
    }
    
    /// Called when all restorable transactions have been processed by the payment queue.
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        //TODO: Restored
        LOG("Restore Processed")
    }
}

extension SKProduct {
    /// - returns: The cost of the product formatted in the local currency.
    var regularPrice: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price)
    }
}

