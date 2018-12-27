import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import GTProgressBar

var progressCount2: CGFloat = 0.0 {
    didSet {
            NotificationCenter.default.post(name: NSNotification.Name("Loader"), object: nil)
    }
}

class CheckDataController: UIViewController {
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var progressBar: GTProgressBar!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var point1: CGFloat = 0.0
    var point2: CGFloat =  0.0
    var count10 = 0
    var countAll: CGFloat = 0.0
    var timePDF = [PdfDocumentInfo]()
    var timePDFRef = [PdfDocumentInfoRef]()
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.loader), name: NSNotification.Name("Loader"), object: nil)
       
        
        self.progressBar.progress = 0.0
        alertView.layer.cornerRadius = 15
        appDelegate.closeCheckData = true
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        DispatchQueue.global(qos: .userInteractive).async {
            self.point2 = CGFloat(1 / self.appDelegate.allCountDoc)
            self.checkDataPdfRef(page: 1)
            self.checkDataPdfProd(page: 1)
            if self.appDelegate.allCountDoc != 0 {
                self.checkActualData()
            }
        }
    }
    
    
    @objc func loader() {
        self.progressBar.animateTo(progress: progressCount2)
        if CGFloat(self.count10) >= self.appDelegate.allCountDoc {
            Thread.sleep(forTimeInterval: 0.15)
            DispatchQueue.main.async(flags: .barrier) {
                self.appDelegate.closeCheckData = true
                Thread.sleep(forTimeInterval: 0.5)
                self.removeFromParent()
                self.view.removeFromSuperview()
            }
        }
    }
    
    fileprivate func checkActualData() {
//        for i in appDelegate.parents {
//            if appDelegate.networkProd.contains(where: {$0 == i.name}) == false {
//                appDelegate.parents = appDelegate.parents.filter({$0.name != i.name})
//                appDelegate.removeFile(name: "\(i.name!)Alert")
//                appDelegate.removeFile(name: "\(i.name!)Info")
//                appDelegate.deleteFromCoreData(id: i.id)
//            }
//        }
//        for i in appDelegate.childs {
//            if appDelegate.networkProd.contains(where: {$0 == i.name}) == false {
//                appDelegate.childs = appDelegate.childs.filter({$0.name != i.name})
//                appDelegate.removeFile(name: "\(i.name!)Alert")
//                appDelegate.removeFile(name: "\(i.name!)Info")
//                appDelegate.deleteFromCoreData(id: i.id)
//            }
//        }
//
    
        for i in appDelegate.referencesParent {
            if appDelegate.networkRef.contains(where: {$0 == i.name}) == false {
                appDelegate.referencesParent = appDelegate.referencesParent.filter({$0.name != i.name})
                appDelegate.deleteFromCoreDataRef(id: i.id)
            }
        }
        
        for i in appDelegate.referencesChild {
            if appDelegate.networkRef.contains(where: {$0 == i.name}) == false {
                appDelegate.referencesChild = appDelegate.referencesChild.filter({$0.name != i.name})
                let name2 = PDFDownloader.shared.addPercent(fromString: i.name!)
                appDelegate.removeFile(name: name2)
                appDelegate.deleteFromCoreDataRef(id: i.id)
            }
        }
    }
    
    func checkDataPdfRef(page: Int) {
        let url = URL(string: "http://ppm.customertests.com/wp-json/wp/v2/reference?page=\(page)&per_page=100")
        guard url != nil else {
            return
        }
        
        Alamofire.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            
            guard response.result.value != nil else {
                return
            }
            let json = JSON(response.result.value!)
            let resaults = json[].arrayValue
            guard resaults.isEmpty == false else {
                return
            }
            if resaults.count == 100 {
                self.checkDataPdfRef(page: page + 1)
            }
            
            
            for resault in resaults {
                self.count10 += 1
                progressCount2 += self.point2
                var name = resault["title"]["rendered"].stringValue
                let first = name.prefix(1).uppercased()
                name = String(name.dropFirst())
                name = first + name
                let id = resault["id"].intValue
                let startLink = resault["acf"]["references"].stringValue
                let name2 = PDFDownloader.shared.addPercent(fromString: name)
                let finishLink = PDFDownloader.shared.removeHtmlSymbols(fromString: startLink, name: name2)
                
                if name != "false" && name != ""  {
                    //prog
                    if resault["parent"].intValue != 0 {
                        
                        if self.appDelegate.networkPdfRef.contains(where: {$0.id == id}) {
                            if self.appDelegate.curentPdfRef.contains(where: {$0.id == id}) {
                                
                                //chek cuttent updates
                                let networkAlertRef = self.appDelegate.curentPdfRef.filter({$0.id == id})
                                let name3 = networkAlertRef.first?.title
                                if networkAlertRef.first?.modified != resault["modified"].stringValue {
                                    self.appDelegate.networkPdfRef = self.appDelegate.networkPdfRef.filter({$0.id != id})
                                    self.appDelegate.curentPdfRef =  self.appDelegate.curentPdfRef.filter({$0.id != id})
                                    self.timePDFRef = self.timePDFRef.filter({$0.id != id})
                                    let name4 = PDFDownloader.shared.addPercent(fromString: name3!)
                                    self.appDelegate.removeFile(name: "\(name4)")
                                    
                                    let object = PdfDocumentInfoRef(id: id,
                                                                    title: name,
                                                                    link: finishLink,
                                                                    description: resault["acf"]["description"].stringValue,
                                                                    modified: resault["modified"].stringValue)
                                    
                                    self.timePDFRef.append(object)
                                    self.appDelegate.networkPdfRef.append(object)
                                    self.appDelegate.curentPdfRef.append(object)
                                    if  finishLink != "" && finishLink != "false" {
                                        let name2 = PDFDownloader.shared.addPercent(fromString: name)
                                        PDFDownloader.shared.dowloandAndSave(name: "\(name2).pdf", url: URL(string: finishLink)!)
                                        
                                    }
                                    let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: self.appDelegate.networkPdfRef)
                                    UserDefaults.standard.set(encodedData, forKey: "networkPdfRef")
                                    UserDefaults.standard.synchronize()
                                    
                                    let encodedData2: Data = NSKeyedArchiver.archivedData(withRootObject: self.appDelegate.curentPdfRef)
                                    UserDefaults.standard.set(encodedData2, forKey: "curentPdfRef")
                                    UserDefaults.standard.synchronize()
                                } else {
                                    let object = PdfDocumentInfoRef(id: id,
                                                                    title: name,
                                                                    link: finishLink,
                                                                    description: resault["acf"]["description"].stringValue,
                                                                    modified: resault["modified"].stringValue)
                                    self.timePDFRef.append(object)
                                }
                            } else {
                                if self.appDelegate.curentPdfRef.contains(where: {$0.id == id}) == false {
                                    let object = PdfDocumentInfoRef(id: id,
                                                                    title: name,
                                                                    link: finishLink,
                                                                    description: resault["acf"]["description"].stringValue,
                                                                    modified: resault["modified"].stringValue)
                                    self.timePDFRef.append(object)
                                    self.appDelegate.curentPdfRef.append(object)
                                    let name2 = PDFDownloader.shared.addPercent(fromString: name)
                                    PDFDownloader.shared.dowloandAndSave(name: "\(name2).pdf", url: URL(string: finishLink)!)
                                    let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: self.appDelegate.networkPdfRef)
                                    UserDefaults.standard.set(encodedData, forKey: "networkPdfRef")
                                    UserDefaults.standard.synchronize()
                                    let encodedData2: Data = NSKeyedArchiver.archivedData(withRootObject: self.appDelegate.curentPdfRef)
                                    UserDefaults.standard.set(encodedData2, forKey: "curentPdfRef")
                                    UserDefaults.standard.synchronize()
                                }
                            }
                        } else {
                            if self.appDelegate.curentPdfRef.contains(where: {$0.id == id}) == false {
                                let object = PdfDocumentInfoRef(id: id,
                                                                title: name,
                                                                link: finishLink,
                                                                description: resault["acf"]["description"].stringValue,
                                                                modified: resault["modified"].stringValue)
                                self.timePDFRef.append(object)
                                self.appDelegate.networkPdfRef.append(object)
                                self.appDelegate.curentPdfRef.append(object)
                                
                                let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: self.appDelegate.networkPdfRef)
                                UserDefaults.standard.set(encodedData, forKey: "networkPdfRef")
                                UserDefaults.standard.synchronize()
                                let encodedData2: Data = NSKeyedArchiver.archivedData(withRootObject: self.appDelegate.curentPdfRef)
                                UserDefaults.standard.set(encodedData2, forKey: "curentPdfRef")
                                UserDefaults.standard.synchronize()
                            }
                            
                            
                            if finishLink != "" && finishLink != "false" {
                                let name2 = PDFDownloader.shared.addPercent(fromString: name)
                                
                                PDFDownloader.shared.dowloandAndSave(name: "\(name2).pdf", url: URL(string: finishLink)!)
                            }
                        }
                    }
                    if self.progressBar.progress < 1 {
                        self.progressBar.progress += self.point2
                    }
                }
               
            }
            self.appDelegate.networkPdfRef = self.timePDFRef
            self.appDelegate.curentPdfRef = self.timePDFRef
            let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: self.appDelegate.networkPdfRef)
            UserDefaults.standard.set(encodedData, forKey: "networkPdfRef")
            UserDefaults.standard.synchronize()
            let encodedData2: Data = NSKeyedArchiver.archivedData(withRootObject: self.appDelegate.curentPdfRef)
            UserDefaults.standard.set(encodedData2, forKey: "curentPdfRef")
            UserDefaults.standard.synchronize()
            //end alamofire
        }
    }
    
    func checkDataPdfProd(page: Int) {
        
        let url = URL(string: "https://ppm.customertests.com/wp-json/wp/v2/posts?page=\(page)&per_page=100")
        guard url != nil else {
            return
        }
        
        Alamofire.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            guard response.result.value != nil else {
                return
            }
            let json = JSON(response.result.value!)
            let resaults = json[].arrayValue
            guard resaults.isEmpty == false else {
                return
            }
            if resaults.count == 100 {
                self.checkDataPdfRef(page: page + 1)
            }
            
            for resault in resaults {
                self.count10 += 1
                progressCount2 += self.point2
                var name = resault["acf"]["model_name"].stringValue
                let first = name.prefix(1).uppercased()
                name = String(name.dropFirst())
                name = first + name
                let id2 = resault["id"].intValue
                let number = resault["acf"]["model_number"].stringValue
                let parent = resault["categories"].arrayValue
                var parentId: Int64!
                let p1 = parent.first?.int64Value
                let p2 = parent.last?.int64Value
                if p1 != nil && p2 != nil {
                    if p1! < p2! {
                        parentId = p2
                    } else {
                        parentId = p1
                    }
                }
                
                if name != "false" && name != ""  || number != "false" && number != ""   {
                    var id: Int?
                    var alerts: String?
                    var model_number: String?
                    var info: String?
                    var model_name: String?
                    var manufacturer: String?
                    var modified: String?
                    var prodType: String?
                    var nbg_code: String?
                    var polarity: String?
                    var sensor_type: String?
                    var dimensions_size: String?
                    var dimensions_weight: String?
                    var connectores_pace_sense: String?
                    var mri_conditional: String?
                    var wireless_telemetry: String?
                    var remote_monitoring: String?
                    var non_magnet_rate: String?
                    var magnet_rate_bol: String?
                    var magnet_rate_eri_eol: String?
                    var patient_alert_feature: String?
                    var detach_tools: String?
                    var x_rey_id: String?
                    var nbd_code: String?
                    var max_energy: String?
                    var hv_waveform: String?
                    var connectores_hight_voltage: String?
                    var eri_notes: String?
                    var bol_characteristics: String?
                    var eri_eol_characteristics: String?
                    var lead_polarity: String?
                    var fixation: String?
                    var insulation_material: String?
                    var max_lead_diameter: String?
                    var placement: String?
                    var number_of_hv_coils: String?
                    if resault["id"].intValue != 0 {
                        id = resault["id"].intValue
                    } else {
                        id = 0
                    }
                    if resault["acf"]["alerts"] != "" &&  resault["acf"]["alerts"] != "false" {
                        alerts = resault["acf"]["alerts"].stringValue
                    } else {
                        alerts = "_"
                    }
                    if resault["acf"]["model_number"] != "" &&  resault["acf"]["model_number"] != "false" {
                        model_number = resault["acf"]["model_number"].stringValue
                    } else {
                        model_number = ""
                    }
                    if resault["acf"]["info"] != "" &&  resault["acf"]["info"] != "false" {
                        info = resault["acf"]["info"].stringValue
                    } else {
                        info = "_"
                    }
                    if resault["acf"]["model_name"] != "" &&  resault["acf"]["model_name"] != "false" {
                        model_name = resault["acf"]["model_name"].stringValue
                    } else {
                        model_name = "None"
                    }
                    if resault["acf"]["manufacturer"] != "" &&  resault["acf"]["manufacturer"] != "false" {
                        manufacturer = resault["acf"]["manufacturer"].stringValue
                    } else {
                        manufacturer = "_"
                    }
                    if resault["modified"] != "" &&  resault["modified"] != "false" {
                        modified = resault["modified"].stringValue
                    } else {
                        modified = "_"
                    }
                    if resault["acf"]["product_type"] != "" &&  resault["acf"]["product_type"] != "false" {
                        prodType = resault["acf"]["product_type"].stringValue
                    } else {
                        prodType = "_"
                    }
                    if resault["acf"]["nbg_code"] != "" &&  resault["acf"]["nbg_code"] != "false" {
                        nbg_code = resault["acf"]["nbg_code"].stringValue
                    } else {
                        nbg_code = "_"
                    }
                    if resault["acf"]["polarity"] != "" &&  resault["acf"]["polarity"] != "false" {
                        polarity = resault["acf"]["polarity"].stringValue
                    } else {
                        polarity = "_"
                    }
                    if resault["acf"]["sensor_type"] != "" &&  resault["acf"]["sensor_type"] != "false" {
                        sensor_type = resault["acf"]["sensor_type"].stringValue
                    } else {
                        sensor_type = "_"
                    }
                    if resault["acf"]["dimensions_size"] != "" &&  resault["acf"]["dimensions_size"] != "false" {
                        dimensions_size = resault["acf"]["dimensions_size"].stringValue
                    } else {
                        dimensions_size = "_"
                    }
                    if resault["acf"]["dimensions_weight"] != "" &&  resault["acf"]["model_number"] != "false" {
                        dimensions_weight = resault["acf"]["dimensions_weight"].stringValue
                    } else {
                        dimensions_weight = "_"
                    }
                    if resault["acf"]["connectores_pace_sense"] != "" &&  resault["acf"]["connectores_pace_sense"] != "false" {
                        connectores_pace_sense = resault["acf"]["connectores_pace_sense"].stringValue
                    } else {
                        connectores_pace_sense = "_"
                    }
                    if resault["acf"]["mri_conditional"] != "" &&  resault["acf"]["mri_conditional"] != "false" {
                        mri_conditional = resault["acf"]["mri_conditional"].stringValue
                    } else {
                        mri_conditional = "_"
                    }
                    if resault["acf"]["wireless_telemetry"] != "" &&  resault["acf"]["wireless_telemetry"] != "false" {
                        wireless_telemetry = resault["acf"]["wireless_telemetry"].stringValue
                    } else {
                        wireless_telemetry = "_"
                    }
                    if resault["acf"]["remote_monitoring"] != "" &&  resault["acf"]["remote_monitoring"] != "false" {
                        remote_monitoring = resault["acf"]["remote_monitoring"].stringValue
                    } else {
                        remote_monitoring = "_"
                    }
                    if resault["acf"]["non_magnet_rate"] != "" &&  resault["acf"]["non_magnet_rate"] != "false" {
                        non_magnet_rate = resault["acf"]["non_magnet_rate"].stringValue
                    } else {
                        non_magnet_rate = "_"
                    }
                    if resault["acf"]["magnet_rate_bol"] != "" &&  resault["acf"]["magnet_rate_bol"] != "false" {
                        magnet_rate_bol = resault["acf"]["magnet_rate_bol"].stringValue
                    } else {
                        magnet_rate_bol = "_"
                    }
                    if resault["acf"]["magnet_rate_eri_eol"] != "" &&  resault["acf"]["magnet_rate_eri_eol"] != "false" {
                        magnet_rate_eri_eol = resault["acf"]["magnet_rate_eri_eol"].stringValue
                    } else {
                        magnet_rate_eri_eol = "_"
                    }
                    if resault["acf"]["patient_alert_feature"] != "" &&  resault["acf"]["patient_alert_feature"] != "false" {
                        patient_alert_feature = resault["acf"]["patient_alert_feature"].stringValue
                    } else {
                        patient_alert_feature = "_"
                    }
                    if resault["acf"]["detach_tool"] != "" &&  resault["acf"]["detach_tool"] != "false" {
                        detach_tools = resault["acf"]["detach_tool"].stringValue
                    } else {
                        detach_tools = "_"
                    }
                    if resault["acf"]["x_rey_id"] != "" &&  resault["acf"]["x_rey_id"] != "false" {
                        x_rey_id = resault["acf"]["x_rey_id"].stringValue
                    } else {
                        x_rey_id = "_"
                    }
                    if resault["acf"]["nbd_code"] != "" &&  resault["acf"]["nbd_code"] != "false" {
                        nbd_code = resault["acf"]["nbd_code"].stringValue
                    } else {
                        nbd_code = "_"
                    }
                    if resault["acf"]["max_energy"] != "" &&  resault["acf"]["max_energy"] != "false" {
                        max_energy = resault["acf"]["max_energy"].stringValue
                    } else {
                        max_energy = "_"
                    }
                    if resault["acf"]["hv_waveform"] != "" &&  resault["acf"]["hv_waveform"] != "false" {
                        hv_waveform = resault["acf"]["hv_waveform"].stringValue
                    } else {
                        hv_waveform = "_"
                    }
                    if resault["acf"]["connectores_hight_voltage"] != "" &&  resault["acf"]["connectores_hight_voltage"] != "false" {
                        connectores_hight_voltage = resault["acf"]["connectores_hight_voltage"].stringValue
                    } else {
                        connectores_hight_voltage = "_"
                    }
                    if resault["acf"]["eri_notes"] != "" &&  resault["acf"]["eri_notes"] != "false" {
                        eri_notes = resault["acf"]["eri_notes"].stringValue
                    } else {
                        eri_notes = "_"
                    }
                    if resault["acf"]["bol_characteristics"] != "" &&  resault["acf"]["bol_characteristics"] != "false" {
                        bol_characteristics = resault["acf"]["bol_characteristics"].stringValue
                    } else {
                        bol_characteristics = "_"
                    }
                    if resault["acf"]["eri_eol_characteristics"] != "" &&  resault["acf"]["eri_eol_characteristics"] != "false" {
                        eri_eol_characteristics = resault["acf"]["eri_eol_characteristics"].stringValue
                    } else {
                        eri_eol_characteristics = "_"
                    }
                    if resault["acf"]["lead_polarity"] != "" &&  resault["acf"]["lead_polarity"] != "false" {
                        lead_polarity = resault["acf"]["lead_polarity"].stringValue
                    } else {
                        lead_polarity = "_"
                    }
                    if resault["acf"]["fixation"] != "" &&  resault["acf"]["fixation"] != "false" {
                        fixation = resault["acf"]["fixation"].stringValue
                    } else {
                        fixation = "_"
                    }
                    if resault["acf"]["insulation_material"] != "" &&  resault["acf"]["insulation_material"] != "false" {
                        insulation_material = resault["acf"]["insulation_material"].stringValue
                    } else {
                        insulation_material = "_"
                    }
                    if resault["acf"]["max_lead_diameter"] != "" &&  resault["acf"]["max_lead_diameter"] != "false" {
                        max_lead_diameter = resault["acf"]["max_lead_diameter"].stringValue
                    } else {
                        max_lead_diameter = "_"
                    }
                    if resault["acf"]["placement"] != "" &&  resault["acf"]["placement"] != "false" {
                        placement = resault["acf"]["placement"].stringValue
                    } else {
                        placement = "_"
                    }
                    if resault["acf"]["max_lead_diameter"] != "" &&  resault["acf"]["max_lead_diameter"] != "false" {
                        max_lead_diameter = resault["acf"]["max_lead_diameter"].stringValue
                    } else {
                        max_lead_diameter = "_"
                    }
                    if resault["acf"]["number_of_hv_coils"] != "" &&  resault["acf"]["number_of_hv_coils"] != "false" {
                        number_of_hv_coils = resault["acf"]["number_of_hv_coils"].stringValue
                    } else {
                        number_of_hv_coils = "_"
                    }
                    
                    var modelNumber2 = PDFDownloader.shared.addPercent(fromString: model_number ?? "")
                    if self.appDelegate.networkPdf.contains(where: {$0.id == id}) {
                        
                        if self.appDelegate.curentPdf.contains(where: {$0.id == id}) {
                            //chek cuttent updates
                            var networkAlert = self.appDelegate.networkPdf.filter({$0.id == id})
                            if networkAlert.isEmpty == true {
                                networkAlert = self.appDelegate.curentPdf.filter({$0.id == id})
                            }
                            
                            if networkAlert.first?.modified != resault["modified"].stringValue {
                                if  name == "" || name == "false" {
                                    self.appDelegate.networkPdf = self.appDelegate.networkPdf.filter({$0.id != id})
                                    self.appDelegate.curentPdf =  self.appDelegate.curentPdf.filter({$0.id != id})
                                    let name2 = PDFDownloader.shared.addPercent(fromString: resault["acf"]["model_name"].stringValue)
                                    self.appDelegate.removeFile(name: "\(name2)Alert")
                                    self.appDelegate.removeFile(name: "\(name2)Info")
                                } else {
                                    self.appDelegate.networkPdf = self.appDelegate.networkPdf.filter({$0.id != id})
                                    self.appDelegate.curentPdf =  self.appDelegate.curentPdf.filter({$0.id != id})
                                    self.timePDF = self.timePDF.filter({$0.id != id})
                                    let name2 = PDFDownloader.shared.addPercent(fromString: resault["acf"]["model_name"].stringValue)
                                    self.appDelegate.removeFile(name: "\(name2)Alert")
                                    self.appDelegate.removeFile(name: "\(name2)Info")
                                }
                                
                                //change
                                let object = PdfDocumentInfo(id: id,
                                                             alerts: alerts,
                                                             model_number: model_number,
                                                             info: info,
                                                             model_name: model_name,
                                                             manufacturer: manufacturer,
                                                             modified: modified,
                                                             prodType: prodType,
                                                             nbg_code: nbg_code,
                                                             polarity: polarity,
                                                             sensor_type: sensor_type,
                                                             dimensions_size: dimensions_size,
                                                             dimensions_weight: dimensions_weight,
                                                             connectores_pace_sense: connectores_pace_sense,
                                                             mri_conditional: mri_conditional,
                                                             wireless_telemetry: wireless_telemetry,
                                                             remote_monitoring: remote_monitoring,
                                                             non_magnet_rate: non_magnet_rate,
                                                             magnet_rate_bol: magnet_rate_bol,
                                                             magnet_rate_eri_eol: magnet_rate_eri_eol,
                                                             patient_alert_feature: patient_alert_feature,
                                                             detach_tools: detach_tools,
                                                             x_rey_id: x_rey_id,
                                                             nbd_code: nbd_code,
                                                             max_energy: max_energy,
                                                             hv_waveform: hv_waveform,
                                                             connectores_hight_voltage: connectores_hight_voltage,
                                                             eri_notes: eri_notes,
                                                             bol_characteristics: bol_characteristics,
                                                             eri_eol_characteristics: eri_eol_characteristics,
                                                             lead_polarity: lead_polarity,
                                                             fixation: fixation,
                                                             insulation_material: insulation_material,
                                                             max_lead_diameter: max_lead_diameter,
                                                             placement: placement,
                                                             number_of_hv_coils: number_of_hv_coils)
                                //
                                self.timePDF.append(object)
                                self.appDelegate.networkPdf.append(object)
                                self.appDelegate.curentPdf.append(object)
                                if name == "" || name == "false" {
                                    let name3 = PDFDownloader.shared.addPercent(fromString: number)
                                    PDFDownloader.shared.dowloandAndSave(name: "\(name3)Alert.pdf", url: URL(string: object.alerts!)!)
                                    PDFDownloader.shared.dowloandAndSave(name: "\(name3 + modelNumber2)Info.pdf", url: URL(string:
                                        object.info!)!)
                                } else {
                                    let name3 = PDFDownloader.shared.addPercent(fromString: name)
                                    PDFDownloader.shared.dowloandAndSave(name: "\(name3 + modelNumber2)Alert.pdf", url: URL(string: object.alerts!)!)
                                    PDFDownloader.shared.dowloandAndSave(name: "\(name3 + modelNumber2)Info.pdf", url: URL(string:
                                        object.info!)!)
                                }
                                
                                
                                
                                let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: self.appDelegate.networkPdf)
                                UserDefaults.standard.set(encodedData, forKey: "networkPdf")
                                UserDefaults.standard.synchronize()
                                
                                let encodedData2: Data = NSKeyedArchiver.archivedData(withRootObject: self.appDelegate.curentPdf)
                                UserDefaults.standard.set(encodedData2, forKey: "curentPdf")
                                UserDefaults.standard.synchronize()
                            } else {
                                let object = PdfDocumentInfo(id: id,
                                                             alerts: alerts,
                                                             model_number: model_number,
                                                             info: info,
                                                             model_name: model_name,
                                                             manufacturer: manufacturer,
                                                             modified: modified,
                                                             prodType: prodType,
                                                             nbg_code: nbg_code,
                                                             polarity: polarity,
                                                             sensor_type: sensor_type,
                                                             dimensions_size: dimensions_size,
                                                             dimensions_weight: dimensions_weight,
                                                             connectores_pace_sense: connectores_pace_sense,
                                                             mri_conditional: mri_conditional,
                                                             wireless_telemetry: wireless_telemetry,
                                                             remote_monitoring: remote_monitoring,
                                                             non_magnet_rate: non_magnet_rate,
                                                             magnet_rate_bol: magnet_rate_bol,
                                                             magnet_rate_eri_eol: magnet_rate_eri_eol,
                                                             patient_alert_feature: patient_alert_feature,
                                                             detach_tools: detach_tools,
                                                             x_rey_id: x_rey_id,
                                                             nbd_code: nbd_code,
                                                             max_energy: max_energy,
                                                             hv_waveform: hv_waveform,
                                                             connectores_hight_voltage: connectores_hight_voltage,
                                                             eri_notes: eri_notes,
                                                             bol_characteristics: bol_characteristics,
                                                             eri_eol_characteristics: eri_eol_characteristics,
                                                             lead_polarity: lead_polarity,
                                                             fixation: fixation,
                                                             insulation_material: insulation_material,
                                                             max_lead_diameter: max_lead_diameter,
                                                             placement: placement,
                                                             number_of_hv_coils: number_of_hv_coils)
                                self.timePDF.append(object)
                            }
                        } else {
                            if self.appDelegate.curentPdf.contains(where: {$0.id == id2}) == false {
                                let object = PdfDocumentInfo(id: id,
                                                             alerts: alerts,
                                                             model_number: model_number,
                                                             info: info,
                                                             model_name: model_name,
                                                             manufacturer: manufacturer,
                                                             modified: modified,
                                                             prodType: prodType,
                                                             nbg_code: nbg_code,
                                                             polarity: polarity,
                                                             sensor_type: sensor_type,
                                                             dimensions_size: dimensions_size,
                                                             dimensions_weight: dimensions_weight,
                                                             connectores_pace_sense: connectores_pace_sense,
                                                             mri_conditional: mri_conditional,
                                                             wireless_telemetry: wireless_telemetry,
                                                             remote_monitoring: remote_monitoring,
                                                             non_magnet_rate: non_magnet_rate,
                                                             magnet_rate_bol: magnet_rate_bol,
                                                             magnet_rate_eri_eol: magnet_rate_eri_eol,
                                                             patient_alert_feature: patient_alert_feature,
                                                             detach_tools: detach_tools,
                                                             x_rey_id: x_rey_id,
                                                             nbd_code: nbd_code,
                                                             max_energy: max_energy,
                                                             hv_waveform: hv_waveform,
                                                             connectores_hight_voltage: connectores_hight_voltage,
                                                             eri_notes: eri_notes,
                                                             bol_characteristics: bol_characteristics,
                                                             eri_eol_characteristics: eri_eol_characteristics,
                                                             lead_polarity: lead_polarity,
                                                             fixation: fixation,
                                                             insulation_material: insulation_material,
                                                             max_lead_diameter: max_lead_diameter,
                                                             placement: placement,
                                                             number_of_hv_coils: number_of_hv_coils)
                                self.appDelegate.networkPdf.append(object)
                                self.appDelegate.curentPdf.append(object)
                                self.timePDF.append(object)
                                if name == "" || name == "false" {
                                    let name3 = PDFDownloader.shared.addPercent(fromString: number)
                                    PDFDownloader.shared.dowloandAndSave(name: "\(name3 + modelNumber2)Alert.pdf", url: URL(string: object.alerts!)!)
                                    PDFDownloader.shared.dowloandAndSave(name: "\(name3 + modelNumber2)Info.pdf", url: URL(string:
                                        object.info!)!)
                                } else {
                                    let name3 = PDFDownloader.shared.addPercent(fromString: name)
                                    PDFDownloader.shared.dowloandAndSave(name: "\(name3 + modelNumber2)Alert.pdf", url: URL(string: object.alerts!)!)
                                    PDFDownloader.shared.dowloandAndSave(name: "\(name3 + modelNumber2)Info.pdf", url: URL(string:
                                        object.info!)!)
                                }
                                let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: self.appDelegate.networkPdf)
                                UserDefaults.standard.set(encodedData, forKey: "networkPdf")
                                UserDefaults.standard.synchronize()
                                
                                let encodedData2: Data = NSKeyedArchiver.archivedData(withRootObject: self.appDelegate.curentPdf)
                                UserDefaults.standard.set(encodedData2, forKey: "curentPdf")
                                UserDefaults.standard.synchronize()
                            }
                        }
                    } else {
                        //change
                        if self.appDelegate.curentPdf.contains(where: {$0.id == id2}) == false {
                            let object = PdfDocumentInfo(id: id,
                                                         alerts: alerts,
                                                         model_number: model_number,
                                                         info: info,
                                                         model_name: model_name,
                                                         manufacturer: manufacturer,
                                                         modified: modified,
                                                         prodType: prodType,
                                                         nbg_code: nbg_code,
                                                         polarity: polarity,
                                                         sensor_type: sensor_type,
                                                         dimensions_size: dimensions_size,
                                                         dimensions_weight: dimensions_weight,
                                                         connectores_pace_sense: connectores_pace_sense,
                                                         mri_conditional: mri_conditional,
                                                         wireless_telemetry: wireless_telemetry,
                                                         remote_monitoring: remote_monitoring,
                                                         non_magnet_rate: non_magnet_rate,
                                                         magnet_rate_bol: magnet_rate_bol,
                                                         magnet_rate_eri_eol: magnet_rate_eri_eol,
                                                         patient_alert_feature: patient_alert_feature,
                                                         detach_tools: detach_tools,
                                                         x_rey_id: x_rey_id,
                                                         nbd_code: nbd_code,
                                                         max_energy: max_energy,
                                                         hv_waveform: hv_waveform,
                                                         connectores_hight_voltage: connectores_hight_voltage,
                                                         eri_notes: eri_notes,
                                                         bol_characteristics: bol_characteristics,
                                                         eri_eol_characteristics: eri_eol_characteristics,
                                                         lead_polarity: lead_polarity,
                                                         fixation: fixation,
                                                         insulation_material: insulation_material,
                                                         max_lead_diameter: max_lead_diameter,
                                                         placement: placement,
                                                         number_of_hv_coils: number_of_hv_coils)
                            self.timePDF.append(object)
                            self.appDelegate.networkPdf.append(object)
                            self.appDelegate.curentPdf.append(object)
                            if name == "" || name == "false" {
                                let name3 = PDFDownloader.shared.addPercent(fromString: number)
                                PDFDownloader.shared.dowloandAndSave(name: "\(name3 + modelNumber2)Alert.pdf", url: URL(string: object.alerts!)!)
                                PDFDownloader.shared.dowloandAndSave(name: "\(name3 + modelNumber2)Info.pdf", url: URL(string:
                                    object.info!)!)
                            } else {
                                let name3 = PDFDownloader.shared.addPercent(fromString: name)
                                PDFDownloader.shared.dowloandAndSave(name: "\(name3 + modelNumber2)Alert.pdf", url: URL(string: object.alerts!)!)
                                PDFDownloader.shared.dowloandAndSave(name: "\(name3 + modelNumber2)Info.pdf", url: URL(string:
                                    object.info!)!)
                            }
                            
                            
                            
                            let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: self.appDelegate.networkPdf)
                            UserDefaults.standard.set(encodedData, forKey: "networkPdf")
                            UserDefaults.standard.synchronize()
                            
                            let encodedData2: Data = NSKeyedArchiver.archivedData(withRootObject: self.appDelegate.curentPdf)
                            UserDefaults.standard.set(encodedData2, forKey: "curentPdf")
                            UserDefaults.standard.synchronize()
                        }
                    }
                }
            }
            
            if self.progressBar.progress < 1 {
                self.progressBar.progress += self.point2
            }
            
//            for i in self.appDelegate.childs {
//                let a = self.appDelegate.childs.filter({$0.parent == i.id})
//                if a.isEmpty {
//                    if self.appDelegate.models.contains(where: {$0.name == i.name}) == false {
//                        self.appDelegate.models.append(i)
//                    }
//                }
//            }
            self.appDelegate.curentPdf = self.timePDF
            self.appDelegate.networkPdf = self.timePDF
            let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: self.appDelegate.networkPdf)
            UserDefaults.standard.set(encodedData, forKey: "networkPdf")
            UserDefaults.standard.synchronize()
            
            let encodedData2: Data = NSKeyedArchiver.archivedData(withRootObject: self.appDelegate.curentPdf)
            UserDefaults.standard.set(encodedData2, forKey: "curentPdf")
            UserDefaults.standard.synchronize()
        }
        //end alamofire
    }
}


