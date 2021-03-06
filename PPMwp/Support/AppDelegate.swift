import UIKit
import Alamofire
import SwiftyJSON
import CoreData
import SwiftyStoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var showDisc =  UserDefaults.standard.bool(forKey: "DiscAlert")
    var currentUser: User!
    var favourites: [String] = []
    var model: String!
    var subscribtion = false {
        didSet {
            print("subs change from \(oldValue) to \(subscribtion)")
        }
    }
    var pdfArray2 = [String]()
    
    var references = [ReferEnt]()
    var referencesParent = [ReferEnt]()
    var referencesChild = [ReferEnt]()
    var fileLocalURLDict = [String:String]()
    var curentPdf = [PdfDocumentInfo]()
    var networkPdf = [PdfDocumentInfo]()
    var curentPdfRef = [PdfDocumentInfoRef]()
    var networkPdfRef = [PdfDocumentInfoRef]()
    var productsDocCount: CGFloat! = 0.0
    var refsDocCount: CGFloat! = 0.0
    var allCountDoc: CGFloat! = 0.0
    var models = [CategoryEnt]()
    var networkProd = [String]()
    var networkRef = [String]()
    
    var closeCheckData = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        DispatchQueue.global(qos: .userInteractive).async {
            if Reachability.isConnectedToNetwork() {
                self.reqProductsDocCount(page: 1)
                self.reqRefsDocCount(page: 1)
            }
        }
        Thread.sleep(forTimeInterval: 1.0)
        if UserDefaults.standard.object(forKey: "networkPdf") != nil {
            let decoded  = UserDefaults.standard.object(forKey: "networkPdf") as! Data
            let decodedTeams = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [PdfDocumentInfo]
            self.networkPdf = decodedTeams
        }
        if UserDefaults.standard.object(forKey: "curentPdf") != nil {
            let decoded  = UserDefaults.standard.object(forKey: "curentPdf") as! Data
            let decodedTeams = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [PdfDocumentInfo]
            self.curentPdf = decodedTeams
        }
        if UserDefaults.standard.object(forKey: "networkPdfRef") != nil {
            let decoded2  = UserDefaults.standard.object(forKey: "networkPdfRef") as! Data
            let decodedTeams = NSKeyedUnarchiver.unarchiveObject(with: decoded2) as! [PdfDocumentInfoRef]
            self.networkPdfRef = decodedTeams
        } else {
            print("dont workl")
        }
        
        if UserDefaults.standard.object(forKey: "curentPdfRef") != nil {
            let decoded  = UserDefaults.standard.object(forKey: "curentPdfRef") as! Data
            let decodedTeams = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [PdfDocumentInfoRef]
            self.curentPdfRef = decodedTeams
        } else {
            print("dont workl2")
        }
        
        if Reachability.isConnectedToNetwork() {
            Store.shared.checkSub()
        }
        subscribtion = UserDefaults.standard.bool(forKey: "subscribe2")
        
//        storeKit
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                // Unlock content
                case .failed, .purchasing, .deferred:
                    break // do nothing
                }
            }
        }
        
            self.check()
        
        
        model = UIDevice.current.modelName
        showDisc = UserDefaults.standard.bool(forKey: "disclaimer2")
        
        if UserDefaults.standard.array(forKey: "savedPDF") != nil {
            pdfArray2 = UserDefaults.standard.array(forKey: "savedPDF") as! [String]
        }
        
        if UserDefaults.standard.dictionary(forKey: "dictinSaved") != nil {
            fileLocalURLDict = UserDefaults.standard.dictionary(forKey: "dictinSaved") as! [String : String]
        }
        if UserDefaults.standard.object(forKey: "currentUser") != nil {
            let decoded  = UserDefaults.standard.object(forKey: "currentUser") as! Data
            let decodedUser = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! User
            
            currentUser = decodedUser
        } else {
            print("arr is empty")
        }
        
        if UserDefaults.standard.array(forKey: "favorArr") != nil {
            favourites = UserDefaults.standard.array(forKey: "favorArr") as! [String]
        } else {
            print("favor is empty")
        }
        
        
        
