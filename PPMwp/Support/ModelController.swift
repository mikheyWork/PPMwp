import UIKit

class ModelController: UIViewController {
    
    var isChecmarkTaped = UserDefaults.standard.bool(forKey: "saved")
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let model = UIDevice.current.model
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        if isChecmarkTaped == true {
            if appDelegate.currentUser != nil {
                if appDelegate.currentUser.id != 0 {
                    if model == "iPhone" {
                        print("pppp")
                        performSegue(withIdentifier: "showiPhone2", sender: nil)
                    } else {
                        performSegue(withIdentifier: "showiPad2", sender: nil)
                    }
                } else {
                    if model == "iPhone" {
                        performSegue(withIdentifier: "showiPhone", sender: nil)
                    } else {
                        performSegue(withIdentifier: "showiPad", sender: nil)
                    }
                }
            } else {
                if model == "iPhone" {
                    performSegue(withIdentifier: "showiPhone", sender: nil)
                } else {
                    performSegue(withIdentifier: "showiPad", sender: nil)
                }
            }
        }  else {
            if model == "iPhone" {
                performSegue(withIdentifier: "showiPhone", sender: nil)
            } else {
                performSegue(withIdentifier: "showiPad", sender: nil)
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if appDelegate.currentUser != nil {
            if appDelegate.currentUser.id != 0 {
                if appDelegate.currentUser.subs == "+" {
                    appDelegate.subscribtion = true
                } else {
                    appDelegate.subscribtion = false
                }
            }
        }
        if model == "iPhone"{
            print("show show show")
            if segue.identifier == "showiPhone2" {
                let vs = segue.destination as! CepiaVC
                vs.showAlert = true
            }
        } else {
            if segue.identifier == "showiPad2" {
                let vs = segue.destination as! CepiaVCiPad
                vs.showAlert = true
            }
        }
    }
}
