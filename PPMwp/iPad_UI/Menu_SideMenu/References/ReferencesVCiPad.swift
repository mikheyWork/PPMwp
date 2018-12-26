import UIKit
import MYTableViewIndex
import GTProgressBar

class ReferencesVCiPad: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, TableViewIndexDelegate, TableViewIndexDataSource {
    
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar1: UISearchBar!
    @IBOutlet weak var tableViewIndex: TableViewIndex!
    
    
    @IBOutlet weak var progressView: UIView!
    
    @IBOutlet weak var progressBar: GTProgressBar!
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var imgView: UIImageView!
    //test
    var carsDictionary = [String: [String]]()
    var carSectionTitles = [String]()
    var cars = [String]()
    var state = false
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var pdfName2 = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.tableView.rowHeight = UITableView.automaticDimension
//        self.tableView.estimatedRowHeight = 73.0
        progressView.isHidden = true
        rangeChar()
        searchBarChange(searchBar: searchBar1)
        index()
        indexFunc()
        tableViewIndex.reloadData()
        searchBar1.delegate = self
        checkState()
        searchBar1.setImage(UIImage(named: "ic_search_18px"), for: UISearchBar.Icon.search, state: UIControl.State.normal)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        self.tableView.reloadData()
        indexFunc()
    }
    
    func index() {
        for i in appDelegate.referencesParent {
            if cars.contains(i.name!) == false {
                cars.append(i.name!)
            }
        }
        
        // 1
        for car in cars {
            let carKey = String(car.prefix(1))
            if var carValues = carsDictionary[carKey] {
                carValues.append(car)
                carsDictionary[carKey] = carValues
            } else {
                carsDictionary[carKey] = [car]
            }
        }
        
        // 2
        carSectionTitles = [String](carsDictionary.keys)
        carSectionTitles = carSectionTitles.sorted(by: { $0 < $1 })
        
    }
    
    func indexFunc() {
        //index
        
        var display: CGFloat
        display = view.bounds.height
        
        if display < 800 {
            tableViewIndex.font = UIFont(name: "Lato", size: 12)!
            tableViewIndex.itemSpacing = 5
        } else if display < 900{
            tableViewIndex.font = UIFont(name: "Lato", size: 13)!
            tableViewIndex.itemSpacing = 6
        } else if display < 1120{
            tableViewIndex.font = UIFont(name: "Lato", size: 15)!
            tableViewIndex.itemSpacing = 12
        } else {
            tableViewIndex.font = UIFont(name: "Lato", size: 15)!
            tableViewIndex.itemSpacing = 24
        }
        
    }
    
    func indexItems(for tableViewIndex: TableViewIndex) -> [UIView] {
        return carSectionTitles.map{ title -> UIView in
            return StringItem(text: title)
        }
    }
    
    func tableViewIndex(_ tableViewIndex: TableViewIndex, didSelect item: UIView, at index: Int) -> Bool {
        
        if index < carSectionTitles.count {
            let indexPath = NSIndexPath(row: 0, section: index)
            tableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: false)
        }
        return true // return true to produce haptic feedback on capable devices
    }
    
    func read(nameFile: String) {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent("\(nameFile).pdf")
            //reading
            let request = URLRequest(url: fileURL)
            self.webView.loadRequest(request)
        }
    }
    
    //search bar
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.text = searchText
        carsDictionary.removeAll()
        carSectionTitles.removeAll()
        tableView.reloadData()
        if searchText != "" {
            for i in appDelegate.referencesParent {
                if cars.contains(i.name!) == false {
                    cars.append(i.name!)
                }
            }
            
            for i in appDelegate.referencesChild {
                if cars.contains(i.name!) == false {
                    cars.append(i.name!)
                }
            }
            
            cars = cars.filter({ (elemt: String) -> Bool in
                elemt.lowercased().contains(searchText.lowercased())
            })
        } else {
            cars.removeAll()
            
            for i in appDelegate.referencesParent {
                if cars.contains(i.name!) == false {
                    cars.append(i.name!)
                }
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
        self.tableView.reloadData()
        self.tableViewIndex.reloadData()
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.endEditing(true)
        searchBar.resignFirstResponder()
        return true
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
        
    }
    
    func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.view.endEditing(true)
        searchBar1.endEditing(true)
        searchBar1.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchBar1.endEditing(true)
        searchBar.resignFirstResponder()
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    
    //searchBar view
    func searchBarChange(searchBar: UISearchBar) {
        
        //SearchBar Text
        let textFieldInsideUISearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideUISearchBar?.textColor = UIColor(red: 32/255, green: 46/255, blue: 61/255, alpha: 1)
        textFieldInsideUISearchBar?.font = UIFont(name: "Lato", size: 14)
        
        //SearchBar Placeholder
        let textFieldInsideUISearchBarLabel = textFieldInsideUISearchBar!.value(forKey: "placeholderLabel") as? UILabel
        textFieldInsideUISearchBarLabel?.font = UIFont(name: "Lato", size: 14)
    }
    
    func checkState() {
        if state == true {
            self.view.backgroundColor = UIColor.white
            imgView.image = nil
            webView.isHidden = false
//            starBut.isHidden = false
        } else {
            self.view.backgroundColor = UIColor(red: 234/255, green: 34/255, blue: 37/255, alpha: 1)
            imgView.image = UIImage(named: "CEPIA Splash 5")
            webView.isHidden = true
//            starBut.isHidden = true
        }
    }
    
    //nameLbl char range
    fileprivate func rangeChar() {
        let attributedString = nameLbl.attributedText as! NSMutableAttributedString
        attributedString.addAttribute(kCTKernAttributeName as NSAttributedString.Key, value: 3.0, range: NSMakeRange(0, attributedString.length))
        nameLbl.attributedText = attributedString
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
    
    @IBAction func backBut(_ sender: Any) {
        navigationController?.popViewController(animated: false)
    }
    
    @IBAction func menuBut(_ sender: Any) {
        //sideMenu
    }
    
}

extension ReferencesVCiPad {
   
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = UIColor(red: 32/255, green: 46/255, blue: 61/255, alpha: 1)
        return footerView
        
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerLabel = UILabel()
        let headerView = UIView()
        headerView.backgroundColor = UIColor(red: 32/255, green: 46/255, blue: 61/255, alpha: 1)
        headerLabel =
            UILabel(frame: CGRect(x: 30, y: 0, width:
                tableView.bounds.size.width, height: tableView.bounds.size.height))
         headerLabel.font = UIFont(name: "Lato-Black", size: 15)
        headerLabel.textColor = UIColor.white
        headerLabel.text = self.tableView(self.tableView, titleForHeaderInSection: section)
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return carSectionTitles[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return carSectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let carKey = carSectionTitles[section]
        if let carValues = carsDictionary[carKey] {
            return carValues.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 3
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell9", for: indexPath) as! RefTVCell
        
        cell.separatorInset.left = CGFloat(30)
        cell.separatorInset.right = CGFloat(30)
        
        
        cell.separatorInset.left = CGFloat(30)
        cell.separatorInset.right = CGFloat(50)
        // Configure the cell...
        let carKey = carSectionTitles[indexPath.section]
        if let carValues = carsDictionary[carKey] {
            cell.nameLbl.text = carValues[indexPath.row]
            var elem = ""
            let text = cell.nameLbl.text
            let cellName = appDelegate.referencesParent.filter({$0.name == text})
            elem = cellName.first?.description2 ?? ""
            if cellName.isEmpty {
                let arr1 = appDelegate.referencesChild.filter({$0.name == text})
                elem = arr1.first?.description2 ?? ""
            }
            
            let description = elem
            cell.resultLbl.text = description
        }
        return cell
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        
        tableView.sectionIndexColor = UIColor.white
        return [" "]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //parentID
        let selectedCell = tableView.cellForRow(at: indexPath) as! RefTVCell
        let text = selectedCell.nameLbl.text
        if appDelegate.referencesParent.contains(where: {$0.name == text}) {
            let selectedName = appDelegate.referencesParent.filter({$0.name == text})
            let selectedNameID = selectedName.first?.id
            
            performSegue(withIdentifier: "showRef2", sender: selectedNameID)
        } else {
            
            let id = appDelegate.referencesChild.filter({$0.name == text})
            let arr1 = appDelegate.referencesChild.filter({$0.parent == id.first?.id})
            
            if arr1.isEmpty {
                //read
                state = true
                checkState()
                progressView.isHidden = false
                progressShow()
                let pdfName = PDFDownloader.shared.addPercent(fromString: text ?? "")
                pdfName2 = pdfName
                read(nameFile: pdfName)
            } else {
                performSegue(withIdentifier: "showRef2", sender: id.first?.id)
            }
        }
    }
    
    
    
    //MARK: -Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRef2" {
            let parentId = sender as! Int64
            let types = segue.destination as! ReferencesVC2iPad
            types.parentID = parentId
            state = false
            checkState()
        } else if segue.identifier == "showReferFS" {
            let vs = segue.destination as! ReferencesFSVC
            vs.name = pdfName2
            print("name \(pdfName2)")
            if pdfName2 != "" {
                state = true
                checkState()
            } else {
                state = false
                checkState()
            }
           
        } else if segue.identifier == "showMenuRefSeg" {
            state = true
            checkState()
        } else {
            state = false
            checkState()
        }
    }
}
