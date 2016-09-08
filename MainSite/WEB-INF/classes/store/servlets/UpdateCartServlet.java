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

public class UpdateCartServlet extends HttpServlet {
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
            /*if (cookie.getName().equals("pckitUserId")) {
               userIdStr= (String)cookie.getValue();
            }
            else if (cookie.getName().equals("orderId")) {
               orderIdStr=(String)cookie.getValue();
            }
            else if (cookie.getName().equals("order")) {
               cartData=(String)cookie.getValue();
            }*/
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
            //out.print("Name : " + cookie.getName( ) + ",  ");
            //out.print("Value: " + cookie.getValue( )+" <br/>");
         }
      }
      
      if (result.equals("Valid")) {
         /*int orderId= Integer.parseInt(orderIdStr);
         int userId= Integer.parseInt(userIdStr);*/
         //String[] cartStates = {"In Progress", "Buying"};
         //ArrayList<ShoppingCart> orders = login.getOrdersWithStatus(cartStates);
         ShoppingCart cart = login.getActiveCart();
         
         int orderId= cart.getOrderId();
         int userId= login.getUserId();
         String status = request.getParameter("status");
         
         Connection connection = null;
         PreparedStatement pstatement = null;
         
         int updateQuery = -1;
         try {
            Class.forName("com.mysql.jdbc.Driver");
            connection = DriverManager.getConnection("jdbc:mysql://localhost/PCKitDB","root","Potter11a");
            String queryString = "UPDATE Orders SET status=? WHERE orderId=? and userId=?";
            pstatement= connection.prepareStatement(queryString);
            pstatement.setString(1, status);
            pstatement.setInt(2, orderId);
            pstatement.setInt(3, userId);
            updateQuery = pstatement.executeUpdate();
            
            if (updateQuery > 0) {
               pageMessage="Success";
            }
         }
         catch (Exception e) {
            pageMessage="Error occurred while updating cart status.";
         }
      }
      else {
         pageMessage = "Reload";
      }
      
      response.setContentType("text/html;charset=UTF-8");
      response.getWriter().write(pageMessage);
   }

}