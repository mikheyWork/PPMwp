//
//  Functions.swift
//  PPMwp
//
//  Created by softevol on 11/22/18.
//  Copyright © 2018 softevol. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class Functions: NSObject {
    
    
    private override init() { }
    static let shared = Functions()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    
    func requestChangeParam(parameters: Parameters) {
        guard self.appDelegate.currentUser.id != 0 && self.appDelegate.currentUser != nil else {
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
                          parameters: parameters,
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
                }
        }
    }
    
    func checkStar(name: String, button: UIButton) {
        if appDelegate.favourites.contains(where: {$0 == name}) {
            button.setImage(UIImage(named: "star_active"), for: .normal)
        } else {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name("Star"), object: nil)
            }
            button.setImage(UIImage(named: "star"), for: .normal)
        }
    }
    
    func sendFavorInfo(id: Int, button: UIButton) {
        DispatchQueue.global(qos: .userInitiated).async {
            var favor: String!
            let name = String(id)
            if self.appDelegate.curentPdf.contains(where: {$0.id == id}) == true || self.appDelegate.curentPdfRef.contains(where: {$0.id == id}) == true {
                
                if self.appDelegate.favourites.contains(name) == true {
                    //delete
                    self.appDelegate.favourites = self.appDelegate.favourites.filter({$0 != name})
                } else {
                    //add
                    self.appDelegate.favourites.append(name)
                }
                favor = self.appDelegate.favourites.joined(separator: ",")
                if Reachability.isConnectedToNetwork() {
                    //add to wp
                    let user = self.appDelegate.currentUser.name!
                    let password = self.appDelegate.currentUser.password!
                    let url = URL(string: "https://ppm.customertests.com/wp-json/wp/v2/users/\(self.appDelegate.currentUser.id!)")
                    let credentialData = "\(user):\(password)".data(using: String.Encoding.utf8)!
                    let base64Credentials = credentialData.base64EncodedString(options: [])
                    let headers = ["Authorization": "Basic \(base64Credentials)"]
                    
                    let parameters: Parameters = ["description": favor!]
                    
                    Alamofire.request(url!,
                                      method: .post,
                                      parameters: parameters,
                                      encoding: URLEncoding.default,
                                      headers:headers)
                        .responseJSON { (response) in
                            guard response.result.value != nil else {
                                return
                            }
                            let json = JSON(response.result.value!)
                            let id: Int!
                            id = json["id"].intValue
                            if id != nil && id != 0 {
                                let user = User(name: self.appDelegate.currentUser.name,
                                                password: self.appDelegate.currentUser.password!,
                                                favor: json["description"].stringValue,
                                                id: json["id"].intValue,
                                                subs: json["first_name"].stringValue,
                                                disclaimer: json["last_name"].stringValue)
                                self.appDelegate.currentUser = user
                                
                                let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: self.appDelegate.currentUser)
                                UserDefaults.standard.set(encodedData, forKey: "currentUser")
                                UserDefaults.standard.synchronize()
                            }
                            
                            UserDefaults.standard.set(self.appDelegate.favourites, forKey: "favorArr")
                    }
                    DispatchQueue.main.async {
                        self.checkStar(name: name, button: button)
                    }
                } else {
                    let user = User(name: self.appDelegate.currentUser.name,
                                    password: self.appDelegate.currentUser.password!,
                                    favor: favor,
                                    id: self.appDelegate.currentUser.id,
                                    subs: self.appDelegate.currentUser.subs,
                                    disclaimer: self.appDelegate.currentUser.disclaimer)
                    self.appDelegate.currentUser = user
                    
                    let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: self.appDelegate.currentUser)
                    UserDefaults.standard.set(encodedData, forKey: "currentUser")
                    UserDefaults.standard.synchronize()
                }
                
                UserDefaults.standard.set(self.appDelegate.favourites, forKey: "favorArr")
            }
        }
        DispatchQueue.main.async {
            Functions.shared.checkStar(name: String(id), button: button)
        }
    }
    
    func filterSearch( cars: inout Array<SearchItem>, searchText: String) {
        for i in appDelegate.referencesParent {
            let a = appDelegate.referencesParent.filter({$0.id == i.id})
            if cars.contains(where: {$0.id == a.first!.id}) == false {
                let b = SearchItem(id: Int(i.id), name: i.name!, discription: i.description2!, number: "", manufacturer: "", fullName: i.name!)
                cars.append(b)
            }
        }
        
        for i in appDelegate.curentPdf {
            if cars.contains(where: {$0.id == i.id}) == false {
                if i.model_name != "" && i.model_name != "_" && i.model_name != nil {
                    let b = SearchItem(id: i.id!, name: i.model_name!, discription: i.manufacturer!, number: i.model_number ?? "", manufacturer: i.manufacturer ?? "", fullName: (i.model_name ?? "") + (i.model_number ?? ""))
                    cars.append(b)
                } else {
                    let b = SearchItem(id: i.id!, name: i.model_number!, discription: i.manufacturer!, number: i.model_number ?? "", manufacturer: i.manufacturer ?? "", fullName: (i.model_number ?? "") + (i.model_number ?? ""))
                    cars.append(b)
                }
            }
        }
        
        for i in appDelegate.parents {
            
            let arr1 = appDelegate.parents.filter({$0.name == i.name})
            let arr2 = appDelegate.childs.filter({$0.parent == arr1.first?.id})
            let arr3 = appDelegate.curentPdf.filter({$0.prodTypeId == arr2.first?.id})
            if arr3.count > 0 {
                if cars.contains(where: {$0.id == i.id}) == false {
                    let b = SearchItem(id: Int(i.id), name: i.name!, discription: "a", number: "", manufacturer: "", fullName: i.name!)
                    cars.append(b)
                }
            }
        }
        
        for i in appDelegate.models {
            let arr1 = appDelegate.childs.filter({$0.id == i.id})
            var arr2 = [PdfDocumentInfo]()
            if arr1.isEmpty == false{
                arr2 = appDelegate.curentPdf.filter({$0.prodTypeId == arr1.first?.id})
            }
            if arr2.count > 0 {
                let a = appDelegate.models.filter({$0.id == i.id})
                if cars.contains(where: {$0.id == a.first!.id}) == false {
                    let b = SearchItem(id: Int(i.id), name: i.name!, discription: "a", number: "", manufacturer: "", fullName: i.name!)
                    cars.append(b)
                }
            }
        }
        cars = cars.filter({ (elemt: SearchItem) -> Bool in
            elemt.fullName?.lowercased().contains(searchText.lowercased()) ?? false
        })
    }
    
}
