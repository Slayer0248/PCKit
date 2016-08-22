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

public class UpdateCartServlet extends HttpServlet {
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