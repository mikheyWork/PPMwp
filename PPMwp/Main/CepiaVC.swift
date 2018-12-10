import UIKit
import GTProgressBar
import Alamofire
import SwiftyJSON

class CepiaVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var searchBarLbl: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var hidenMenu: UIView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    var from: String!
    var showAlert = false
    var carsDictionary = [String: [SearchItem]]()
    var carSectionTitles = [String]()
    var cars = [SearchItem]()
    var cars2 = [SearchItem]()
    var isSearching = false
    var loadDataWpBool = false
    var progressBar = GTProgressBar()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate.subscribtion = true
        DispatchQueue.main.async {
            NotificationCenter.default.addObserver(self, selector: #selector(self.showCongr), name: NSNotification.Name("Check"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.loadDataWp), name: NSNotification.Name("CheckSub"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.showMenu), name: NSNotification.Name("ShowMenu"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.showBlock), name: NSNotification.Name("ShowBlock"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.hideBlock), name: NSNotification.Name("HideBlock"), object: nil)
        }
        hidenMenu.isHidden = false
        activity.isHidden = true
        showMenu()
        if Reachability.isConnectedToNetwork() {
            loadDataWp()
        } else {
            hidenMenu.isHidden = true
            if appDelegate.subscribtion == true {
                hidenMenu.isHidden = true
            } else {
                //???
                hidenMenu.isHidden = false
            }
        }
        if appDelegate.childs.count == 0 {
            appDelegate.fetchCoreDataRef()
        }
        
        if appDelegate.referencesChild.count == 0 {
            appDelegate.fetchCoreDataRef()
        }
        
        //test store
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        rangeChar()
        searchBarChange(searchBar: searchBarLbl)
        showTable()
        index()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if Reachability.isConnectedToNetwork() == true {
            //requset actual data
            DispatchQueue.global(qos: .userInteractive).async {
                if self.appDelegate.currentUser.id != 0 {
                    guard self.appDelegate.currentUser != nil && self.appDelegate.currentUser.password != nil else {
                        return
                    }
                    let user = self.appDelegate.currentUser.name!
                    let password = self.appDelegate.currentUser.password!
                    let url = URL(string: "https://ppm.customertests.com/wp-json/wp/v2/users/\(self.appDelegate.currentUser.id!)")
                    let credentialData = "\(user):\(password)".data(using: String.Encoding.utf8)!
                    let base64Credentials = credentialData.base64EncodedString(options: [])
                    let headers = ["Authorization": "Basic \(base64Credentials)"]
                    
                    Alamofire.request(url!,
                                      method: .post,
                                      parameters: nil,
                                      encoding: URLEncoding.default,
                                      headers:headers)
                        .responseJSON { [weak self] (response) in
                            guard response.result.value != nil else {
                                return
                            }
                            let json = JSON(response.result.value!)
                            let id: Int!
                            id = json["id"].intValue
                            if id != nil && id != 0 {
                                let user = User(name: json["name"].stringValue,
                                                password: (self?.appDelegate.currentUser.password!)!,
                                                favor: json["description"].stringValue,
                                                id: json["id"].intValue,
                                                subs: json["first_name"].stringValue,
                                                disclaimer: json["last_name"].stringValue)
                                self?.appDelegate.currentUser = user
                                let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: self!.appDelegate.currentUser!)
                                UserDefaults.standard.set(encodedData, forKey: "currentUser")
                                UserDefaults.standard.synchronize()
                            }
                    }
                }
            }
        } else {
            if appDelegate.subscribtion == true {
                
                self.appDelegate.favourites = [String]()
                let a  = self.appDelegate.currentUser.favor.split(separator: ",")
                if a.isEmpty == false {
                    self.appDelegate.favourites.removeAll()
                    for i in a {
                        if self.appDelegate.favourites.contains(String(i)) == false {
                            self.appDelegate.favourites.append(String(i))
                        }
                    }
                }
            } else {
                showAlertError2(withText: "Buy an annual subscription of $ 9.99 AUD for PPM Genius applications.", title: "Error Purchase")
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        addTapGestureToHideKeyboard1()
    }
    
    @objc func loadDataWp() {
        guard loadDataWpBool == false else {
            return
        }
        loadDataWpBool = true
        let a  = self.appDelegate.currentUser.favor.split(separator: ",")
        if a.isEmpty == false {
            self.appDelegate.favourites.removeAll()
            for i in a {
                
                if self.appDelegate.favourites.contains(String(i)) == false {
                    if appDelegate.curentPdf.contains(where: {$0.id == Int(String(i))}) || appDelegate.curentPdfRef.contains(where: {$0.id == Int(String(i))}) || appDelegate.childs.contains(where: {$0.id == Int64(String(i))}) || appDelegate.referencesChild.contains(where: {$0.id == Int64(String(i))})  {
                        self.appDelegate.favourites.append(String(i))
                        print("favor id is \(i)")
                    }
                }
            }
        }
        if appDelegate.subscribtion == true {
            if showAlert == true {
                showSub(nameVC: "CheckDataController", alpha: 0.2)
            }
        } else {
            showSub(nameVC: "SubscribeAlert", alpha: 0.2)
        }
        
        if appDelegate.currentUser.disclaimer == "+" {
            appDelegate.showDisc = true
        } else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "DiscAlert")
            vc?.view.backgroundColor = UIColor.white
            self.addChild(vc!)
            self.view.addSubview((vc?.view)!)
            self.appDelegate.showDisc = true
        }
        showMenu()
    }
    
    @objc func showBlock() {
        hidenMenu.isHidden = false
        hidenMenu.backgroundColor = UIColor.white.withAlphaComponent(0.0)
        activity.isHidden = false
        activity.startAnimating()
    }
    @objc func hideBlock() {
        hidenMenu.isHidden = true
        hidenMenu.backgroundColor = UIColor.white.withAlphaComponent(1.0)
        activity.isHidden = true
        activity.stopAnimating()
    }
    
    
    @objc func showMenu() {
        if appDelegate.showDisc == true {
            hidenMenu.isHidden = true
        } else {
            hidenMenu.isHidden = false
        }
    }
    
    func addTapGestureToHideKeyboard1() {
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(view.endEditing))
        if tableView.isHidden == true {
            view.addGestureRecognizer(tapGesture)
        } else {
            if (view.gestureRecognizers?.count)! > 0 {
                for i in (view?.gestureRecognizers)! {
                    view.removeGestureRecognizer(i)
                }
            }
        }
    }
    
    func deleteTapGestureToHideKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(view.endEditing))
        view.removeGestureRecognizer(tapGesture)
    }
    
    func index() {
//        for i in appDelegate.parents {
//
//            let arr1 = appDelegate.childs.filter({$0.parent == i.id})
//            var count = 0
//            for j in arr1 {
//                let arr2 = appDelegate.curentPdf.filter({$0.prodTypeId == j.id})
//                count += arr2.count
//            }
//            if count != 0 {
//                if cars.contains(where: {$0.id == i.id}) == false {
//                    cars.append(SearchItem(id: Int(i.id), name: i.name ?? "", discription: "", number: "", manufacturer: ""))
//                }
//            }
//
//        }
        
        for i in appDelegate.parents {
            let a = appDelegate.parents.filter({$0.name == i.name})
            if cars.contains(where: {$0.name == a.first!.name!}) == false {
                let b = SearchItem(id: Int(i.id), name: i.name!, discription: "a", number: "", manufacturer: "")
                cars.append(b)
            }
        }
        
        for car in cars {
            let carKey = String(car.name.prefix(1))
            if var carValues = carsDictionary[carKey] {
                carValues.append(car)
                carsDictionary[carKey] = carValues
            } else {
                carsDictionary[carKey] = [car]
            }
        }
        carSectionTitles = [String](carsDictionary.keys)
        carSectionTitles = carSectionTitles.sorted(by: { $0 < $1 })
        UserDefaults.standard.set(appDelegate.subscribtion, forKey: "subscribe2")
    }
    
    func showTable() {
        if isSearching == true {
            tableView.isHidden = false
        } else {
            tableView.isHidden = true
        }
    }
    
    //search bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.text = searchText
        
        if searchText != "" {
            if appDelegate.subscribtion == true {
               isSearching = true
            }
        } else {
            isSearching = false
        }
        showTable()
        tableView.reloadData()
        carsDictionary.removeAll()
        carSectionTitles.removeAll()
        addTapGestureToHideKeyboard1()
        
        if searchText != "" {
            for i in appDelegate.referencesParent {
                let a = appDelegate.referencesParent.filter({$0.id == i.id})
                if cars.contains(where: {$0.id == a.first!.id}) == false {
                    let b = SearchItem(id: Int(i.id), name: i.name!, discription: i.description2!, number: "", manufacturer: "")
                    cars.append(b)
                }
            }
            
            for i in appDelegate.curentPdf {
                if cars.contains(where: {$0.id == i.id}) == false {
                    if i.model_name != "" && i.model_name != "_" && i.model_name != nil {
                        let b = SearchItem(id: i.id!, name: i.model_name!, discription: i.manufacturer!, number: i.model_number ?? "", manufacturer: i.manufacturer ?? "")
                        cars.append(b)
                    } else {
                        let b = SearchItem(id: i.id!, name: i.model_number!, discription: i.manufacturer!, number: i.model_number ?? "", manufacturer: i.manufacturer ?? "")
                        cars.append(b)
                    }
                }
            }
            
            for i in appDelegate.parents {
                if cars.contains(where: {$0.id == i.id}) == false {
                    let b = SearchItem(id: Int(i.id), name: i.name!, discription: "a", number: "", manufacturer: "")
                    cars.append(b)
                }
            }
            
            for i in appDelegate.models {
                print("i.model \(i.name)")
                let a = appDelegate.models.filter({$0.id == i.id})
                if cars.contains(where: {$0.id == a.first!.id}) == false {
                    let b = SearchItem(id: Int(i.id), name: i.name!, discription: "a", number: "", manufacturer: "")
                    cars.append(b)
                }
            }
            cars = cars.filter({ (elemt: SearchItem) -> Bool in
                elemt.name.lowercased().contains(searchText.lowercased())
            })
        } else {
            for i in appDelegate.parents {
                let a = appDelegate.parents.filter({$0.id == i.id})
                if cars.contains(where: {$0.id == a.first!.id}) == false {
                    let b = SearchItem(id: Int(i.id), name: i.name!, discription: "a", number: "", manufacturer: "")
                    cars.append(b)
                }
            }
            for i in appDelegate.models {
                let a = appDelegate.models.filter({$0.id == i.id})
                if cars.contains(where: {$0.id == a.first!.id}) == false {
                    let b = SearchItem(id: Int(i.id), name: i.name!, discription: "a", number: "", manufacturer: "")
                    cars.append(b)
                }
            }
        }
        for car in cars {
            let carKey = String(car.name.prefix(1))
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
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.endEditing(true)
        searchBar.resignFirstResponder()
        isSearching = false
        showTable()
        return true
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
        
    }
    
    func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.view.endEditing(true)
        searchBarLbl.endEditing(true)
        searchBarLbl.resignFirstResponder()
        isSearching = false
        showTable()
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchBarLbl.endEditing(true)
        searchBar.resignFirstResponder()
        isSearching = false
        showTable()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        isSearching = false
        showTable()
    }
    
    //searchBar view
    func searchBarChange(searchBar: UISearchBar) {
        searchBar.setImage(UIImage(named: "ic_search_18px"), for: UISearchBar.Icon.search, state: UIControl.State.normal)
        searchBar.isTranslucent = true
        searchBar.alpha = 1
        searchBar.backgroundImage = UIImage()
        searchBar.barTintColor = UIColor.clear
        searchBar.layer.borderWidth = 1
        searchBar.layer.cornerRadius = 5
        searchBar.layer.borderColor = UIColor(red: 232/255, green: 234/255, blue: 235/255, alpha: 1).cgColor
        
        //SearchBar Text
        let textFieldInsideUISearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideUISearchBar?.textColor = UIColor(red: 32/255, green: 46/255, blue: 61/255, alpha: 1)
        textFieldInsideUISearchBar?.font = UIFont(name: "Lato", size: 14)
        
        //SearchBar Placeholder
        let textFieldInsideUISearchBarLabel = textFieldInsideUISearchBar!.value(forKey: "placeholderLabel") as? UILabel
        textFieldInsideUISearchBarLabel?.font = UIFont(name: "Lato", size: 14)
    }
    
    //nameLbl char range
    fileprivate func rangeChar() {
        let attributedString = nameLbl.attributedText as! NSMutableAttributedString
        attributedString.addAttribute(kCTKernAttributeName as NSAttributedString.Key, value: 3.0, range: NSMakeRange(0, attributedString.length))
        nameLbl.attributedText = attributedString
    }
    
    func showSub(nameVC: String, alpha: Double) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: nameVC)
        
        vc?.view.backgroundColor = UIColor.gray.withAlphaComponent(CGFloat(alpha))
        self.addChild(vc!)
        self.view.addSubview((vc?.view)!)
    }
    
    @objc func showCongr() {
        if Reachability.isConnectedToNetwork() == true {
            if appDelegate.subscribtion == true {
                //              showSub(nameVC: "CheckDataController", alpha: 0.2)
            }
        }
    }
    
    
    @IBAction func manufBut(_ sender: Any) {
        from = "Manuf"
        performSegue(withIdentifier: "showManufacturers", sender: (Any).self)
    }
    
    @IBAction func prodBut(_ sender: Any) {
        from = "ProdTypes"
        performSegue(withIdentifier: "showProductTypes", sender: (Any).self)
        
    }
    
    @IBAction func modelsBut(_ sender: Any) {
        from = "Models"
        performSegue(withIdentifier: "showProductTypes", sender: (Any).self)
    }
    
    
    @IBAction func alertsBut(_ sender: Any) {
        performSegue(withIdentifier: "showAlerts", sender: (Any).self)
        
    }
    
    @IBAction func favorTaped(_ sender: Any) {
        performSegue(withIdentifier: "showFavourites", sender: (Any).self)
    }
    
    @IBAction func refTaped(_ sender: Any) {
        performSegue(withIdentifier: "showRef", sender: (Any).self)
    }
    
    @IBAction func menuBut(_ sender: Any) {
        performSegue(withIdentifier: "showSideMenu2", sender: (Any).self)
    }
}

