<!DOCTYPE html>
<html>
   <head>
      <title>PCKit</title>
      <link rel="stylesheet" href="../stylesheets/main.css">
      <link rel="stylesheet" href="../stylesheets/signup.css">
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
     	            url: "./account-exists/",
     	            data: "email=" + encodeURIComponent($("#emailText").val()),
     	            success: function (data) {
     	               console.log(data);
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