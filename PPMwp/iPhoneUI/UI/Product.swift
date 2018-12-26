//
//  Product.swift
//  WP.m.1
//
//  Created by softevol on 9/10/18.
//  Copyright © 2018 softevol. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MYTableViewIndex

class Product: UIViewController, UITableViewDataSource, UITableViewDelegate, TableViewIndexDataSource, TableViewIndexDelegate  {
    
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewIndex: TableViewIndex!
    
    var parentID: Int64?
    var carsDictionary = [String: [PdfDocumentInfo]]()
    var carSectionTitles = [String]()
    var cars = [PdfDocumentInfo]()
    var showIndex = false
    var name = " "
    var id = 0
    
    var manufacturer: String!
    var prodTypes: String!
    var models: String!
    var prodName: String!
    var from = ""
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
    }
    
    func indexFunc() {
        //index
        
        var display: CGFloat
        display = view.bounds.height
        
        tableViewIndex.backgroundColor = UIColor.clear
        if display < 600 {
            tableViewIndex.font = UIFont(name: "Lato", size: 8)!
            tableViewIndex.itemSpacing = 2
        } else if display < 700{
            tableViewIndex.font = UIFont(name: "Lato", size: 10)!
            tableViewIndex.itemSpacing = 4
        } else if display < 800 {
            tableViewIndex.font = UIFont(name: "Lato", size: 11)!
            tableViewIndex.itemSpacing = 4
        } else {
            tableViewIndex.font = UIFont(name: "Lato", size: 12)!
            tableViewIndex.itemSpacing = 4
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
    
    func index() {
        
        for i in appDelegate.curentPdf {
            if manufacturer != "" && manufacturer != nil {
                if prodTypes != "" && prodTypes != nil {
                    if i.manufacturer == manufacturer && i.prodType == prodTypes {
                        cars.append(i)
                    }
                }
            } else {
                if models == nil || models == "" {
                    if prodTypes != "" && prodTypes != nil {
                        if i.prodType == prodTypes {
                            cars.append(i)
                        }
                    }
                } else {
                    
                    if prodTypes != "" && prodTypes != nil {
                        if i.prodType == prodTypes && i.model_name == models {
                            cars.append(i)
                        }
                    } else {
                        print("done\(models!)/")
                        print("i. \(i.model_name!)")
                        if i.model_name == models {
                            
                            cars.append(i)
                        }
                    }
                }
            }
        }
        
        //
        for car in cars {
            var carKey = ""
            carKey = String(car.model_number?.prefix(1) ?? "")
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
    
    //    nameLbl char range
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
    
}

extension Product {
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell4", for: indexPath) as! ProductsTVCell
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 241/255, green: 243/255, blue: 246/255, alpha: 1.0)
        cell.selectedBackgroundView = backgroundView
        cell.separatorInset.left = CGFloat(25)
        cell.separatorInset.right = CGFloat(40)
        let carKey = carSectionTitles[indexPath.section]
        if let carValues = carsDictionary[carKey] {
            let prod = carValues[indexPath.row]
            cell.id = prod.id ?? 0
            cell.prodLbl.text = prod.model_number
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return [" "]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ProductsTVCell
        performSegue(withIdentifier: "showVitalStatistics", sender: cell)
    }   
    
    //MARK: -Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showVitalStatistics" {
            let name = sender as! ProductsTVCell
            let vs = segue.destination as! VitalStatVC
            vs.id = Int(name.id)
            let a = appDelegate.curentPdf.filter({$0.id == Int(name.id)})
            vs.name = a.first?.model_name ?? ""
        }
    }
}
