/**
 * Paypal Button and Instant Payment Notification (IPN) Integration with Java
 */
package store.ipn;

/**
 * Model class to hold Paypal IPN Notification related information
 */
 
 //Code by Clay Jacobs
public class IpnInfo {

    private String itemName;
    private String itemNumber;
    private String paymentStatus;
    private String paymentAmount;
    private String paymentCurrency;
    private String txnId;
    private String receiverEmail;
    private String payerEmail;
    private String response;
    private String requestParams;
    private String error;
    private Long logTime;
    //private int userId;
    private int orderId;

    /*public int getUserId() {
       return userId;
    }
    
    public void setUserId(int userId) {
       this.userId = userId;
    }*/

    public int getOrderId() {
       return orderId;
    }
    
    public void setOrderId(int orderId) {
       this.orderId = orderId;
    }

    public String getItemName() {
        return itemName;
    }

    public void setItemName(String itemName) {
        this.itemName = itemName;
    }

    public String getItemNumber() {
        return itemNumber;
    }

    public void setItemNumber(String itemNumber) {
        this.itemNumber = itemNumber;
    }

    public Long getLogTime() {
        return logTime;
    }

    public void setLogTime(Long logTime) {
        this.logTime = logTime;
    }

    public String getPayerEmail() {
        return payerEmail;
    }

    public void setPayerEmail(String payerEmail) {
        this.payerEmail = payerEmail;
    }

    public String getPaymentAmount() {
        return paymentAmount;
    }

    public void setPaymentAmount(String paymentAmount) {
        this.paymentAmount = paymentAmount;
    }

    public String getPaymentCurrency() {
        return paymentCurrency;
    }

    public void setPaymentCurrency(String paymentCurrency) {
        this.paymentCurrency = paymentCurrency;
    }

    public String getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }

    public String getReceiverEmail() {
        return receiverEmail;
    }

    public void setReceiverEmail(String receiverEmail) {
        this.receiverEmail = receiverEmail;
    }

    public String getRequestParams() {
        return requestParams;
    }

    public void setRequestParams(String requestParams) {
        this.requestParams = requestParams;
    }

    public String getResponse() {
        return response;
    }

    public void setResponse(String response) {
        this.response = response;
    }

    public String getTxnId() {
        return txnId;
    }

    public void setTxnId(String txnId) {
        this.txnId = txnId;
    }

    public String getError() {
        return error;
    }

    public void setError(String error) {
        this.error = error;
    }

    @Override
    public String toString() {
        return "txn_id = " + this.getTxnId()
                 + ", orderId = " + this.getOrderId()
                + ", response = " + this.getResponse()
                + ", payment_status = " + this.getPaymentStatus()
                + ", payer_email = " + this.getPayerEmail()
                + ", item_name = " + this.getItemName()
                + ", item_number = " + this.getItemNumber()
                + ", payment_amount = " + this.getPaymentAmount()
                + ", payment_currency = " + this.getPaymentCurrency()
                + ", receiver_email = " + this.getReceiverEmail()
                + ", request_params = " + this.getRequestParams()
                + ", log_time = " + this.getLogTime()
                + ", error = " + this.getError();
    }

}