import UIKit
import GTProgressBar

class DiscAlert: UIViewController {
    
    
    @IBOutlet weak var subscribeBut: UIButton!
    
    @IBOutlet weak var cancelBut: UIButton!
    
    @IBOutlet weak var textView: UITextView!
    
    var progressBar = GTProgressBar()
    
    //fire
    var user: UserModel!
    
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
//        UserDefaults.standard.set(appDelegate.showDisc, forKey: "DiscAlert")
//        
//        let ref2  = Database.database().reference(withPath: "users").child((self.user.uid)).child("disclaimer")
//        ref2.setValue(["disclaimer": self.appDelegate.showDisc])
//        
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
        self.removeFromParent()
        self.view.removeFromSuperview()
    }
}
