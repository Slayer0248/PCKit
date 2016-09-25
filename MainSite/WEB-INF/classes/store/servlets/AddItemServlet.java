package store.servlets;

import java.io.*;
import java.util.*;
import java.util.logging.Logger;
import java.util.logging.Level;
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

import store.cart.ShoppingCart;
import store.cart.CartItem;

import accounts.AuthJWTUtil;
import accounts.UserLogin;
import accounts.VerifyCsrfToken;

//Code by Clay Jacobs


public class AddItemServlet extends HttpServlet {
   @Override
   protected void doPost(HttpServletRequest request, HttpServletResponse response)
         throws IOException, ServletException {
      Logger logger = Logger.getLogger(this.getClass().getName());
      String pageMessage="Invalid csrf token";
      VerifyCsrfToken tokenCompare= new VerifyCsrfToken();
      if (tokenCompare.isValidToken(request, response)) {
         
         
         
         AuthJWTUtil authUtil = new AuthJWTUtil();
         long nowMillis = System.currentTimeMillis();
         java.util.Date now = new java.util.Date(nowMillis);
      
         pageMessage = "Invalid Post Request.";  
         Cookie cookie = null;
         Cookie[] cookies = null;
         // Get an array of Cookies associated with this domain
         cookies = request.getCookies();
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
            }
         }
      
         if (result.equals("Valid")) {
            ShoppingCart cart = login.getActiveCart();
            int orderId= cart.getOrderId();
            int userId= login.getUserId();
            int logBuildId = -1;
            int logQuantity = -1;
      
            String[] updates = request.getParameter("updates").split(",");
            //String cartData = cart.getCookieStr();
         
            Connection connection = null;
            PreparedStatement pstatement = null;
            PreparedStatement pstatement2 = null;
            ResultSet rs = null;
            
            try {
               CartManagerUtil cartManager = new CartManagerUtil();
         
               Class.forName("com.mysql.jdbc.Driver");
               connection = DriverManager.getConnection("jdbc:mysql://localhost/PCKitDB","root","Potter11a");
            
            
               //update quantities
               int updateQuery=0;
               int updateQuery2=0;
               for (int i=0; i<updates.length; i++) {
                  String[] values = updates[i].split(":");
                  int curBuildId = Integer.parseInt(values[0]);
                  int quantity = Integer.parseInt(values[1]);
                  logBuildId =curBuildId;
                  logQuantity = quantity;
               
         
                  if (cart.find(curBuildId)==-1) {
                     String queryString = "INSERT INTO OrderBuilds(orderId, buildId, quantity) VALUES (?, ?, ?)";
                     pstatement = connection.prepareStatement(queryString);
                     pstatement.setInt(1, orderId);
                     pstatement.setInt(2, curBuildId);
                     pstatement.setInt(3, quantity);
                     updateQuery += pstatement.executeUpdate();
                     pstatement.close();
                  
                     CartItem item = cartManager.createFromId(curBuildId, connection);
                     cart.add(item, quantity);
                  }
                  else {
                     String queryString = "UPDATE OrderBuilds SET quantity=? WHERE orderId=? and buildId=?";
                     pstatement = connection.prepareStatement(queryString);
                     pstatement.setInt(1, quantity);
                     pstatement.setInt(2, orderId);
                     pstatement.setInt(3, curBuildId);
                     updateQuery += pstatement.executeUpdate();
                     pstatement.close();
                     cart.setItemQuantity(cart.find(curBuildId), quantity);
                  
                  }
               }
            
            
               //update totalPrice
               int price = (int)(cart.getTotalPrice() * 100.0);
               String queryString = "UPDATE Orders SET totalPrice=? WHERE orderId=? and userId=?";
               pstatement2 = connection.prepareStatement(queryString);
               pstatement2.setInt(1, price);
               pstatement2.setInt(2, orderId);
               pstatement2.setInt(3, userId);
               updateQuery2 = pstatement2.executeUpdate();
               pstatement2.close();
            
               if (updateQuery == updates.length && updateQuery2 != 0) {
                  pageMessage="Success";
                     
               }
            }
            catch (Exception e) {
               pageMessage="Error occurred while adding item to cart.";
               logger.log(Level.SEVERE, "Error occurred while adding "+logQuantity+" of build " +logBuildId+" to cart " + orderId+ " for user " + userId, e);
            }
         }
         else {
            pageMessage="Reload";
         }
      
         
      }
      response.setContentType("text/html;charset=UTF-8");
      response.getWriter().write(pageMessage);
   }
}
