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
    var carsDictionary = [String: [String]]()
    var carSectionTitles = [String]()
    var cars = [String]()
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
            if  manufacturer != "" {
                let allId = appDelegate.parents.filter({$0.name == manufacturer}).first?.id
                parentID = appDelegate.childs.filter({$0.parent == allId}).first?.id
            }
            var resault = [CategoryEnt]()
            if manufacturer != "" {
                
                let pop = appDelegate.curentPdf.filter({$0.prodTypeId == parentID})
                
                for i in pop {
                    if cars.contains(where: {$0 == i.model_name}) == false && cars.contains(where: {$0 == i.model_number}) == false {
                        var name = i.model_name
                        if name == nil || name == "" {
                            name = i.model_number
                        }
                        cars.append(name!)
                    }
                }
                
            } else {
                let selectedNameID = appDelegate.childs.filter({$0.id == parentID})
                resault = appDelegate.childs.filter{$0.name == selectedNameID.first?.name}
                for i in resault {
                    let resArr = appDelegate.curentPdf.filter({$0.prodTypeId == i.id})
                    for j in resArr {
                        if cars.contains(where: {$0 == j.model_name}) == false && cars.contains(where: {$0 == j.model_number}) == false {
                            var name = j.model_name
                            if name == nil || name == "" {
                                name = j.model_number
                            }
                            cars.append(name!)
                        }
                    }
                }
            }
        } else {
            for i in appDelegate.curentPdf {
                cars.append(i.model_name!)
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
            cell.nameLbl.text = carValues[indexPath.row]
            cell.text2 = carValues[indexPath.row]
            let text = cell.nameLbl.text
            var cellName = appDelegate.curentPdf.filter({$0.model_name == text})
            if cellName.isEmpty == true {
                cellName = appDelegate.curentPdf.filter({$0.model_number == text})
            }
            let selectedNameID = cellName.first?.manufacturer
            let a = cellName.first?.model_number!
            cell.resaultLbl.text = selectedNameID
            if a != nil {
                if cell.text2 == a {
                    cell.nameLbl.text = carValues[indexPath.row]
                } else {
                    cell.nameLbl.text = "\(carValues[indexPath.row]) \(a!)"
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
        let text = selectedCell.text2
        var selectedName = appDelegate.curentPdf.filter({$0.model_name == text})
        if selectedName.isEmpty {
            selectedName = appDelegate.curentPdf.filter({$0.model_number == text})
        }
        let selectedNameID = selectedName.first?.id
        if from == "Manuf" {
            
            performSegue(withIdentifier: "ShowVital2", sender: selectedNameID)
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
            let parentId = sender as! Int
            let vs = segue.destination as! VitalStatVCiPad
            let filterArr = appDelegate.curentPdf.filter({$0.id == parentId})
            
            var name2 = filterArr.first?.model_name
            if name2 == "" {
                name2 = filterArr.first?.model_number
            }
            if name2 != nil {
                vs.name = name2!
                vs.parentID = filterArr.first?.prodTypeId
                vs.manufacturer = manufacturer
                vs.prodName = name2
            }
            
        }
        
        }
    
}

