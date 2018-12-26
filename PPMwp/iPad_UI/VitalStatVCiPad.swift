import UIKit
import MYTableViewIndex
import GTProgressBar

class VitalStatVCiPad: UIViewController, UITableViewDelegate, UITableViewDataSource, TableViewIndexDelegate, TableViewIndexDataSource{
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var nameLbl2: UILabel!
    //    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var starBut: UIButton!
    @IBOutlet weak var tableView2: UITableView!
    @IBOutlet weak var tableViewIndex: TableViewIndex!
    
    
    @IBOutlet weak var tableView3: UITableView!
    
    @IBOutlet weak var tableView4: UITableView!
    
    @IBOutlet weak var tableView5: UITableView!
    
    @IBOutlet weak var tableView6: UITableView!
    
    
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var progressView: UIView!
    
    @IBOutlet weak var progressBar: GTProgressBar!
    
    
    var parentID: Int64?
    var cell: UITableViewCell!
    var starIsTaped = false
    var name = " "
    var carsDictionary = [String: [PdfDocumentInfo]]()
    var carSectionTitles = [String]()
    var cars = [PdfDocumentInfo]()
    
    var a = [PdfDocumentInfo]()
    var b = [ReferEnt]()
    
    var prodArr = [PdfDocumentInfo]()
    var fieldsDict = [String:String]()
    var keysAZ = [String]()
    var keysAZAll = [String]()
    var keysAZ1 = [String]()
    var keysAZ2 = [String]()
    var keysCount1 = 0
    var keysCount2 = 0
    var trueName = ""
    var orientation = false
    var namePdf = ""
    var readed = false
    var nameTr = ""
    var name2 = ""
    var manufacturer = ""
    var prodName: String!
    var id = 0
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.isHidden = true
        progressView.isHidden = true
        changeName()
        addDataToDict()
        trueName = name
        
        rangeChar(label: nameLbl)
        rangeChar(label: nameLbl2)
        Functions.shared.checkStar(name: String(id), button: starBut)
        indexFunc()
        //find element
        a = appDelegate.curentPdf.filter({$0.id == id })
        b = [ReferEnt]()
        if a.isEmpty == true {
            b = appDelegate.referencesChild.filter({$0.name == name })
        }
        orient()
        
