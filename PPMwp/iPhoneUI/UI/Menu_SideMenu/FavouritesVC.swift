import UIKit

class FavouritesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var carsDictionary = [String: [String]]()
    var carSectionTitles = [String]()
    var cars = [String]()
    var id = 0
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate.favourites.removeAll()
        let a  = self.appDelegate.currentUser.favor.split(separator: ",")
        if a.isEmpty == false {
            self.appDelegate.favourites.removeAll()
            for i in a {
                
                if self.appDelegate.favourites.contains(String(i)) == false {
                    if appDelegate.curentPdf.contains(where: {$0.id == Int(String(i))}) || appDelegate.curentPdfRef.contains(where: {$0.id == Int(String(i))}) ||  appDelegate.referencesChild.contains(where: {$0.id == Int64(String(i))})  {
                        self.appDelegate.favourites.append(String(i))
                    }
                }
            }
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateData ), name: NSNotification.Name("Star"), object: nil)
        
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
        rangeChar()
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        self.tableView.reloadData()
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
    
    
    @IBAction func backBut(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func menuBut(_ sender: Any) {
        //sideMenu
    }
    
    @IBAction func starTaped(_ sender: Any) {
        self.tableView.reloadData()
    }
}

extension FavouritesVC {
    
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
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 241/255, green: 243/255, blue: 246/255, alpha: 1.0)
        cell.selectedBackgroundView = backgroundView
        
        Functions.shared.checkStar(name: String(id), button: cell.starBut)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! FavorTVCell
       
        if appDelegate.curentPdf.contains(where: {$0.id == cell.id})  {
            performSegue(withIdentifier: "showFavourVital", sender: cell)
        } else {
            performSegue(withIdentifier: "showFavRefer", sender: cell)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFavourVital" {
            let name = sender as! FavorTVCell
            let vs = segue.destination as! VitalStatVC
            vs.id = name.id
        }
        
        if segue.identifier == "showFavRefer" {
            let name = sender as! FavorTVCell
            let vs = segue.destination as! PDFviewerVC
            vs.id = name.id
        }
    }
}
