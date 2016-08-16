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

import util.SecureEncrypt;

public class LogoutServlet extends HttpServlet {
   @Override
   protected void doPost(HttpServletRequest request, HttpServletResponse response)
         throws IOException, ServletException {
      HttpSession session=request.getSession(false);
      session.setAttribute("userid", null);
      session.setAttribute("name", null);
      session.invalidate();
      response.sendRedirect(".");
   }
}