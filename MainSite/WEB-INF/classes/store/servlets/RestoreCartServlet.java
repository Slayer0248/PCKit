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

public class RestoreCartServlet extends HttpServlet {
   @Override
   protected void doPost(HttpServletRequest request, HttpServletResponse response)
         throws IOException, ServletException {
      String pageMessage = "Invalid Post Request.";  
      Cookie cookie = null;
      Cookie[] cookies = null;
      // Get an array of Cookies associated with this domain
      cookies = request.getCookies();
      String userIdStr ="";
      if( cookies != null ) {
         for (int i = 0; i < cookies.length; i++){
            cookie = cookies[i];
            if (cookie.getName().equals("pckitUserId")) {
               userIdStr= (String)cookie.getValue();
            }
            //out.print("Name : " + cookie.getName( ) + ",  ");
            //out.print("Value: " + cookie.getValue( )+" <br/>");
         }
      }
      
      if (userIdStr != null) {
         int userId = Integer.parseInt(userIdStr);
         String status = request.getParameter("status");
      
         Connection connection = null;
         PreparedStatement pstatement = null;
         ResultSet rs =null;
         int orderId = -1;
         
         try {
            Class.forName("com.mysql.jdbc.Driver");
            connection = DriverManager.getConnection("jdbc:mysql://localhost/PCKitDB","root","Potter11a");
            String queryString = "SELECT * FROM Orders WHERE userId=? and orderStatus=?";
            pstatement = connection.prepareStatement(queryString);
            pstatement.setInt(1, userId);
            pstatement.setString(2, status);
            rs = pstatement.executeQuery();
            rs.next();
            orderId = rs.getInt("orderId");
            
            rs.close();
            pstatement.close();
            
            CartManagerUtil cartManager = new CartManagerUtil();
            ShoppingCart cart = cartManager.createFromOrderId(orderId, connection);
            
            Cookie orderIdCookie = new Cookie("orderId", "" + orderId);
            orderIdCookie.setMaxAge(30*60);
            orderIdCookie.setPath("/");
            response.addCookie(orderIdCookie);
               
            Cookie orderCookie = new Cookie("order", cart.getCookieStr());
            orderIdCookie.setMaxAge(30*60);
            orderIdCookie.setPath("/");
            response.addCookie(orderIdCookie);
            
            pageMessage="Success";
         }
         catch (Exception e) {
            pageMessage="Error occurred while restoring cart.";
         }
      }
      else {
         pageMessage="Reload";
      }
      response.setContentType("text/html;charset=UTF-8");
      response.getWriter().write(pageMessage);
   }

}