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


public class AccountExistsServlet extends HttpServlet {
   @Override
   protected void doPost(HttpServletRequest request, HttpServletResponse response)
         throws IOException, ServletException {
      
      String resultMsg="Invalid csrf token";   
      
      VerifyCsrfToken tokenCompare= new VerifyCsrfToken();
      if (tokenCompare.isValidToken(request, response)) {
             
         resultMsg=""; 
         String email = request.getParameter("email");
         Connection connection = null;
         PreparedStatement pstatement = null;
         ResultSet rs = null;
         int rowCount = -1;
      
      
      
         try {
            Class.forName("com.mysql.jdbc.Driver");
            connection = DriverManager.getConnection("jdbc:mysql://localhost/PCKitDB","root","Potter11a");
            String queryString = "SELECT COUNT(*) FROM PCKitAccounts WHERE email=?";
            pstatement = connection.prepareStatement(queryString);
            pstatement.setString(1, email);
            rs = pstatement.executeQuery();
            rs.next();
            rowCount = rs.getInt(1);
         }
         catch (Exception e) {
            resultMsg="Error occurred while reading database.";
         }
      
         if (rowCount>0) {
            resultMsg = "Yes";
         }
         else {
            resultMsg = "No";
         }
      
         
      }
      response.setContentType("text/html;charset=UTF-8");
      response.getWriter().write(resultMsg);
   }
}