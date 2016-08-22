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

import store.cart.ShoppingCart;
import store.cart.CartItem;

public class AddItemServlet extends HttpServlet {
   @Override
   protected void doPost(HttpServletRequest request, HttpServletResponse response)
         throws IOException, ServletException {
      String pageMessage = "Invalid Post Request.";  
      Cookie cookie = null;
      Cookie[] cookies = null;
      // Get an array of Cookies associated with this domain
      cookies = request.getCookies();
      String userIdStr ="";
      String orderIdStr="";
      String cartData = "";
      if( cookies != null ) {
         for (int i = 0; i < cookies.length; i++){
            cookie = cookies[i];
            if (cookie.getName().equals("pckitUserId")) {
               userIdStr= (String)cookie.getValue();
            }
            else if (cookie.getName().equals("orderId")) {
               orderIdStr=(String)cookie.getValue();
            }
            else if (cookie.getName().equals("order")) {
               cartData=(String)cookie.getValue();
            }
            //out.print("Name : " + cookie.getName( ) + ",  ");
            //out.print("Value: " + cookie.getValue( )+" <br/>");
         }
      }
      
      if (orderIdStr != null || userIdStr != null || cartData != null) {
         int orderId= Integer.parseInt(orderIdStr);
         int userId= Integer.parseInt(userIdStr);
      
         String[] updates = request.getParameter("updates").split(",");
         
         Connection connection = null;
         PreparedStatement pstatement = null;
         PreparedStatement pstatement2 = null;
         ResultSet rs = null;
            
         try {
            CartManagerUtil cartManager = new CartManagerUtil();
         
            Class.forName("com.mysql.jdbc.Driver");
            connection = DriverManager.getConnection("jdbc:mysql://localhost/PCKitDB","root","Potter11a");
            
            ShoppingCart cart = cartManager.createFromCartString(cartData, connection);
            
            
            //update quantities
            int updateQuery=0;
            int updateQuery2=0;
            for (int i=0; i<updates.length; i++) {
               String[] values = updates[i].split(":");
               int curBuildId = Integer.parseInt(values[0]);
               int quantity = Integer.parseInt(values[1]);
               
         
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
               if( cookies != null ) {
                  for (int i = 0; i < cookies.length; i++){
                     cookie = cookies[i];
                     if (cookie.getName().equals("order")) {
                        cookie.setValue(cart.getCookieStr());
                        cookie.setMaxAge(30*60);
                        cookie.setPath("/");
                        response.addCookie(cookie);
                     }
                  }
               }
            }
            
         }
         catch (Exception e) {
            pageMessage="Error occurred while adding item to cart.";
         }
      }
      else {
         pageMessage="Reload";
      }
      
      response.setContentType("text/html;charset=UTF-8");
      response.getWriter().write(pageMessage);
   }
}
