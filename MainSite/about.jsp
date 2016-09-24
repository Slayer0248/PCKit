<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>
<%@ page import="java.util.Date,accounts.AuthJWTUtil,accounts.UserLogin" %>
<%@ page import="java.security.SecureRandom,java.math.BigInteger" %>
<!--Code by Clay Jacobs-->
<!DOCTYPE html>
<html>
   <head>
      <title>PCKit</title>
      <link rel="stylesheet" href="stylesheets/main.css">
      <link rel="stylesheet" href="stylesheets/about.css">
      <link rel="stylesheet" href="stylesheets/accountNav.css">
      <link rel="stylesheet" href="stylesheets/fonts.css">
      <script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.4/jquery.min.js" type="text/javascript"></script>
      <script type="text/javascript">
         var w = Math.max(document.documentElement.clientWidth, window.innerWidth || 0)
         var h = Math.max(document.documentElement.clientHeight, window.innerHeight || 0)
         console.log("%d x %d", w, h);
         $(document).ready(function() {
            var fSize = parseFloat($('#placeholderText').css('font-size'))
            console.log("%f px or %f em", fSize, fSize/16);
            $("#curPageContent").load("./AboutSection/AboutUs.html");
            $("#curPageContent").css("height", "600px");
            $("#aboutSectionDiv").css("height", "600px");
        });
        
        function updatePage(navLink) {
           //return false;
           if (navLink != $(".curTab")) {
               $(".curTab").removeClass("curTab");
               $(navLink).addClass("curTab");
             
             
               $("#curPageContent").html("");
               if ($(navLink).html() == "About Us") {
                  $("#curPageContent").load("./AboutSection/AboutUs.html");
                  $("#curPageContent").css("height", "600px");
                  $("#aboutSectionDiv").css("height", "600px");
               }
               else if ($(navLink).html() == "Bios") {
                  $("#curPageContent").load("./AboutSection/Bios.html");
                  $("#curPageContent").css("height", "1300px");
                  $("#aboutSectionDiv").css("height", "1300px");
               }
               else if ($(navLink).html() == "Contact Us") {
                  $("#curPageContent").load("./AboutSection/ContactUs.html");
                  $("#curPageContent").css("height", "80px");
                  $("#aboutSectionDiv").css("height", "80px");
               }
               else {
                  //error case
               }
           }
        }
         
        
        function getCookie(name) {
           var re = new RegExp(name + "=([^;]+)");
           var value = re.exec(document.cookie);
           return (value != null) ? unescape(value[1]) : null;
       }
      </script>
   </head>
   <body>
      <div class="fill-screen">
         <img class="make-it-fit" src="images/background.png" id="bgImage" alt="">
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
              UserLogin login = null;
              String loggedUser ="";
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
                 url:"./accounts/logout/",
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

           <a id="accessLoginLink"href="./accounts/Login.jsp" class="accountAccessText">Login/Sign up</a>

        <% }

        }else{%>
           <a id="accessLoginLink"href="./accounts/Login.jsp" class="accountAccessText">Login/Sign up</a>
        <%}%>
        </div>
         <div class="scrollable" id="mainContentDiv">
             <div id="aboutSectionDiv">
             <div id="aboutSectionNavDiv">
              <ul id="aboutSectionNavLinks">
            	<li class="aboutSectionNavItem"><a id="aboutUsNav" class="aboutSectionNavLink curTab" href="#" onclick="updatePage(this); return false;">About Us</a></li>
            	<li class="aboutSectionNavItem"><a id="biosNav" class="aboutSectionNavLink" href="#" onclick="updatePage(this); return false;">Bios</a></li>
            	<li class="aboutSectionNavItem"><a id="contactUsNav" class="aboutSectionNavLink" href="#" onclick="updatePage(this); return false;">Contact Us</a></li>
              </ul>
             </div>
              <div id="curPageContent">
              
              
              
              </div>
            </div>
         </div> 
         <div id="siteNavDiv">
            <center>
            <ul id="siteNavLinks">
            	<li class="siteNavItem"><a class="siteNavLink" href=".">Home</a></li>
                <li class="siteNavItem"><a class="siteNavLink" href="./forums/list.page">Forums</a></li>
            	<li class="siteNavItem"><a class="siteNavLink" href="#">About PCkit</a></li>
            	<li class="siteNavItem"><a class="siteNavLink" href="./MailingList/">Stay Notified</a></li>
            </ul>
            </center>
         </div>
         
      </div>
      
      
      
      <!--hidden button style = "color: transparent; background-color: transparent; border-color: transparent; cursor: default;"
      <input id="next" type="submit" style="color: red; background-color: red; border-color: transparent; cursor: default;">
      <input id="prev" type="submit" style="color: green; background-color: green; border-color: transparent; cursor: default;">-->
   </body>
</html>
