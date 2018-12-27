import UIKit
import MYTableViewIndex


class ProductTypesiPad: UIViewController, UITableViewDelegate, UITableViewDataSource, TableViewIndexDataSource, TableViewIndexDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var tableViewIndex: TableViewIndex!
    
    
    //MARK: -variales
    var from: String!
    var parentID: Int64?
    var carsDictionary = [String: [PdfDocumentInfo]]()
    var carSectionTitles = [String]()
    var cars = [PdfDocumentInfo]()
    var cars2 = [PdfDocumentInfo]()
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
        
        self.tableView.reloadData()
        indexFunc()
    }
    
    func index() {
        
        for i in appDelegate.curentPdf {
            if manufacturer != nil && manufacturer != "" {
                if i.manufacturer == manufacturer {
                    if cars.contains(where: {$0.prodType == i.prodType}) == false {
                        cars.append(i)
                    }
                }
            } else {
                if cars.contains(where: {$0.prodType == i.prodType}) == false {
                    cars.append(i)
                }
            }
        }
        
        
        for car in cars {
            var name = ""
            if car.model_name != "" && car.model_name != "_" {
                name = car.model_name ?? ""
            } else {
                name = car.model_number ?? ""
            }
            let carKey = String(name.prefix(1))
            if var carValues = carsDictionary[carKey] {
                carValues.append(car)
                carsDictionary[carKey] = carValues
            } else {
                carsDictionary[carKey] = [car]
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

extension ProductTypesiPad {
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath) as! ProductTypesTVCell
        
        cell.separatorInset.left = CGFloat(30)
        cell.separatorInset.right = CGFloat(30)
        
        cell.separatorInset.left = CGFloat(30)
        cell.separatorInset.right = CGFloat(50)
        // Configure the cell...
        let carKey = carSectionTitles[indexPath.section]
        if let carValues = carsDictionary[carKey] {
            let prod = carValues[indexPath.row]
            cell.nameLbl.text = prod.prodType
            var ressArray = appDelegate.curentPdf.filter({$0.prodType == cell.nameLbl.text})
            if manufacturer != "" && manufacturer != nil {
                ressArray = ressArray.filter({$0.manufacturer == manufacturer})
            }
            cell.resaultLbl.text = "\(ressArray.count) Results"
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
        let selectedCell = tableView.cellForRow(at: indexPath) as! ProductTypesTVCell
        if from == "Manuf" {
            performSegue(withIdentifier: "ShowProd2", sender: selectedCell)
        }
        if from == "Models" {
            performSegue(withIdentifier: "showModel", sender: selectedCell)
        }
        if from == "ProdTypes" {
            performSegue(withIdentifier: "ShowProd2", sender: selectedCell)
        }
    }
    
    //MARK: -Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showModel" {
            let types = segue.destination as! ModelsVCiPad
            let cell = sender as! ProductTypesTVCell
            types.prodTypes = cell.nameLbl.text ?? ""
            types.manufacturer = manufacturer
            types.from = from
        }
        if segue.identifier == "ShowProd2" {
            let types = segue.destination as! ProductiPad
            let cell = sender as! ProductTypesTVCell
            types.prodTypes = cell.nameLbl.text
            types.manufacturer = manufacturer
            types.from = from
        }
    }
}
