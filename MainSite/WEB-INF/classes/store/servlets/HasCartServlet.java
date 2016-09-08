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
import store.cart.ShoppingCart;

public class HasCartServlet extends HttpServlet {
   @Override
   protected void doPost(HttpServletRequest request, HttpServletResponse response)
         throws IOException, ServletException {
      //maxStocked & unit prices
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
      int exists = 0;
      if( cookies != null ) {
         for (int i = 0; i < cookies.length; i++){
            cookie = cookies[i];
            /*if (cookie.getName().equals("pckitUserId")) {
               userIdStr= (String)cookie.getValue();
            }
            if (cookie.getName().equals("orderId")) {
               exists=1;
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
                       
               }
            }
            //out.print("Name : " + cookie.getName( ) + ",  ");
            //out.print("Value: " + cookie.getValue( )+" <br/>");
         }
      }
      int userId= login.getUserId();
      String[] cartStates = {"In Progress", "Buying"};
      ArrayList<ShoppingCart> orders = login.getOrdersWithStatus(cartStates);
      
      if (orders.size() > 0) {
         exists=1;
      }
      if (result.equals("Valid")) {
         pageMessage = exists ==1? "Yes" : "No";
      }
      else {
         pageMessage = "Reload";
      }
      response.setContentType("text/html;charset=UTF-8");
      response.getWriter().write(pageMessage);
   }
}