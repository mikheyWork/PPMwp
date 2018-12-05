import Foundation
import SwiftyStoreKit



class Store: NSObject {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    private override init() { }
    static let shared = Store()
    
    let inAppPurchase = "mikhey.PPM.Genius3.Subscription"
    let secret = "523764ba89824292bc45e96ae17f1137"
    var state = ""
    
    func retrieveInfo() {
        SwiftyStoreKit.retrieveProductsInfo([inAppPurchase]) { result in
            if let product = result.retrievedProducts.first {
                let priceString = product.localizedPrice!
                print("Product: \(product.localizedDescription), price: \(priceString)")
            }
            else if let invalidProductId = result.invalidProductIDs.first {
                print("Invalid product identifier: \(invalidProductId)")
            }
            else {
                print("Error: \(result.error!)")
            }
        }
    }
    
    func checkSub() {
        
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: secret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                // Verify the purchase of a Subscription
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable, // or .nonRenewing (see below)
                    productId: self.inAppPurchase,
                    inReceipt: receipt)
                switch purchaseResult {
                case .purchased(let expiryDate, let items):
                    self.appDelegate.subscribtion = true
                    DispatchQueue.main.async {
                        print("subso purchased is \(self.appDelegate.subscribtion)")
                        if self.appDelegate.closeCheckData == false {
                            NotificationCenter.default.post(name: NSNotification.Name("Check"), object: nil)
                        }
                    }
                    
                    print("\(self.inAppPurchase) is valid until \(expiryDate)\n\(items)\n")
                case .expired(let expiryDate, let items):
                    //change
                    self.appDelegate.subscribtion = false
                                        DispatchQueue.main.async {
                                            print("subso purchased is \(self.appDelegate.subscribtion)")
                                            if self.appDelegate.closeCheckData == false {
                                                NotificationCenter.default.post(name: NSNotification.Name("Check"), object: nil)
                                            }
                                        }
                    print("\(self.inAppPurchase) is valid until \(expiryDate)\n\(items) is expired since \(expiryDate)\n\(items)\n")
                case .notPurchased:
                    self.appDelegate.subscribtion = false
                    print("The user has never purchased \(self.inAppPurchase)")
                }
                
            case .error(let error):
                self.appDelegate.subscribtion = false
                print("Receipt verification failed: \(error.localizedDescription)")
            }
           
            print("subs99 is \(self.appDelegate.subscribtion)")
            UserDefaults.standard.set(self.appDelegate.subscribtion, forKey: "subscribe2")
            NotificationCenter.default.post(name: NSNotification.Name("CheckSub"), object: nil)
                if self.appDelegate.currentUser != nil {
                if self.appDelegate.currentUser.id != 0 {
                    if self.appDelegate.subscribtion == true {
                        let parameters = ["first_name" : "+"]
                        Functions.shared.requestChangeParam(parameters: parameters)
                    } else {
                        let parameters2 = ["first_name" : "-"]
                        Functions.shared.requestChangeParam(parameters: parameters2)
                    }
                }
            }
        }
    }
    
    func purachaseProduct() {
        NotificationCenter.default.post(name: NSNotification.Name("ShowBlock"), object: nil)
        SwiftyStoreKit.retrieveProductsInfo([inAppPurchase]) { result in
            if let product = result.retrievedProducts.first {
                SwiftyStoreKit.purchaseProduct(product, quantity: 1, atomically: true) { result in
                    switch result {
                    case .success(let purchase):
                        NotificationCenter.default.post(name: NSNotification.Name("HideBlock"), object: nil)
                        print("Purchase Success: \(purchase.productId)")
                        self.appDelegate.subscribtion = true
                        print("purchased free acc")
                                        if self.appDelegate.closeCheckData == false {
                                            print("app buy")
                                            NotificationCenter.default.post(name: NSNotification.Name("CheckSub"), object: nil)
                                        }
                                        let parameters = ["first_name" : "+"]
                                    Functions.shared.requestChangeParam(parameters: parameters)
                    case .error(let error):
                        NotificationCenter.default.post(name: NSNotification.Name("HideBlock"), object: nil)
                        switch error.code {
                        case .unknown: print("Unknown error. Please contact support")
                        case .clientInvalid: print("Not allowed to make the payment")
                        case .paymentCancelled: break
                        case .paymentInvalid: print("The purchase identifier was invalid")
                        case .paymentNotAllowed: print("The device is not allowed to make the payment")
                        case .storeProductNotAvailable: print("The product is not available in the current storefront")
                        case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                        case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                        case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                        default: print((error as NSError).localizedDescription)
                        }
                    }
                }
            }
        }
    }
}
