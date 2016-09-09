package accounts;

import java.security.SecureRandom;
import java.math.BigInteger;
import java.io.*;
import java.util.*;
import java.sql.*;

import store.servlets.CartManagerUtil;

public class LoginTracker {

   //private UserLogin;
   private CartManagerUtil cmUtil; 

   public LoginTracker() {
      cmUtil= new CartManagerUtil();
   }
   
   public java.util.Date toDate(java.sql.Timestamp timestamp) {
        long milliseconds = timestamp.getTime() + (timestamp.getNanos() / 1000000);
        return new java.util.Date(milliseconds);
    }
    
    public java.sql.Timestamp toTimestamp(java.util.Date date) {
        return new java.sql.Timestamp(date.getTime());
    }
    
    public ArrayList<UserLogin> getAllLogins(java.util.Date now, Connection conn) throws Exception {
       ArrayList<UserLogin> logins = new ArrayList<UserLogin>();
       
       Class.forName("com.mysql.jdbc.Driver");
       String queryString = "SELECT * FROM PCKitSessions";
       PreparedStatement pstatement = conn.prepareStatement(queryString);
       ResultSet rs = pstatement.executeQuery();
       while(rs.next()) {
          boolean loggedIn = rs.getInt("isLogged") == 1;
          UserLogin login = new UserLogin(rs.getString("sessionId"), rs.getInt("userId"), toDate(rs.getTimestamp("sessionStart")), rs.getInt("length"));
          login.setLoggedIn(loggedIn);
          logins.add(login);
       }
       rs.close();
       pstatement.close();
       
       return logins;
    }
   
   public void refreshAllLogins(java.util.Date now, Connection conn) throws Exception {
       ArrayList<UserLogin> logins = new ArrayList<UserLogin>();
       
       Class.forName("com.mysql.jdbc.Driver");
       String queryString = "SELECT * FROM PCKitSessions";
       PreparedStatement pstatement = conn.prepareStatement(queryString);
       ResultSet rs = pstatement.executeQuery();
       while(rs.next()) {
          boolean loggedIn = rs.getInt("isLogged") == 1;
          UserLogin login = new UserLogin(rs.getString("sessionId"), rs.getInt("userId"), toDate(rs.getTimestamp("sessionStart")), rs.getInt("length"));
          login.setLoggedIn(loggedIn);
          logins.add(login);
       }
       rs.close();
       pstatement.close();
       
       
       for (int i=0; i<logins.size(); i++) {
          UserLogin login = logins.get(i);
          
          if (!(login.isAlive(now))) {
             logoutUserSession(login.getSessionId(), conn);
          }
       }
   }
   
   
   
   public String nextSessionId(java.util.Date now, Connection conn) throws Exception  {
       /*long nowMillis = System.currentTimeMillis();
       Date now = new Date(nowMillis);*/
       
       String result = null;
       while (result == null) {
          SecureRandom random = new SecureRandom();
          String curVal = new BigInteger(130, random).toString(32);
          if (!sessionIdInUse(curVal, now, conn)) {
             result = curVal;
          }
       }
       
       return result;  
    }
    
