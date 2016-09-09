package store.servlets;

import java.util.logging.Logger;
import java.util.logging.Level;

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
import store.cart.ShoppingCart;

public class DeleteCartServlet extends HttpServlet {
   @Override
   protected void doPost(HttpServletRequest request, HttpServletResponse response)
         throws IOException, ServletException {
         
      Logger logger = Logger.getLogger(this.getClass().getName());
         
      AuthJWTUtil authUtil = new AuthJWTUtil();
      long nowMillis = System.currentTimeMillis();
      java.util.Date now = new java.util.Date(nowMillis);
    
      String pageMessage = "Invalid Post Request.";  
      Cookie cookie = null;
      Cookie[] cookies = null;
      // Get an array of Cookies associated with this domain
      cookies = request.getCookies();
      /*String userIdStr ="";
      String orderIdStr="";
      String cartData = "";*/
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
                  result = authUtil.validateToken(token, now, connection);
                  if (result.equals("Valid")) {
                      login = authUtil.getLoginResult();
                  }
               }
               catch (Exception e) {
                  logger.log(Level.SEVERE, "Login token not found.", e);   
               }
            }
            /*if (cookie.getName().equals("pckitUserId")) {
               userIdStr= (String)cookie.getValue();
            }
            else if (cookie.getName().equals("orderId")) {
               orderIdStr=(String)cookie.getValue();
            }
            else if (cookie.getName().equals("order")) {
               cartData=(String)cookie.getValue();
            }*/
            //out.print("Name : " + cookie.getName( ) + ",  ");
            //out.print("Value: " + cookie.getValue( )+" <br/>");
         }
      }
      
      if (result.equals("Valid")) {
         /*int userId = Integer.parseInt(userIdStr);
         int orderId = Integer.parseInt(orderIdStr);*/
         String[] cartStates = {"In Progress", "Buying"};
         ArrayList<ShoppingCart> orders = login.getOrdersWithStatus(cartStates);
         ShoppingCart cart = orders.get(0);
         int orderId= cart.getOrderId();
         int userId= login.getUserId();
         
         Connection connection = null;
         PreparedStatement pstatement = null;
         PreparedStatement pstatement2 = null;
         
         try {
            connection = DriverManager.getConnection("jdbc:mysql://localhost/PCKitDB","root","Potter11a");
            int updateQuery = 0;
            String queryString = "Delete from OrderBuilds where orderId=?";
            pstatement = connection.prepareStatement(queryString);
            pstatement.setInt(1, orderId);
            updateQuery = pstatement.executeUpdate();
            pstatement.close();
            
            
            int updateQuery2 = 0;
            String queryString2 = "Delete from Orders where orderId=? and userId=?";
            pstatement2 = connection.prepareStatement(queryString2);
            pstatement2.setInt(1, orderId);
            pstatement2.setInt(2, userId);
            updateQuery2 = pstatement2.executeUpdate();
            pstatement2.close();
               
            if (updateQuery2 != 0 || updateQuery != 0) {
                  pageMessage = "Successful";
            }
            
            authUtil.deleteOrderId(orderId, connection);
           
         
         }
         catch (Exception e) {
            pageMessage="An error occurred while deleting your cart.";
            logger.log(Level.SEVERE, "An error occurred while deleting cart " +orderId+" for user " + userId, e); 
         }
      }
      else {
         pageMessage = "Reload"; 
      }
      response.setContentType("text/html;charset=UTF-8");
      response.getWriter().write(pageMessage);
   }
   
   
}
