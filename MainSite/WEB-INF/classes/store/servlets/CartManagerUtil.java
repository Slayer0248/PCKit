package store.servlets;

import java.io.*;
import java.util.*;
import java.sql.*;

import store.cart.ShoppingCart;
import store.cart.CartItem;

public class CartManagerUtil {
   public CartManagerUtil () {
   
   }
   
   public ShoppingCart createFromOrderId(int orderId, Connection conn) throws SQLException, ClassNotFoundException  {
      ShoppingCart cart = new ShoppingCart();
      ArrayList<Integer> buildIds = new ArrayList<Integer>();
      ArrayList<Integer> quantities = new ArrayList<Integer>();
      
      Class.forName("com.mysql.jdbc.Driver");
      String queryString = "SELECT * FROM OrderBuilds WHERE orderId=?";
      PreparedStatement pstatement = conn.prepareStatement(queryString);
      pstatement.setInt(1, orderId);
      ResultSet rs = pstatement.executeQuery();
      while(rs.next()) {
         buildIds.add(rs.getInt("buildId"));
         quantities.add(rs.getInt("quantity"));
      }
      rs.close();
      pstatement.close();
   
      for (int i=0; i<buildIds.size(); i++) {
         int buildId = buildIds.get(i);
         int quantity = quantities.get(i);
         CartItem item = createFromId(buildId, conn);
         cart.add(item, quantity);
      }
      
      return cart;
   }
   
   public ShoppingCart createFullFromOrderId(int orderId, Connection conn) throws SQLException, ClassNotFoundException {
      ShoppingCart cart = new ShoppingCart();
      ArrayList<Integer> buildIds = new ArrayList<Integer>();
      ArrayList<Integer> quantities = new ArrayList<Integer>();
      
      Class.forName("com.mysql.jdbc.Driver");
      String queryString = "SELECT * FROM OrderBuilds WHERE orderId=?";
      PreparedStatement pstatement = conn.prepareStatement(queryString);
      pstatement.setInt(1, orderId);
      ResultSet rs = pstatement.executeQuery();
      while(rs.next()) {
         buildIds.add(rs.getInt("buildId"));
         quantities.add(rs.getInt("quantity"));
      }
      rs.close();
      pstatement.close();
   
      for (int i=0; i<buildIds.size(); i++) {
         int buildId = buildIds.get(i);
         int quantity = quantities.get(i);
         CartItem item = createFullFromId(buildId, conn);
         cart.add(item, quantity);
      }
      
      return cart;
   }
   
   
   public ShoppingCart createFromCartString(String cartStr, Connection conn) throws SQLException, ClassNotFoundException  {
      ShoppingCart cart = new ShoppingCart();
      if (cartStr.length()>0) {
         String[] itemStrs = cartStr.split(",");
         for (int i=0; i<itemStrs.length; i++) {
            String[] values = itemStrs[i].split(":");
            int buildId = Integer.parseInt(values[0]);
            int quantity = Integer.parseInt(values[1]);
            CartItem item = createFromId(buildId , conn);
            cart.add(item, quantity);
         }
      }
      
      return cart;
   }
   
   public ShoppingCart createFullFromCartString(String cartStr, Connection conn) throws SQLException, ClassNotFoundException  {
      ShoppingCart cart = new ShoppingCart();
      if (cartStr.length()>0) {
         String[] itemStrs = cartStr.split(",");
         for (int i=0; i<itemStrs.length; i++) {
            String[] values = itemStrs[i].split(":");
            int buildId = Integer.parseInt(values[0]);
            int quantity = Integer.parseInt(values[1]);
            CartItem item = createFullFromId(buildId , conn);
            cart.add(item, quantity);
         }
      }
      
      return cart;
   }
   
   public CartItem createFromId(int buildId, Connection conn) throws SQLException, ClassNotFoundException  {
      int maxInStock =-1;
      double price=-1.0;
   
      Class.forName("com.mysql.jdbc.Driver");
      String queryString = "SELECT price, numStocked FROM Builds WHERE buildId=?";
      PreparedStatement pstatement = conn.prepareStatement(queryString);
      pstatement.setInt(1, buildId);
      ResultSet rs = pstatement.executeQuery();
      rs.next();
      maxInStock = rs.getInt("numStocked");
      price= (double)(rs.getInt("price"));
      price = price/100.0;
      pstatement.close();
      
      CartItem item = new CartItem(buildId, "", "", price, maxInStock);
      return item;
   }
   
   public CartItem createFullFromId(int buildId, Connection conn) throws SQLException, ClassNotFoundException  {
      int maxInStock =-1;
      double price=-1.0;
   
      Class.forName("com.mysql.jdbc.Driver");
      String queryString = "SELECT * FROM Builds WHERE buildId=?";
      PreparedStatement pstatement = conn.prepareStatement(queryString);
      pstatement.setInt(1, buildId);
      ResultSet rs = pstatement.executeQuery();
      rs.next();
      maxInStock = rs.getInt("numStocked");
      price= (double)(rs.getInt("price"));
      price = price/100.0;
      String description = rs.getString("buildDescriptions");
      String name = rs.getString("buildName");
      pstatement.close();      


      CartItem item = new CartItem(buildId, name, description, price, maxInStock);
      return item;
   }
   

}