    /*Logout current  sessionId */
    //public void logoutUserSession(String sessionId, String ipAddress, Connection conn) throws Exception {
    public void logoutUserSession(String sessionId, Connection conn) throws Exception {
       
       Class.forName("com.mysql.jdbc.Driver");
       //String queryString = "UPDATE PCKitSessions SET isLogged=1 WHERE sessionId=? and sessionIP=?";
       String queryString = "DELETE FROM PCKitSessions WHERE sessionId=?";
       PreparedStatement pstatement = conn.prepareStatement(queryString);
       pstatement.setString(1, sessionId);
       //pstatement.setString(2, ipAddress);
       pstatement.executeUpdate();
       pstatement.close();
       
       String queryString2 = "DELETE FROM PCKitSessionData WHERE sessionId=?";
       PreparedStatement pstatement2 = conn.prepareStatement(queryString2);
       pstatement2.setString(1, sessionId);
       //pstatement.setString(2, ipAddress);
       pstatement2.executeUpdate();
       pstatement2.close();
       
    }
    
    
    /*Get user login for current user */
    //public UserLogin getUserInfo(String sessionId, String ipAddress, Connection conn)  throws Exception {
    public UserLogin getUserInfo(String sessionId, Connection conn)  throws Exception {
       //String queryString = "SELECT * FROM PCKitSessions WHERE sessionId=? and sessionIP=?";
       String queryString = "SELECT * FROM PCKitSessions WHERE sessionId=?";
       PreparedStatement pstatement = conn.prepareStatement(queryString);
       pstatement.setString(1, sessionId);
       //pstatement.setString(2, ipAddress);
       ResultSet rs = pstatement.executeQuery();
       rs.next();
       int userId = rs.getInt("userId");
       
       
       UserLogin login = new UserLogin(rs.getString("sessionId"), rs.getInt("userId"), toDate(rs.getTimestamp("sessionStart")), rs.getInt("length"));
       login.setLoggedIn(true);
       
       rs.close();
       pstatement.close();
       
       String queryString2 = "SELECT * FROM PCKitAccounts WHERE userId=?";
       PreparedStatement pstatement2 = conn.prepareStatement(queryString2);
       pstatement2.setInt(1, userId);
       ResultSet rs2 = pstatement2.executeQuery();
       rs2.next();
       String firstName = rs2.getString("firstName");
       String lastName =rs2.getString("lastName");
       String email= rs2.getString("email");
       rs2.close();
       pstatement2.close();
       
       String queryString3 = "SELECT * FROM PCKitSessionData WHERE sessionId=? and userId=?";
       PreparedStatement pstatement3 = conn.prepareStatement(queryString3);
       pstatement3.setString(1, sessionId);
       pstatement3.setInt(2, userId);
       //pstatement.setString(2, ipAddress);
       ResultSet rs3 = pstatement.executeQuery();
       rs3.next();
       int activeOrderId = rs3.getInt("activeOrderId");
       rs3.close();
       pstatement3.close();
       
       
       login.setFirstName(firstName);
       login.setLastName(lastName);
       login.setEmail(email);
       login.setOrders(cmUtil.getUserCarts(userId, conn));
       login.setActiveCart(activeOrderId);
       return login;
    }
    
    /*Logout all sessions with sessionId */
    /*public void logoutSessions(String sessionId, Connection conn) throws Exception {
       ArrayList<String> updateSessions
       Connection connection = null;
       PreparedStatement pstatement = null;
       ResultSet rs =null;
       
       PreparedStatement pstatement2 = null;
       int 
    }*/
    
    /*Check if generated session id is already in the db and is active */
    //public boolean sessionIdInUse(String sessionId, String ipAddress, Date now, Connection conn) throws Exception {
    public boolean sessionIdInUse(String sessionId, java.util.Date now, Connection conn) throws Exception {
       boolean sessionIdFound = false;
       Class.forName("com.mysql.jdbc.Driver");
       //String queryString = "SELECT * FROM PCKitSessions WHERE sessionId=? and sessionIP=?";
       String queryString = "SELECT * FROM PCKitSessions WHERE sessionId=?";
       PreparedStatement pstatement = conn.prepareStatement(queryString);
       pstatement.setString(1, sessionId);
       //pstatement.setString(2, ipAddress);
       ResultSet rs = pstatement.executeQuery();
       while (rs.next()) {
          if (!sessionIdFound) {
             int loggedStatus = rs.getInt("isLogged");
             java.util.Date start = toDate(rs.getTimestamp("sessionStart"));
             Calendar cal = Calendar.getInstance();
             cal.setTime(start);
             cal.add(Calendar.MINUTE, rs.getInt("length"));
             java.util.Date end = cal.getTime();
             
             if (now.compareTo(start) >= 0 && now.compareTo(end) <= 0 && loggedStatus==1) {
                sessionIdFound=true;
             }
          }
       }
       rs.close();
       pstatement.close();
       
       return sessionIdFound;
       
    }
    
    /*Check if user session timed out*/
    //public boolean userLoginExpired(String sessionId, String ipAddress, Date now, Connection conn) throws Exception {
    public boolean userLoginExpired(String sessionId, java.util.Date now, Connection conn) throws Exception {
       boolean expired = false;
       Class.forName("com.mysql.jdbc.Driver");
       //String queryString = "SELECT * FROM PCKitSessions WHERE sessionId=? and sessionIP=?";
       String queryString = "SELECT * FROM PCKitSessions WHERE sessionId=?";
       PreparedStatement pstatement = conn.prepareStatement(queryString);
       pstatement.setString(1, sessionId);
       //pstatement.setString(2, ipAddress);
       ResultSet rs = pstatement.executeQuery();
       rs.next();
       int loggedStatus = rs.getInt("isLogged");
       java.util.Date start = toDate(rs.getTimestamp("sessionStart"));
       Calendar cal = Calendar.getInstance();
       cal.setTime(start);
       cal.add(Calendar.MINUTE, rs.getInt("length"));
       java.util.Date end = cal.getTime();
       
       if (now.compareTo(start) < 0 || now.compareTo(end) > 0) {
          expired =true;
       }
       rs.close();
       pstatement.close();
       
       return expired;
    }
    
