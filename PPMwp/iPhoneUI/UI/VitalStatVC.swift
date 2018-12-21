import UIKit
import Alamofire
import SwiftyJSON

class VitalStatVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var tableView1: UITableView!
    @IBOutlet weak var starBut: UIButton!
    
    @IBOutlet weak var tableView2: UITableView!

    
    var manufacturer2: String!
    var prodTypes: String!
    var cell: UITableViewCell!
    var name = " "
    var fieldsDict = [String:String]()
    var keysAZ = [String]()
    var prodArr = [PdfDocumentInfo]()
    var hide1 = true
    var hide2 = true
    var id = 0
   
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rangeChar()
        tableView1.isScrollEnabled = false
        prodArr = appDelegate.curentPdf.filter({$0.id == id})
        if prodArr.isEmpty == true {
            prodArr = appDelegate.curentPdf.filter({$0.model_number == name})
        }
        addDataToDict()
        
        self.tableView2.rowHeight = UITableView.automaticDimension
        
        self.tableView2.estimatedRowHeight = 73.0
    }
    
    var nameVC = "VitalStatVC"
    fileprivate func rangeChar() {
        let attributedString = nameLbl.attributedText as! NSMutableAttributedString
        attributedString.addAttribute(kCTKernAttributeName as NSAttributedString.Key, value: 3.0, range: NSMakeRange(0, attributedString.length))
        nameLbl.attributedText = attributedString
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView1.reloadData()
        Functions.shared.checkStar(name: String(id), button: starBut)
    }
    
    override func viewWillLayoutSubviews() {
        self.tableView1.reloadData()
    }
    
    fileprivate func buttonChang(senderButton: UIButton,senderSwitch: Bool) {
        if senderSwitch == false {
            starBut.setImage(UIImage(named: "star"), for: UIControl.State.normal)
        } else {
            starBut.setImage(UIImage(named: "star_active"), for: UIControl.State.normal)
        }
    }
    
    @IBAction func backBut(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func menuBut(_ sender: Any) {
        //sideMenu
    }
    
    @IBAction func starBut(_ sender: Any) {
        Functions.shared.sendFavorInfo(id: id, button: starBut)
        Functions.shared.checkStar(name: String(id), button: starBut)
    }
}

extension VitalStatVC {
    
    //MARK: -table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if tableView == tableView1 {
            count = 2
        }
        if tableView == tableView2 {
            count = keysAZ.count + 3
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == tableView1 {
            let cell1  = tableView.dequeueReusableCell(withIdentifier: "Cell5", for: indexPath) as! VitalTVCell
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor(red: 241/255, green: 243/255, blue: 246/255, alpha: 1.0)
            
            if indexPath.row == 0 {
                let arr = appDelegate.curentPdf.filter({$0.id == id})
                let info = arr.first?.modified
                cell1.doc = "Alert"
                if info != nil && info != "" {
                    if arr.first?.alerts != nil && arr.first?.alerts != "" && arr.first?.alerts != "false" {
                        let a = UIImage(named: "Alert")!
                        cell1.imgView.image = a
                        let info2 = info?.dropLast(9)
                        cell1.contentLbl.text = String(info2!)
                        cell1.accessoryType = .disclosureIndicator
                        cell1.selectionStyle = .default
                        hide1 = false
                    } else {
                        cell1.contentLbl.text = " "
                        cell1.imgView.image = nil
                        cell1.selectionStyle = .none
                        cell1.seperatorColor.backgroundColor = UIColor.white
                    }
                } else {
                    cell1.contentLbl.text = " "
                    cell1.imgView.image = nil
                    cell1.selectionStyle = .none
                    cell1.seperatorColor.backgroundColor = UIColor.white
                }
            } else {
                if appDelegate.curentPdf.contains(where: {$0.id == id}) == true {
                    cell1.doc = "Info"
                    let a = appDelegate.curentPdf.filter({$0.id == id})
                    if a.first?.info != nil && a.first?.info != "false" && a.first?.info != "" {
                        let b = UIImage(named: "Info")
                        cell1.imgView.image = b
                        cell1.contentLbl.text = "MRI Conditional"
                        cell1.accessoryType = .disclosureIndicator
                        cell1.selectionStyle = .default
                        hide2 = false
                    } else {
                        cell1.contentLbl.text = ""
                        cell1.imgView.image = nil
                        cell1.selectionStyle = .none
                        cell1.seperatorColor.backgroundColor = UIColor.white
                    }
                } else {
                    cell1.contentLbl.text = ""
                    cell1.imgView.image = nil
                    cell1.selectionStyle = .none
                    cell1.seperatorColor.backgroundColor = UIColor.white
                }
            }
            print("hide1 \(hide1)")
            print("hide2 \(hide2)")
            if hide1 == true && hide2 == true {
                tableView.isHidden = true
            } else {
                tableView.isHidden = false
            }
            cell = cell1
        }
        if tableView == tableView2 {
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "VitalStatInfo", for: indexPath) as! VitalTVCell2
            cell2.nameLbl.text = ""
            cell2.contentLbl.text = ""
            if indexPath.row < keysAZ.count {
                let key = keysAZ[indexPath.row]
                cell2.nameLbl.text = key
                cell2.contentLbl.text = fieldsDict[key]
            }
            
           cell = cell2
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if indexPath.row == 0 {
            //search in current
            if appDelegate.curentPdf.contains(where: {$0.id == id}) == true {
                let a = appDelegate.curentPdf.filter({$0.id == id})
                if a.first?.alerts != nil && a.first?.alerts != "" && a.first?.alerts != "false" {
                    performSegue(withIdentifier: "showPDF", sender: indexPath)
                    cell.selectionStyle = .default
                } else {
                    cell.selectionStyle = .none
                }
            } else {
                cell.selectionStyle = .none
            }
        } else {
            if appDelegate.curentPdf.contains(where: {$0.id == id}) == true {
                let a = appDelegate.curentPdf.filter({$0.id == id})
                if a.first?.info != nil && a.first?.info != "" && a.first?.info != "false" {
                    performSegue(withIdentifier: "showPDF", sender: indexPath)
                    cell.selectionStyle = .default
                } else {
                    cell.selectionStyle = .none
                }
            } else {
                cell.selectionStyle = .none
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPDF" {
            let indexPath = sender as! IndexPath
            let cell = tableView(tableView1, cellForRowAt: indexPath) as! VitalTVCell
            let pDFLoadVC = segue.destination as! PDFviewerVC
            pDFLoadVC.nameVC = nameVC
            pDFLoadVC.id = id
            pDFLoadVC.doc = cell.doc
            print("1 \(nameVC)")
            print("2 \(id)")
            print("3 \(cell.doc)")
        }
    }
    
    func addDataToDict() {
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
    }
}
