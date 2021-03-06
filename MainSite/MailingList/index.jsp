<%@ page language="java" pageEncoding="UTF-8" contentType="text/html;charset=utf-8"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>
<%@ page import="java.util.Date,accounts.AuthJWTUtil,accounts.UserLogin" %>
<%@ page import="java.security.SecureRandom,java.math.BigInteger" %>
<!--Code by Clay Jacobs-->
<!DOCTYPE html>
<html>
   <head>
      <title>PCKit Subscription</title>
      <link rel="stylesheet" href="../stylesheets/main.css">
      <link rel="stylesheet" href="../stylesheets/mailingList.css">
      <link rel="stylesheet" href="../stylesheets/accountNav.css">
      <link rel="stylesheet" href="../stylesheets/fonts.css">
      
     <%SecureRandom random = new SecureRandom();
      Cookie testCookie = new Cookie("csrf", "" + random.nextLong());
      testCookie.setHttpOnly(true);
      response.addCookie(testCookie);
     %>


      <script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.4/jquery.min.js" type="text/javascript"></script>
      <script type="text/javascript">
         function getCookie(name) {
           var re = new RegExp(name + "=([^;]+)");
           var value = re.exec(document.cookie);
           return (value != null) ? unescape(value[1]) : null;
        }
      
         var docCookies = {
           getItem: function (sKey) {
             if (!sKey) { return null; }
             return decodeURIComponent(document.cookie.replace(new RegExp("(?:(?:^|.*;)\\s*" + encodeURIComponent(sKey).replace(/[\-\.\+\*]/g, "\\$&") + "\\s*\\=\\s*([^;]*).*$)|^.*$"), "$1")) || null;
           },
           setItem: function (sKey, sValue, vEnd, sPath, sDomain, bSecure) {
             if (!sKey || /^(?:expires|max\-age|path|domain|secure)$/i.test(sKey)) { return false; }
                var sExpires = "";
             if (vEnd) {
                switch (vEnd.constructor) {
                   case Number:
                      sExpires = vEnd === Infinity ? "; expires=Fri, 31 Dec 9999 23:59:59 GMT" : "; max-age=" + vEnd;
                      break;
                   case String:
                      sExpires = "; expires=" + vEnd;
                      break;
                   case Date:
                      sExpires = "; expires=" + vEnd.toUTCString();
                      break;
               }
            }
            document.cookie = encodeURIComponent(sKey) + "=" + encodeURIComponent(sValue) + sExpires + (sDomain ? "; domain=" + sDomain : "") + (sPath ? "; path=" + sPath : "") + (bSecure ? "; secure" : "");
            return true;
          },
          removeItem: function (sKey, sPath, sDomain) {
             if (!this.hasItem(sKey)) { return false; }
                document.cookie = encodeURIComponent(sKey) + "=; expires=Thu, 01 Jan 1970 00:00:00 GMT" + (sDomain ? "; domain=" + sDomain : "") + (sPath ? "; path=" + sPath : "");
                return true;
          },
          hasItem: function (sKey) {
             if (!sKey) { return false; }
             return (new RegExp("(?:^|;\\s*)" + encodeURIComponent(sKey).replace(/[\-\.\+\*]/g, "\\$&") + "\\s*\\=")).test(document.cookie);
          },
          keys: function () {
             var aKeys = document.cookie.replace(/((?:^|\s*;)[^\=]+)(?=;|$)|^\s*|\s*(?:\=[^;]*)?(?:\1|$)/g, "").split(/\s*(?:\=[^;]*)?;\s*/);
             for (var nLen = aKeys.length, nIdx = 0; nIdx < nLen; nIdx++) { aKeys[nIdx] = decodeURIComponent(aKeys[nIdx]); }
             return aKeys;
          }
        };
        
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
      
         var w = Math.max(document.documentElement.clientWidth, window.innerWidth || 0)
         var h = Math.max(document.documentElement.clientHeight, window.innerHeight || 0)
         var csrf;
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
     	      csrfToken = docCookies.getItem("csrf");
     	      inData = $('#mailingForm').serialize();
     	      inData = inData + "&action=AddEmail";
     	      console.log(inData);
     	      $.ajax({
                 type: 'POST',
                 url: '/MailingList/response/',
                 data: inData
              }).done(function(data) {document.write(data);});
     	   }
     	   else {
              docCookies.removeItem("csrf");
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
     	      return false; 
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
              String loggedUser="";
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
          <a id="accessLoginLink" href="../accounts/Login.jsp" class="accountAccessText">Login/Sign up</a>
        <% } %>  
        </div>
         <div class="scrollable" id="mainContentDiv">
           <center><img src="../images/PCkit-logo-trans.png" id="logoImageHeader" alt=""></center>
           <p id="form-description">PCkit will be fully up and running by Fall 2016. In the 
              meantime, prospective customers, affiliates, and interested parties should sign up for
              our mailing list.</p><br>
              
           <form id="mailingForm">
              <p id="formKey"><font id="requiredStar">*</font><font id="requiredDescription"> - Field is required.</font></p>
              <p>
                 <label class="mailField" for="firstName" id="firstNameLabel"><font id="requiredStar">*</font>First name: </label>
                 <input type="text" id="firstNameText" name="firstName">
                 <label class="mailField" for="lastName" id="lastNameLabel"><font id="requiredStar">*</font>Last name: </label>
                 <input type="text" id="lastNameText" name="lastName">
              </p>
              <p id="emailSection"><label class="mailField" for="Email" id="emailLabel"><font id="requiredStar">*</font>Email: </label><input type="text" id="emailText" name="Email"></p>
              <p id="companySection"><label class="mailField" for="Company" id="companyLabel">Company: </label><input type="text" id="companyText" name="Company"></p>
              <span id="iSelectSpan">
              <p id="interestSection">
                 <label class="mailField" for="Interest" id="interestLabel"><font id="requiredStar">*</font>What is your interest in PCKit?</label>
                 <select id="interestSelect" name="Interest" onfocus="this.oldvalue = this.value;" onChange="interestChanged(this); this.oldvalue = this.value;">
                    <option value="none"></option>
                    <option value="consumer">Consumer</option>
                    <option value="business">Business</option>
                    <option value="supplier">Supplier</option>
                    <option value="applicant">Applicant</option>
                    <option value="media">Media</option>
                    <option value="other">Other</option>
                 </select>
              </span>
              <span id="aSelectSpan">
              <p id="adMediumSection">
                 <label class="mailField" for="AdMedium" id="adMediumLabel"><font id="requiredStar">*</font>How did you hear about PCKit?</label>
                 <select id="adMediumSelect" name="AdMedium" onfocus="this.oldvalue = this.value;" onChange="adMediumChanged(this); this.oldvalue = this.value;">
                    <option value="none"></option>
                    <option value="word">Word of mouth</option>
                    <option value="search">Web Search</option>
                    <option value="link">Link shared/Redirect</option>
                    <option value="other">Other</option>
                 </select>
              </p>
              </span>
              <div id="miscInputSection">
                 <p>
                    <label class="mailField" for="Notes" id="notesLabel">Anything else you'd like us to know?</label><br>
                    <textarea rows="8" cols="50" maxlength="500" wrap="hard" id="notesText" name="Notes" onkeyup="updateCharCount(this)"></textarea><br>
                    <center><font id="charCounter">0/500<font></center>
                 </p> 
              <p><input type="submit" id="submitFormButton" value="Add to Mailing List"></p>
              </div>
           </form>
           
          
           
          <!-- <% } %>-->
         </div> 
         <div id="siteNavDiv">
            <center>
            <ul id="siteNavLinks">
            	<li class="siteNavItem"><a class="siteNavLink" href="..">Home</a></li>
                <li class="siteNavItem"><a class="siteNavLink" href="../forums/list.page">Forums</a></li>
                <li class="siteNavItem"><a class="siteNavLink" href="../OrderSection/orderProcess.jsp">Store</a></li>
            	<li class="siteNavItem"><a class="siteNavLink" href="../about.jsp">About PCkit</a></li>
            	<li class="siteNavItem"><a class="siteNavLink" href="#">Stay Notified</a></li>
            </ul>
            </center>
         </div>
         
      </div>
      
   </body>
</html>