    /*Check if user login exists on password entry*/
    //public boolean userLoginExists(int userId, String ipAddress, Connection conn) throws Exception {
    public boolean userLoginExists(int userId, Connection conn) throws Exception {
       int rowCount =-1;
    
       Class.forName("com.mysql.jdbc.Driver");
       //String queryString = "SELECT COUNT(*) FROM PCKitSessions WHERE userId=? and sessionIP=?";
       String queryString = "SELECT COUNT(*) FROM PCKitSessions WHERE userId=?";
       PreparedStatement pstatement = conn.prepareStatement(queryString);
       pstatement.setInt(1, userId);
       //pstatement.setString(2, ipAddress);
       ResultSet rs = pstatement.executeQuery();
       rs.next();
       rowCount = rs.getInt(1);
       
       rs.close();
       pstatement.close();
       return rowCount > 0;
       
    }
    
    /*Check if user is logged in on password entry*/
    //public boolean userLoggedIn(int userId, String ipAddress, Connection conn) throws Exception {
    public boolean userLoggedIn(int userId, Connection conn) throws Exception {
       boolean loggedIn = false;
    
       Class.forName("com.mysql.jdbc.Driver");
       //String queryString = "SELECT * FROM PCKitSessions WHERE userId=? and sessionIP=?";
       String queryString = "SELECT * FROM PCKitSessions WHERE userId=?";
       PreparedStatement pstatement = conn.prepareStatement(queryString);
       pstatement.setInt(1, userId);
       //pstatement.setString(2, ipAddress);
       
       
       ResultSet rs = pstatement.executeQuery();
       while(rs.next()) {
          loggedIn = rs.getInt("isLogged") == 1;
       }
       rs.close();
       pstatement.close();
     
       return loggedIn;  
    }
    
    
    
    
    /*Create user login on password entry in db*/
    //public UserLogin createLogin(int userId, String sessionId, String ipAddress, Date now, int length, Connection conn)  throws Exception {
    public UserLogin createLogin(int userId, String sessionId, java.util.Date now, int length, Connection conn)  throws Exception {
       
       Class.forName("com.mysql.jdbc.Driver");
       //String queryString = "INSERT INTO PCKitSessions(sessionId, userId, sessionStart, sessionIP, length, isLogged) VALUES (?, ?, ?, ?, ?, ?)";
       String queryString = "INSERT INTO PCKitSessions(sessionId, userId, sessionStart, length, isLogged) VALUES (?, ?, ?, ?, ?)";
       PreparedStatement pstatement = conn.prepareStatement(queryString);
       pstatement.setString(1, sessionId);
       pstatement.setInt(2, userId);
       pstatement.setTimestamp(3, toTimestamp(now));
       /*pstatement.setString(4, ipAddress);
       pstatement.setInt(5, length);
       pstatement.setInt(6, 1);*/
       pstatement.setInt(4, length);
       pstatement.setInt(5, 1);
       pstatement.executeUpdate();
       pstatement.close();
       
       
       String queryString2 = "SELECT * FROM PCKitAccounts WHERE userId=?";
       PreparedStatement pstatement2 = conn.prepareStatement(queryString2);
       pstatement2.setInt(1, userId);
       ResultSet rs = pstatement2.executeQuery();
       rs.next();
       String firstName = rs.getString("firstName");
       String lastName =rs.getString("lastName");
       String email= rs.getString("email");
       rs.close();
       pstatement2.close();
       
       String queryString3 = "INSERT INTO PCKitSessionData(sessionId, userId, activeOrderId) VALUES (?, ?, ?)";
       PreparedStatement pstatement3 = conn.prepareStatement(queryString3);
       pstatement3.setString(1, sessionId);
       pstatement3.setInt(2, userId);
       pstatement3.setNull(3, java.sql.Types.INTEGER);
       pstatement3.executeUpdate();
       pstatement3.close();
       
       //UserLogin login = new UserLogin(sessionId, ipAddress, userId, now, length);
       UserLogin login = new UserLogin(sessionId, userId, now, length);
       login.setLoggedIn(true);
       login.setFirstName(firstName);
       login.setLastName(lastName);
       login.setEmail(email);
       login.setOrders(cmUtil.getUserCarts(userId, conn));
       return login;
       
    }
    
    
    /*Update user login on password entry in db*/
    //public UserLogin updateLogin(int userId, String sessionId, String ipAddress, Date now, int length, Connection conn)  throws Exception {
    public UserLogin updateLogin(int userId, String sessionId, java.util.Date now, int length, Connection conn)  throws Exception {
       Class.forName("com.mysql.jdbc.Driver");
       //String queryString = "UPDATE PCKitSessions SET sessionId=?, sessionStart=?, length=?, isLogged=? WHERE userId=?, sessionIP=?";
       String queryString = "UPDATE PCKitSessions SET sessionId=?, sessionStart=?, length=?, isLogged=? WHERE userId=?";
       PreparedStatement pstatement = conn.prepareStatement(queryString);
       pstatement.setString(1, sessionId);
       pstatement.setTimestamp(2, toTimestamp(now));
       pstatement.setInt(3, length);
       pstatement.setInt(4, 1);
       pstatement.setInt(5, userId);
       /*pstatement.setString(6, ipAddress);*/
       pstatement.executeUpdate();
       pstatement.close();
       
       String queryString2 = "SELECT * FROM PCKitAccounts WHERE userId=?";
       PreparedStatement pstatement2 = conn.prepareStatement(queryString2);
       pstatement2.setInt(1, userId);
       ResultSet rs = pstatement2.executeQuery();
       rs.next();
       String firstName = rs.getString("firstName");
       String lastName =rs.getString("lastName");
       String email= rs.getString("email");
       rs.close();
       pstatement2.close();
       
       //UserLogin login = new UserLogin(sessionId, ipAddress, userId, now, length);
       UserLogin login = new UserLogin(sessionId, userId, now, length);
       login.setLoggedIn(true);
       login.setFirstName(firstName);
       login.setLastName(lastName);
       login.setEmail(email);
       login.setOrders(cmUtil.getUserCarts(userId, conn));
       return login;
    }
    
