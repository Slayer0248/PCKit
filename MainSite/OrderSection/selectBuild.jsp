<%@ page language="java" pageEncoding="UTF-8" contentType="text/html;charset=utf-8"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*,java.security.SecureRandom" %>
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
        });
         
        function updateKitStatus(selected) {
           if ($(selected).hasClass("unselectedKitButton")) {
              $(selected).removeClass("unselectedKitButton");
              $(selected).addClass("selectedKitButton");
              $(selected).html("REMOVE FROM CART");
              
              $.ajax({
                 type:"POST",
                 url:"./addToCart/",
                 data:"updates=" + encodeURIComponent($(selected).prop("id").substring(11) + ":1")
               }).done(function(data) {});
           }
           else if ($(selected).hasClass("selectedKitButton")) {
              $(selected).removeClass("selectedKitButton");
              $(selected).addClass("unselectedKitButton");
              $(selected).html("BUY THIS KIT");
              
              $.ajax({
                 type:"POST",
                 url:"./removeFromCart/",
                 data:"updates=" + encodeURIComponent($(selected).prop("id").substring(11) + ":1")
               }).done(function(data) {});
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
                 data:""
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
              Cookie cookie = null;
              Cookie[] cookies = null;
              // Get an array of Cookies associated with this domain
              cookies = request.getCookies();
              String loggedUser ="";
              if( cookies != null ) {
                 for (int i = 0; i < cookies.length; i++){
                    cookie = cookies[i];
                    if (cookie.getName().equals("pckitName")) {
                       loggedUser = (String)cookie.getValue();
                    }
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
                 data:""
              }).done(function(data) { /*Reload current page*/ location.reload(); });
           }
        </script>
        <div class="dropdown">
          <p id="accessLoginLink" class="accountAccessText accessLink"><%= loggedUser%></p><div id="arrowDiv" class="arrow-down" onclick="toggleDropdown();"></div>
          <div class="dropdown-content">
            <a id="accessLogoutLink" href="javascript:void(0)" onclick="logoutUser();" class="accountAccessText">Logout</p>
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

           <% } else { 
           
             if (request.getAttribute("minTier") == null) { %>
             
             <center><img src="../images/PCkit-logo-trans.png" id="logoImageHeader" alt="">
            <p id="form-description">This page cannot be accessed in this manner.</p>
            </center>
             
            <% } else { 
           
             String tierStr = (String)request.getAttribute("minTier");
             int buildTier = Integer.parseInt(tierStr);
             
             Connection connection = null;
             PreparedStatement pstatement = null;
             ResultSet rs = null;
             
             try {
             
                Class.forName("com.mysql.jdbc.Driver");
                connection = DriverManager.getConnection("jdbc:mysql://localhost/PCKitDB","root","Potter11a");
                String queryString = "SELECT * FROM Builds WHERE hardwareTier=? AND buildType=?";
                pstatement = connection.prepareStatement(queryString);
                pstatement.setInt(1, buildTier);
                pstatement.setInt(2, "PC Build");
                rs = pstatement.executeQuery();
                int count=0;
           %>
            <!--<center><img src="../images/PCkit-logo-trans.png" id="logoImage" alt=""></center>
           <p id="descriptionText">Build a custom PC to play the games you want to play at the quality you want to play.</p>
           <button id="BuildPCBuuton" onclick="location.href='selectGames.jsp';">Build your PC</button>-->
           <p id="selectPCP" class="actionText">Select a PCKit</p>
           <p id="noticeP" class="subtitleText">Every kit ships with tools and our custom builder's guide!</p>

           <table id="buildsTable" align="center">
           
           
              
              <tr class="buildsTableRow">
              <% while (rs.next()) {
                String[] descriptions =rs.getString("buildDescriptions").split(":");
                String shortDescription = descriptions[0];
                String longDescription = descriptions[1];
                double price= rs.getInt("price")/100.00;
                 %>
                  <td class="buildCell" id="build<%= rs.getInt("buildId")%>">
                     <p class="buildDescriptionShort"><%= shortDescription%></p>
                     <img class="buildIcon" src="images/BuildIcon.png" width="200px" height="140px">
                     <p class="buildPrice">$<%= price%></p>
                     <p class="buildDescriptionMed"><%= longDescription%></p>
                     <hr class="buildDivider">
                     <button id="selectBuild<%= rs.getInt("buildId")%> class="buyKitButton unselectedKitButton" onclick="updateKitStatus(this)">BUY THIS KIT</button>
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
              }
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
      
      
      
      <!--hidden button style = "color: transparent; background-color: transparent; border-color: transparent; cursor: default;"
      <input id="next" type="submit" style="color: red; background-color: red; border-color: transparent; cursor: default;">
      <input id="prev" type="submit" style="color: green; background-color: green; border-color: transparent; cursor: default;">-->
   </body>
</html>
