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


public class DeleteCartServlet extends HttpServlet {
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
      
      if (userIdStr != null || orderIdStr != null) {
         int userId = Integer.parseInt(userIdStr);
         int orderId = Integer.parseInt(orderIdStr);
         
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
            String queryString2 = "Delete from Order where orderId=? and userId=?";
            pstatement2 = connection.prepareStatement(queryString2);
            pstatement2.setInt(1, orderId);
            pstatement2.setInt(2, userId);
            updateQuery2 = pstatement2.executeUpdate();
            pstatement2.close();
               
            if (updateQuery2 != 0 || updateQuery != 0) {
                  pageMessage = "Successful";
            }
            
            if( cookies != null ) {
               for (int i = 0; i < cookies.length; i++){
                  cookie = cookies[i];
                  if (cookie.getName().equals("orderId")) {
                     cookie.setMaxAge(0);
                     cookie.setValue(null);
                     response.addCookie(cookie);
                  }
                  else if (cookie.getName().equals("order")) {
                     cookie.setMaxAge(0);
                     cookie.setValue(null);
                     response.addCookie(cookie);
                  }
                  //out.print("Name : " + cookie.getName( ) + ",  ");
                  //out.print("Value: " + cookie.getValue( )+" <br/>");
              }
           }
         
         }
         catch (Exception e) {
            pageMessage="An error occurred while deleting your cart.";
         }
      }
      else {
         pageMessage = "Reload"; 
      }
      response.setContentType("text/html;charset=UTF-8");
      response.getWriter().write(pageMessage);
   }
   
   
}