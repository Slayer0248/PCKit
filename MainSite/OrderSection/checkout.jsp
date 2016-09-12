<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import = "com.paypal.crypto.sample.ClientSide"%>
<%@ page import = "java.io.*,java.security.cert.*"%>
<%@ page import = "java.security.*,javax.crypto.*"%>
<%@ page import = "org.bouncycastle.cms.*,java.security.*,org.bouncycastle.util.*,org.bouncycastle.cert.jcajce.*"%>
<%@ page import="org.bouncycastle.operator.*,org.bouncycastle.operator.jcajce.*,org.bouncycastle.cms.jcajce.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>
<%@ page import="store.servlets.CartManagerUtil,store.cart.ShoppingCart,store.cart.CartItem" %>
<%@ page import="java.util.Date,accounts.AuthJWTUtil,accounts.UserLogin" %>
<%@ page import="java.security.SecureRandom,java.math.BigInteger" %>

<!DOCTYPE html>
<html>
   <head>
      <title>PCKit</title>
      <link rel="stylesheet" href="../stylesheets/main.css">
      <link rel="stylesheet" href="../stylesheets/checkout.css">
      <link rel="stylesheet" href="../stylesheets/accountNav.css">
      <link rel="stylesheet" href="../stylesheets/statusMessage.css">
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
        
        function getCookie(name) {
           var re = new RegExp(name + "=([^;]+)");
           var value = re.exec(document.cookie);
           return (value != null) ? unescape(value[1]) : null;
       }
        
        function getJSONCart(callback, source) {
           
           $.ajax({
               type:"POST",
               url:"./getCartData/",
               headers: { "csrf":getCookie('csrf')},
               data:""
           }).done(function(data) {
              if(data.indexOf("Success") != -1) {
                 var cart = [];
                 var cartStr = data.substring(8);
                 var items = cartStr.split(",");
                 var i;
                 for (i=0; i<items.length; i++) {
                    var itemVals=items[i].split(":");
                    cart.push({"buildId":itemVals[0], "name":itemVals[4], "price":itemVals[3], "stock":itemVals[2], "quantity":itemVals[1]});
                 }
                 
                 callback(source, cart);
              }
           });
        }
        
        function increaseQuantity(source, oldCart) {
          
           if ($(source).hasClass("enabled")) {
           var curId = $(source).prop("id").substring(8);
           var index = -1;
           var i;
           for (i=0; i<oldCart.length && index == -1; i++) {
              if (oldCart[i].buildId == curId) {
                 index = i;
              }
            }
            
            var oldVal = parseInt(oldCart[index].quantity);
            var maxVal = parseInt(oldCart[index].stock);
            var update =  oldVal+1 ;
            
            if (oldVal == 1) {
               $("#decrease"+ curId).removeClass("disabled");
               $("#decrease"+ curId).addClass("enabled");
            }
            $.ajax({
                 type:"POST",
                 url:"./addToCart/",
                 headers: { "csrf":getCookie('csrf')},
                 data:"updates=" + encodeURIComponent(curId + ":" + update)
            }).done(function(data) {
               if (data == "Success") {
                  $("#quantity"+ curId).html(update);

                  if (update == maxVal) {
                     $("#increase"+ curId).removeClass("enabled");
                     $("#increase"+ curId).addClass("disabled");
                  }   
                  refreshPaypalButton();
               }
            });
            }
        }
        
        function decreaseQuantity(source, oldCart) {
           
           if ($(source).hasClass("enabled")) {
           var curId = $(source).prop("id").substring(8);
           var index = -1;
           var i;
           for (i=0; i<oldCart.length && index == -1; i++) {
              if (oldCart[i].buildId == curId) {
                 index = i;
              }
            }
            
            var oldVal = parseInt(oldCart[index].quantity);
            var maxVal = parseInt(oldCart[index].stock);
            var update =  oldVal-1 ;
            if (oldVal == maxVal) {
               $("#increase"+ curId).removeClass("disabled");
               $("#increase"+ curId).addClass("enabled");
            }
            
            $.ajax({
                 type:"POST",
                 url:"./removeFromCart/",
                 headers: { "csrf":getCookie('csrf')},
                 data:"updates=" + encodeURIComponent(curId + ":" + update)
               }).done(function(data) {
                  if (data == "Success") {
                     $("#quantity"+ curId).html(update);
                     if (update == 1) {
                        $("#decrease"+ curId).removeClass("enabled");
                        $("#decrease"+ curId).addClass("disabled");
                     }   
                     refreshPaypalButton();
                  }
               
               });
            }
        }
        
        function removeFromCart(source, oldCart) {
            var curId = $(source).prop("id").substring(14);
            if (oldCart.length >1) {
               var index = -1;
               var i;
               for (i=0; i<oldCart.length && index == -1; i++) {
                  if (oldCart[i].buildId == curId) {
                     index = i;
                  }
               }
             
               $.ajax({
                    type:"POST",
                    url:"./removeFromCart/",
                    headers: { "csrf":getCookie('csrf')},
                    data:"updates=" + encodeURIComponent(curId + ":0")
               }).done(function(data) {
                  if (data == "Success") {
                      //drop current row
                      $("#orderItemRow" + curId).remove();
                      refreshPaypalButton();
                  
                      var j;
                      for (j = index+1; j<oldCart.length; j++ ) {
                         $("#itemIndexCell" + oldCart[j].buildId).html("<center>" + j+"</center>");
                      }
                      
                       
                  }
               });
            }
            else {
               //can't remove on this page
            }
        }
        
        function updateCartStatus() {
        
        }
        
        function refreshPaypalButton() {
          
           $.ajax({
             type:"POST",
             url:"./processCart/",
             headers: { "csrf":getCookie('csrf')},
             data:""
           }).done(function(data) {
              if (data.indexOf("Success") != -1 &&  $("input[name='encrypted']").length > 0) {
                 var encryptedStr = data.substring(8);
                 $("input[name='encrypted']").attr("value", encryptedStr);
              }
              else if (data == "Reload") {
              
              }
           
           });
          
        }
        
        
        function goToPrevPage() {
        
        
        }
         
      </script>
   </head>
   <body>
      <div class="fill-screen">
        <%
           //ClientSide client_side = new ClientSide( "my-pubcert.pem", "my-prvkey.p12", "paypal_cert_pem.txt", "Potter11a" );

		   //String result = client_side.getButtonEncryptionValue( "cert_id=SFTMKZFWK2YK8,cmd=_cart,upload=1,business=pckitcompany@gmail.com,item_name_1=Handheld Computer,amount_1=500.00", "/home/ec2-user/pckit/MainSite/OrderSection/my-prvkey.p12", "/home/ec2-user/pckit/MainSite/OrderSection/my-pubcert.pem", "/home/ec2-user/pckit/MainSite/OrderSection/paypal_cert_pem.txt", "Potter11a" );
		   //String result = client_side.getButtonEncryptionValue( "business=pckitcompany@gmail.com\n    cert_id=SFTMKZFWK2YK8\n    cmd=_cart\n    upload=1\n    item_name=Handheld Computer\n    amount=500.00", "/Applications/tomcat/webapps/PCKit/Accounts/my-prvkey.p12", "/Applications/tomcat/webapps/PCKit/Accounts/my-pubcert.pem", "/Applications/tomcat/webapps/PCKit/Accounts/paypal_cert_pem.txt", "Potter11a" );
        %>
         <img class="make-it-fit" src="../images/background.png" id="bgImage" alt="">
         <div id="accountAccessDiv">
           <%
              AuthJWTUtil authUtil = new AuthJWTUtil();
              long nowMillis = System.currentTimeMillis();
              java.util.Date now = new java.util.Date(nowMillis);
              
              try {
              
                 SecureRandom random = new SecureRandom();
                 String tokenCSRF = new BigInteger(130, random).toString(32);
                 
                 Cookie cookieCSRF2 = new Cookie("csrfCheck", authUtil.makeCSRFCookie(tokenCSRF, nowMillis, 30));
                 cookieCSRF2.setPath("/");
                 cookieCSRF2.setHttpOnly(true);
                 cookieCSRF2.setSecure(true);
                 response.addCookie(cookieCSRF2);
                 
                 Cookie cookieCSRF = new Cookie("csrf",tokenCSRF);
                 cookieCSRF.setPath("/");
                 cookieCSRF.setSecure(true);
                 response.addCookie(cookieCSRF);
              
                 
              
              }
              catch (Exception e) {
              
              }
              
              Cookie cookie = null;
              Cookie[] cookies = null;
              // Get an array of Cookies associated with this domain
              cookies = request.getCookies();
              String loggedUser ="";
              //String orderText = "";
              UserLogin login = null;
              String result = "";
              if( cookies != null ) {
                 for (int i = 0; i < cookies.length; i++){
                    cookie = cookies[i];
                    if (cookie.getName().equals("pckitLogin")) {
                       String token = (String)cookie.getValue();
                       Connection connection =null;
                       try {
                          Class.forName("com.mysql.jdbc.Driver");
                          connection = DriverManager.getConnection("jdbc:mysql://localhost/PCKitDB","root","Potter11a");
                          ArrayList<UserLogin> logs = authUtil.getAll(now, connection);
                          authUtil.refreshAll(now, connection); 
                          result = authUtil.validateToken(token, now, connection);
                          if (result.equals("Valid")) {
                             login = authUtil.getLoginResult();
                             loggedUser = authUtil.escapeHTML(login.getFirstName()) + " " + authUtil.escapeHTML(login.getLastName());
                          }
                       }
                       catch (Exception e) {
                          
                       }
                    }
                    /*if (cookie.getName().equals("order")) {
                       orderText = (String)cookie.getValue();
                    }*/
                    //out.print("Name : " + cookie.getName( ) + ",  ");
                    //out.print("Value: " + cookie.getValue( )+" <br/>");
                 }


                if (loggedUser.length() > 0) { %>
          <script type="text/javascript">
          function toggleDropdown() {
             if ($("#arrowDiv").hasClass("arrow-down")) {
                $("#arrowDiv").removeClass("arrow-down");
                $("#arrowDiv").addClass("arrow-up");
                var curWidth = $("#accessLoginLink").width();
                $(".dropdown-content").width(curWidth);
                $(".dropdown-content").height(30);
                $(".dropdown").addClass("showDropdown");
                $(".dropdown-content").addClass("showDropdown");

             }
             else {
                $("#arrowDiv").removeClass("arrow-up");
                $("#arrowDiv").addClass("arrow-down");
                $(".dropdown").removeClass("showDropdown");
                $(".dropdown-content").removeClass("showDropdown");
             }
          }

          function logoutUser() {
              $.ajax({
                 type:"POST",
                 url:"../accounts/logout/",
                 headers: { "csrf":getCookie('csrf')},
                 data:"",
                 error: function (xhr, status, message) {
                     console.log(xhr.responseText );
                     console.log('A jQuery error has occurred. Status: ' + status + ' - Message: ' + message);
                  }

              }).done(function(data) { /*Reload current page*/ location.reload(); });
           }
        </script>
        <div class="dropdown">
          <p id="accessLoginLink" class="accountAccessText accessLink"><%= loggedUser%></p><div id="arrowDiv" class="arrow-down" onclick="toggleDropdown();"></div>
          <div class="dropdown-content">
            <a id="accessLogoutLink" href="javascript:void(0)" onclick="logoutUser();" class="accountAccessText">Logout</a>
          </div>
        </div>
        <% }
        else { %>

           <a id="accessLoginLink"href="../accounts/Login.jsp" class="accountAccessText">Login/Sign up</a>

        <% }

        } else {%>
           <a id="accessLoginLink"href="../accounts/Login.jsp" class="accountAccessText">Login/Sign up</a>
        <% } %>
        </div>
         <div class="scrollable" id="mainContentDiv">
            <%if (loggedUser.length() == 0) { %>
            <center><img src="../images/PCkit-logo-trans.png" id="logoImageHeader" alt="">
            <p id="form-description">You must be logged in to view this page.</p>
            </center>

           <% } else { %>
           
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
                 
        <%  String[] cartStates = {"In Progress", "Buying"};
            ArrayList<ShoppingCart> orders = login.getOrdersWithStatus(cartStates);
            ShoppingCart cart = null;
             
             if (orders.size() > 0) {
                cart = orders.get(0);
                %>
                <%= cart.size()%>                

                <% for(int i=0; i<cart.size(); i++) {
                   CartItem curItem = cart.get(i);
                   int quantity = cart.getItemQuantity(i);
                   String decreaseState = "enabled";
                   String increaseState = "enabled";
                   if (quantity==1) {
                      decreaseState = "disabled";
                   }
                   if (quantity==curItem.getInventory()) {
                      increaseState = "disabled";
                   }
                %>
                <tr id="orderItemRow<%= curItem.getItemId()%>" class="itemRow">
                   <td id="itemIndexCell<%= curItem.getItemId()%>" class="indexCol"><center><%= i+1%></center></td>
                   <td id="itemNameCell<%= curItem.getItemId()%>" class="nameCol"><%=  authUtil.escapeHTML(curItem.getName())%></td>
                   <td id="itemPriceCell<%= curItem.getItemId()%>" class="priceCol"><center>$<%= curItem.getPrice()%></center></td>
                   <td id="itemQuantityCell<%= curItem.getItemId()%>" class="quantityCol">
                      
                      <center>
                      <img src="../images/DecreaseButton.png" id="decrease<%= curItem.getItemId()%>" class="imgButton <%= decreaseState%>" onclick="getJSONCart(decreaseQuantity, this)"/>
                      <font id="quantity<%= curItem.getItemId()%>"><%= quantity%></font>
                      <img src="../images/IncreaseButton.png" id="increase<%= curItem.getItemId()%>" class="imgButton <%= increaseState%>" onclick="getJSONCart(increaseQuantity, this)"/></center>
                   </td>
                   <td id="itemRemoveCell<%= curItem.getItemId()%>" class="removeCol" onclick="getJSONCart(removeFromCart, this)"><center>X</center></td>
                </tr>
                 <% } 
                 
                 }  else {%>No shopping cart found<%  }%>
                 
                 
              </table><center>
                <% if (cart != null) { %>
              <form id="payPalForm" action="https://www.paypal.com/cgi-bin/webscr" method="post" target="_top">
                <input type="hidden" name="cmd" value="_s-xclick">
                <input type="hidden" name="encrypted" value="<%= cart.getEncryptedStr()%>">
                <input type="image" src="https://www.paypalobjects.com/en_US/i/btn/btn_buynowCC_LG.gif" border="0" name="submit" alt="PayPal - The safer, easier way to pay online!">
                <img alt="" border="0" src="https://www.paypalobjects.com/en_US/i/scr/pixel.gif" width="1" height="1">
              </form>
              <% } %>
           </div>
           
           <% 
           } %>
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
