package accounts;

import java.io.*;
import java.util.*;
import java.sql.*;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import util.SecureEncrypt;

public class RegisterServlet extends HttpServlet {
   @Override
   protected void doPost(HttpServletRequest request, HttpServletResponse response)
         throws IOException, ServletException {
      String pageMessage = "Invalid Post Request.";         
      SecureEncrypt seTest= new SecureEncrypt();


      String firstName = request.getParameter("firstName");
      String lastName = request.getParameter("lastName");
      String email = request.getParameter("Email");
      String password = request.getParameter("Password");
      
      Connection connection = null;
      PreparedStatement pstatement = null;
      
      try {
        //byte[] encryptedPass = seTest.encryptToBytes(password, "AES");
        String encryptedPass = seTest.encryptToString(password, "AES");
        Class.forName("com.mysql.jdbc.Driver");
        int updateQuery = 0;
        connection = DriverManager.getConnection("jdbc:mysql://localhost/PCKitDB","root","Potter11a");
        String queryString = "INSERT INTO PCKitAccounts(email, password, firstName, lastName) VALUES (?, ?, ?, ?)";
        pstatement = connection.prepareStatement(queryString);
        pstatement.setString(1, email);
        //pstatement.setBytes(2, encryptedPass);
        pstatement.setString(2, encryptedPass);
        pstatement.setString(3, firstName);
        pstatement.setString(4, lastName);
        updateQuery = pstatement.executeUpdate();
        if (updateQuery != 0) {
           pageMessage="Your account has been created! <a href='Login.jsp'>Click here</a> to login.";
        }
      }
      catch (Exception e) {
         pageMessage="An error occurred while creating your account!";
      }
      
      request.setAttribute("Message", pageMessage);
      request.getRequestDispatcher("../registered.jsp").forward(request, response);
   }
}
