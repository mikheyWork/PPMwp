//
//  AlertsFSVC.swift
//  WP.m.1
//
//  Created by softevol on 10/1/18.
//  Copyright © 2018 softevol. All rights reserved.
//

import UIKit

class AlertsFSVC: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var imgView: UIImageView!
    
    var name = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if name != "" {
            name = PDFDownloader.shared.addPercent(fromString: name)
            read(nameFile: name)
            self.view.backgroundColor = UIColor.white
            imgView.isHidden = true
            webView.isHidden = false
        } else {
            webView.isHidden = true
            imgView.isHidden = false
            self.view.backgroundColor = UIColor(red: 234/255, green: 34/255, blue: 37/255, alpha: 1)
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
    
    @IBAction func backBut(_ sender: Any) {
        navigationController?.popViewController(animated: false)
    }
    
    @IBAction func backBut2(_ sender: Any) {
        navigationController?.popViewController(animated: false)
    }
    
    @IBAction func menuBut(_ sender: Any) {
        //sideMenu
    }

}
