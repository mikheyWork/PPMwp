import UIKit
import MYTableViewIndex


class ModelsVCiPad: UIViewController, UITableViewDelegate, UITableViewDataSource, TableViewIndexDataSource, TableViewIndexDelegate{
    
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var tableViewIndex: TableViewIndex!
    
    var from: String!
    
    var parentID: Int64?
    //    var category: [Categ] = []
    var filterArray: [CategoryEnt] = []
    
    //test
    var carsDictionary = [String: [PdfDocumentInfo]]()
    var carSectionTitles = [String]()
    var cars = [PdfDocumentInfo]()
    var manufacturer = ""
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rangeChar()
        indexFunc()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        indexFunc()
    }
    
    func index() {
        if parentID != nil {
            if manufacturer != nil && manufacturer != "" {
                let allId = appDelegate.parents.filter({$0.name == manufacturer}).first?.id
                parentID = appDelegate.childs.filter({$0.parent == allId}).first?.id
            }
            var resault = [CategoryEnt]()
            if manufacturer != "" && manufacturer != nil {
                
                let pop = appDelegate.curentPdf.filter({$0.prodTypeId == parentID})
                
                for i in pop {
                    print("pop \(i.model_name) \(i.model_number)")
                    if cars.contains(where: {$0.id == i.id}) == false {
                        cars.append(i)
                        print("\(i.model_name) \(i.model_number)")
                    }
                }
                
            } else {
                let selectedNameID = appDelegate.childs.filter({$0.id == parentID})
                resault = appDelegate.childs.filter{$0.name == selectedNameID.first?.name}
                for i in resault {
                    let resArr = appDelegate.curentPdf.filter({$0.prodTypeId == i.id})
                    for j in resArr {
                        if cars.contains(where: {$0.id == j.id}) == false {
                            cars.append(j)
                        }
                    }
                }
                for car in cars {
                    print("carr \(car.model_name)")
                }
            }
        } else {
            for i in appDelegate.curentPdf {
                cars.append(i)
            }
        }
        
        //
        for car in cars {
            var carKey = ""
            if car.model_name != "" && car.model_name != "_" {
                carKey = String(car.model_name?.prefix(1) ?? "")
                if var carValues = carsDictionary[carKey] {
                    carValues.append(car)
                    carsDictionary[carKey] = carValues
                } else {
                    carsDictionary[carKey] = [car]
                }
            } else {
                carKey = String(car.model_number?.prefix(1) ?? "q")
                if var carValues = carsDictionary[carKey] {
                    carValues.append(car)
                    carsDictionary[carKey] = carValues
                } else {
                    carsDictionary[carKey] = [car]
                }
            }
            
        }
        
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
        index()
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
    
    //    nameLbl char range
    fileprivate func rangeChar() {
        let attributedString = nameLbl.attributedText as! NSMutableAttributedString
        attributedString.addAttribute(kCTKernAttributeName as NSAttributedString.Key, value: 3.0, range: NSMakeRange(0, attributedString.length))
        nameLbl.attributedText = attributedString
    }
    
    @IBAction func backBut(_ sender: Any) {
        navigationController?.popViewController(animated: false)
    }
    
    @IBAction func menuBut(_ sender: Any) {
        //sideMenu
    }
}



extension ModelsVCiPad {
    
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
        // 1
        return carSectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // 2
        
        let carKey = carSectionTitles[section]
        if let carValues = carsDictionary[carKey] {
            return carValues.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 3
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell3", for: indexPath) as! ModelsTVCell
        
        cell.separatorInset.left = CGFloat(30)
        cell.separatorInset.right = CGFloat(50)
        // Configure the cell...
        let carKey = carSectionTitles[indexPath.section]
        if let carValues = carsDictionary[carKey] {
            let product = carValues[indexPath.row]
            cell.id = product.id ?? 0
            if product.model_name != "" && product.model_name != "_" {
                cell.nameLbl.text = product.model_name
                cell.text2 = product.model_name ?? ""
            } else {
                cell.nameLbl.text = product.model_number
                cell.text2 = product.model_number ?? ""
            }
            
            let text = cell.nameLbl.text
            var cellName = appDelegate.curentPdf.filter({$0.model_name == text})
            if cellName.isEmpty == true {
                cellName = appDelegate.curentPdf.filter({$0.model_number == text})
            }
            let a = product.model_number
            cell.resaultLbl.text = product.manufacturer
            if a != nil {
                if cell.text2 == a {
                    cell.nameLbl.text = product.model_number
                } else {
                    cell.nameLbl.text = "\(String(describing: product.model_name!)) \(a!)"
                }
            }
        }
        return cell
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        
        tableView.sectionIndexColor = UIColor.white
        
        
        //        return carSectionTitles
        return [" "]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        //parentID
        let selectedCell = tableView.cellForRow(at: indexPath) as! ModelsTVCell
        
        if from == "Manuf" {
            
            performSegue(withIdentifier: "ShowVital2", sender: selectedCell)
        }
        if from == "Models" {
            performSegue(withIdentifier: "showProduct", sender: selectedCell)
        }
    }
    
    
    //MARK: -Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showProduct" {
            let parentId = sender as! ModelsTVCell
            let text = parentId.text2
            var selectedName = appDelegate.curentPdf.filter({$0.model_name == text})
            if selectedName.isEmpty {
                selectedName = appDelegate.curentPdf.filter({$0.model_number == text})
            }
            let arr1 = appDelegate.childs.filter({$0.id == selectedName.first?.prodTypeId})
            let arr2 = appDelegate.parents.filter({$0.id == arr1.first?.parent})
            let prod = segue.destination as! ProductiPad
            prod.name = text
            prod.prodName = text
            prod.parentID = selectedName.first?.prodTypeId
            prod.manufacturer = (arr2.first?.name)!
        }
        
        if segue.identifier == "ShowVital2" {
            let parentId = sender as! ModelsTVCell
            let vitalStat = segue.destination as! VitalStatVCiPad
            vitalStat.id = parentId.id
            let a = appDelegate.curentPdf.filter({$0.id == parentId.id})
            vitalStat.manufacturer = a.first?.manufacturer ?? ""
            vitalStat.parentID = a.first?.prodTypeId ?? 0
        }
    }
}

