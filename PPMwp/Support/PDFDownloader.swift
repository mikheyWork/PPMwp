import Foundation
import UIKit


class PDFDownloader: NSObject {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    private override init() { }
    static let shared = PDFDownloader()
    
   
    
    func dowloandAndSave(name: String, url: URL) {
        let filename = getDocumentsDirectory().appendingPathComponent("\(name)")
        if (!FileManager.default.fileExists(atPath: filename.path)){
            getDataFromUrl(url: url) { data, response, error in
                guard let data = data, error == nil else {
                    return
                }
                print(response?.suggestedFilename ?? url.lastPathComponent)
                
                DispatchQueue.global(qos: .userInteractive).async() {
                    try? data.write(to: filename)
                    print ("File saved at Path: \(filename)")
                }
            }
        } else {
            DispatchQueue.global(qos: .userInteractive).async() {
            print ("File already exist at Path: \(filename)")
            }
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in completion(data, response, error) }.resume()
    }

    func removeHtmlSymbols (fromString string:String, name: String) -> String {
        return string.replacingOccurrences(of: "<p>", with: "", options: .literal, range: nil).replacingOccurrences(of: "</p>", with: "", options: .literal, range: nil)
    }
    
    func addPercent (fromString string:String) -> String {
        return string.replacingOccurrences(of: " ", with: "", options: .literal, range: nil).replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
    }
    
    func addAmper (fromString string:String) -> String {
        return string.replacingOccurrences(of: "&#038;", with: "&", options: .literal, range: nil).replacingOccurrences(of: "&#038;", with: "&", options: .literal, range: nil)
    }
    
}
