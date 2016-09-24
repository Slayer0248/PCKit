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

public class HasCartServlet extends HttpServlet {
   @Override
   protected void doPost(HttpServletRequest request, HttpServletResponse response)
   throws IOException, ServletException {
      Logger logger = Logger.getLogger(this.getClass().getName());
      String pageMessage = "Invalid csrf token";
      VerifyCsrfToken tokenCompare= new VerifyCsrfToken();
      if (tokenCompare.isValidToken(request, response)) {
         //maxStocked & unit prices
         AuthJWTUtil authUtil = new AuthJWTUtil();
         long nowMillis = System.currentTimeMillis();
         java.util.Date now = new java.util.Date(nowMillis);
         
         pageMessage = "Invalid Post Request.";
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
                        logger.log(Level.SEVERE, "Login token not found.", e);
                     }
                  }
                  //out.print("Name : " + cookie.getName( ) + ",  ");
                  //out.print("Value: " + cookie.getValue( )+" <br/>");
               }
            }
            
            
            if (result.equals("Valid")) {
               int userId= login.getUserId();
               pageMessage = login.getActiveCart() == null ? "No" : "Yes";
            }
            else {
               pageMessage = "Reload";
            }
            
         }
         response.setContentType("text/html;charset=UTF-8");
         response.getWriter().write(pageMessage);
      }
   }
