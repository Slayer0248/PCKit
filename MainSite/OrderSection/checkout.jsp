<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import = "com.paypal.crypto.sample.ClientSide"%>
<%@ page import = "java.io.*,java.security.cert.*"%>
<%@ page import = "java.security.*,javax.crypto.*"%>
<%@ page import = "org.bouncycastle.cms.*,java.security.*,org.bouncycastle.util.*,org.bouncycastle.cert.jcajce.*"%>
<%@ page import="org.bouncycastle.operator.*,org.bouncycastle.operator.jcajce.*,org.bouncycastle.cms.jcajce.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>

<!DOCTYPE html>
<html>
   <head>
      <title>PCKit</title>
      <link rel="stylesheet" href="../stylesheets/main.css">
      <link rel="stylesheet" href="../stylesheets/checkout.css">
      <link rel="stylesheet" href="../stylesheets/fonts.css">
      
      <script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.4/jquery.min.js" type="text/javascript"></script>
      <script type="text/javascript">
         var w = Math.max(document.documentElement.clientWidth, window.innerWidth || 0)
         var h = Math.max(document.documentElement.clientHeight, window.innerHeight || 0)
         console.log("%d x %d", w, h);
         $(document).ready(function() {
            var fSize = parseFloat($('#placeholderText').css('font-size'))
            console.log("%f px or %f em", fSize, fSize/16);
        });
         
      </script>
   </head>
   <body>
      <div class="fill-screen">
        <%
           ClientSide client_side = new ClientSide( "my-pubcert.pem", "my-prvkey.p12", "paypal_cert_pem.txt", "Potter11a" );

		   String result = client_side.getButtonEncryptionValue( "cert_id=SFTMKZFWK2YK8,cmd=_cart,upload=1,business=pckitcompany@gmail.com,item_name_1=Handheld Computer,amount_1=500.00", "/home/ec2-user/pckit/MainSite/OrderSection/my-prvkey.p12", "/home/ec2-user/pckit/MainSite/OrderSection/my-pubcert.pem", "/home/ec2-user/pckit/MainSite/OrderSection/paypal_cert_pem.txt", "Potter11a" );
		   //String result = client_side.getButtonEncryptionValue( "business=pckitcompany@gmail.com\n    cert_id=SFTMKZFWK2YK8\n    cmd=_cart\n    upload=1\n    item_name=Handheld Computer\n    amount=500.00", "/Applications/tomcat/webapps/PCKit/Accounts/my-prvkey.p12", "/Applications/tomcat/webapps/PCKit/Accounts/my-pubcert.pem", "/Applications/tomcat/webapps/PCKit/Accounts/paypal_cert_pem.txt", "Potter11a" );
        %>
         <img class="make-it-fit" src="../images/background.png" id="bgImage" alt="">
         <div class="scrollable" id="mainContentDiv">
            <!--<center><img src="../images/PCkit-logo-trans.png" id="logoImage" alt=""></center>
           <p id="descriptionText">Build a custom PC to play the games you want to play at the quality you want to play.</p>
           <button id="BuildPCBuuton" onclick="location.href='selectGames.jsp';">Build your PC</button>-->
           <div id="curPageContent">
              <center><table id="orderSummaryTable">
                 <tr id="orderSummaryHeader">
                   <th id="itemIndexHeader" class="indexCol"></th>
                   <th id="itemNameHeader" class="nameCol">Item</th>
                   <th id="itemPriceHeader" class="priceCol">Price</th>
                   <th id="itemQuantityHeader" class="quantityCol">Quantity</th>
                   <th id="itemRemoveHeader" class="removeCol">In Cart</th>
                 </tr>
                <tr id="orderItemRow1" class="itemRow">
                   <td id="itemIndexCell1" class="indexCol"><center>1</center></td>
                   <td id="itemNameCell1" class="nameCol">Item</td>
                   <td id="itemPriceCell1" class="priceCol"><center>Price</center></td>
                   <td id="itemQuantityCell1" class="quantityCol">
                      <center><img src="../images/DecreaseButton.png" id="decrease1" class="imgButton"/>
                      <font id="quantity1">1</font>
                      <img src="../images/IncreaseButton.png" id="increase1" class="imgButton"/></center>
                   </td>
                   <td id="itemRemoveCell1" class="removeCol"><center>X</center></td>
                </tr>
              </table><center>
              <form id="payPalForm" action="https://www.paypal.com/cgi-bin/webscr" method="post" target="_top">
                <input type="hidden" name="cmd" value="_s-xclick">
                <input type="hidden" name="encrypted" value="<%= result %>">
                <input type="image" src="https://www.paypalobjects.com/en_US/i/btn/btn_buynowCC_LG.gif" border="0" name="submit" alt="PayPal - The safer, easier way to pay online!">
                <img alt="" border="0" src="https://www.paypalobjects.com/en_US/i/scr/pixel.gif" width="1" height="1">
              </form>
           </div>
         </div> 
         <img src="../images/BackArrow.png" id="backButton" class="orderNavButton" onclick="location.href='selectBuild.jsp';"/>
         <!--<img src="../images/NextArrow.png" id="nextButton" class="orderNavButton" onclick="location.href='orderProcess.html';"/>-->
         <div id="siteNavDiv">
            <center>
            <ul id="siteNavLinks">
            	<li class="siteNavItem"><a class="siteNavLink" href="..">Home</a></li>
            	<li class="siteNavItem"><a class="siteNavLink" href="../about.html">About PCkit</a></li>
            	<li class="siteNavItem"><a class="siteNavLink" href="../MailingList/">Stay Notified</a></li>
            </ul>
            </center>
         </div>

         
      </div>
      
      
      
      <!--hidden button style = "color: transparent; background-color: transparent; border-color: transparent; cursor: default;"
      <input id="next" type="submit" style="color: red; background-color: red; border-color: transparent; cursor: default;">
      <input id="prev" type="submit" style="color: green; background-color: green; border-color: transparent; cursor: default;">-->
   </body>
</html>
