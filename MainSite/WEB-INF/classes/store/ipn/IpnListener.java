package store.ipn;

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

//Code by Clay Jacobs
public class IpnListener extends HttpServlet {
   @Override
   protected void doPost(HttpServletRequest request, HttpServletResponse response)
   throws IOException, ServletException {
      String ipnUrl ="https://www.sandbox.paypal.com/cgi-bin/webscr";
      String receiverEmail = "cjdevtests@gmail.com";
      String paymentAmount = "0.01";
      String paymentCurrency = "USD";
      IpnConfig ipnConfig = new IpnConfig(ipnUrl, receiverEmail, paymentAmount, paymentCurrency);
      IpnInfoService infoService = new IpnInfoService();
      Logger logger = Logger.getLogger(this.getClass().getName());
      
      IpnHandler myIpnHandler = new IpnHandler();
      myIpnHandler.setIpnConfig(ipnConfig);
      myIpnHandler.setIpnInfoService(infoService);
      myIpnHandler.setLogger(logger);
       try {
          myIpnHandler.handleIpn(request);
       } catch (Exception e) {
          System.out.println("catch me now....");
       }
   }
}