import UIKit
import GTProgressBar
import Alamofire


class PDFviewerVC: UIViewController {
    
    
    @IBOutlet weak var starBut: UIButton!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var progressA: GTProgressBar!
    @IBOutlet weak var subView: UIView!
    
    @IBOutlet weak var menuBut: UIButton!
    var nameVC = " -_- 2"
    var name = " "
    var isHiden = false
    var downloadProgress: Double!
    var id = 0
    var doc = ""
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let elem1 = appDelegate.curentPdf.filter({$0.id == id})
        var name = ""
        if elem1.first?.model_name != "" && elem1.first?.model_name != "_" {
            name = elem1.first?.model_name ?? ""
        } else {
            name = elem1.first?.model_number ?? ""
        }
        
        if elem1.isEmpty {
            let elem2 = appDelegate.curentPdfRef.filter({$0.id == id})
            name = elem2.first?.title ?? ""
        }
        var name2 = PDFDownloader.shared.addPercent(fromString: name)
        if doc != "" {
            name2 += doc
        }
        
        if name.contains("Info") {
            name = String(name.dropLast(4))
        } else if name.contains("Alert") {
            name = String(name.dropLast(5))
        } else {
            
        }
        
        progressShow()
        Functions.shared.checkStar(name: String(id), button: starBut)
        checkSub()
        read(nameFile: name2)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Functions.shared.checkStar(name: String(id), button: starBut)
        progressA.progress = 0.0
        print("sup \(supportedInterfaceOrientations.rawValue)")
    }
    
  
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (self.isMovingFromParent) {
            UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        }
        
    }
    
    @objc func canRotate() -> Void {}

    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation == .portrait || UIDevice.current.orientation == .portraitUpsideDown {
            menuBut.isHidden = false
        } else {
            menuBut.isHidden = true
        }
    }
    
    func progressShow() {
        var progress: Float = 0.0
        self.progressA.progress = 0
        // Do the time critical stuff asynchronously
        DispatchQueue.global(qos: .background).async {
            repeat {
                progress += 0.075
                Thread.sleep(forTimeInterval: 0.25)
                DispatchQueue.main.async(flags: .barrier) {
                    self.progressA.animateTo(progress: CGFloat(progress))
                }
                // time progress
            } while progress < 1.0
            DispatchQueue.main.async {
                self.subView.isHidden = true
            }
        }
    }
    

    func read(nameFile: String) {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent("\(nameFile).pdf")
            //reading
            let request = URLRequest(url: fileURL)
            self.webView.loadRequest(request)
        }
    }
    
    func checkSub() {
        if isHiden == true {
            subView.isHidden = true
        } else {
            subView.isHidden = false
        }
    }
    
    @IBAction func backBut(_ sender: Any) {
        switch nameVC {
            
        case "VitalStatVC":
            
            for controller in self.navigationController!.viewControllers as Array {
                if controller.isKind(of: VitalStatVC.self) {
                    self.navigationController!.popToViewController(controller, animated: true)
                    break
                }
            }
            
        case "ReferencesVC2":
            for controller in self.navigationController!.viewControllers as Array {
                if controller.isKind(of: ReferencesVC2.self) {
                    self.navigationController!.popToViewController(controller, animated: true)
                    break
                }
            }
        default:
            navigationController?.popViewController(animated: false)
        }
    }
    
    @IBAction func menuBut(_ sender: Any) {
        //sideMenu
        if UIDevice.current.orientation == .portrait || UIDevice.current.orientation == .portraitUpsideDown {
            performSegue(withIdentifier: "showPDFSideMenu", sender: nil)
            
        } else {
            
        }
    }
    
    @IBAction func starBut(_ sender: Any) {
        Functions.shared.sendFavorInfo(id: id, button: starBut)
        Functions.shared.checkStar(name: String(id), button: starBut)
    }
    
}
