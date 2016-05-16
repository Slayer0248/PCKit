<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>
<!DOCTYPE html>
<html>
   <head>
      <title>PCKit Subscription</title>
      <link rel="stylesheet" href="stylesheets/main.css">
      
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
     	      $.ajax({
                 type: 'POST',
                 url: 'mailingList.jsp',
                 data: $('#mailingForm').serialize()
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
         <img class="make-it-fit" src="images/background.png" id="bgImage" alt="">
         <div class="scrollable" id="mainContentDiv">
           <center><img src="images/PCkit-logo-trans.png" id="logoImageHeader" alt=""></center>
           <% if ("POST".equalsIgnoreCase(request.getMethod())) { 
                  String firstName = request.getParameter("firstName");
                  String lastName = request.getParameter("lastName");
                  String email = request.getParameter("Email");
                  String company = request.getParameter("Email");
                  String interest = request.getParameter("Interest").equals("other")? request.getParameter("InterestOther") : request.getParameter("Interest");
                  String adMedium = request.getParameter("AdMedium").equals("other")? request.getParameter("AdMediumOther") : request.getParameter("AdMedium");
                  String notes = request.getParameter("Notes");
                  
                  //out.println("<p id='form-description'>" + firstName+ ", " +lastName+ ", " +email+", " +company+", " +interest+", " +adMedium+", " +notes+"</p>");
                  
                  Connection connection = null;
                  PreparedStatement pstatement = null;
                  Class.forName("com.mysql.jdbc.Driver");
                  int updateQuery = 0;
                  try {
                     connection = DriverManager.getConnection("jdbc:mysql://localhost/PCKitDB","root","Potter11a");
                     String queryString = "INSERT INTO mailList(first,last,email,company,relationship,publicity,otherInfo) VALUES (?, ?, ?, ?, ?, ?, ?)";
                     pstatement = connection.prepareStatement(queryString);
                     pstatement.setString(1, firstName);
                     pstatement.setString(2, lastName);
                     pstatement.setString(3, email);
                     pstatement.setString(4, company);
                     pstatement.setString(5, interest);
                     pstatement.setString(6, adMedium);
                     pstatement.setString(7, notes);
                     updateQuery = pstatement.executeUpdate();
                  
                     if (updateQuery != 0) { 
            %>
            <p id="form-description">Success!</p>
            
            
            <%       }
                  }
                  catch (SQLException e) { %>
            <p id="form-description">Failure!</p>    
                   
            <%    }
                  finally {
                     pstatement.close();
                     connection.close();
                  }
              } else { %>
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
                 </select><!--<br>
                 <label class="mailField" for="InterestOther" id="interestOtherLabel">Please specify: </label><input type="text" id="interestOtherText" name="InterestOther">-->
              </p>
              </span>
              <span id="aSelectSpan">
              <p id="adMediumSection">
                 <label class="mailField" for="AdMedium" id="adMediumLabel"><font id="requiredStar">*</font>How did you hear about PCKit?</label>
                 <select id="adMediumSelect" name="AdMedium" onfocus="this.oldvalue = this.value;" onChange="adMediumChanged(this); this.oldvalue = this.value;">
                    <option value="none"></option>
                    <option value="talking">Word of mouth</option>
                    <option value="search">Web Search</option>
                    <option value="link">Link shared/Redirect</option>
                    <option value="other">Other</option>
                 </select><!--<br>
                 <label class="mailField" for="AdMediumOther" id="adMediumOtherLabel">Please specify: </label><input type="text" id="adMediumOtherText" name="AdMediumOther">-->
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
           
          
           
           <% } %>
         </div> 
         <div id="siteNavDiv">
            <center>
            <ul id="siteNavLinks">
            	<li class="siteNavItem"><a class="siteNavLink" href="#">Home</a></li>
            	<li class="siteNavItem"><a class="siteNavLink" href="index.html">About PCkit</a></li>
            	<li class="siteNavItem"><a class="siteNavLink" href="#">Stay Notified</a></li>
            </ul>
            </center>
         </div>
         
      </div>
      
      
      <!--hidden button style = "color: transparent; background-color: transparent; border-color: transparent; cursor: default;"
      <input id="next" type="submit" style="color: red; background-color: red; border-color: transparent; cursor: default;">
      <input id="prev" type="submit" style="color: green; background-color: green; border-color: transparent; cursor: default;">-->
   </body>
</html>