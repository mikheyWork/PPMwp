import UIKit
import GTProgressBar

class CepiaVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var searchBarLbl: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var from: String!
    var showAlert = false
    var carsDictionary = [String: [String]]()
    var carSectionTitles = [String]()
    var cars = [SearchItem]()
    var cars2 = [SearchItem]()
    var isSearching = false

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    var progressBar = GTProgressBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        NotificationCenter.default.addObserver(self, selector: #selector(showCongr), name: NSNotification.Name("Check"), object: nil)
//         NotificationCenter.default.addObserver(self, selector: #selector(fireBaseSub), name: NSNotification.Name("CheckSub"), object: nil)
        print("current user is id:\(appDelegate.currentUser.id!), name: \(appDelegate.currentUser.name!), pass: \(appDelegate.currentUser.password!), favor: \(appDelegate.currentUser.favor!) ")
        searchBarLbl.delegate = self
        
       
        
        
        
        appDelegate.subscribtion = true
        showSub(nameVC: "CheckDataController")
        
        if appDelegate.childs.count == 0 {
            appDelegate.fetchCoreDataRef()
        }
        
        if appDelegate.referencesChild.count == 0 {
            appDelegate.fetchCoreDataRef()
        }
    
        //test store
        IAPService.shared.getProducts()
        
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        rangeChar()
        
        searchBarChange(searchBar: searchBarLbl)
        showTable()
        index()
        print("app \(appDelegate.subscribtion)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let a  = appDelegate.currentUser.favor.split(separator: ",")
        if a.isEmpty == false {
            print("favor add")
            appDelegate.favourites.removeAll()
            for i in a {
                if appDelegate.favourites.contains(String(i)) == false {
                    appDelegate.favourites.append(String(i))
                }
            }
        } else {
            
        }
        
        if Reachability.isConnectedToNetwork() == true {
           
        } else {
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
    }
    
    override func viewWillLayoutSubviews() {
        addTapGestureToHideKeyboard1()
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
        
        for i in appDelegate.parents {
            let a = appDelegate.parents.filter({$0.name == i.name})
            if cars.contains(where: {$0.name == a.first!.name!}) == false {
                let b = SearchItem(id: Int(i.id), name: i.name!, discription: "a")
                cars.append(b)
            }
        }
        
        // 1
        for car in cars {
            let carKey = String(car.name.prefix(1))
            if var carValues = carsDictionary[carKey] {
                carValues.append(car.name)
                carsDictionary[carKey] = carValues
            } else {
                carsDictionary[carKey] = [car.name]
            }
        }
        
        // 2
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
            isSearching = true
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
                    let b = SearchItem(id: Int(i.id), name: i.name!, discription: i.description2!)
                    cars.append(b)
                }
            }
            
            for i in appDelegate.parents {
                let a = appDelegate.parents.filter({$0.id == i.id})
                if cars.contains(where: {$0.id == a.first!.id}) == false {
                    let b = SearchItem(id: Int(i.id), name: i.name!, discription: "a")
                    cars.append(b)
                }
            }
            for i in appDelegate.models {
                let a = appDelegate.models.filter({$0.id == i.id})
                if cars.contains(where: {$0.id == a.first!.id}) == false {
                    let b = SearchItem(id: Int(i.id), name: i.name!, discription: "a")
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
                    let b = SearchItem(id: Int(i.id), name: i.name!, discription: "a")
                    cars.append(b)
                }
            }
            for i in appDelegate.models {
                let a = appDelegate.models.filter({$0.id == i.id})
                if cars.contains(where: {$0.id == a.first!.id}) == false {
                    let b = SearchItem(id: Int(i.id), name: i.name!, discription: "a")
                    cars.append(b)
                }
            }
        }
        for car in cars {
            let carKey = String(car.name.prefix(1))
            if var carValues = carsDictionary[carKey] {
                carValues.append(car.name)
                carsDictionary[carKey] = carValues
            } else {
                carsDictionary[carKey] = [car.name]
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
    
    func showSub(nameVC: String) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: nameVC)
        
        vc?.view.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
        self.addChild(vc!)
        self.view.addSubview((vc?.view)!)
    }
    
    
    @IBAction func manufBut(_ sender: Any) {
        from = "Manuf"
        if Reachability.isConnectedToNetwork() {
            if appDelegate.closeCheckData == true {
                performSegue(withIdentifier: "showManufacturers", sender: (Any).self)
            }
        } else {
            performSegue(withIdentifier: "showManufacturers", sender: (Any).self)
        }
        
    }
    
    @IBAction func prodBut(_ sender: Any) {
        from = "ProdTypes"
        if Reachability.isConnectedToNetwork() {
            if appDelegate.closeCheckData == true {
                performSegue(withIdentifier: "showProductTypes", sender: (Any).self)
            }
        } else {
            performSegue(withIdentifier: "showProductTypes", sender: (Any).self)
        }
        
    }
    
    @IBAction func modelsBut(_ sender: Any) {
       from = "Models"
        if Reachability.isConnectedToNetwork() {
            if appDelegate.closeCheckData == true {
                performSegue(withIdentifier: "showProductTypes", sender: (Any).self)
            }
        } else {
            performSegue(withIdentifier: "showProductTypes", sender: (Any).self)
        }
    }
    
    
    @IBAction func alertsBut(_ sender: Any) {
        if Reachability.isConnectedToNetwork() {
            if appDelegate.closeCheckData == true {
                performSegue(withIdentifier: "showAlerts", sender: (Any).self)
            }
        } else {
            performSegue(withIdentifier: "showAlerts", sender: (Any).self)
        }
    }
    
    @IBAction func favorTaped(_ sender: Any) {
        if Reachability.isConnectedToNetwork() {
            if appDelegate.closeCheckData == true {
                performSegue(withIdentifier: "showFavourites", sender: (Any).self)
            }
        } else {
            performSegue(withIdentifier: "showFavourites", sender: (Any).self)
        }
    }
    
    @IBAction func refTaped(_ sender: Any) {
        if Reachability.isConnectedToNetwork() {
            if appDelegate.closeCheckData == true {
                performSegue(withIdentifier: "showRef", sender: (Any).self)
            }
        } else {
            performSegue(withIdentifier: "showRef", sender: (Any).self)
        }
    }
    
    @IBAction func menuBut(_ sender: Any) {
        if Reachability.isConnectedToNetwork() {
            if appDelegate.closeCheckData == true {
                performSegue(withIdentifier: "showSideMenu2", sender: (Any).self)
            }
        } else {
            performSegue(withIdentifier: "showSideMenu2", sender: (Any).self)
        }
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
            
            cell.nameLbl.text = carValues[indexPath.row]
            let text = cell.nameLbl.text
            if appDelegate.parents.contains(where: {$0.name == text}) {
                let cellName = appDelegate.parents.filter({$0.name == text})
                let selectedNameID = cellName.first?.id
                let resault = appDelegate.childs.filter{$0.parent == selectedNameID}
                let arr2 = appDelegate.childs.filter({$0.parent == resault.first?.id})
                var arr3 = [PdfDocumentInfo]()
                for i in arr2 {
                    var car = appDelegate.curentPdf.filter({$0.model_name == i.name})
                    if car.isEmpty == false {
                        if arr3.contains(where: {$0.model_name == i.name}) == false {
                            arr3.append(car.first!)
                        }
                    } else {
                        car = appDelegate.curentPdf.filter({$0.model_number == i.name})
                        if car.isEmpty == false {
                            if arr3.contains(where: {$0.model_number == i.name}) == false {
                                arr3.append(car.first!)
                            }
                        }
                    }
                    
                }
                cell.resultsLbl.text = "\(arr3.count) Results"
            }
            if appDelegate.childs.contains(where: {$0.name == text}) {
                var arr1 = appDelegate.curentPdf.filter({$0.model_name == text})
                if arr1.isEmpty {
                    arr1 = appDelegate.curentPdf.filter({$0.model_number == text})
                }
                cell.resultsLbl.text = "\(arr1.count) Results"
                
                
            }
            if appDelegate.referencesParent.contains(where: {$0.name == text}) {
                let arr1 = appDelegate.referencesParent.filter({$0.name == text})
                cell.resultsLbl.text = arr1.first?.description2!
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
        let text = selectedCell.nameLbl.text
        var selectedName = appDelegate.parents.filter({$0.name == text})
        var selectedNameID: Int64!
        if selectedName.isEmpty {
            selectedName = appDelegate.models.filter({$0.name == text})
            if selectedName.isEmpty {
//                let reflName = selectedName.first?.name
                if Reachability.isConnectedToNetwork() {
                    if appDelegate.referencesParent.contains(where: {$0.name == text}) {
                        if appDelegate.closeCheckData == true {
                            from = "Models"
                            performSegue(withIdentifier: "showRefSearch", sender: indexPath)
                        }
                    } else {
                        from = "Models"
                        performSegue(withIdentifier: "showRefSearch", sender: indexPath)
                    }
                } else if Reachability.isConnectedToNetwork() {
                    if appDelegate.referencesChild.contains(where: {$0.name == text}) {
                        if appDelegate.closeCheckData == true {
                            from = "Models"
                            performSegue(withIdentifier: "showRefSearch", sender: indexPath)
                        }
                    } else {
                        from = "Models"
                        performSegue(withIdentifier: "showRefSearch", sender: indexPath)
                    }
                }
            } else {
                let modelName = selectedName.first?.name
                if Reachability.isConnectedToNetwork() {
                    if appDelegate.closeCheckData == true {
                        from = "Models"
                         performSegue(withIdentifier: "searchCepia", sender: modelName)
                    }
                } else {
                    from = "Models"
                    performSegue(withIdentifier: "searchCepia", sender: modelName)
                }
               
            }
            
        } else {
            selectedNameID = selectedName.first?.id
            
            let cell = tableView.cellForRow(at: indexPath) as! CepiaTVCell

            if Reachability.isConnectedToNetwork() {
                if appDelegate.closeCheckData == true {
                    from = "Manuf"
                    performSegue(withIdentifier: "searchProd", sender: cell)
                }
            } else {
                from = "Manuf"
                performSegue(withIdentifier: "searchProd", sender: cell)
            }
            
        }
        
        
        
    }
    
    @objc func showCongr() {
        if Reachability.isConnectedToNetwork() == true {
            if showAlert == true {
                //при релизе вкл
                if appDelegate.subscribtion == true {
                    showSub(nameVC: "CheckDataController")
                }
            }
        }
    }
    
    //        MARK: -Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        print("appDel is \(appDelegate.closeCheckData)")
        print("state is \(IAPService.shared.state)")
        if IAPService.shared.state == "purchasing" {
            
        } else if IAPService.shared.state == "purchased" {
            print("purchased subs")
        } else if appDelegate.subscribtion == false {
            showAlertError(withText: "Buy an annual subscription of $ 9.99 AUD for PPM Genius applications.")
        } else {
            print("error state is \(IAPService.shared.state)")
        }
        
            //при релизе включить
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
        if segue.identifier == "searchCepia" {
            let nameModel = sender as! String
            let types = segue.destination as! VitalStatVC
            types.name = nameModel
        }
        if segue.identifier == "showRefSearch" {
            let indexPath = sender as! IndexPath
            let selectedCell = tableView.cellForRow(at: indexPath) as! CepiaTVCell
            let text = selectedCell.nameLbl.text
            var selectedName = appDelegate.referencesParent.filter({$0.name == text})
            if selectedName.isEmpty == false {
                let selectedNameID = selectedName.first?.id
                let vc = segue.destination as! ReferencesVC2
                print("selectedName2 \(String(describing: selectedNameID!))")
                vc.parentID = selectedNameID
            } else {
                selectedName = appDelegate.referencesChild.filter({$0.name == text})
                let selectedNameID = selectedName.first?.parent
                print("selectedName \(String(describing: selectedNameID!))")
                let vc = segue.destination as! ReferencesVC2
                vc.parentID = selectedNameID
            }
        }
        showAlert = false
        searchBarLbl.text = ""
    }
    
    
    func showAlertError(withText: String) {
        let alert = UIAlertController(title: "Confirm Purchase", message: withText, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel)
        let subscribeAction = UIAlertAction(title: "Subscribe", style: .default) { (subscribe) in
            IAPService.shared.purchase(product: .autoRenewingSubs)
        }
        alert.addAction(cancelAction)
        alert.addAction(subscribeAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    func showAlertError2(withText: String, title: String) {
        let alert = UIAlertController(title: title, message: withText, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .default) { (cencel) in
            
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
    
    init(id: Int, name: String, discription: String) {
        self.id = id
        self.name = name
        self.discription = discription
    }
}
