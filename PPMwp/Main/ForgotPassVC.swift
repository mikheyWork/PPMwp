import UIKit
import Alamofire
import SwiftyJSON
import Darwin

class ForgotPassVC: UIViewController {
    
    
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var emailLbl: UITextField!
    @IBOutlet weak var reqBut: UIButton!
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var id: Int!
    var mailTrue = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(soop), name: NSNotification.Name("soop"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(soop2), name: NSNotification.Name("soop2"), object: nil)
        rangeChar()
        addTapGestureToHideKeyboard()
        activity.isHidden = true
    }
    
    @objc func soop() {
        showAlertError(title: "Request Failed", withText: "Invalid Email Address")
    }
    
    @objc func soop2() {
        showAlertError(title: "Succsess", withText: "Request is succsess")
    }
    
    //nameLbl char range
    fileprivate func rangeChar() {
        let attributedString = nameLbl.attributedText as! NSMutableAttributedString
        attributedString.addAttribute(kCTKernAttributeName as NSAttributedString.Key, value: 3.0, range: NSMakeRange(0, attributedString.length))
        nameLbl.attributedText = attributedString
        reqBut.layer.cornerRadius = 5
    }
    
    func showAlertError(title: String, withText: String) {
        let alert = UIAlertController(title: title, message: withText, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
        self.activity.isHidden = true
        self.activity.stopAnimating()
    }
    
    func forgotReq(page: Int) {
        let user = "so_se"
        let password = "q>ezaOBCPj0T"
        let url = URL(string: "https://ppm.customertests.com/wp-json/wp/v2/users?page=\(page)&per_page=100")
        let credentialData = "\(user):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString(options: [])
        let headers = ["Authorization": "Basic \(base64Credentials)"]
        DispatchQueue.main.async {
            self.activity.isHidden = false
            self.activity.startAnimating()
        }

        Alamofire.request(url!,
                          method: .get,
                          parameters: nil,
                          encoding: URLEncoding.default,
                          headers:headers)
            .responseJSON { (response) in
                guard response.result.value != nil else {
                    print("json response false: \(response)")
                    return
                }
                
                let json = JSON(response.result.value!)
                let resaults = json[].arrayValue
                if resaults.count == 100 {
                    print("page is full, page is \(page)")
                    self.forgotReq(page: page + 1)
                } else {
                    print("not full page")
                }
                for resault in resaults {
                    if self.emailLbl.text == resault["name"].stringValue {
                        self.id = resault["id"].intValue
                        self.mailTrue = true
                        //delete current user
                        let user = User(name: "_", password: "_", favor: "_", id: 0, subs: "_", disclaimer: "_")
                        self.appDelegate.currentUser = user
                        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: self.appDelegate.currentUser)
                        UserDefaults.standard.set(encodedData, forKey: "currentUser")
                        UserDefaults.standard.synchronize()
                        UserDefaults.standard.setValue(false, forKey: "saved2")
                        let text =  "Hello, \n \nYou have requested a password reset, follow the link below to reset it. \n \nChange Password: https://ppm.customertests.com/forgot-password/ \nThanks, \nCEPIA Team"
                        MailSender.shared.sendEmail(subject: "Reset password", body: text, mail: self.emailLbl.text!)
                        
                        
                    } else {
                        self.mailTrue = false
                    }
                }
                if resaults.count < 100 {
                    if self.mailTrue ==  false {
                        DispatchQueue.main.async {
                            self.showAlertError(title: "Request Failed", withText: "Username was not found.")
                            self.activity.isHidden = true
                            self.activity.stopAnimating()
                        }
                    } else {
                    }
                }
        }
    }
    
    @IBAction func requestBut(_ sender: Any) {
        
        guard emailLbl.text != "" else { return }
        
            if Reachability.isConnectedToNetwork() {
                DispatchQueue.global(qos: .userInteractive).async {
                self.forgotReq(page: 1)
                }
            } else {
                showAlertError(title: "Request Failed", withText: "No internet connection")
                self.activity.isHidden = true
                self.activity.stopAnimating()
            }
    }
        @IBAction func backBut(_ sender: Any) {
            navigationController?.popViewController(animated: true)
        }
}
