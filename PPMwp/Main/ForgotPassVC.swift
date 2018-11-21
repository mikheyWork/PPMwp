import UIKit

class ForgotPassVC: UIViewController {
    
    
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var emailLbl: UITextField!
    @IBOutlet weak var reqBut: UIButton!
    
    var emailAddress = "user@example.com";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rangeChar()
        addTapGestureToHideKeyboard()
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
    }
    
    @IBAction func requestBut(_ sender: Any) {
        
        guard emailLbl.text != "" else { return }
        
    }
        
        @IBAction func backBut(_ sender: Any) {
            navigationController?.popViewController(animated: true)
        }
        
        
}
