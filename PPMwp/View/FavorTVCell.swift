import UIKit

class FavorTVCell: UITableViewCell {
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var prodLbl: UILabel!
    
    @IBOutlet weak var starBut: UIButton!
    var starActive = false
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func starTaped(_ sender: Any) {
        Functions.shared.sendFavorInfo(name: prodLbl.text!, button: starBut)
        DispatchQueue.main.async {
             NotificationCenter.default.post(name: NSNotification.Name("Star"), object: nil)
        }
       
    }
}
