import skpsmtpmessage
import Foundation


class MailSender: NSObject, SKPSMTPMessageDelegate {
    static let shared = MailSender()
    
    func sendEmail(subject: String, body: String, mail: String) {
        let message = SKPSMTPMessage()
        message.relayHost = "smtp.gmail.com"
        message.login = "testerios69@gmail.com"
        message.pass = "123123QweQ"
        message.requiresAuth = true
        message.wantsSecure = true
        message.relayPorts = [587]
        message.fromEmail = "testerios69@gmail.com"
        message.toEmail = mail
        message.subject = subject
        let messagePart = [kSKPSMTPPartContentTypeKey: "text/plain; charset=UTF-8", kSKPSMTPPartMessageKey: body]
        message.parts = [messagePart]
        message.delegate = self
        message.send()
    }
    
    func messageSent(_ message: SKPSMTPMessage!) {
        print("Successfully sent email!")
        DispatchQueue.main.async{
            NotificationCenter.default.post(name: NSNotification.Name("AlertTrue"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name("soop"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name("Alert2"), object: nil)
        }
    }
    
    func messageFailed(_ message: SKPSMTPMessage!, error: Error!) {
        print("Sending email failed!")
        DispatchQueue.main.async{
            NotificationCenter.default.post(name: NSNotification.Name("AlertFalse"), object: nil) 
            NotificationCenter.default.post(name: NSNotification.Name("soop2"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name("Alert"), object: nil)
        }
    }
}
