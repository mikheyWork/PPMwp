import UIKit

class RegistrVC: UIViewController {
    
    var user: UserModel!
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
    
    @IBAction func registrBut(_ sender: Any) {
        guard let email = emailText.text, let password = passwordText.text, email != "", password != "", rePassText.text != ""  else {
            showAlertError(title: "Create Account Failed", withText: "Complete the fields.")
            return
        }
        
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
