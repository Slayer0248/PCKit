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


public class DeleteCartStatusServlet extends HttpServlet {
   @Override
   protected void doPost(HttpServletRequest request, HttpServletResponse response)
         throws IOException, ServletException {
         
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
      if( cookies != null ) {
         for (int i = 0; i < cookies.length; i++){
            cookie = cookies[i];
            /*if (cookie.getName().equals("pckitUserId")) {
               userIdStr= (String)cookie.getValue();
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
      
      if (result.equals("Valid")) {
         //int userId = Integer.parseInt(userIdStr);
         int userId = login.getUserId();
         String status = request.getParameter("status");
         ArrayList<Integer> orderIds = new ArrayList<Integer>();
         
         
         
         Connection connection = null;
         PreparedStatement pstatement = null;
         PreparedStatement pstatement2 = null;
         PreparedStatement pstatement3 = null;
         ResultSet rs = null;
         try {
         
         
            connection = DriverManager.getConnection("jdbc:mysql://localhost/PCKitDB","root","Potter11a");
            String queryString = "SELECT * FROM Orders WHERE userId=? and orderStatus=?";
            pstatement = connection.prepareStatement(queryString);
            pstatement.setInt(1, userId);
            pstatement.setString(2, status);
            rs = pstatement.executeQuery();
           
            while(rs.next()) {
               int orderId= rs.getInt("orderId");
               int wasFound = -1;
               for (int i=0; i<orderIds.size() && wasFound==-1; i++) {
                  if (orderIds.get(i) == orderId) {
                     wasFound=1;
                  }
               }
               
               if (wasFound == -1) {
                  orderIds.add(orderId);
               }
            }
            rs.close();
            pstatement.close();
            
            int updateQuery = 0;
            int updateQuery2 = 0;
            
            for (int i=0; i<orderIds.size(); i++) {
               int curId = orderIds.get(i);
               String queryString2 = "Delete from OrderBuilds where orderId=?";
               pstatement2 = connection.prepareStatement(queryString2);
               pstatement2.setInt(1, curId);
               updateQuery += pstatement2.executeUpdate();
               pstatement2.close();
            
            
            
               String queryString3 = "Delete from Order where orderId=? and userId=?";
               pstatement3 = connection.prepareStatement(queryString3);
               pstatement3.setInt(1, curId);
               pstatement3.setInt(2, userId);
               updateQuery2 += pstatement3.executeUpdate();
               pstatement3.close();
            }
               
            if (updateQuery2 != 0 || updateQuery != 0) {
                  pageMessage = "Successful";
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