//        delete data(core data)
//                removeDataFrom(entity: "CategoryEnt")
//        if need
        Store.shared.retrieveInfo()
        
        Thread.sleep(forTimeInterval: 1.5)
        //if need delete file
        //        removeFile(name: " ")
        
        return true
    }
    
    
    func removeFile(name: String) {
        //remove file
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
            let removeFile = dir.appendingPathComponent("\(name).pdf")
            let fileManager = FileManager.default
            do{
                try fileManager.removeItem(at: removeFile)
            }catch{
                print("cant remove file…")
            }
        }
    }
    
    func removeDataFrom(entity: String) {
        // create the delete request for the specified entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        // get reference to the persistent container
        let persistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        
        // perform the delete
        do {
            try persistentContainer.viewContext.execute(deleteRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    
    @objc func check() {
        if Reachability.isConnectedToNetwork() == true {
            removeDataFrom(entity: "ReferEnt")
            reqRef(page: 1)
        } else {
            fetchCoreDataRef()
        }
    }
    
    func reqProductsDocCount(page: Int) {
        let url = URL(string: "https://ppm.customertests.com/wp-json/wp/v2/posts?page=\(page)&per_page=100")
        guard url != nil else {
            return
        }
        
        Alamofire.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { [weak self] (response) in
            guard response.result.value != nil else {
                return
            }
            let json = JSON(response.result.value!)
            let resaults = json[].arrayValue
            guard resaults.isEmpty == false else {
                print("page is empty")
                return
            }
            if resaults.count == 100 {
                print("page is full, page is \(page)")
                self!.reqProductsDocCount(page: page + 1)
            } else {
                print("not full page")
            }
            self?.allCountDoc += CGFloat(resaults.count)
        }
    }
    
    func reqRefsDocCount(page: Int) {
        let url = URL(string: "http://ppm.customertests.com/wp-json/wp/v2/reference?page=\(page)&per_page=100")
        guard url != nil else {
            return
        }
        
        Alamofire.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { [weak self] (response) in
            guard response.result.value != nil else {
                return
            }
            let json = JSON(response.result.value!)
            let resaults = json[].arrayValue
            guard resaults.isEmpty == false else {
                print("page is empty")
                return
            }
            if resaults.count == 100 {
                print("page is full, page is \(page)")
                self!.reqRefsDocCount(page: page + 1)
            } else {
                print("not full page")
            }
            self?.allCountDoc += CGFloat(resaults.count)
        }
    }
    
    func reqRef(page: Int) {
        let url = URL(string: "http://ppm.customertests.com/wp-json/wp/v2/reference?page=\(page)&per_page=100")
        guard url != nil else {
            return
        }
        
        Alamofire.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            let json = JSON(response.result.value!)
            let resaults = json[].arrayValue
            guard resaults.isEmpty == false else {
                print("page is empty")
                return
            }
            if resaults.count == 100 {
                print("page is full, page is \(page)")
                self.reqRef(page: page + 1)
            } else {
                print("not full page")
            }
            for resault in resaults {
                var name = resault["title"]["rendered"].stringValue
                if name.contains("&#038;") {
                    name = PDFDownloader.shared.addAmper(fromString: name)
                }
                let first = name.prefix(1).uppercased()
                name = String(name.dropFirst())
                name = first + name
                 self.networkRef.append(name)
                let a = self.references.filter{$0.name == name}
                if a.isEmpty == false {
                    for i in a {
                        if i.parent == 0 {
                            if self.referencesParent.contains(where: {$0.name == i.name}) == false {
                                self.referencesParent.append(i)
                            }
                        } else {
                            if self.referencesChild.contains(where: {$0.name == i.name}) == false {
                                self.referencesChild.append(i)
                            }
                        }
                    }
                } else {
                   
                    self.saveRefer(name: name,
                                   id: resault["id"].intValue,
                                   parent: resault["parent"].intValue,
                                   description: resault["acf"]["description"].stringValue)
                }
            }
        }
    }
    
    func saveRefer(name: String, id: Int, parent: Int, description: String) {
        
        let context = persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "ReferEnt", in: context)
        let categObject = NSManagedObject(entity: entity!, insertInto: context) as! ReferEnt
        categObject.id = Int64(id)
        categObject.parent = Int64(parent)
        categObject.name = name
        categObject.description2 = description
        
        if context.hasChanges {
            do {
                
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        
        if categObject.parent == 0 {
            referencesParent.append(categObject)
        } else {
            referencesChild.append(categObject)
        }
    }
    
    
    func resetAllRecords(in entity : String) // entity = Your_Entity_Name
    {
        let context = ( UIApplication.shared.delegate as! AppDelegate ).persistentContainer.viewContext
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do
        {
            try context.execute(deleteRequest)
            try context.save()
        }
        catch
        {
        }
    }
    
    func deleteFromCoreData(id: Int64) {
        let context = ( UIApplication.shared.delegate as! AppDelegate ).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<CategoryEnt> = CategoryEnt.fetchRequest()
        fetchRequest.predicate = NSPredicate.init(format: "id==\(id)")
        let objects = try! context.fetch(fetchRequest)
        for obj in objects {
            if networkProd.contains(where: {$0 == obj.name}) == false {
                            context.delete(obj)
            }
        }
        
        do {
            try context.save() // <- remember to put this :)
        } catch {
            // Do something... fatalerror
        }
    }
    
    func deleteFromCoreDataRef(id: Int64) {
        let context = ( UIApplication.shared.delegate as! AppDelegate ).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<ReferEnt> = ReferEnt.fetchRequest()
        fetchRequest.predicate = NSPredicate.init(format: "id==\(id)")
        let objects = try! context.fetch(fetchRequest)
        for obj in objects {
            if networkRef.contains(where: {$0 == obj.name}) == false {
                            context.delete(obj)
            }
        }
        
        do {
            try context.save() // <- remember to put this :)
        } catch {
        }
    }
    
    
    
    func fetchCoreDataRef() {
        let context = persistentContainer.viewContext
        let fetchReq: NSFetchRequest<ReferEnt> = ReferEnt.fetchRequest()
        
        do {
            references = try context.fetch(fetchReq)
        } catch {
            print(error.localizedDescription)
        }
        filter2()
    }
    
    func filter2() {
        for i in references {
            
            if i.parent == 0 {
                referencesParent.append(i)
            } else {
                referencesChild.append(i)
            }
        }
    }
    
    //check sub
    
    func applicationWillResignActive(_ application: UIApplication) {
        NotificationCenter.default.post(name: NSNotification.Name("stopAnimation"), object: nil)
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        NotificationCenter.default.post(name: NSNotification.Name("stopAnimation"), object: nil)
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if let rootViewController = self.topViewControllerWithRootViewController(rootViewController: window?.rootViewController) {
            if (rootViewController.responds(to: Selector(("canRotate")))) {
                // Unlock landscape view orientations for this view controller
                return .allButUpsideDown;
            }
        }
        
        // Only allow portrait (standard behaviour)
        return .portrait;
    }
    
    private func topViewControllerWithRootViewController(rootViewController: UIViewController!) -> UIViewController? {
        if (rootViewController == nil) { return nil }
        if (rootViewController.isKind(of: UITabBarController.self)) {
            return topViewControllerWithRootViewController(rootViewController: (rootViewController as! UITabBarController).selectedViewController)
        } else if (rootViewController.isKind(of: UINavigationController.self)) {
            return topViewControllerWithRootViewController(rootViewController: (rootViewController as! UINavigationController).visibleViewController)
        } else if (rootViewController.presentedViewController != nil) {
            return topViewControllerWithRootViewController(rootViewController: rootViewController.presentedViewController)
        }
        return rootViewController
    }
}

extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

extension String {
    var html2AttributedString: NSAttributedString? {
        return Data(utf8).html2AttributedString
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}
