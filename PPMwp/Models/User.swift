import Foundation

class User: NSObject, NSCoding {
    var name: String!
    var password: String!
    var favor: String!
    var id: Int!
    var subs: String!
    var disclaimer: String!
    
    init(name: String, password: String, favor: String, id: Int, subs: String, disclaimer: String) {
        self.name = name
        self.password = password
        self.favor = favor
        self.id = id
        self.subs = subs
        self.disclaimer = disclaimer
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
         let name = aDecoder.decodeObject(forKey: "name") as! String
         let password = aDecoder.decodeObject(forKey: "password") as! String
         let favor = aDecoder.decodeObject(forKey: "favor") as! String
         let id = aDecoder.decodeObject(forKey: "id") as! Int
         let subs = aDecoder.decodeObject(forKey: "subs") as! String
         let disclaimer = aDecoder.decodeObject(forKey: "disclaimer") as! String
        
        self.init(name: name, password: password, favor: favor, id: id, subs: subs, disclaimer: disclaimer)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(password, forKey: "password")
        aCoder.encode(favor, forKey: "favor")
        aCoder.encode(id, forKey: "id")
        aCoder.encode(subs, forKey: "subs")
        aCoder.encode(disclaimer, forKey: "disclaimer")
    }
}
