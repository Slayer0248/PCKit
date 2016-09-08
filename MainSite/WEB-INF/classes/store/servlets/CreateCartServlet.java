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

public class CreateCartServlet extends HttpServlet {
   @Override
   protected void doPost(HttpServletRequest request, HttpServletResponse response)
         throws IOException, ServletException {
         
      AuthJWTUtil authUtil = new AuthJWTUtil();
      long nowMillis = System.currentTimeMillis();
      java.util.Date now = new java.util.Date(nowMillis);
         
      String pageMessage = "Invalid Post Request.";  
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
      
         Connection connection = null;
         PreparedStatement pstatement = null;
         
         PreparedStatement pstatement2 = null;
         ResultSet rs = null;
         try {
            Class.forName("com.mysql.jdbc.Driver");
            int updateQuery = 0;
            connection = DriverManager.getConnection("jdbc:mysql://localhost/PCKitDB","root","Potter11a");
            String queryString = "INSERT INTO Orders(userId, totalPrice, orderStatus) VALUES (?, ?, ?)";
            pstatement = connection.prepareStatement(queryString);
            pstatement.setInt(1, userId);
            pstatement.setInt(2, 0);
            pstatement.setString(3, "In Progress");
            updateQuery = pstatement.executeUpdate();
            pstatement.close();
            if (updateQuery != 0) {
               pageMessage="Success";
        
               String queryString2 = "SELECT orderId from Orders where userId=? and orderStatus=?";
               pstatement2 = connection.prepareStatement(queryString2);
               pstatement2.setInt(1, userId);
               pstatement2.setString(2, "In Progress");
               rs = pstatement2.executeQuery();
               rs.next();
               int orderId=rs.getInt("orderId");
               
               Cookie orderIdCookie = new Cookie("orderId", "" + orderId);
               orderIdCookie.setMaxAge(30*60);
               orderIdCookie.setPath("/");
               //orderIdCookie.setPath("/");
               orderIdCookie.setSecure(true);
               response.addCookie(orderIdCookie);
               
               Cookie orderCookie = new Cookie("order", "");
               orderCookie.setMaxAge(30*60);
               orderCookie.setPath("/");
               //orderCookie.setPath("/");
               response.addCookie(orderCookie);
            }
         }
         catch (Exception e) {
            pageMessage="An error occurred while creating your cart.";
         }
      }
      else {
         pageMessage="Reload";
      }
      
      response.setContentType("text/html;charset=UTF-8");
      response.getWriter().write(pageMessage);
   }

}
