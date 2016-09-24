
/**
 * Paypal Button and Instant Payment Notification (IPN) Integration with Java
 */
package store.ipn;

import java.io.*;
import java.util.*;
import java.sql.*;


/**
 * Arbitrary service class to simulate the storage and retrieval of Paypal IPN Notification related information
 */
 
 //Code by Clay Jacobs
public class IpnInfoService {

    /**
     * Store Paypal IPN Notification related information for future use
     *
     * @param ipnInfo {@link IpnInfo}
     * @throws IpnException
     */
    public void log (final IpnInfo ipnInfo) throws IpnException {
        /**
         * Implementation...
         */
        Connection connection = null;
        PreparedStatement pstatement = null;
        
        try {
        
           IpnInfo testIpnInfo = getIpnInfo(ipnInfo.getTxnId());
           
           Class.forName("com.mysql.jdbc.Driver");
           connection = DriverManager.getConnection("jdbc:mysql://localhost/PCKitDB","root","Potter11a");
           if (testIpnInfo == null) {
              String queryString = "INSERT INTO PCKitTransactions (txnId, orderId, itemName, itemNumber, paymentStatus, paymentAmount, paymentCurrency, receiverEmail, payerEmail, logTime) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
              pstatement = connection.prepareStatement(queryString);
              pstatement.setString(1, ipnInfo.getTxnId());
              pstatement.setInt(2, ipnInfo.getOrderId());
              pstatement.setString(3, ipnInfo.getItemName());
              pstatement.setString(4, ipnInfo.getItemNumber());
              pstatement.setString(5, ipnInfo.getPaymentStatus());
              pstatement.setString(6, ipnInfo.getPaymentAmount());
              pstatement.setString(7, ipnInfo.getPaymentCurrency());
              pstatement.setString(8, ipnInfo.getReceiverEmail());
              pstatement.setString(9, ipnInfo.getPayerEmail());
              pstatement.setLong(10, ipnInfo.getLogTime().longValue());
           
           } else {
              String queryString = "UPDATE PCKitTransactions SET itemName=?, itemNumber=?, paymentStatus=?, paymentAmount=?, paymentCurrency=?, receiverEmail=?, payerEmail=?, logTime=? WHERE txnId=? and orderId=?";
              pstatement = connection.prepareStatement(queryString);
              pstatement.setString(1, ipnInfo.getItemName());
              pstatement.setString(2, ipnInfo.getItemNumber());
              pstatement.setString(3, ipnInfo.getPaymentStatus());
              pstatement.setString(4, ipnInfo.getPaymentAmount());
              pstatement.setString(5, ipnInfo.getPaymentCurrency());
              pstatement.setString(6, ipnInfo.getReceiverEmail());
              pstatement.setString(7, ipnInfo.getPayerEmail());
              pstatement.setLong(8, ipnInfo.getLogTime().longValue());
              pstatement.setString(9, ipnInfo.getTxnId());
              pstatement.setInt(10, ipnInfo.getOrderId());
              
              
           }
           pstatement.executeUpdate();
           pstatement.close();
        
        }
        catch (Exception e) {
        
        }
    }

    /**
     * Fetch Paypal IPN Notification related information saved earlier
     *
     * @param txnId Paypal IPN Notification's Transaction ID
     * @return {@link IpnInfo}
     * @throws IpnException
     */
    public IpnInfo getIpnInfo (final String txnId) throws IpnException {
        IpnInfo ipnInfo = null;
        Connection connection = null;
        PreparedStatement pstatement = null;
        ResultSet rs = null;
        try {
           Class.forName("com.mysql.jdbc.Driver");
           connection = DriverManager.getConnection("jdbc:mysql://localhost/PCKitDB","root","Potter11a");
           String queryString = "SELECT * FROM PCKitTransactions WHERE txnId=?";
           pstatement = connection.prepareStatement(queryString);
           pstatement.setString(1, txnId);
           rs = pstatement.executeQuery();
           rs.next();
           ipnInfo= new IpnInfo();
           ipnInfo.setTxnId(rs.getString("txnId"));
           ipnInfo.setOrderId(rs.getInt("orderId"));
           ipnInfo.setItemName(rs.getString("itemName"));
           ipnInfo.setItemNumber(rs.getString("itemNumber"));
           ipnInfo.setPaymentStatus(rs.getString("paymentStatus"));
           ipnInfo.setPaymentAmount(rs.getString("paymentAmount"));
           ipnInfo.setPaymentCurrency(rs.getString("paymentCurrency"));
           ipnInfo.setReceiverEmail(rs.getString("receiverEmail"));
           ipnInfo.setPayerEmail(rs.getString("payerEmail"));
           ipnInfo.setLogTime(new Long(rs.getLong("logTime")));
           rs.close();
           
        }
        catch (Exception e) {
        
        }
        
        /**
         * Implementation...
         */
        return ipnInfo;
    }

}
