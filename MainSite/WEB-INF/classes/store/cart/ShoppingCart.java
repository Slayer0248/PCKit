package store.cart;

import java.util.*;

import com.paypal.crypto.sample.ClientSide;
import java.security.cert.*;
import java.security.*;
import javax.crypto.*;
import org.bouncycastle.cms.*;
import org.bouncycastle.util.*;
import org.bouncycastle.cert.jcajce.*;
import org.bouncycastle.operator.*;
import org.bouncycastle.operator.jcajce.*;
import org.bouncycastle.cms.jcajce.*;
import java.io.*;
import java.util.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;

public class ShoppingCart {
   private ArrayList<CartItem> items;
   private ArrayList<Integer> quantities;
   private String orderStatus;
   private int orderId;
   private int minTier;
   
   public ShoppingCart() {
      items = new ArrayList<CartItem>();
      quantities = new ArrayList<Integer>();
      orderStatus = "";
   }
   
   public int size() {
      return items.size();
   }
   
   public void add(CartItem product, int quantity) {
      items.add(product);
      quantities.add(quantity);
   }
   
   public void remove(int index) {
      items.remove(index);
      quantities.remove(index);
   }
   
   public CartItem get(int index) {
      return items.get(index);
   }
   
   public void set(int index, CartItem product) {
      items.set(index, product);
   }
   
   public int getItemQuantity(int index) {
      return quantities.get(index);
   }
   
   public void setItemQuantity(int index, int quantity) {
      quantities.set(index, quantity);
   }
    
    public int find(int buildId) {
        int index=-1;
        int i=0;
        while (i<items.size() && index==-1) {
            CartItem curItem=items.get(i);
            if (curItem.getItemId()==buildId) {
                index=i;
            }
            i++;
        }
        return index;
    }
   
   public double getTotalPrice() {
      double total=0;
      for (int i=0; i<items.size(); i++) {
         CartItem curItem = items.get(i);
         double itemCosts = curItem.getPrice() * quantities.get(i);
         total = total + itemCosts;
      }
      return total;
   }
   
   public int getOrderId() {
      return orderId;
   }
   
   public void setOrderId(int id) {
      orderId = id;
   }
   
   public String getOrderStatus() {
      return orderStatus;
   }
   
   public void setOrderStatus(String status) {
      orderStatus = status;
   }
   
   
   public int getMinTier() {
      return minTier;
   }
   
   public void setMinTier(int tier) {
      minTier = tier;
   }
   
   
   
   
   public String getCookieStr() {
      String result = "";
      for (int i=0; i<items.size(); i++) {
         CartItem curItem = items.get(i);
         int quantity = quantities.get(i);
         if (i==items.size()-1) {
            result = result + curItem.getItemId() + ":" + quantity;
         }
         else {
            result = result + curItem.getItemId() + ":" + quantity + ",";
         }
      }
      return result;
   }
   
   
   public String getDataStr() {
      String result = "";
      for (int i=0; i<items.size(); i++) {
         CartItem curItem = items.get(i);
         int quantity = quantities.get(i);
         if (i==items.size()-1) {
            result = result + curItem.getItemId() + ":" + quantity + ":" + curItem.getInventory() + ":" + curItem.getPrice()+  ":" + curItem.getName() ;
         }
         else {
            result = result + curItem.getItemId() + ":" + quantity + ":" + curItem.getInventory() + ":" + curItem.getPrice() +  ":" + curItem.getName() + ",";
         }
      }
      return result;
   }
   
   
   public String getEncryptedStr() throws IOException, CertificateException, KeyStoreException, UnrecoverableKeyException,
	InvalidAlgorithmParameterException, NoSuchAlgorithmException, NoSuchProviderException, CertStoreException, CMSException, OperatorCreationException{
      ClientSide client_side = new ClientSide( "my-pubcert.pem", "my-prvkey.p12", "paypal_cert_pem.txt", "Potter11a" );
      
      //String basePath = "/Applications/tomcat/webapps/PCKitLive/OrderSection/";
      String basePath = "/home/ec2-user/pckit/MainSite/OrderSection/";
      String rawData = "cert_id=SFTMKZFWK2YK8,cmd=_cart,upload=1,business=pckitcompany@gmail.com,";
      for (int i=0; i<items.size(); i++) {
         CartItem curItem = items.get(i);
         int quantity = quantities.get(i);
         int count = i+1;
         String itemName = curItem.getName().length() > 0 ? curItem.getName() : "PCKit Build " + curItem.getItemId();
         if (i==items.size()-1) {
            rawData = rawData + "item_name_" + count + "=" + itemName + ",amount_" + count + "=" + curItem.getPrice() + ",quantity_"  + count + "=" + quantity;
         }
         else {
            rawData = rawData + "item_name_" + count + "=" + itemName + ",amount_" + count + "=" + curItem.getPrice() + ",quantity_"  + count + "=" + quantity + ",";
         }
      }
      String result = client_side.getButtonEncryptionValue(rawData, basePath + "my-prvkey.p12",  basePath + "my-pubcert.pem", basePath +"paypal_cert_pem.txt", "Potter11a" );
      return result;
   }
   
   
}