<%@ page language="java" pageEncoding="UTF-8" contentType="text/html;charset=utf-8"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="java.util.Date,accounts.AuthJWTUtil,accounts.UserLogin" %>
<%@ page import="java.security.SecureRandom,java.math.BigInteger" %>
<!--Code by Clay Jacobs-->
<!DOCTYPE html>
<html>
   <head>
      <title>PCKit</title>
      <link rel="stylesheet" href="../stylesheets/main.css">
      <link rel="stylesheet" href="../stylesheets/orderProcess1.css">
      <link rel="stylesheet" href="../stylesheets/accountNav.css">
      <link rel="stylesheet" href="../stylesheets/existingCartMessage.css">
      <link rel="stylesheet" href="../stylesheets/fonts.css">
      
      <script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.4/jquery.min.js" type="text/javascript"></script>
      <script type="text/javascript">
         var w = Math.max(document.documentElement.clientWidth, window.innerWidth || 0)
         var h = Math.max(document.documentElement.clientHeight, window.innerHeight || 0)
         console.log("%d x %d", w, h);
         $(document).ready(function() {
            var fSize = parseFloat($('#placeholderText').css('font-size'))
            console.log("%f px or %f em", fSize, fSize/16);
            $("#overlay").hide();
        });
        
        function getCookie(name) {
           var re = new RegExp(name + "=([^;]+)");
           var value = re.exec(document.cookie);
           return (value != null) ? unescape(value[1]) : null;
       }
        
        
           function restoreCart() {
              var status;
              var index =$("#cartMessageText").text().indexOf("purchase");
              if (index == -1) {
                 status = "In Progress";
              }
              else {
                 status = "Buying";
              }
              
              $.ajax({
                 type:"POST",
                 url:"./restoreCart/",
                 headers: { "csrf":getCookie('csrf')},
                 data:"status="+encodeURIComponent(status) 
               }).done(function(data) {
                  if (data == "Reload") {
                     location.reload();
                  }
                  else if (data == "Success") {
                     result = data;
                     $.ajax({
                       type:"POST",
                       url:"./selectBuild.jsp",
                       data:JSON.stringify({"minTier": 1})
                     }).done(function(data2) { /*window.location.href = "http://www.pckitcj.com/OrderSection/selectBuild.jsp";*/
document.write(data2); history.pushState({}, null, "https://www.pckitcj.com/OrderSection/selectBuild.jsp"); });
                  }
               });
              
              
           }
           
           function restoreAndCheckoutCart() {
              $.ajax({
                 type:"POST",
                 url:"./restoreCart/",
                 headers: { "csrf":getCookie('csrf')},
                 data:"status="+encodeURIComponent("Buying") 
               }).done(function(data) {
                  if (data == "Reload") {
                     location.reload();
                  }
                  else if (data == "Success") {
                     result = data;
                     $.ajax({
                       type:"POST",
                       url:"./checkout.jsp",
                       data:""
                     }).done(function(data) { window.location.href = "http://www.pckitcj.com/OrderSection/checkout.jsp"; });
                  }
               });
           }
           
           function deleteCart() {
              var status;
              var index =$("#cartMessageText").text().indexOf("purchase");
              if (index == -1) {
                 status = "In Progress";
              }
              else {
                 status = "Buying";
              }
              
           
              $.ajax({
                type:"POST",
                url:"./deleteCartsWithStatus/",
                headers: { "csrf":getCookie('csrf')},
                data:"status="+encodeURIComponent(status) 
              }).done(function(data) {
                 console.log(data);
                 if (data =="Reload") {
                     location.reload();
                 } 
                 else if (data == "Successful") {
                     location.href='./selectGames.jsp';
                 }
              });
           }
           
           function hasCart(callback) {
               $.ajax({
                 type:"POST",
                 url:"./hasCart/",
                 headers: { "csrf":getCookie('csrf')},
                 success:callback
               });
           }
           
           function goToNextPage(isCart) {          
             if ($("#accessLogoutLink").length > 0 && isCart=="No") { 
             $.ajax({
                 type:"POST",
                 url:"./cartExists/",
                 headers: { "csrf":getCookie('csrf')},
                 data:"status="+encodeURIComponent("Buying") 
               }).done(function(data) {
                  if (data == "Yes") {
                      //show restore & purchase message & add blur
                      $("#accountAccessDiv").addClass("blur");
                      $("#mainContentDiv").addClass("blur");
                      $("#siteNavDiv").addClass("blur");
                      $("#bgImage").addClass("blur");
                      $("#overlay").show();
                      $("#popup").html("<span id='msgSpan'><p id='cartMessageText'>You were logged out while completing a purchase. Would you like to proceed with your saved cart?</p></span><span id='linkSpan'><a class='cartActionLink' id='checkoutLink' href='javascript: void(0)' onclick='restoreAndCheckoutCart();'>Skip to Checkout</a><a class='cartActionLink' id='restoreLink' href='javascript: void(0)' onclick='restoreCart();'>Restore Cart</a><a class='cartActionLink' id='deleteLink' href='javascript: void(0)' onclick='deleteCart();'>Delete Cart</a></span>");
                      //$(cartMsg).insertBefore($("#bgImage"));
                  }
                 
                  else if (data == "No" || data == "Delete")  {
                     if (data == "Delete") {
                     
                        $.ajax({
                           type:"POST",
                           url:"./deleteCartsWithStatus/",
                           headers: { "csrf":getCookie('csrf')},
                           data:"status="+encodeURIComponent("Buying") 
                         }).done(function(data3) {
                            if (data3 =="Reload") {
                               location.reload();
                            } 
                        });
                     } 
                     $.ajax({
                       type:"POST",
                       url:"./cartExists/",
                       headers: { "csrf":getCookie('csrf')},
                       data:"status="+encodeURIComponent("In Progress") 
                     }).done(function(data2) {
                         if (data2 == "Yes") {
                             //show restore message & add blur
                             $("#accountAccessDiv").addClass("blur");
                             $("#mainContentDiv").addClass("blur");
                             $("#siteNavDiv").addClass("blur");
                             $("#bgImage").addClass("blur");
                             $("#overlay").show();
                             $("#popup").html("<span id='msgSpan'><p id='cartMessageText'>You were logged out with a cart in progress. Would you like to proceed with your saved cart?</p></span><span id='linkSpan'><a class='cartActionLink' id='restoreLink' href='javascript: void(0)' onclick='restoreCart();'>Restore Cart</a><a class='cartActionLink' id='deleteLink' href='javascript: void(0)' onclick='deleteCart();'>Delete Cart</a></span>");
                             //$(cartMsg).insertBefore($("#bgImage"));
                         }
                         else if (data2 == "Delete") {
                           //create servlet to delete with status for user here
                           $.ajax({
                              type:"POST",
                              url:"./deleteCartsWithStatus/",
                              headers: { "csrf":getCookie('csrf')},
                              data:"status="+encodeURIComponent("In Progress") 
                            }).done(function(data3) {
                                if (data3 =="Successful") {
                                   location.href='./selectGames.jsp';
                                }
                                else if (data3 =="Reload") {
                                   location.reload();
                                } 
                            });
                     
                            location.href='./selectGames.jsp';
                         }
                         else if (data2 == "No") {
                             location.href='./selectGames.jsp';
                         }
                         else if (data2 == "Reload") {
                            location.reload();
                         }
                     });
                  }
                  else if (data == "Reload") {
                     location.reload();
                  }
               });
              }
              else {
                 location.href='./selectGames.jsp';
              }
           }
         
      </script>
   </head>
   <body>
      <div class="fill-screen">
         <div id='overlay'><div id='popup'><span id='msgSpan'><p id='cartMessageText'></p></span></div></div>
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
              UserLogin login = null;
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
                          String result = authUtil.validateToken(token, now, connection);
                          if (result.equals("Valid")) {
                             login = authUtil.getLoginResult();
                             loggedUser = authUtil.escapeHTML(login.getFirstName()) + " " + authUtil.escapeHTML(login.getLastName());
                          }
                       }
                       catch (Exception e) {
                          
                       }
                    }
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
                 data:""
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

        }else{%>
           <a id="accessLoginLink"href="../accounts/Login.jsp" class="accountAccessText">Login/Sign up</a>
        <%}%>
        </div>
         <div class="scrollable centerHorizontally" id="mainContentDiv">
            <!--<center><img src="../images/PCkit-logo-trans.png" id="logoImage" alt=""></center>-->
           <p id="descriptionText">Build a custom PC to play the games you want to play at the quality you want to play.</p>
           <button id="BuildPCBuuton" onclick="hasCart(goToNextPage);">Build your PC</button>
         </div>
         <div id="siteNavDiv">
            <center>
            <ul id="siteNavLinks">
            	<li class="siteNavItem"><a class="siteNavLink" href="..">Home</a></li>
                <li class="siteNavItem"><a class="siteNavLink" href="../forums/list.page">Forums</a></li>
                <li class="siteNavItem"><a class="siteNavLink" href="../OrderSection/orderProcess.jsp">Store</a></li>
            	<li class="siteNavItem"><a class="siteNavLink" href="../about.jsp">About PCkit</a></li>
            	<li class="siteNavItem"><a class="siteNavLink" href="../MailingList/">Stay Notified</a></li>
            </ul>
            </center>
         </div>
         
      </div>

   </body>
</html>