        self.tableView3.rowHeight = UITableView.automaticDimension
        self.tableView3.estimatedRowHeight = 73.0
        self.tableView4.rowHeight = UITableView.automaticDimension
        self.tableView4.estimatedRowHeight = 73.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView2.reloadData()
        orient()
        name2 = name
        Functions.shared.checkStar(name: String(id), button: starBut)
        
    }
    
    override func viewWillLayoutSubviews() {
        self.tableView2.reloadData()
        indexFunc()
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        orient()
    }
    
    
    fileprivate func changeName() {
        let arr1 = appDelegate.curentPdf.filter({$0.id == id})
        var timeName = ""
        if arr1.first?.model_name != "" && arr1.first?.model_name != "" {
            timeName = arr1.first?.model_name ?? ""
        } else {
            timeName = arr1.first?.model_number ?? ""
        }
        namePdf = PDFDownloader.shared.addPercent(fromString: timeName)
        if arr1.first?.model_number != "" && arr1.first?.model_number != "_" {
            namePdf += PDFDownloader.shared.addPercent(fromString: arr1.first?.model_number ?? "")
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
    
    func orient() {
        let orient = UIDevice.current.orientation
        if orient.isLandscape {
            tableView4.isHidden = false
            tableView6.isHidden = false
            tableView5.isHidden = true
            orientation = true
        } else {
            tableView4.isHidden = true
            tableView6.isHidden = true
            tableView5.isHidden = false
            orientation = false
        }
        tableView3.reloadData()
        tableView4.reloadData()
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
        } else if display < 1500{
            tableViewIndex.font = UIFont(name: "Lato", size: 15)!
            tableViewIndex.itemSpacing = 24
        } else {
            tableViewIndex.font = UIFont(name: "Lato", size: 13)!
            tableViewIndex.itemSpacing = 5
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
            tableView2.scrollToRow(at: indexPath as IndexPath, at: .top, animated: false)
        }
        return true // return true to produce haptic feedback on capable devices
    }
    
    //    nameLbl char range
    fileprivate func rangeChar(label: UILabel) {
        let attributedString = label.attributedText as! NSMutableAttributedString
        attributedString.addAttribute(kCTKernAttributeName as NSAttributedString.Key, value: 3.0, range: NSMakeRange(0, attributedString.length))
        label.attributedText = attributedString
    }
    
    @IBAction func fScreenTaped(_ sender: Any) {
        performSegue(withIdentifier: "showFsVital", sender: nil)
    }
    
    @IBAction func backBut(_ sender: Any) {
        navigationController?.popViewController(animated: false)
    }
    
    @IBAction func menuBut(_ sender: Any) {
        //sideMenu
    }
    
    @IBAction func starBut(_ sender: Any) {
        Functions.shared.sendFavorInfo(id: id, button: starBut)
    }
    
    func checkStar() {
        if appDelegate.favourites.contains(where: {$0 == name}) {
            starBut.setImage(UIImage(named: "star_active"), for: .normal)
        } else {
            starBut.setImage(UIImage(named: "star"), for: .normal)
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

extension VitalStatVCiPad {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == self.tableView2 {
            return 20
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        if tableView == self.tableView2 {
            
            footerView.backgroundColor = UIColor(red: 32/255, green: 46/255, blue: 61/255, alpha: 1)
        }
        
        return footerView
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerLabel = UILabel()
        let headerView = UIView()
        if tableView == self.tableView2 {
            headerView.backgroundColor = UIColor(red: 32/255, green: 46/255, blue: 61/255, alpha: 1)
            headerLabel =
                UILabel(frame: CGRect(x: 30, y: 0, width:
                    tableView.bounds.size.width, height: tableView.bounds.size.height))
            headerLabel.font = UIFont(name: "Lato-Black", size: 15)
            headerLabel.textColor = UIColor.white
            headerLabel.text = self.tableView(self.tableView2, titleForHeaderInSection: section)
            headerLabel.sizeToFit()
            headerView.addSubview(headerLabel)
        }
        return headerView
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // 1
        var count: Int!
        if tableView == self.tableView2 {
            count = carSectionTitles.count
        } else {
            count = 1
        }
        return count
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.tableView2 {
            // 2
            
            let carKey = carSectionTitles[section]
            if let carValues = carsDictionary[carKey] {
                return carValues.count
            }
            return 5
        }
        if tableView == self.tableView3 {
            var count = 0
            if orientation == false {
                count = keysAZAll.count + 4
            } else {
                count = keysAZ1.count
            }
            return count
        }
        if tableView == self.tableView4 {
            var count = 0
            if orientation == false {
                count = keysAZ2.count + 4
            } else {
                count = keysAZ2.count + 4
            }
            return count
        }
        if tableView == self.tableView5 {
            return 2
        }
        if tableView == self.tableView6 {
            return 2
        }
        
        return 2
    }
    
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        
        var a: [String] = []
        
        if tableView == self.tableView2 {
            tableView.sectionIndexColor = UIColor.white
            
            a = [" "]
        }
        if tableView == self.tableView3 {
            return []
        }
        if tableView == self.tableView4 {
            return []
        }
        if tableView == self.tableView5 {
            return []
        }
        if tableView == self.tableView6 {
            return []
        }
        
        return a
    }
    
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var stringName: String!
        stringName = carSectionTitles[section]
        return stringName
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView2 {
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "CellVS", for: indexPath) as! ProdVitalTableViewCell
            cell2.separatorInset.left = CGFloat(30)
            cell2.separatorInset.right = CGFloat(50)
            // Configure the cell...
            let carKey = carSectionTitles[indexPath.section]
            var prod: PdfDocumentInfo!
            if let carValues = carsDictionary[carKey] {
                prod = carValues[indexPath.row]
                cell2.prodLbl.text = prod.model_number
                cell2.id = prod.id ?? 0
                cell2.resultLbl.text = prod.manufacturer
            }
            if cell2.id == id {
                cell2.backgroundColor = UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1)
            } else {
                cell2.backgroundColor = UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 0)
            }
            
            cell = cell2
            
        }
        
        if tableView == self.tableView3 {
            let cell3 = tableView.dequeueReusableCell(withIdentifier: "CellTable3", for: indexPath) as! VitalTVCell
            cell3.contentLbl.text = ""
            cell3.nameLbl.text = ""
            if orientation == false {
                if indexPath.row < keysAZAll.count {
                    let key = keysAZAll[indexPath.row]
                    cell3.nameLbl.text = key
                    cell3.contentLbl.text = fieldsDict[key]
                }
            } else {
                if indexPath.row < keysAZ1.count {
                    let key = keysAZ1[indexPath.row]
                    cell3.nameLbl.text = key
                    cell3.contentLbl.text = fieldsDict[key]
                }
            }
            
            
            cell = cell3
        }
        
        if tableView == tableView4 {
            let cell4 = tableView.dequeueReusableCell(withIdentifier: "CellTable4", for: indexPath) as! VitalTVCell
            cell4.contentLbl.text = ""
            cell4.nameLbl.text = ""
            if orientation == true {
                if indexPath.row < keysAZ2.count {
                    let key = keysAZ2[indexPath.row]
                    cell4.nameLbl.text = key
                    cell4.contentLbl.text = fieldsDict[key]
                }
            } else {
                if indexPath.row < keysAZ2.count {
                    let key = keysAZ2[indexPath.row]
                    cell4.nameLbl.text = key
                    cell4.contentLbl.text = fieldsDict[key]
                }
            }
            
            cell = cell4
        }
        
        if tableView == self.tableView5 {
            let cell5 = tableView.dequeueReusableCell(withIdentifier: "CellTable5", for: indexPath) as! VitalStatSeg
            if indexPath.row == 0 {
                var arr = [PdfDocumentInfo]()
                if arr.isEmpty == false {
                    arr.removeAll()
                }
                arr = appDelegate.curentPdf.filter({$0.id == id})
                let info = arr.first?.modified
                if info != nil && info != "" {
                    if arr.first?.alerts != nil && arr.first?.alerts != "" && arr.first?.alerts != "false" {
                        let a = UIImage(named: "Alert")!
                        let info2 = info?.dropLast(9)
                        cell5.imgView.image = a
                        cell5.nameLbl.text = String(info2!)
                        cell5.accessoryType = .disclosureIndicator
                        cell5.selectionStyle = .default
                        cell5.hideView.isHidden = true
                        //                        cell5.separatorColor.isHidden = false
                    } else {
                        cell5.nameLbl.text = " "
                        cell5.imgView.image = nil
                        cell5.selectionStyle = .none
                        cell5.hideView.isHidden = false
                        cell5.accessoryType = .none
                    }
                } else {
                    cell5.nameLbl.text = " "
                    cell5.imgView.image = nil
                    cell5.selectionStyle = .none
                    cell5.hideView.isHidden = false
                    cell5.accessoryType = .none
                }
            } else {
                if appDelegate.curentPdf.contains(where: {$0.id == id}) == true {
                    let a = appDelegate.curentPdf.filter({$0.id == id})
                    if a.first?.info != nil && a.first?.info != "false" && a.first?.info != "" {
                        cell5.imgView.image = UIImage(named: "Info")
                        cell5.nameLbl.text = "MRI Conditional"
                        cell5.accessoryType = .disclosureIndicator
                        cell5.selectionStyle = .default
                        cell5.hideView.isHidden = true
                    } else {
                        cell5.nameLbl.text = ""
                        cell5.imgView.image = nil
                        cell5.selectionStyle = .none
                        cell5.hideView.isHidden = false
                        cell5.accessoryType = .none
                    }
                } else {
                    cell5.nameLbl.text = ""
                    cell5.imgView.image = nil
                    cell5.selectionStyle = .none
                    cell5.hideView.isHidden = false
                    cell5.accessoryType = .none
                }
            }
            cell = cell5
        }
        
        if tableView == tableView6 {
            let cell6 = tableView.dequeueReusableCell(withIdentifier: "CellTable6", for: indexPath) as! VitalStatSeg
            if indexPath.row == 0 {
                var arr = [PdfDocumentInfo]()
                if arr.isEmpty == false {
                    arr.removeAll()
                }
                arr = appDelegate.curentPdf.filter({$0.id == id})
                let info = arr.first?.modified
                if info != nil && info != "" {
                    if arr.first?.alerts != nil && arr.first?.alerts != "" && arr.first?.alerts != "false" {
                        let a = UIImage(named: "Alert")!
                        cell6.imgView.image = a
                        
                        let info2 = info?.dropLast(9)
                        
                        cell6.nameLbl.text = String(info2!)
                        cell6.accessoryType = .disclosureIndicator
                        cell6.selectionStyle = .default
                        cell6.hideView.isHidden = true
                    } else {
                        cell6.nameLbl.text = " "
                        cell6.imgView.image = nil
                        cell6.selectionStyle = .none
                        cell6.hideView.isHidden = false
                        cell6.accessoryType = .none
                    }
                } else {
                    cell6.nameLbl.text = " "
                    cell6.imgView.image = nil
                    cell6.selectionStyle = .none
                    cell6.hideView.isHidden = false
                    cell6.accessoryType = .none
                }
            } else {
                if appDelegate.curentPdf.contains(where: {$0.id == id}) == true {
                    var a = appDelegate.curentPdf.filter({$0.id == id})
                    if a.first?.info != nil && a.first?.info != "false" && a.first?.info != "" {
                        
                        //
                        cell6.imgView.image = UIImage(named: "Info")
                        cell6.nameLbl.text = "MRI Conditional"
                        cell6.accessoryType = .disclosureIndicator
                        cell6.selectionStyle = .default
                        cell6.hideView.isHidden = true
                        //                        cell5.separatorColor.isHidden = false
                    } else {
                        cell6.nameLbl.text = ""
                        cell6.imgView.image = nil
                        cell6.selectionStyle = .none
                        cell6.hideView.isHidden = false
                        cell6.accessoryType = .none
                    }
                } else {
                    cell6.nameLbl.text = ""
                    cell6.imgView.image = nil
                    cell6.selectionStyle = .none
                    cell6.hideView.isHidden = false
                    cell6.accessoryType = .none
                }
            }
            cell = cell6
        }  
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tableView2 {
            let cell = tableView.cellForRow(at: indexPath) as! ProdVitalTableViewCell
            name = cell.text2
            name2 = name
            id = cell.id
            webView.isHidden = true
            readed = false
            addDataToDict()
            changeName()
            tableView2.reloadData()
            tableView3.reloadData()
            tableView4.reloadData()
            tableView5.reloadData()
            tableView6.reloadData()
            
        }
        
        if tableView == tableView5 || tableView == tableView6 {
            if indexPath.row == 0 {
                //search in current
                
                if appDelegate.curentPdf.contains(where: {$0.id == id}) == true {
                    var a = appDelegate.curentPdf.filter({$0.id == id})
                    if a.isEmpty == true {
                        a = appDelegate.curentPdf.filter({$0.id == id})
                    }
                    if a.first?.alerts != nil && a.first?.alerts != "" && a.first?.alerts != "false" {
                        //open pdf
                        webView.isHidden = false
                        progressView.isHidden = false
                        progressShow()
                        
                        readed = true
                        nameTr = "\(namePdf)Alert"
                        read(nameFile: "\(namePdf)Alert")
                        
                        cell.selectionStyle = .default
                    } else {
                        cell.selectionStyle = .none
                    }
                } else {
                    cell.selectionStyle = .none
                }
            } else {
                if appDelegate.curentPdf.contains(where: {$0.id == id}) == true {
                    var a = appDelegate.curentPdf.filter({$0.id == id})
                    if a.isEmpty == true {
                        a = appDelegate.curentPdf.filter({$0.id == id})
                    }
                    if a.first?.info != nil && a.first?.info != "" && a.first?.info != "false" {
                        //open pdf
                        webView.isHidden = false
                        readed = true
                        progressView.isHidden = false
                        progressShow()
                        nameTr = "\(namePdf)Info"
                        read(nameFile: "\(namePdf)Info")
                        cell.selectionStyle = .default
                    } else {
                        cell.selectionStyle = .none
                    }
                } else {
                    cell.selectionStyle = .none
                }
            }
        }
        Functions.shared.checkStar(name: String(id), button: starBut)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFsVital" {
            let vc = segue.destination as! VitalFullScrennVC
            vc.name = name
            vc.readed = readed
            vc.name2 = name2
            vc.nameRead = nameTr
            vc.id = id
        }
    }
    
    func addDataToDict() {
        
        if prodArr.isEmpty == false {
            prodArr.removeAll()
        }
        if fieldsDict.isEmpty == false {
            fieldsDict.removeAll()
        }
        if keysAZ.isEmpty == false {
            keysAZ.removeAll()
        }
        if keysAZAll.isEmpty == false {
            keysAZAll.removeAll()
        }
        if keysAZ1.isEmpty == false {
            keysAZ1.removeAll()
        }
        if keysAZ2.isEmpty == false {
            keysAZ2.removeAll()
        }
        
        prodArr = appDelegate.curentPdf.filter({$0.id == id})
        
        //start
        if prodArr.first?.manufacturer != "" && prodArr.first?.manufacturer != "_" {
            fieldsDict["Manufacturer"] = prodArr.first?.manufacturer
            keysAZ.append("Manufacturer")
        }
        if prodArr.first?.model_number != "" && prodArr.first?.model_number != "_" {
            fieldsDict["Model Number"] = prodArr.first?.model_number
            keysAZ.append("Model Number")
        }
        if prodArr.first?.model_name != "" && prodArr.first?.model_name != "_" {
            fieldsDict["Model Name"] = prodArr.first?.model_name
            keysAZ.append("Model Name")
        }
        //
        if prodArr.first?.nbg_code != "" && prodArr.first?.nbg_code != "_" {
            fieldsDict["NBG Code"] = prodArr.first?.nbg_code
            keysAZ.append("NBG Code")
        }
        if prodArr.first?.nbd_code != "" && prodArr.first?.nbd_code != "_" {
            fieldsDict["NBD Code"] = prodArr.first?.nbd_code
            keysAZ.append("NBD Code")
        }
        if prodArr.first?.sensor_type != "" && prodArr.first?.sensor_type != "_" {
            fieldsDict["Sensor Type"] = prodArr.first?.sensor_type
            keysAZ.append("Sensor Type")
        }
        if prodArr.first?.number_of_hv_coils != "" && prodArr.first?.number_of_hv_coils != "_" {
            fieldsDict["Number of HV Coils"] = prodArr.first?.number_of_hv_coils
            keysAZ.append("Number of HV Coils")
        }
        if prodArr.first?.polarity != "" && prodArr.first?.polarity != "_" {
            fieldsDict["Polarity"] = prodArr.first?.polarity
            keysAZ.append("Polarity")
        }
        if prodArr.first?.max_energy != "" && prodArr.first?.max_energy != "_" {
            fieldsDict["Max energy(Joules)"] = prodArr.first?.max_energy
            keysAZ.append("Max energy(Joules)")
        }
        if prodArr.first?.hv_waveform != "" && prodArr.first?.hv_waveform != "_" {
            fieldsDict["HV Waveform"] = prodArr.first?.hv_waveform
            keysAZ.append("HV Waveform")
        }
        if prodArr.first?.dimensions_size != "" && prodArr.first?.dimensions_size != "_" {
            fieldsDict["Dimensions: Size(H x W x D in mm)"] = prodArr.first?.dimensions_size
            keysAZ.append("Dimensions: Size(H x W x D in mm)")
        }
        if prodArr.first?.dimensions_weight != "" && prodArr.first?.dimensions_weight != "_" {
            fieldsDict["Dimensions: Weight(g)/Voltage(cc)"] = prodArr.first?.dimensions_weight
            keysAZ.append("Dimensions: Weight(g)/Voltage(cc)")
        }
        if prodArr.first?.lead_polarity != "" && prodArr.first?.lead_polarity != "_" {
            fieldsDict["Lead Polarity"] = prodArr.first?.lead_polarity
            keysAZ.append("Lead Polarity")
        }
        if prodArr.first?.fixation != "" && prodArr.first?.fixation != "_" {
            fieldsDict["Fixation (# Turns to Deploy)"] = prodArr.first?.fixation
            keysAZ.append("Fixation (# Turns to Deploy)")
        }
        if prodArr.first?.insulation_material != "" && prodArr.first?.insulation_material != "_" {
            fieldsDict["Insulation Material"] = prodArr.first?.insulation_material
            keysAZ.append("Insulation Material")
        }
        if prodArr.first?.max_lead_diameter != "" && prodArr.first?.max_lead_diameter != "_" {
            fieldsDict["Max Lead Diameter(Fr)/ Min Introducer Siz(Fr)"] = prodArr.first?.max_lead_diameter
            keysAZ.append("Max Lead Diameter(Fr)/ Min Introducer Siz(Fr)")
        }
        if prodArr.first?.connectores_pace_sense != "" && prodArr.first?.connectores_pace_sense != "_" {
            fieldsDict["Connectors Pace/Sense"] = prodArr.first?.connectores_pace_sense
            keysAZ.append("Connectors Pace/Sense")
        }
        if prodArr.first?.connectores_hight_voltage != "" && prodArr.first?.connectores_hight_voltage != "_" {
            fieldsDict["Connectors Hight Voltage"] = prodArr.first?.connectores_hight_voltage
            keysAZ.append("Connectors Hight Voltage")
        }
        if prodArr.first?.placement != "" && prodArr.first?.placement != "_" {
            fieldsDict["Placement"] = prodArr.first?.placement
            keysAZ.append("Placement")
        }
        if prodArr.first?.mri_conditional != "" && prodArr.first?.mri_conditional != "_" {
            fieldsDict["MRI Conditional"] = prodArr.first?.mri_conditional
            keysAZ.append("MRI Conditional")
        }
        if prodArr.first?.wireless_telemetry != "" && prodArr.first?.wireless_telemetry != "_" {
            fieldsDict["Wireless Telemetry"] = prodArr.first?.wireless_telemetry
            keysAZ.append("Wireless Telemetry")
        }
        if prodArr.first?.remote_monitoring != "" && prodArr.first?.remote_monitoring != "_" {
            fieldsDict["Remote Monitoring"] = prodArr.first?.remote_monitoring
            keysAZ.append("Remote Monitoring")
        }
        if prodArr.first?.eri_notes != "" && prodArr.first?.eri_notes != "_" {
            fieldsDict["ERI Notes"] = prodArr.first?.eri_notes
            keysAZ.append("ERI Notes")
        }
        if prodArr.first?.bol_characteristics != "" && prodArr.first?.bol_characteristics != "_" {
            fieldsDict["BOL Characteristics"] = prodArr.first?.bol_characteristics
            keysAZ.append("BOL Characteristics")
        }
        if prodArr.first?.non_magnet_rate != "" && prodArr.first?.non_magnet_rate != "_" {
            fieldsDict["Non Magnet Rate: BOL/(ERI/EOL)"] = prodArr.first?.non_magnet_rate
            keysAZ.append("Non Magnet Rate: BOL/(ERI/EOL)")
        }
        if prodArr.first?.magnet_rate_bol != "" && prodArr.first?.magnet_rate_bol != "_" {
            fieldsDict["Magnet Rate:BOL"] = prodArr.first?.magnet_rate_bol
            keysAZ.append("Magnet Rate:BOL")
        }
        if prodArr.first?.magnet_rate_eri_eol != "" && prodArr.first?.magnet_rate_eri_eol != "_" {
            fieldsDict["Magnet Rate:ERI/EOL"] = prodArr.first?.magnet_rate_eri_eol
            keysAZ.append("Magnet Rate:ERI/EOL")
        }
        if prodArr.first?.eri_eol_characteristics != "" && prodArr.first?.eri_eol_characteristics != "_" {
            fieldsDict["ERI/EOL Characteristics"] = prodArr.first?.eri_eol_characteristics
            keysAZ.append("ERI/EOL Characteristics")
        }
        if prodArr.first?.patient_alert_feature != "" && prodArr.first?.patient_alert_feature != "_" {
            fieldsDict["Patient Alert Feature"] = prodArr.first?.patient_alert_feature
            keysAZ.append("Patient Alert Feature")
        }
        if prodArr.first?.detach_tools != "" && prodArr.first?.detach_tools != "_" {
            fieldsDict["Detach Tool"] = prodArr.first?.detach_tools
            keysAZ.append("Detach Tool")
        }
        if prodArr.first?.x_rey_id != "" && prodArr.first?.x_rey_id != "_" {
            fieldsDict["X-ray ID"] = prodArr.first?.x_rey_id
            keysAZ.append("X-ray ID")
        }
        keysAZAll = keysAZ
        if keysAZ.count % 2 == 0 {
            // +1
            keysCount1 = keysAZ.count / 2
            keysCount2 = keysCount1
            
            for _ in 0..<keysCount1 {
                keysAZ1.append(keysAZ.first!)
                keysAZ.removeFirst()
                
            }
            for _ in 0..<keysCount2 {
                keysAZ2.append(keysAZ.first!)
                keysAZ.removeFirst()
            }
            
        } else {
            keysCount1 = (keysAZ.count / 2) + 1
            keysCount2 = keysAZ.count / 2
            
            for _ in 0..<keysCount1 {
                keysAZ1.append(keysAZ.first!)
                keysAZ.removeFirst()
                
            }
            for _ in 0..<keysCount2 {
                keysAZ2.append(keysAZ.first!)
                keysAZ.removeFirst()
            }
        }
    }
    
}
