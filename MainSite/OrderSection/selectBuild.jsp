<%@ page language="java" pageEncoding="UTF-8" contentType="text/html;charset=utf-8"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*,java.security.SecureRandom" %>
<%@ page import="java.util.Date,accounts.AuthJWTUtil,accounts.UserLogin,store.cart.ShoppingCart" %>
<%@ page import="java.math.BigInteger" %>
<!--Code by Clay Jacobs-->
<!DOCTYPE html>
<html>
   <head>
      <title>PCKit</title>
      <link rel="stylesheet" href="../stylesheets/main.css">
      <link rel="stylesheet" href="../stylesheets/selectBuild.css">
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
            //setupWithCart();
        });
        
        function getCookie(name) {
           var re = new RegExp(name + "=([^;]+)");
           var value = re.exec(document.cookie);
           return (value != null) ? unescape(value[1]) : null;
       }
 
         
        function updateKitStatus(selected) {
           if ($(selected).hasClass("unselectedKitButton")) {
              
              
              $.ajax({
                 type:"POST",
                 url:"./addToCart/",
                 headers: { "csrf":getCookie('csrf')},
                 data:"updates=" + encodeURIComponent($(selected).prop("id").substring(11) + ":1")
               }).done(function(data) {
                  if (data == "Success") {
                     $(selected).removeClass("unselectedKitButton");
                     $(selected).addClass("selectedKitButton");
                     $(selected).html("REMOVE FROM CART");
                  }
               });
           }
           else if ($(selected).hasClass("selectedKitButton")) {
              
              
              $.ajax({
                 type:"POST",
                 url:"./removeFromCart/",
                 headers: { "csrf":getCookie('csrf')},
                 data:"updates=" + encodeURIComponent($(selected).prop("id").substring(11) + ":0")
               }).done(function(data) {
                   if (data == "Success") {
                      $(selected).removeClass("selectedKitButton");
                      $(selected).addClass("unselectedKitButton");
                      $(selected).html("BUY THIS KIT");
                   }
               });
           }
        }
        
        function goToNextPage() {
           var errors="";
           if ($(".selectedKitButton").length ==0) {
              //show form error
              errors= errors+"<li class='formErrorReason'>At least one build must be selected.</li>";  
           }
           if (errors.length==0){
               
               
               $.ajax({
                 type:"POST",
                 url:"./checkout.jsp",
                 data:"",
error: function (xhr, status, message) {
                     console.log(xhr.responseText );
                     console.log('A jQuery error has occurred. Status: ' + status + ' - Message: ' + message);
                  }

               }).done(function(data) { window.location.href = "http://www.pckit.org/OrderSection/checkout.jsp"; });
               
               
           }
           else {
              if ($("#formErrorsDiv").length > 0) {
     	          $("#errorsList").children().remove();
     	          $("#errorsList").html(errors);
     	      }
              else {
     	         fullErrorOutput = '<div id="formErrorsDiv"><p id="formErrorsInfo">Can\'t proceed due to the following errors:</p><ul id="errorsList" type="disc">';
     	         fullErrorOutput = fullErrorOutput + errors + '</ul></div>';
     	         $(fullErrorOutput).insertBefore($("#selectPCP"));
     	      }
           }
        }
      </script>
   </head>
   <body>
      <div class="fill-screen">

         <% 
         //TODO: check for csrf cookie and csrf token in POST so we can display the page
             
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
              String orderText = "";
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
        <% } 
        ArrayList<Integer> buildIds = new ArrayList<Integer>();
        if (orderText.length() > 0) {
           String[] builds = orderText.split(",");
           for (int i=0; i<builds.length; i++) {
              int buildId = Integer.parseInt(builds[i].split(":")[0]);
              buildIds.add(buildId);
           }
        }
        %>
        </div>
         <div class="scrollable" id="mainContentDiv">
            <%if (loggedUser.length() == 0) { %>
            <center><img src="../images/PCkit-logo-trans.png" id="logoImageHeader" alt="">
            <p id="form-description">You must be logged in to view this page.</p>
            </center>

           <% } else { 
           
             ShoppingCart cart = login.getActiveCart();
            
             int buildTier = cart.getMinTier();
             
             Connection connection = null;
             PreparedStatement pstatement = null;
             ResultSet rs = null;
             
             try {
             
                Class.forName("com.mysql.jdbc.Driver");
                connection = DriverManager.getConnection("jdbc:mysql://localhost/PCKitDB","root","Potter11a");
                String queryString = "SELECT * FROM Builds WHERE hardwareTier=? AND buildType=?";
                pstatement = connection.prepareStatement(queryString);
                pstatement.setInt(1, buildTier);
                pstatement.setString(2, "PC Build");
                rs = pstatement.executeQuery();
                int count=0;
           %>
           <p id="selectPCP" class="actionText">Select a PCKit</p>
           <p id="noticeP" class="subtitleText">Every kit ships with tools and our custom builder's guide!</p>

           <table id="buildsTable" align="center">
           
           
              
              <tr class="buildsTableRow">
              <% while (rs.next()) {
                String[] descriptions =rs.getString("buildDescriptions").split(":");
                String shortDescription = descriptions[0];
                String longDescription = descriptions[1];
                double price= rs.getInt("price")/100.00;
                
                int isSelected = 0;
                for (int i=0; i<buildIds.size() && isSelected==0; i++) {
                   if (rs.getInt("buildId") == buildIds.get(i)) {
                      isSelected =1;
                   }
                }
                 %>
                  <td class="buildCell" id="build<%= rs.getInt("buildId")%>">
                     <p class="buildDescriptionShort"><%=  authUtil.escapeHTML(shortDescription)%></p>
                     <img class="buildIcon" src="images/BuildIcon.png" width="200px" height="140px">
                     <p class="buildPrice">$<%=  price%></p>
                     <p class="buildDescriptionMed"><%=  authUtil.escapeHTML(longDescription)%></p>
                     <hr class="buildDivider">
                     <% if (isSelected == 0) { %>
                     <button id='selectBuild<%= rs.getInt("buildId")%>' class="buyKitButton unselectedKitButton" onclick="updateKitStatus(this)">BUY THIS KIT</button>
                     <% } else { %>
                     <button id='selectBuild<%= rs.getInt("buildId")%>' class="buyKitButton selectedKitButton" onclick="updateKitStatus(this)">REMOVE FROM CART</button>
                     <% } %>
                     <!--<ul></ul>-->
                     <p class="buildSpecs">AMD FX-6300 3.5GHz 6-Core Processor<br><br>
                     G.Skill Ripjaws Series 8GB (2 x 4GB) DDR3-1600 Memory<br><br>
                     Seagate Barracuda 1TB 3.5" 7200RPM Internal Hard Drive<br><br>
                     EVGA GeForce GTX 950 2GB Superclocked Video Card</p>
                  </td>
              <% } %>
              </tr>
              
           </table>

           <%  }
               catch (Exception e) {%>
                 <center><img src="../images/PCkit-logo-trans.png" id="logoImageHeader" alt="">
            <p id="form-description">An error occurred while reading the database.</p>
            </center>
           <%   }
           } %>
         </div> 
         <% if (loggedUser.length() > 0) { %>
            <img src="../images/BackArrow.png" id="backButton" class="orderNavButton" onclick="location.href='selectGames.jsp';"/>
            <img src="../images/NextArrow.png" id="nextButton" class="orderNavButton" onclick="goToNextPage()"/>
         <% } %>
         <div id="siteNavDiv">
            <center>
            <ul id="siteNavLinks">
            	<li class="siteNavItem"><a class="siteNavLink" href="..">Home</a></li>
                <li class="siteNavItem"><a class="siteNavLink" href="../forums/list.page">Forums</a></li>
            	<li class="siteNavItem"><a class="siteNavLink" href="../about.jsp">About PCkit</a></li>
            	<li class="siteNavItem"><a class="siteNavLink" href="../MailingList/">Stay Notified</a></li>
            </ul>
            </center>
         </div>

         
      </div>
 
   </body>
</html>
