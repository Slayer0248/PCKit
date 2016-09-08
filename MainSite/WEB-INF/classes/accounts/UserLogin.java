package accounts;

import java.util.Date;
import java.util.*;
import store.cart.ShoppingCart;

public class UserLogin {

   /*Login data*/
   private String sessionId;
   private String sessionIP;
   private int userId;
   private Date startDate;
   private Date endDate;
   private boolean loggedIn;
   
   /*User data*/
   private String firstName;
   private String lastName;
   private String email;
   
   /*Order data*/
   private ArrayList<ShoppingCart> orders;
   
   public UserLogin() {
      orders = new ArrayList<ShoppingCart>();
   }
   
   public UserLogin(String sId, String ip, int uId, Date start, int length) {
      sessionId = sId;
      sessionIP = ip;
      userId = uId;
      startDate = start;
      Calendar cal = Calendar.getInstance();
      cal.setTime(start);
      cal.add(Calendar.MINUTE, length);
      endDate = cal.getTime();
      orders = new ArrayList<ShoppingCart>();
   }
   
    public UserLogin(String sId, int uId, Date start, int length) {
      sessionId = sId;
      sessionIP = null;
      userId = uId;
      startDate = start;
      Calendar cal = Calendar.getInstance();
      cal.setTime(start);
      cal.add(Calendar.MINUTE, length);
      endDate = cal.getTime();
      orders = new ArrayList<ShoppingCart>();
   }
   
   
   /*login data methods*/
   public String getSessionId() {
      return sessionId;
   }
   
   public void setSessionId(String sId) {
      sessionId=sId;
   }
   
   public String getSessionIP() {
      return sessionIP;
   }
   
   public void setSessionIP(String ip) {
      sessionIP=ip;
   }
   
   public int getUserId() {
      return userId;
   }
   
   public void setUserId(int uId) {
      userId=uId;
   }
   
   public Date getStartDate() {
      return startDate;
   }
   
   public void setStartDate(Date start) {
      startDate=start;
   }
   
   public Date getEndDate() {
      return endDate;
   }
   
   public void setEndDate(Date end) {
      endDate=end;
   }
   
   public boolean getLoggedIn() {
      return loggedIn;
   }
   
   public void setLoggedIn(boolean val) {
      loggedIn=val;
   }
   
   public boolean isAlive(Date now) {
      if (now.compareTo(startDate) < 0 || now.compareTo(endDate) > 0) {
         return false;
      }
      return true;
   }
   
   
   /*user data methods*/
   
   public String getFirstName() {
      return firstName;
   }
   
   public void setFirstName(String first) {
      firstName=first;
   }
   
   
   public String getLastName() {
      return lastName;
   }
   
   public void setLastName(String last) {
      lastName=last;
   }
   
   public String getEmail() {
      return email;
   }
   
   public void setEmail(String value) {
      email=value;
   }
   
   
   /*order data methods*/
   public ArrayList<ShoppingCart> getOrders() {
      return orders;
   }
   
   public void setOrders(ArrayList<ShoppingCart> allOrders) {
      orders=allOrders;
   }
   
   public ArrayList<ShoppingCart> getOrdersWithStatus(String[] states) {
      ArrayList<ShoppingCart> carts = new ArrayList<Integer>();
      for (int i=0; i<orders.size(); i++) {
         ShoppingCart curCart = orders.get(i);
         for (int j=0; j<states.length; j++) {
            String status = states[j];
            if(curCart.getOrderStatus().equals(status)) {
               carts.add(curCart);
            }
         }
      }
      return carts;
   }
   
}