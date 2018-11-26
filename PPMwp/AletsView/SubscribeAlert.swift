import UIKit
import GTProgressBar

class SubscribeAlert: UIViewController {
    
    @IBOutlet weak var alertView: UIView!
    
    @IBOutlet weak var subscribeBut: UIButton!
    
    @IBOutlet weak var cancelBut: UIButton!
    
    var progressBar = GTProgressBar()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    @IBAction func subscribeButTaped(_ sender: Any) {
        if Reachability.isConnectedToNetwork() {
            Store.shared.purachaseProduct()
            print("a")
        }
        
        
        self.removeFromParent()
        self.view.removeFromSuperview()
    }
    
    @IBAction func cancelButTapped(_ sender: Any) {
        
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: LoginVC.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
        
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
