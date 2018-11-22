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
        
        let user = "so_se"
        let password = "q>ezaOBCPj0T"
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
                var answer = json["message"].stringValue
                print("answer \(answer)")
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
                    
                    self.performSegue(withIdentifier: "loginAfterRegister", sender: nil)
                }
        }
    }

@IBAction func registrBut(_ sender: Any) {
    guard let email = emailText.text, let password = passwordText.text, email != "", password != "", rePassText.text != ""  else {
        showAlertError(title: "Create Account Failed", withText: "Complete the fields.")
        return
    }
    register()
}

@IBAction func backBut(_ sender: Any) {
    navigationController?.popViewController(animated: true)
}

override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if appDelegate.model == "iPhone"{
        
    } else {
        
    }
}
}