extension CepiaVC {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        let footerViewSub = UIView()
        footerViewSub.frame =  CGRect(x: 25     , y: 0, width:
            tableView.bounds.size.width - 65 , height: 0.5)
        footerView.backgroundColor = UIColor.white.withAlphaComponent(1)
        return footerView
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerLabel = UILabel()
        let headerView = UIView()
        headerView.backgroundColor = UIColor.white
        headerLabel =
            UILabel(frame: CGRect(x: 25, y: 0, width:
                tableView.bounds.size.width, height: tableView.bounds.size.height))
        headerLabel.font = UIFont(name: "Lato-Black", size: 15)
        headerLabel.textColor = UIColor(red: 181/255, green: 193/255, blue: 209/255, alpha: 1)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellCepia", for: indexPath) as! CepiaTVCell
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 241/255, green: 243/255, blue: 246/255, alpha: 1.0)
        cell.selectedBackgroundView = backgroundView
        cell.separatorInset.left = CGFloat(25)
        cell.separatorInset.right = CGFloat(40)
        // Configure the cell...
        let carKey = carSectionTitles[indexPath.section]
        if let carValues = carsDictionary[carKey] {
            let prod =  carValues[indexPath.row]
            cell.nameLbl.text = prod.name
            cell.text2 = cell.nameLbl.text ?? ""
            let id = prod.id ?? 0
            cell.id = id
            if appDelegate.curentPdf.contains(where: {$0.id == id}) {
                cell.nameLbl.text = prod.name + " \(prod.number ?? "")"
                cell.resultsLbl.text = prod.manufacturer
            }
            
            if appDelegate.parents.contains(where: {$0.id == id}) {
                let cellName = appDelegate.parents.filter({$0.id == id})
                let selectedNameID = cellName.first?.id
                let resault = appDelegate.childs.filter{$0.parent == selectedNameID}
                var resaultArr = [PdfDocumentInfo]()
                for i in resault {
                    let arr = appDelegate.curentPdf.filter({$0.prodTypeId == i.id})
                    for j in arr {
                        resaultArr.append(j)
                    }
                }
                let arr3 = resaultArr
                cell.resultsLbl.text = "\(arr3.count) Results"
            }
            if appDelegate.childs.contains(where: {$0.id == id}) {
                if appDelegate.models.contains(where: {$0.id == id}) == false {
                    var arr1 = appDelegate.curentPdf.filter({$0.id == id})
                    if arr1.isEmpty {
                        arr1 = appDelegate.curentPdf.filter({$0.id == id})
                    }
                    cell.resultsLbl.text = "\(arr1.count) Results"
                } else {
                    let arr1 = appDelegate.childs.filter({$0.id == id})
                    let arr4 = appDelegate.childs.filter({$0.name == arr1.first?.name})
                    
                    
                    for i in arr4 {
                        print("j \(i.name)")
                    }
                    
                    var arr2 = [PdfDocumentInfo]()
                    for i in arr4 {
                        let arr3 = appDelegate.curentPdf.filter({$0.prodTypeId == i.id})
                        arr2 += arr3
                    }
                    cell.resultsLbl.text = "\(arr2.count) RResults"
                }
            }
            if appDelegate.referencesParent.contains(where: {$0.id == id}) {
                let arr1 = appDelegate.referencesParent.filter({$0.id == id})
                cell.resultsLbl.text = arr1.first?.description2 ?? ""
            }
        }
        
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        tableView.sectionIndexColor = UIColor(red: 40/255, green: 36/255, blue: 58/255, alpha: 1)
        return [" "]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //parentID
        let selectedCell = tableView.cellForRow(at: indexPath) as! CepiaTVCell
        let text = selectedCell.text2
        if appDelegate.parents.contains(where: {$0.name == text}) {
            let cell = tableView.cellForRow(at: indexPath) as! CepiaTVCell
            performSegue(withIdentifier: "searchProd", sender: cell)
        } else if appDelegate.models.contains(where: {$0.name == text}) {
            let modelName = appDelegate.models.filter({$0.name == text})
             performSegue(withIdentifier: "showModels", sender: modelName.first?.name)
        } else if appDelegate.curentPdf.contains(where: {$0.model_name == text}) || appDelegate.curentPdf.contains(where: {$0.model_number == text}) {
            performSegue(withIdentifier: "searchCepia", sender: selectedCell)
        } else {
            performSegue(withIdentifier: "showRefSearch", sender: indexPath)
        }
    }
    
    //        MARK: -Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if appDelegate.subscribtion == false {
            showAlertError(withText: "Buy an annual subscription of $ 9.99 AUD for PPM Genius applications.")
        }
        if segue.identifier == "searchCepia" {
            let name = sender as! CepiaTVCell
            let vs = segue.destination as! VitalStatVC
                print("nammm \(name.nameLbl)")
            vs.id = name.id
        }
        if segue.identifier == "showManufacturers" {
            let manuf = segue.destination as! Manufacturers
            manuf.from = from
        }
        if segue.identifier == "showProductTypes" {
            let manuf = segue.destination as! ProductTypes
            manuf.from = from
        }
        if segue.identifier == "searchProd" {
            let cell = sender as! CepiaTVCell
            let arr = appDelegate.parents.filter({$0.name == cell.nameLbl.text})
            let types = segue.destination as! ProductTypes
            types.from = "Manuf"
            types.parentID = arr.first?.id
            types.manufacturer = arr.first?.name
        }
        if segue.identifier == "showModels" {
            let nameModel = sender as! String
            let types = segue.destination as! ModelsVC
            let arr1 = appDelegate.models.filter({$0.name == nameModel})
            types.parentID = arr1.first?.id
        }
        if segue.identifier == "showRefSearch" {
            let indexPath = sender as! IndexPath
            let selectedCell = tableView.cellForRow(at: indexPath) as! CepiaTVCell
            let text = selectedCell.nameLbl.text
            var selectedName = appDelegate.referencesParent.filter({$0.name == text})
            if selectedName.isEmpty == false {
                let selectedNameID = selectedName.first?.id
                let vc = segue.destination as! ReferencesVC2
                vc.parentID = selectedNameID
            } else {
                selectedName = appDelegate.referencesChild.filter({$0.name == text})
                let selectedNameID = selectedName.first?.parent
                let vc = segue.destination as! ReferencesVC2
                vc.parentID = selectedNameID
            }
        }
        showAlert = false
        searchBarLbl.text = ""
        loadDataWpBool = false
    }
    
    
    func showAlertError(withText: String) {
        let alert = UIAlertController(title: "Error Purchase", message: withText, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel)
        let subscribeAction = UIAlertAction(title: "Subscribe", style: .default) { (subscribe) in
            Store.shared.purachaseProduct()
        }
        alert.addAction(cancelAction)
        alert.addAction(subscribeAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    func showAlertError2(withText: String, title: String) {
        let alert = UIAlertController(title: title, message: withText, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .default) { (cencel) in
            self.appDelegate.favourites.removeAll()
            for controller in self.navigationController!.viewControllers as Array {
                if controller.isKind(of: LoginVC.self) {
                    self.navigationController!.popToViewController(controller, animated: true)
                    break
                }
            }
        }
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
}

class SearchItem {
    var id: Int!
    var name: String!
    var discription: String?
    var number: String?
    var manufacturer: String?
    
    init(id: Int, name: String, discription: String, number: String, manufacturer: String) {
        self.id = id
        self.name = name
        self.discription = discription
        self.number = number
        self.manufacturer = manufacturer
    }
}
