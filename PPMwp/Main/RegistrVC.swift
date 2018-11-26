import UIKit
import Alamofire
import SwiftyJSON

class RegistrVC: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var emailText: UITextField!
    
    @IBOutlet weak var passwordText: UITextField!
    
    
    @IBOutlet weak var rePassText: UITextField!
    @IBOutlet weak var goBut: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rangeChar()
        emailText.layer.cornerRadius = 5
        addTapGestureToHideKeyboard()
        
    }
    
    //nameLbl char range
    fileprivate func rangeChar() {
        let attributedString = nameLbl.attributedText as! NSMutableAttributedString
        attributedString.addAttribute(kCTKernAttributeName as NSAttributedString.Key, value: 3.0, range: NSMakeRange(0, attributedString.length))
        nameLbl.attributedText = attributedString
        goBut.layer.cornerRadius = 5
    }
    
    func showAlertError(title: String, withText: String) {
        let alert = UIAlertController(title: title, message: withText, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func register() {
        
        let user = "Technical"
        let password = "cxjLks)s&814RMwEjHHZkDKw"
        let url = URL(string: "https://ppm.customertests.com/wp-json/wp/v2/users")
        let credentialData = "\(user):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString(options: [])
        let headers = ["Authorization": "Basic \(base64Credentials)"]
        
        let parameters: Parameters = ["username": emailText.text!, "email": emailText.text!, "password": passwordText.text!]
      
        Alamofire.request(url!,
                          method: .post,
                          parameters: parameters,
                          encoding: URLEncoding.default,
                          headers:headers)
            .responseJSON { (response) in
                guard response.result.value != nil else {
                    print("json response false: \(response)")
                    return
                }
                let json = JSON(response.result.value!)
                print("json: \(json)")
                //error handle
                var answer = ""
                answer = json["code"].stringValue
                print("answer is \(answer)")
                if answer == "Invalid parameter(s): email" || answer == "rest_invalid_param" {
                    self.showAlertError(title: "Create Account Failed", withText: "Invalid email address.")
                } else if answer == "existing_user_email" || answer == "existing_user_login"  {
                    self.showAlertError(title: "Create Account Failed", withText: "Sorry, that email already exists.")
                } else {
                    //
                    let id: Int!
                    id = json["id"].intValue
                    print("id is \(id)")
                    if id != nil && id != 0 {
                        print("work0")
                        let user = User(name: json["name"].stringValue,
                                        password: self.passwordText.text!,
                                        favor: json["description"].stringValue,
                                        id: json["id"].intValue,
                                        subs: json["first_name"].stringValue,
                                        disclaimer: json["last_name"].stringValue)
                        self.appDelegate.currentUser = user
                        
                        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: self.appDelegate.currentUser)
                        UserDefaults.standard.set(encodedData, forKey: "currentUser")
                        UserDefaults.standard.synchronize()
                        
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "loginAfterRegister", sender: nil)
                        }
                        
                }
                
                }
        }
    }
    
    @IBAction func registrBut(_ sender: Any) {
        
        
        if passwordText.text == rePassText.text {
            guard let email = emailText.text, let password = passwordText.text, email != "", password != "", rePassText.text != ""  else {
                showAlertError(title: "Create Account Failed", withText: "Complete the fields.")
                return
            }
            if Reachability.isConnectedToNetwork() {
                DispatchQueue.global().async {
                    self.register()
                }
            } else {
                self.showAlertError(title: "Sign In Failed", withText: "No internet connection.")
            }
            
        } else {
            showAlertError(title: "Create Account Failed", withText: "Passwords don’t match.")
        }
    }
    
    @IBAction func backBut(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if appDelegate.currentUser != nil {
            if appDelegate.currentUser.id != 0 {
                if appDelegate.currentUser.subs == "+" {
                    appDelegate.subscribtion = true
                } else {
                    appDelegate.subscribtion = false
                }
                if appDelegate.currentUser.disclaimer == "+" {
                    appDelegate.showDisc = true
                } else {
                    appDelegate.showDisc = false
                }
            }
        }
        if appDelegate.model == "iPhone"{
            if segue.identifier == "loginAfterRegister" {
                print("subs3: \(appDelegate.subscribtion)")
                let vs = segue.destination as! CepiaVC
                vs.showAlert = true
            }
        } else {
            if segue.identifier == "loginAfterRegister" {
                let vs = segue.destination as! CepiaVCiPad
                vs.showAlert = true
            }
        }
    }
}
