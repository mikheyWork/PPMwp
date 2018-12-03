import Foundation

class PdfDocumentInfoRef: NSObject, NSCoding {
    
    var id: Int?
    var title: String?
    var link: String?
    var description2: String?
    var modified: String?
    
    
    
    init(id: Int, title: String, link: String, description: String, modified: String?) {
        self.id = id
        self.title = title
        self.link = link
        self.description2 = description
        self.modified = modified
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeObject(forKey: "id2") as! Int
        let title = aDecoder.decodeObject(forKey: "title") as! String
        let link = aDecoder.decodeObject(forKey: "link") as! String
        let description2 = aDecoder.decodeObject(forKey: "description") as! String
         let modified = aDecoder.decodeObject(forKey: "modified") as! String
        self.init(id: id, title: title, link: link, description: description2, modified: modified)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id2")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(link, forKey: "link")
        aCoder.encode(description2, forKey: "description")
        aCoder.encode(modified, forKey: "modified")
    }
    
    
}

