import UIKit
import GTProgressBar

class FavouritesVCiPad: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var progressView: UIView!
    
    @IBOutlet weak var progressBar: GTProgressBar!
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    //test
    var carsDictionary = [String: [String]]()
    var carSectionTitles = [String]()
    var cars = [String]()
    var state = false
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var name = ""
    var name2 = ""
    var id = 0
    override func viewDidLoad() {
        super.viewDidLoad()
       
        NotificationCenter.default.addObserver(self, selector: #selector(updateData ), name: NSNotification.Name("Star"), object: nil)
        progressView.isHidden = true
        checkState()
        rangeChar()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        for i in appDelegate.favourites {
            if cars.contains(i) == false {
                cars.append(i)
            }
        }
        
        for car in cars {
            let carKey = String(car.prefix(1))
            if var carValues = carsDictionary[carKey] {
                carValues.append(car)
                carsDictionary[carKey] = carValues
            } else {
                carsDictionary[carKey] = [car]
            }
        }
        carSectionTitles = [String](carsDictionary.keys)
        carSectionTitles = carSectionTitles.sorted(by: { $0 < $1 })
        
        
        let name3 = String(name2.dropLast())
        print("name3 \(name3)")
        if name3 != "" {
            if appDelegate.referencesChild.contains(where: {$0.name == name3}) == false {
                print("1")
                state = false
                progressView.isHidden = true
            } else {
                print("2")
                state = true
                progressView.isHidden = true
            }
        } else {
            state = false
        }
       checkState()
        tableView.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        checkState()
    }
    
    @objc func updateData() {
        self.tableView.reloadData()
    }
    
    //nameLbl char range
    fileprivate func rangeChar() {
        let attributedString = nameLbl.attributedText as! NSMutableAttributedString
        attributedString.addAttribute(kCTKernAttributeName as NSAttributedString.Key, value: 3.0, range: NSMakeRange(0, attributedString.length))
        nameLbl.attributedText = attributedString
    }
    
    func checkState() {
        if state == true {
            self.view.backgroundColor = UIColor.white
            imgView.image = nil
            webView.isHidden = false
        } else {
            self.view.backgroundColor = UIColor(red: 234/255, green: 34/255, blue: 37/255, alpha: 1)
            imgView.image = UIImage(named: "CEPIA Splash 5")
            webView.isHidden = true
        }
        
    }
    
    func progressShow() {
        var progress: Float = 0.0
        self.progressBar.progress = 0
        // Do the time critical stuff asynchronously
        DispatchQueue.global(qos: .background).async {
            repeat {
                progress += 0.075
                Thread.sleep(forTimeInterval: 0.25)
                DispatchQueue.main.async(flags: .barrier) {
                    
                    self.progressBar.animateTo(progress: CGFloat(progress))
                }
                // time progress
            } while progress < 1.0
            DispatchQueue.main.async {
                self.progressView.isHidden = true
            }
        }
    }
    
    @IBAction func backTo(_ sender: Any) {
            performSegue(withIdentifier: "showFSFav", sender: name)
    }
    @IBAction func backBut(_ sender: Any) {
        navigationController?.popViewController(animated: false)
    }
    
    @IBAction func menuBut(_ sender: Any) {
        //sideMenu
    }
    
}

extension FavouritesVCiPad {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.favourites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell7", for: indexPath) as! FavorTVCell
        let current = appDelegate.favourites[indexPath.row]
        self.id = Int(current) ?? 0
        cell.id = Int(current) ?? 0
        var element: String!
        var number: String!
        let arr1 = appDelegate.curentPdf.filter({$0.id == Int(current)})
        if arr1.first?.model_name != "" && arr1.first?.model_name != "_" {
            element = arr1.first?.model_name
        } else {
            element = arr1.first?.model_number
        }
        number = arr1.first?.model_number
        
        if arr1.isEmpty {
            let arr2 = appDelegate.curentPdfRef.filter({$0.id == Int(current)})
            element = arr2.first?.title
            number = ""
        }
        cell.prodLbl.text = element + " \(number ?? "")"
        if cell.id == id {
            cell.backgroundView?.backgroundColor = UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1)
        }
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1)
        cell.selectedBackgroundView = backgroundView
        Functions.shared.checkStar(name: String(id), button: cell.starBut)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! FavorTVCell
        let a = appDelegate.curentPdf.filter({$0.id == cell.id})
        if a.isEmpty == false {
            id = a.first?.id ?? 0
        } else {
            let b = appDelegate.curentPdfRef.filter({$0.id == cell.id})
            id = b.first?.id ?? 0
        }
        var text = " "
        if cell.prodLbl.text != nil {
            text = cell.prodLbl.text!
        }
        name2 = text
        if appDelegate.curentPdf.contains(where: {$0.id == cell.id})  {
            performSegue(withIdentifier: "showFavourVital", sender: cell)
        } else {
            name = text
            let pdfName = PDFDownloader.shared.addPercent(fromString: text)
            progressView.isHidden = false
            progressShow()
            read(nameFile: pdfName)
            state = true
            checkState()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFavourVital" {
            let name = sender as! FavorTVCell
            let vs = segue.destination as! VitalStatVCiPad
            vs.id = name.id
            let a = appDelegate.curentPdf.filter({$0.id == name.id})
            vs.manufacturer = a.first?.manufacturer ?? ""
            vs.parentID = a.first?.prodTypeId ?? 0
        }
        if segue.identifier == "showFSFav" {
            let name = sender as! String
            let vs = segue.destination as! FavouriteFSVC
            vs.name = name
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
    
}
