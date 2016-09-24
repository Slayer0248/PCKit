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
import accounts.VerifyCsrfToken;
import store.cart.ShoppingCart;

//Code by Clay Jacobs

public class CreateCartServlet extends HttpServlet {
   @Override
   protected void doPost(HttpServletRequest request, HttpServletResponse response)
   throws IOException, ServletException {
      Logger logger = Logger.getLogger(this.getClass().getName());
      String pageMessage = "Invalid csrf token";
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
         String token = "";
         if( cookies != null ) {
            for (int i = 0; i < cookies.length; i++){
               cookie = cookies[i];
               if (cookie.getName().equals("pckitLogin")) {
                  token = (String)cookie.getValue();
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
               int userId = login.getUserId();
               String tierStr = (String)request.getParameter("minTier");
               int tier = Integer.parseInt(tierStr);
               
               Connection connection = null;
               PreparedStatement pstatement = null;
               
               PreparedStatement pstatement2 = null;
               ResultSet rs = null;
               try {
                  Class.forName("com.mysql.jdbc.Driver");
                  int updateQuery = 0;
                  connection = DriverManager.getConnection("jdbc:mysql://localhost/PCKitDB","root","Potter11a");
                  String queryString = "INSERT INTO Orders(userId, totalPrice, orderStatus, recommendedTier) VALUES (?, ?, ?, ?)";
                  pstatement = connection.prepareStatement(queryString);
                  pstatement.setInt(1, userId);
                  pstatement.setInt(2, 0);
                  pstatement.setString(3, "In Progress");
                  pstatement.setInt(4, tier);
                  updateQuery = pstatement.executeUpdate();
                  pstatement.close();
                  
                  String result2 = authUtil.validateToken(token, now, connection);
                  if (result2.equals("Valid")) {
                     UserLogin login2 = authUtil.getLoginResult();
                     String[] cartStates = {"In Progress"};
                     ArrayList<ShoppingCart> orders = login2.getOrdersWithStatus(cartStates);
                     ShoppingCart cart = orders.get(0);
                     authUtil.setOrderId(login.getUserId(), login.getSessionId(), cart.getOrderId(), connection);
                  }
                  
                  pageMessage="Success";
                  
               }
               catch (Exception e) {
                  pageMessage="An error occurred while creating your cart.";
                  logger.log(Level.SEVERE, "An error occurred while creating cart for user " + userId, e);
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
