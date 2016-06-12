
import java.io.*;
import java.util.*;
import java.sql.*;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/response")
public class MailingListServlet extends HttpServlet {
    private String host;
    private String port;
    private String user;
    private String pass;
    
    public void init() {
        // reads SMTP server setting from web.xml file
        ServletContext context = getServletContext();
        host = context.getInitParameter("host");
        port = context.getInitParameter("port");
        user = context.getInitParameter("user");
        pass = context.getInitParameter("pass");
    }
   
   /*@Override
   public void doGet(HttpServletRequest request, HttpServletResponse response)
         throws IOException, ServletException {
         
        String pageMessage = "This page's content can't be accessed as specified.";
        String address = "/WEB-INF/mailingList.jsp";
        request.getRequestDispatcher(address).forward(request, response);
   }*/
   
   @Override
   public void doPost(HttpServletRequest request, HttpServletResponse response)
         throws IOException, ServletException {
      String pageMessage = "Invalid Post Request.";
      String mailMessage = "";
      String action = request.getParameter("action");
      if (action.equals("AddEmail")) {
         String firstName = request.getParameter("firstName");
         String lastName = request.getParameter("lastName");
         String email = request.getParameter("Email");
         String company = request.getParameter("Company");
         String interest = request.getParameter("Interest").equals("other")? request.getParameter("InterestOther") : request.getParameter("Interest");
         String adMedium = request.getParameter("AdMedium").equals("other")? request.getParameter("AdMediumOther") : request.getParameter("AdMedium");
         String notes = request.getParameter("Notes");
                  
                  //out.println("<p id='form-description'>" + firstName+ ", " +lastName+ ", " +email+", " +company+", " +interest+", " +adMedium+", " +notes+"</p>");
                  
         Connection connection = null;
         PreparedStatement pstatement = null;
         
         try {
            Class.forName("com.mysql.jdbc.Driver");
            int updateQuery = 0;
            connection = DriverManager.getConnection("jdbc:mysql://localhost/PCKitDB","root","Potter11a");
            String queryString = "INSERT INTO mailList(first,last,email,company,relationship,publicity,otherInfo) VALUES (?, ?, ?, ?, ?, ?, ?)";
            pstatement = connection.prepareStatement(queryString);
            pstatement.setString(1, firstName);
            pstatement.setString(2, lastName);
            pstatement.setString(3, email);
            pstatement.setString(4, company);
            pstatement.setString(5, interest);
            pstatement.setString(6, adMedium);
            pstatement.setString(7, notes);
            updateQuery = pstatement.executeUpdate();
                  
            if (updateQuery != 0) {
               mailMessage = mailMessage + "Hello " + firstName + " " + lastName + ",<br><br>&emsp; Your information has been added to PCkit's mailing list! Click here to <a href='mailto:PCKitCompany@gmail.com?subject=UNSUBSCRIBE'>unsubscribe</a> at any time";
               EmailUtility.sendEmail(host, port, user, pass, email, "PCKit Mailing List Confirmation",
                    mailMessage);
               pageMessage = "Your information has been added to our mailing list!";
               request.setAttribute("Message", pageMessage);
               getServletContext().getRequestDispatcher("/response.jsp").forward(
                    request, response);
               
            }
            
            
         }
         catch (Exception e) {
            pageMessage = "An error occurred while adding your data to the mailing list! Please try again later.";
            request.setAttribute("Message", pageMessage);
            getServletContext().getRequestDispatcher("/response.jsp").forward(
                request, response);
         }
         request.setAttribute("Message", pageMessage);
         getServletContext().getRequestDispatcher("/response.jsp").forward(
            request, response);
      }
      
      
      
   }
   
}