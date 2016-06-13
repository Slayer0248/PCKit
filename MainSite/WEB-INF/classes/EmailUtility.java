
import java.util.Date;
import java.util.Properties;
 
import javax.mail.Authenticator;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Store;
import javax.mail.Transport;
import javax.mail.internet.AddressException;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;


/* Oauth client id = 59183232439-4deb529u0kjhs67pud7r8jmp027dhctp.apps.googleusercontent.com
 * Oauth client secret = sLzF-RxpRmSmUFVLM8oBORDS
 * */
public class EmailUtility {
    public static void sendEmail(String host, String port,
            final String userName, final String password, String toAddress,
            String subject, String message) throws AddressException,
            MessagingException {
 
        // sets SMTP server properties
        Properties properties = new Properties();
        
        properties.put("mail.smtp.host", host);
        properties.put("mail.smtp.port", port);
        properties.put("mail.smtp.auth", "true");
        //properties.put("mail.smtp.socketFactory.port", "465");
        //properties.put("mail.smtp.socketFactory.class", "javax.net.ssl.SSLSocketFactory");
        //properties.put("mail.smtp.ssl.enable", "true");
        //properties.put("mail.smtp.ssl.trust", host);
        //properties.put("mail.smtp.user", "PCKitCompany");
        //properties.put("mail.smtp.password", password);
        //properties.put("mail.smtp.auth.mechanisms", "XOAUTH2");
        properties.put("mail.smtp.starttls.enable", "true");
 

        // creates a new session with an authenticator
        Authenticator auth = new Authenticator() {
            public PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication("PCKitCompany", password);
            }
        };
 
        Session session = Session.getDefaultInstance(properties, auth);
        //Session session = Session.getDefaultInstance(properties);
        //Store store = session.getStore("smtp");
        //store.connect("smtp.gmail.com", userName, password);

        // creates a new e-mail message
        Message msg = new MimeMessage(session);

        System.out.println(toAddress); 
        msg.setFrom(new InternetAddress(userName));
        //InternetAddress[] toAddresses = { new InternetAddress(toAddress) };
        msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toAddress));
        msg.setSubject(subject);
        msg.setSentDate(new Date());
        msg.setContent(message, "text/html; charset=utf-8");
 
        // sends the e-mail
        /*Transport transport = session.getTransport("smtp");


       transport.connect(host, userName, password);
       transport.sendMessage(msg, msg.getAllRecipients());
       transport.close();*/

        Transport.send(msg);
 
    }
}
