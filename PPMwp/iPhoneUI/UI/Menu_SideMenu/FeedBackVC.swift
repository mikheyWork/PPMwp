import UIKit
import MessageUI

class FeedBackVC: UIViewController, MFMailComposeViewControllerDelegate {
    
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var subjText: UITextField!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendBut: UIButton!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    let placeholder = "Message"
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(showAlert), name: NSNotification.Name("Alert2"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showAlert2), name: NSNotification.Name("Alert"), object: nil)
        super.viewDidLoad()
        sendBut.layer.cornerRadius = 5
        textViewChange()
        addTapGestureToHideKeyboard()
        rangeChar()
        activity.isHidden = true
        activity.stopAnimating()
    }
    
    //nameLbl char range
    fileprivate func rangeChar() {
        let attributedString = nameLbl.attributedText as! NSMutableAttributedString
        attributedString.addAttribute(kCTKernAttributeName as NSAttributedString.Key, value: 3.0, range: NSMakeRange(0, attributedString.length))
        nameLbl.attributedText = attributedString
    }
    
    fileprivate func textViewChange() {
        textView.text = "Message"
        textView.textColor = UIColor(red: 143/255, green: 150/255, blue: 158/255, alpha: 1)
        textView.font = UIFont(name: "Lato", size: 14.0)
        textView.returnKeyType = .done
        textView.delegate = self
        
        var myMutableStringTitle = NSMutableAttributedString()
        let Name  = "Subject" // PlaceHolderText
        myMutableStringTitle = NSMutableAttributedString(string:Name, attributes: [NSAttributedString.Key.font:UIFont(name: "Lato", size: 14.0)!]) // Font
        myMutableStringTitle.addAttribute(NSAttributedString.Key.foregroundColor, value:  UIColor(red: 143/255, green: 150/255, blue: 158/255, alpha: 1), range:NSRange(location:0,length:Name.count))
        
        subjText.attributedPlaceholder = myMutableStringTitle
    }
    
    //mail
    func showAlertError(text: String ,withText: String) {
        let alert = UIAlertController(title: text, message: withText, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func sendBut(_ sender: Any) {
        if Reachability.isConnectedToNetwork() {
            guard subjText.text != "" && textView.text != "" && textView.text != "Message" else {
                let alert = UIAlertController(title: "Failed", message: "Complete the fields.", preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                return
            }
            activity.isHidden = false
            activity.startAnimating()
            MailSender.shared.sendEmail(subject: subjText.text!, body: textView.text!, mail: "team@qubasoft.com")
        } else {
            let alert = UIAlertController(title: "Failed", message: "No internet connection.", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func backBut(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func menuBut(_ sender: Any) {
        
    }
}

extension FeedBackVC: UITextViewDelegate {
    //MARK:- UITextViewDelegates
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Message" {
            textView.text = ""
            textView.textColor = UIColor(red: 32/255, green: 46/255, blue: 61/255, alpha: 1)
            textView.font = UIFont(name: "Lato", size: 14.0)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Message"
            textView.textColor = UIColor(red: 143/255, green: 150/255, blue: 158/255, alpha: 1)
            textView.font = UIFont(name: "Lato", size: 14.0)
        }
    }
    
    @objc func showAlert() {
        activity.isHidden = true
        activity.stopAnimating()
        let alert = UIAlertController(title: "Sent", message: "Your message was sent.", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func showAlert2() {
        activity.isHidden = true
        activity.stopAnimating()
        let alert = UIAlertController(title: "Failed", message: "Failed request", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}

