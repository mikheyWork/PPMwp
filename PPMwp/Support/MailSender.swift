import skpsmtpmessage

class MailSender: NSObject, SKPSMTPMessageDelegate {
    static let shared = MailSender()
    
    func sendEmail(subject: String, body: String) {
        let message = SKPSMTPMessage()
        message.relayHost = "smtp.gmail.com"
        message.login = "testerios69@gmail.com"
        message.pass = "123123QweQ"
        message.requiresAuth = true
        message.wantsSecure = true
        message.relayPorts = [587]
        message.fromEmail = "testerios69@gmail.com"
        message.toEmail = "vlm.softevol@gmail.com"
        message.subject = subject
        let messagePart = [kSKPSMTPPartContentTypeKey: "text/plain; charset=UTF-8", kSKPSMTPPartMessageKey: body]
        message.parts = [messagePart]
        message.delegate = self
        message.send()
    }
    
    func messageSent(_ message: SKPSMTPMessage!) {
        print("Successfully sent email!")
    }
    
    func messageFailed(_ message: SKPSMTPMessage!, error: Error!) {
        print("Sending email failed!")
    }
}
