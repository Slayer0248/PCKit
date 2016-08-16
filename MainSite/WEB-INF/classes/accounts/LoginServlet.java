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
import javax.servlet.http.HttpSession;

import util.SecureEncrypt;

public class LoginServlet extends HttpServlet {
   @Override
   protected void doPost(HttpServletRequest request, HttpServletResponse response)
         throws IOException, ServletException {
      String pageMessage = "Invalid Post Request.";         
      SecureEncrypt seTest= new SecureEncrypt();


      String email = request.getParameter("Email");
      String password = request.getParameter("Password");
      
      Connection connection = null;
      PreparedStatement pstatement = null;
      ResultSet rs = null;
      
      try {
        byte[] encryptedPass = seTest.encryptToBytes(password, "AES");
        
        Class.forName("com.mysql.jdbc.Driver");
        connection = DriverManager.getConnection("jdbc:mysql://localhost/PCKitDB","root","Potter11a");
        String queryString = "SELECT * FROM PCKitAccounts WHERE email=? and password=?";
        pstatement = connection.prepareStatement(queryString);
        pstatement.setString(1, email);
        pstatement.setBytes(2, encryptedPass);
        rs = pstatement.executeQuery();
        rs.next();
        
        HttpSession session=request.getSession(); 
        session.setAttribute("userid", rs.getInt("userId"));
        session.setAttribute("name", rs.getString("firstName") + " " + rs.getString("lastName"));
      }
      catch (Exception e) {
         pageMessage="An error occurred while creating your account!";
      }
      
      response.sendRedirect("..");
   }
}