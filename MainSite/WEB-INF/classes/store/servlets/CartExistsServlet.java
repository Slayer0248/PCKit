package store.servlets;

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

import accounts.AuthJWTUtil;
import accounts.UserLogin;


public class CartExistsServlet extends HttpServlet {
   @Override
   protected void doPost(HttpServletRequest request, HttpServletResponse response)
         throws IOException, ServletException {
      //maxStocked & unit prices
            String pageMessage = "Invalid Post Request.";  
            
      AuthJWTUtil authUtil = new AuthJWTUtil();
      long nowMillis = System.currentTimeMillis();
      java.util.Date now = new java.util.Date(nowMillis);
      
      Cookie cookie = null;
      Cookie[] cookies = null;
      // Get an array of Cookies associated with this domain
      cookies = request.getCookies();
      //String userIdStr ="";
      UserLogin login = null;
      String result = "";
      if( cookies != null ) {
         for (int i = 0; i < cookies.length; i++){
            cookie = cookies[i];
            if (cookie.getName().equals("pckitLogin")) {
               String token = (String)cookie.getValue();
               Connection connection =null;
               try {
                  Class.forName("com.mysql.jdbc.Driver");
                  connection = DriverManager.getConnection("jdbc:mysql://localhost/PCKitDB","root","Potter11a");
                  authUtil.refreshAll(now, connection); 
                  authUtil.deauthorize(token, connection);
                  result = authUtil.validateToken(token, now, connection);
                  if (result.equals("Valid")) {
                      login = authUtil.getLoginResult();
                  }
               }
               catch (Exception e) {
                       
               }
            }
            /*if (cookie.getName().equals("pckitUserId")) {
               userIdStr= (String)cookie.getValue();
            }*/
            //out.print("Name : " + cookie.getName( ) + ",  ");
            //out.print("Value: " + cookie.getValue( )+" <br/>");
         }
      }
      
      if (result.equals("Valid")) {
         //int userId = Integer.parseInt(userIdStr);
         int userId = login.getUserId();
         String status = request.getParameter("status");
      
         Connection connection = null;
         PreparedStatement pstatement = null;
         ResultSet rs =null;
         int rowCount = -1;
         
         try {
            Class.forName("com.mysql.jdbc.Driver");
            connection = DriverManager.getConnection("jdbc:mysql://localhost/PCKitDB","root","Potter11a");
            String queryString = "SELECT COUNT(*) FROM Orders WHERE userId=? and orderStatus=?";
            pstatement = connection.prepareStatement(queryString);
            pstatement.setInt(1, userId);
            pstatement.setString(2, status);
            rs = pstatement.executeQuery();
            rs.next();
            rowCount = rs.getInt(1);
            
         }
         catch (Exception e) {
            pageMessage="Error occurred while reading database.";
         }
         
         if (rowCount==1) {
            pageMessage="Yes";
         }
         else if (rowCount>1) {
            pageMessage="Delete";
         }
         else {
            pageMessage="No";
         }
      }
      else {
         pageMessage="Reload";
      }
      response.setContentType("text/html;charset=UTF-8");
      response.getWriter().write(pageMessage);
   }

}