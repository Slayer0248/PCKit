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

public class LogoutServlet extends HttpServlet {
   @Override
   protected void doPost(HttpServletRequest request, HttpServletResponse response)
         throws IOException, ServletException {
      HttpSession session=request.getSession(false);
      session.setAttribute("userid", null);
      session.setAttribute("name", null);
      session.invalidate();
      Cookie cookie = null;
      Cookie[] cookies = null;
      cookies = request.getCookies();
      if( cookies != null ) {
         for (int i = 0; i < cookies.length; i++){
            cookie = cookies[i];
            if (cookie.getName().equals("pckitUserId") || cookie.getName().equals("pckitName") || 
                cookie.getName().equals("orderId") || cookie.getName().equals("order")) {
               cookie.setPath("/");
               cookie.setMaxAge(0);
               cookie.setValue(null);
               response.addCookie(cookie);
            }
            //out.print("Name : " + cookie.getName( ) + ",  ");
            //out.print("Value: " + cookie.getValue( )+" <br/>");
         }
      }
      
      
      //response.sendRedirect(".");
   }
}
