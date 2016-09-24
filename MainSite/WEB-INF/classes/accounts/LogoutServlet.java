package accounts;

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

import util.SecureEncrypt;
import java.util.Date;

//Code by Clay Jacobs
public class LogoutServlet extends HttpServlet {
   @Override
   protected void doPost(HttpServletRequest request, HttpServletResponse response)
         throws IOException, ServletException {
      /*HttpSession session=request.getSession(false);
      session.setAttribute("userid", null);
      session.setAttribute("name", null);
      session.invalidate();*/
      VerifyCsrfToken tokenCompare= new VerifyCsrfToken();
      if (tokenCompare.isValidToken(request, response)) {
      
         AuthJWTUtil authUtil = new AuthJWTUtil();
         long nowMillis = System.currentTimeMillis();
         java.util.Date now = new java.util.Date(nowMillis);
         Cookie cookie = null;
         Cookie[] cookies = null;
         cookies = request.getCookies();
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
                     authUtil.deauthorize(token, connection);
                  }
                  catch (Exception e) {
                       
                  }
               
                  cookie.setPath("/");
                  cookie.setMaxAge(0);
                  cookie.setValue(null);
                  response.addCookie(cookie);
               }
               //out.print("Name : " + cookie.getName( ) + ",  ");
               //out.print("Value: " + cookie.getValue( )+" <br/>");
            }
         }
      }
      
      
      //response.sendRedirect(".");
   }
}
