import UIKit
import GTProgressBar
import SwiftyStoreKit

class SubscribeAlert: UIViewController {
    
    @IBOutlet weak var alertView: UIView!
    
    @IBOutlet weak var subscribeBut: UIButton!
    
    @IBOutlet weak var cancelBut: UIButton!
    
    @IBOutlet weak var restoreProd: UIButton!
    
    var progressBar = GTProgressBar()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        restoreProd.layer.cornerRadius = 5
        alertView.layer.cornerRadius = 15
        subscribeBut.layer.cornerRadius = 5
        cancelBut.layer.cornerRadius = 5
        cancelBut.layer.borderWidth = 1
        cancelBut.layer.borderColor = UIColor(displayP3Red: 175/255, green: 187/255, blue: 201/255, alpha: 1).cgColor
    }
    
    override func viewWillLayoutSubviews() {
        if appDelegate.closeCheckData == true {
            self.removeFromParent()
            self.view.removeFromSuperview()
        }
    }
    
    func showSub(nameVC: String) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: nameVC)
        
        vc?.view.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
        self.addChild(vc!)
        self.view.addSubview((vc?.view)!)
    }
    
    
    @IBAction func resoreTap(_ sender: Any) {
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
                NotificationCenter.default.post(name: NSNotification.Name("Restore1"), object: nil)
            }
            else if results.restoredPurchases.count > 0 {
                print("Restore Success: \(results.restoredPurchases)")
                NotificationCenter.default.post(name: NSNotification.Name("Restore2"), object: nil)
            }
            else {
                print("Nothing to Restore")
                NotificationCenter.default.post(name: NSNotification.Name("Restore3"), object: nil)
            }
        }
    }
    
    @IBAction func subscribeButTaped(_ sender: Any) {
        if Reachability.isConnectedToNetwork() {
            Store.shared.purachaseProduct()
        }
        
        self.removeFromParent()
        self.view.removeFromSuperview()
    }
    
    @IBAction func cancelButTapped(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        
        let user = User(name: "_", password: "_", favor: "_", id: 0, subs: "_", disclaimer: "_")
        self.appDelegate.currentUser = user
        self.appDelegate.favourites.removeAll()
        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: self.appDelegate.currentUser)
        UserDefaults.standard.set(encodedData, forKey: "currentUser")
        UserDefaults.standard.synchronize()
        UserDefaults.standard.setValue(false, forKey: "saved2")
        
        self.removeFromParent()
        self.view.removeFromSuperview()
    }
    
    
}
