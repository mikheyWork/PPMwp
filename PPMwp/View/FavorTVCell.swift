import UIKit

class FavorTVCell: UITableViewCell {
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var id = 0
    @IBOutlet weak var prodLbl: UILabel!
    
    @IBOutlet weak var starBut: UIButton!
    var starActive = false
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        Functions.shared.checkStar(name: String(id), button: starBut)
    }
    
    @IBAction func starTaped(_ sender: Any) {
        Functions.shared.sendFavorInfo(id: id, button: starBut)
        DispatchQueue.main.async {
             NotificationCenter.default.post(name: NSNotification.Name("Star"), object: nil)
        }
    }
}
