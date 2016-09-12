<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>
<%@ page import="java.util.Date,accounts.AuthJWTUtil,accounts.UserLogin" %>
<%@ page import="java.security.SecureRandom,java.math.BigInteger" %>

<!DOCTYPE html>
<html>
   <head>
      <title>PCKit</title>
      <link rel="stylesheet" href="../stylesheets/main.css">
      <link rel="stylesheet" href="../stylesheets/signup.css">
      <link rel="stylesheet" href="../stylesheets/accountNav.css">
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
        
       var ESC_MAP = {
          '&': '&amp;',
          '<': '&lt;',
          '>': '&gt;',
          '"': '&quot;',
          "'": '&#39;'
       };

       function escapeHTML(s, forAttribute) {
          return s.replace(forAttribute ? /[&<>'"]/g : /[&<>]/g, function(c) {
             return ESC_MAP[c];
          });
       }
        
        $(function(){
           $("#signUpForm").on("submit", function(e) {
              e.preventDefault();
              var errorList="";
              if($("#firstNameText").val().length == 0 || $("#firstNameText").val() == null) {
     	          errorList = errorList + "<li class='formErrorReason'>First name field is empty</li><br>";
     	      }
     	      if($("#lastNameText").val().length == 0 || $("#lastNameText").val() == null) {
     	         errorList = errorList + "<li class='formErrorReason'>Last name field is empty</li><br>";
     	      }
     	      if($("#emailText").val().length == 0 || $("#emailText").val() == null) {
     	         errorList = errorList + "<li class='formErrorReason'>Email field is empty</li><br>";
     	      }
     	      else if($("#emailText").val().includes("@") == false) {
     	         errorList = errorList + "<li class='formErrorReason'>Email value isn't a valid email address.</li><br>";
     	      }
     	      
     	      if($("#passwordText").val().length == 0 || $("#passwordText").val() == null) {
     	         errorList = errorList + "<li class='formErrorReason'>Password field is empty</li><br>";
     	      }
     	      else if($("#passwordMatchText").val().length == 0 || $("#passwordMatchText").val() == null) {
     	         errorList = errorList + "<li class='formErrorReason'>Confirm Password field is empty</li><br>";
     	      }
     	      else if($("#passwordText").val() != $("#passwordMatchText").val()) {
     	         errorList = errorList + "<li class='formErrorReason'>Passwords don't match</li><br>";
     	         
     	      }
     	      
     	      
     	      if (errorList.length == 0) {
     	         $.ajax({
     	            type : "POST",
     	            url: "/accounts/account-exists/",
     	            headers: { "csrf":getCookie('csrf')},
     	            data: "email=" + encodeURIComponent($("#emailText").val()),
     	            success: function (data) {
     	               if (data == "No") {
     	                  nextData = "Email=" + encodeURIComponent($("#emailText").val()) +"&Password="+encodeURIComponent($("#passwordText").val())+ "&firstName="+encodeURIComponent($("#firstNameText").val()) +  "&lastName="+encodeURIComponent($("#lastNameText").val());
     	                  $.ajax({
     	                    type : "POST",
     	                    url: "/accounts/register/",
     	                    headers: { "csrf":getCookie('csrf')},
     	                    data: nextData
     	                  }).done(function(outData) { document.write(outData); });
     	               }
     	               else {
     	                  if (data == "Yes") {
     	                     errorList = errorList + "<li class='formErrorReason'>Account already exists.</li><br>";
     	                  }
     	                  else {
     	                     errorList = errorList + "<li class='formErrorReason'>" + data + "</li><br>";
     	                  }
     	                  fullErrorOutput = '<div id="formErrorsDiv"><ul id="errorsList" type="disc">';
     	                  fullErrorOutput = fullErrorOutput +errorList + '</ul></div>';
     	                  $(fullErrorOutput).insertBefore($("#signUpForm"));
     	                  var shift= 20 +$("#formErrorsDiv").height();
     	         
     	                  $("#signUpDiv").css("height", (233+shift).toString()+ "px");
     	                  $("#signUpDiv").css("margin-top", (250-shift).toString()+ "px");
     	               }
     	            }
     	         });
     	       
     	      
     	      }
     	      else {
     	         fullErrorOutput = '<div id="formErrorsDiv"><ul id="errorsList" type="disc">';
     	         fullErrorOutput = fullErrorOutput + errorList + '</ul></div>';
     	         $(fullErrorOutput).insertBefore($("#signUpForm"));
     	         var shift= 20 +$("#formErrorsDiv").height();
     	         
     	         $("#signUpDiv").css("height", (233+shift).toString()+ "px");
     	         $("#signUpDiv").css("margin-top", (250-shift).toString()+ "px");
     	          
     	         
     	      }
     	      
     	      
           });
           
           $("#signUpAction").bind("click",function(){
              $("#signUpForm").submit();  // consider idOfYourForm `id` of your form which you are going to submit
           });
        });
         
      </script>
   </head>
   <body>
      <div class="fill-screen">

         <%
         /*TODO: check for csrf cookie and csrf token in POST so we can display the page*/

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
                 url:"./logout/",
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

           <a id="accessLoginLink"href="Login.jsp" class="accountAccessText">Login/Sign up</a>

        <% }

        }else{%>
          <a id="accessLoginLink" href="Login.jsp" class="accountAccessText">Login/Sign up</a>
        <% } %>
        </div>
         <div class="scrollable" id="mainContentDiv">
             
             <center><div id="signUpDiv">
                <center><p id="signUpHeader">PCKit Sign Up</p></center>
                <form id="signUpForm">
                   <span id="firstNameSpan">
                      <label class="signUpField" for="firstName" id="firstNameLabel">First Name:</label>
                      <input type="text" id="firstNameText" name="firstName">
                   </span>
                   <span id="lastNameSpan">
                      <label class="signUpField" for="lastName" id="lastNameLabel">Last Name:</label>
                      <input type="text" id="lastNameText" name="lastName">
                   </span>
                   <span id="emailSpan">
                      <label class="signUpField" for="Email" id="emailLabel">Email:</label>
                      <input type="text" id="emailText" name="Email">
                   </span>
                   <span id="passwordSpan">
                      <label class="signUpField" for="Password" id="passwordLabel">Password:</label>
                      <input type="password" id="passwordText" name="Password">
                   </span>
                   <span id="passwordMatchSpan">
                      <label class="signUpField" for="PasswordMatch" id="passwordMatchLabel">Confirm:</label>
                      <input type="password" id="passwordMatchText" name="PasswordMatch">
                   </span>
                   <span id="linkSpan">
                      <a id="loginAction" class="signUpLink" href="Login.jsp">Login</a>
                      <a id="signUpAction" class="signUpLink" href="javascript: void(0)">Sign up</a>
                   </span>
                </form>
             </div></center>

         </div> 

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
