import Foundation
import UIKit
import StoreKit

class IAPService: NSObject {
    
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    private override init() { }
    static let shared = IAPService()
    
    var state: String!
    var products = [SKProduct]()
    let paymentQueue = SKPaymentQueue.default()
    
    func getProducts() {
        let products: Set = [IAPProd.autoRenewingSubs.rawValue]
        let request = SKProductsRequest(productIdentifiers: products)
        request.delegate = self as SKProductsRequestDelegate
        request.start()
        paymentQueue.add(self)
    }
    
    func purchase(product: IAPProd) {
        guard let productToPurchase = products.filter({ $0.productIdentifier == product.rawValue }).first else { return }
        let payment = SKPayment(product: productToPurchase)
        paymentQueue.add(payment)
    }
    
    
    func restorePurchase() {
        print("restore purachases")
        paymentQueue.restoreCompletedTransactions()
    }
}

extension IAPService: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
        for product in response.products {
            print("product.localizedTitle is \(product.localizedTitle)")
        }
    }
}

extension IAPService: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("bbb")
        for transaction in transactions {
            print(transaction.transactionState.status())
            print(transaction.payment.productIdentifier)
            switch transaction.transactionState {
            case .purchasing:
                state = "purchasing"
                print("pur222")
                break
            case .restored:
                state = "restored"
                print("restored free acc")
                queue.finishTransaction(transaction)
            case .purchased:
                appDelegate.subscribtion = true
                state = "purchased"
                print("purchased free acc")
                if appDelegate.closeCheckData == false {
                    NotificationCenter.default.post(name: NSNotification.Name("Check"), object: nil)
                }
                let parameters = ["first_name" : "+"]
                Functions.shared.requestChangeParam(parameters: parameters)
               
            default:
                print("error restored")
                state = "error"
                queue.finishTransaction(transaction)
            }
        }
        UserDefaults.standard.set(appDelegate.subscribtion, forKey: "subscribe2")
    }
    
    func restored() {
        print("restored buy")
        paymentQueue.restoreCompletedTransactions()
    }
}

extension SKPaymentTransactionState {
    
    func status() -> String {
        switch self {
        case .deferred: return "deferred"
        case .failed: return "failed"
        case .purchased: return "purchased"
        case .purchasing: return "purchasing"
        case .restored: return  "restored"
        }
    }
}
