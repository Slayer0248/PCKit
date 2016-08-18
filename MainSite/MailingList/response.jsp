<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>
<!DOCTYPE html>
<html>
   <head>
      <title>PCKit Subscription</title>
      <link rel="stylesheet" href="../stylesheets/main.css">
      <link rel="stylesheet" href="../stylesheets/mailingList.css">
      <link rel="stylesheet" href="../stylesheets/accountNav.css">
      <link rel="stylesheet" href="../stylesheets/fonts.css">
      <script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.4/jquery.min.js" type="text/javascript"></script>
      <script type="text/javascript">
         var w = Math.max(document.documentElement.clientWidth, window.innerWidth || 0)
         var h = Math.max(document.documentElement.clientHeight, window.innerHeight || 0)
         console.log("%d x %d", w, h);
         $(document).ready(function() {
            //var fSize = parseFloat($('#placeholderText').css('font-size'))
            //console.log("%f px or %f em", fSize, fSize/16);
            var textLen = $('#submitFormButton').width();
            //var textLen2 = $('#adMediumSection').width();
            //console.log("%d px, %d px", textLen, textLen2);
            //var endPos1 = $('#selectSpan').position().top + $('#selectSpan').height();
            //var endPos2 = $('#lastNameText').position().left + $('#lastNameText').width();
            //var pos1 = $('#interestSelect').position().left;
            //var pos2 = $('#adMediumSelect').position().left;
            console.log("%d px", textLen);
        });
        
        function interestChanged(select) {
           if (select.value == "other" && select.oldvalue != "other") {
              //add other field for interest
              $("#aSelectSpan").css("margin-top", "30px");
              $('<br><label class="mailField" for="InterestOther" id="interestOtherLabel">Please specify: \
              </label><input type="text" id="interestOtherText" name="InterestOther">').insertAfter($("#interestSelect"));
           }
           else if (select.value != "other" && select.oldvalue == "other") {
              //remove other field for interest
              var i;
              for (i=0; i<3; i++) {
                 $("#interestSection").children().last().remove();
              }
              //$("#interestSection").find("br").remove();
              $("#aSelectSpan").css("margin-top", "10px");
           } 
        }
        
        function adMediumChanged(select) {
           if (select.value == "other" && select.oldvalue != "other") {
              //add other field for adMedium
              $("#miscInputSection").css("top", "205px");
              $('<br><label class="mailField" for="AdMediumOther" id="adMediumOtherLabel">Please specify: \
              </label><input type="text" id="adMediumOtherText" name="AdMediumOther">').insertAfter($("#adMediumSelect"));
           }
           else if (select.value != "other" && select.oldvalue == "other") {
              var i;
              for (i=0; i<3; i++) {
                 $("#adMediumSection").children().last().remove();
              }
              //$("#adMediumSection").find("br").remove();
              $("#miscInputSection").css("top", "185px");
              //remove other field for adMedium
           } 
        }
         
        function updateCharCount(val) {
           var len = val.value.length;
     	   var txt = len.toString() + "/500";
     	   $("#charCounter").html(txt);
     	}
     	
     	$(function () {
     	$("#mailingForm").on("submit", function (e) {
     	   e.preventDefault();
     	   var errorList = "";
     	   console.log("%s", $("#firstNameText").val());
     	   if($("#firstNameText").val().length == 0 || $("#firstNameText").val() == null) {
     	      errorList = errorList + "<li class='formErrorReason'>First name field is empty</li>";
     	   }
     	   if($("#lastNameText").val().length == 0 || $("#lastNameText").val() == null) {
     	      errorList = errorList + "<li class='formErrorReason'>Last name field is empty</li>";
     	   }
     	   if($("#emailText").val().length == 0 || $("#emailText").val() == null) {
     	      errorList = errorList + "<li class='formErrorReason'>Email field is empty</li>";
     	   }
     	   else if($("#emailText").val().includes("@") == false) {
     	      errorList = errorList + "<li class='formErrorReason'>Email value isn't a valid email address.</li>";
     	   }
     	   
     	   
     	   var interestVal = $("#interestSelect option:selected").val();
     	   console.log("%s", interestVal);
     	   if (interestVal == "none" || (interestVal == "other" && 
     	       ($("#interestOtherText").val().length == 0 || $("#interestOtherText").val() == null))) {
     	      errorList = errorList + "<li class='formErrorReason'>No value was given for interest in PCkit.</li>";
     	   }
     	   
     	   var adMediumVal = $("#adMediumSelect option:selected").val();
     	   if (adMediumVal == "none" || (adMediumVal == "other" && 
     	       ($("#adMediumOtherText").val().length == 0 || $("#adMediumOtherText").val() == null))) {
     	      errorList = errorList + "<li class='formErrorReason'>No value was given for how you learned about us.</li>";
     	   }
     	   
     	   if (errorList.length == 0) {
     	      //$("#form-description").remove();
     	      //$("#mailingForm").remove();
     	      //$("#form-description").html($('#mailingForm').serialize());
     	      inData = $('#mailingForm').serializeObject();
     	      inData["action"] = "AddEmail";
     	      $.ajax({
                 type: 'POST',
                 url: 'response',
                 data: inData
              }).done(function(data) {document.write(data);});
     	   }
     	   else {
     	      if ($("#formErrorsDiv").length) {
     	         $("#errorsList").children().remove();
     	          $("#errorsList").html(errorList);
     	      }
     	      else {
     	         fullErrorOutput = '<div id="formErrorsDiv"><p id="formErrorsInfo">Form wasn\'t submitted due to the following errors:</p><ul id="errorsList" type="disc">';
     	         fullErrorOutput = fullErrorOutput + errorList + '</ul></div>';
     	         $(fullErrorOutput).insertBefore($("#mailingForm"));
     	      }
     	      
     	      var formTop = 280 + $("#formErrorsDiv").height();
     	      $("#mailingForm").css("top", formTop.toString() +"px");
     	      
     	   }
     	   
		   //return false;
     	});
     	});
      </script>
   </head>
   <body>
      <div class="fill-screen">
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

        }else{ %>
          <a id="accessLoginLink" href="../accounts/Login.jsp" class="accountAccessText">Login/Sign up</a>
        <% } %>
        </div>

         <div class="scrollable" id="mainContentDiv">
           <center><img src="../images/PCkit-logo-trans.png" id="logoImageHeader" alt=""></center>
          
           <p id="form-description"><% String msg = (String)request.getAttribute("Message");
            if(msg == null || msg.equals("")) {%>
              This page can't be accessed in this manner.
           <% } else {%>
              <%=msg%>
           <% } %></p><br>
              
           
         </div> 
         <div id="siteNavDiv">
            <center>
            <ul id="siteNavLinks">
            	<li class="siteNavItem"><a class="siteNavLink" href="..">Home</a></li>
                <li class="siteNavItem"><a class="siteNavLink" href="..\forums\list.page">Forums</a></li>
            	<li class="siteNavItem"><a class="siteNavLink" href="..\about.jsp">About PCkit</a></li>
            	<li class="siteNavItem"><a class="siteNavLink" href=".">Stay Notified</a></li>
            </ul>
            </center>
         </div>
         
      </div>
      
      
      <!--hidden button style = "color: transparent; background-color: transparent; border-color: transparent; cursor: default;"
      <input id="next" type="submit" style="color: red; background-color: red; border-color: transparent; cursor: default;">
      <input id="prev" type="submit" style="color: green; background-color: green; border-color: transparent; cursor: default;">-->
   </body>
</html>
