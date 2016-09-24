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
import javax.servlet.http.Cookie;
import javax.servlet.http.*;
import javax.servlet.*;

import util.SecureEncrypt;
import java.util.logging.Logger;
import java.util.Date;

//Code by Clay Jacobs

public class LoginServlet extends HttpServlet {
   @Override
   protected void doPost(HttpServletRequest request, HttpServletResponse response)
         throws IOException, ServletException {
    
      String output="Invalid csrf token";
      VerifyCsrfToken tokenCompare= new VerifyCsrfToken();
      if (tokenCompare.isValidToken(request, response)) {
         String pageMessage = "Invalid Post Request.";         
         SecureEncrypt seTest= new SecureEncrypt();
         AuthJWTUtil authUtil = new AuthJWTUtil();
         Logger logger = Logger.getLogger(this.getClass().getName());

         String email = request.getParameter("Email");
         String password = request.getParameter("Password");
      
         Connection connection = null;
         PreparedStatement pstatement = null;
         ResultSet rs = null;
         output="";
      
         try {
            String encryptedPass = seTest.encryptToString(password, "AES");
            Class.forName("com.mysql.jdbc.Driver");
            connection = DriverManager.getConnection("jdbc:mysql://localhost/PCKitDB","root","Potter11a");
            String queryString = "SELECT * FROM PCKitAccounts WHERE email=? and password=?";
            pstatement = connection.prepareStatement(queryString);
            pstatement.setString(1, email);
            pstatement.setString(2, encryptedPass);
            rs = pstatement.executeQuery();
            rs.next();
        
            int userId = rs.getInt("userId");
            rs.close();
            pstatement.close();
        
            long nowMillis = System.currentTimeMillis();
            java.util.Date now = new java.util.Date(nowMillis);
        
        
            output=output+"got to authUtil use\n";
            authUtil.refreshAll(now, connection); 
            output=output+"got past refresh\n";
            authUtil.authorize(userId, nowMillis, 30, connection);
            output=output+"got past authorize\n";


            Cookie login = new Cookie("pckitLogin", authUtil.getJWTResult());
            login.setMaxAge(30*60);
            login.setPath("/");
            login.setHttpOnly(true);
            login.setSecure(true);
            response.addCookie(login);

            output = output+authUtil.getJWTResult();
        
         }
         catch (Exception e) {
            pageMessage="An error occurred while creating your account!";
            output=output+"Error: "+e.toString();
         }
      }
      response.getWriter().write(output);
      request.getRequestDispatcher("../").include(request, response);
   }
}