    public void updateActiveOrderId(int userId, String sessionId, int orderId, Connection conn)  throws Exception {
       Class.forName("com.mysql.jdbc.Driver");
       //String queryString = "UPDATE PCKitSessions SET sessionId=?, sessionStart=?, length=?, isLogged=? WHERE userId=?, sessionIP=?";
       String queryString = "UPDATE PCKitSessionData SET activeOrderId=? WHERE sessionId=? and userId=?";
       PreparedStatement pstatement = conn.prepareStatement(queryString);
       pstatement.setInt(1, orderId);
       pstatement.setString(2, sessionId);
       pstatement.setInt(3, userId);
       /*pstatement.setString(6, ipAddress);*/
       pstatement.executeUpdate();
       pstatement.close();
    }
    
    public void clearActiveOrderId(int orderId,  Connection conn)  throws Exception {
       ArrayList<String> sessionIds = new ArrayList<String>();
    
       Class.forName("com.mysql.jdbc.Driver");
       //String queryString = "UPDATE PCKitSessions SET sessionId=?, sessionStart=?, length=?, isLogged=? WHERE userId=?, sessionIP=?";
       String queryString = "Select * from PCKitSessionData WHERE activeOrderId=?";
       PreparedStatement pstatement = conn.prepareStatement(queryString);
       pstatement.setInt(1, orderId);
       ResultSet rs = pstatement.executeQuery();
       while(rs.next()) {
          String sessionId = rs.getString("sessionId");
          sessionIds.add(sessionId);
       }
       
       rs.close();
       pstatement.close();
       
       for (int i=0; i<sessionIds.size(); i++) {
          String queryString2 = "UPDATE PCKitSessionData SET activeOrderId=? WHERE sessionId=?";
          PreparedStatement pstatement2 = conn.prepareStatement(queryString2);
          pstatement2.setNull(1, java.sql.Types.INTEGER);
          pstatement2.setString(2, sessionIds.get(i));
          pstatement2.executeUpdate();
          pstatement2.close();
       }
       
    }
    
    
    
    
    

}