import UIKit
import SwiftyJSON
import Alamofire

class LoginVC: UIViewController, UITextFieldDelegate {
    
    
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var emailLbl: UITextField!
    @IBOutlet weak var passLbl: UITextField!
    @IBOutlet weak var checkBut: UIButton!
    @IBOutlet weak var goBut: UIButton!
    
    var isChecmarkTaped = UserDefaults.standard.bool(forKey: "saved")
    var a: Int! = 0
    var path = UserDefaults.standard.bool(forKey: "saved2")
    
    var showSubAlert = false

    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        rangeChar()
        addTapGestureToHideKeyboard()
        buttonChang(senderButton: checkBut, senderSwitch: isChecmarkTaped)
        
        textFieldFont(text: "Email", textField: emailLbl, fontName: "Lato", fontSize: 14.0)
        textFieldFont(text: "Password", textField: passLbl, fontName: "Lato", fontSize: 14.0)
        
        
        //check sub
        if isChecmarkTaped == true {
            if path == true {
                
            }
            if appDelegate.currentUser.id != 0 {
                performSegue(withIdentifier: "cepia", sender: nil)
            }
            print("go to tap")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        emailLbl.text = ""
        passLbl.text = ""
    }
    
    //nameLbl char range
    fileprivate func rangeChar() {
        let attributedString = nameLbl.attributedText as! NSMutableAttributedString
        attributedString.addAttribute(kCTKernAttributeName as NSAttributedString.Key, value: 3.0, range: NSMakeRange(0, attributedString.length))
        nameLbl.attributedText = attributedString
        goBut.layer.cornerRadius = 5
    }
    
    fileprivate func buttonChang(senderButton: UIButton,senderSwitch: Bool) {
        if senderSwitch == false {
            checkBut.setImage(UIImage(named: "Rectangle 11"), for: .normal)
        } else {
            
            checkBut.setImage(UIImage(named: "Artboard"), for: .normal)
        }
    }
    
    func showAlertError(title: String,withText: String) {
        let alert = UIAlertController(title: title, message: withText, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func backBut(_ sender: Any) {
    }
    
    @IBAction func logibButTaped(_ sender: Any) {
        guard let email = emailLbl.text, let password = passLbl.text, email != "", password != ""  else {
            showAlertError(title: "Sign In Failed", withText: "Complete the fields.")
            return
        }
        print("aaa2")
        logIn()
        
    }
    
    @IBAction func createAccBut(_ sender: Any) {
        
    }
    
    @IBAction func forgotPassBut(_ sender: Any) {
        
    }
    
    @IBAction func checkbutTaped(_ sender: Any) {
        
        if isChecmarkTaped == false {
            isChecmarkTaped = true
        } else {
            isChecmarkTaped = false
        }
        buttonChang(senderButton: checkBut, senderSwitch: isChecmarkTaped)
        UserDefaults.standard.setValue(isChecmarkTaped, forKey: "saved")
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if appDelegate.model == "iPhone"{
            if segue.identifier == "cepia" {
                let vs = segue.destination as! CepiaVC
                vs.showAlert = true
            }
        } else {
            if segue.identifier == "cepia" {
                let vs = segue.destination as! CepiaVCiPad
                vs.showAlert = true
            }
        }
    }
    
    func logIn() {
        
        guard let user = emailLbl.text, let password = passLbl.text, user != "", password != "" else {
            print("empty fields")
            return
        }
        let url = URL(string: "https://ppm.customertests.com/wp-json/wp/v2/users/me")
        let credentialData = "\(user):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString(options: [])
        let headers = ["Authorization": "Basic \(base64Credentials)"]
        
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
//                print("json: \(json)")
                let id: Int!
                id = json["id"].intValue
                if id != nil && id != 0 {
//                    print("work0")
                    self.performSegue(withIdentifier: "cepia", sender: nil)
                    let user = User(name: json["name"].stringValue,
                                    password: self.passLbl.text!,
                                    favor: json["description"].stringValue,
                                    id: json["id"].intValue,
                                    subs: json["first_name"].stringValue,
                                    disclaimer: json["last_name"].stringValue)
                    self.appDelegate.currentUser = user
                    
                    let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: self.appDelegate.currentUser)
                    UserDefaults.standard.set(encodedData, forKey: "currentUser")
                    UserDefaults.standard.synchronize()
                }
        }
    }
}

extension UIViewController {
    func addTapGestureToHideKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(view.endEditing))
        view.addGestureRecognizer(tapGesture)
    }
    
    func textFieldFont(text: String, textField: UITextField, fontName: String, fontSize: CGFloat) {
        var myMutableStringTitle = NSMutableAttributedString()
        let name  = text // PlaceHolderText
        myMutableStringTitle = NSMutableAttributedString(string:name, attributes: [NSAttributedString.Key.font:UIFont(name: fontName, size: fontSize)!])
        textField.attributedPlaceholder = myMutableStringTitle
    }
    
    
}
