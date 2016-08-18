<!DOCTYPE html>
<html>
   <head>
      <title>PCKit</title>
      <link rel="stylesheet" href="../stylesheets/main.css">
      <link rel="stylesheet" href="../stylesheets/login.css">
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
         
        $(function(){
           $("#loginForm").on("submit", function(e) {
              e.preventDefault();
              var errorList="";
     	      if($("#emailText").val().length == 0 || $("#emailText").val() == null) {
     	         errorList = errorList + "<li class='formErrorReason'>Email field is empty</li><br>";
     	      }
     	      else if($("#emailText").val().includes("@") == false) {
     	         errorList = errorList + "<li class='formErrorReason'>Email value isn't a valid email address.</li><br>";
     	      }
     	      
     	      if($("#passwordText").val().length == 0 || $("#passwordText").val() == null) {
     	         errorList = errorList + "<li class='formErrorReason'>Password field is empty</li><br>";
     	      }
     	      
     	      
     	      if (errorList.length == 0) {
     	         $.ajax({
     	            type : "POST",
     	            url: "/accounts/login-exists/",
     	            data: "email=" + encodeURIComponent($("#emailText").val()) + "&password=" + encodeURIComponent($("#passwordText").val()),
     	            success: function (data) {
     	               if (data == "Yes") {
                          console.log("got here");
     	                  nextData = "Email=" + encodeURIComponent($("#emailText").val()) + "&Password=" + encodeURIComponent($("#passwordText").val());
     	                  $.ajax({
     	                    type : "POST",
     	                    url: "./login/",
     	                    data: nextData
     	                  }).done(function(outData) { console.log(outData); 
                                                      /*document.write(outData);*/
                                                        window.location.href="https://www.pckit.org/"; });
     	               }
     	               else {
     	                  if (data == "No") {
     	                     errorList = errorList + "<li class='formErrorReason'>Username/password was incorrect.</li><br>";
     	                  }
     	                  else {
     	                     errorList = errorList + "<li class='formErrorReason'>" + data + "</li><br>";
     	                  }
     	                  fullErrorOutput = '<div id="formErrorsDiv"><ul id="errorsList" type="disc">';
     	                  fullErrorOutput = fullErrorOutput +errorList + '</ul></div>';
     	                  $(fullErrorOutput).insertBefore($("#loginForm"));
     	                  var shift= 20 +$("#formErrorsDiv").height();
     	         
     	                  $("#loginDiv").css("height", (233+shift).toString()+ "px");
     	                  $("#loginDiv").css("margin-top", (250-shift).toString()+ "px");
     	               }
     	            }
     	         });
     	       
     	      
     	      }
     	      else {
     	         fullErrorOutput = '<div id="formErrorsDiv"><ul id="errorsList" type="disc">';
     	         fullErrorOutput = fullErrorOutput + errorList + '</ul></div>';
     	         $(fullErrorOutput).insertBefore($("loginForm"));
     	         var shift= 20 +$("#formErrorsDiv").height();
     	         
     	         $("#loginDiv").css("height", (233+shift).toString()+ "px");
     	         $("#loginDiv").css("margin-top", (250-shift).toString()+ "px");
     	          
     	         
     	      }
     	      
     	      
           });
           
           $("#loginAction").bind("click",function(){
              $("#loginForm").submit();  // consider idOfYourForm `id` of your form which you are going to submit
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
                 url:"./logout/",
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

           <a id="accessLoginLink" href="Login.jsp" class="accountAccessText">Login/Sign up</a>

        <% }

        }else{ %>
           <a id="accessLoginLink" href="Login.jsp" class="accountAccessText">Login/Sign up</a>
        <% } %>
        </div>
         <div class="scrollable" id="mainContentDiv">             
             <center><div id="loginDiv">
                <center><p id="loginHeader">PCKit Login</p></center>
                <form id="loginForm">
                   <span id="emailSpan">
                      <label class="loginField" for="Email" id="emailLabel">Email:</label>
                      <input type="text" id="emailText" name="Email">
                   </span>
                   <span id="passwordSpan">
                      <label class="loginField" for="Password" id="passwordLabel">Password:</label>
                      <input type="password" id="passwordText" name="Password">
                   </span>
                   <span id="linkSpan">
                      <a id="loginAction" class="loginLink" href="javascript: void(0)">Login</a>
                      <a id="signUpAction" class="loginLink" href="Signup.jsp">Sign up</a>
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
