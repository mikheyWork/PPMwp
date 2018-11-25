import UIKit
import GTProgressBar
import Alamofire
import SwiftyJSON

class DiscAlert: UIViewController {
    
    
    @IBOutlet weak var subscribeBut: UIButton!
    
    @IBOutlet weak var cancelBut: UIButton!
    
    @IBOutlet weak var textView: UITextView!
    
    var progressBar = GTProgressBar()
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var showSbuscr = false {
        didSet {
            if appDelegate.subscribtion == false {
                showSub(nameVC: "SubscribeAlert")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        subscribeBut.layer.cornerRadius = 5
    }
    
    func showSub(nameVC: String) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: nameVC)
        
        vc?.view.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
        self.addChild(vc!)
        self.view.addSubview((vc?.view)!)
    }
    
    
    @IBAction func subscribeButTaped(_ sender: Any) {
        appDelegate.showDisc = true
        
        let parameters = ["last_name" : "+"]

        Functions.shared.requestChangeParam(parameters: parameters)
        
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
        if Reachability.isConnectedToNetwork() {
            self.appDelegate.favourites.removeAll()
        }
        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: self.appDelegate.currentUser)
        UserDefaults.standard.set(encodedData, forKey: "currentUser")
        UserDefaults.standard.synchronize()
        UserDefaults.standard.setValue(false, forKey: "saved2")
        self.removeFromParent()
        self.view.removeFromSuperview()
    }
}
