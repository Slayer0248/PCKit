<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>
<%@ page import="java.util.Date,accounts.AuthJWTUtil,accounts.UserLogin" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<!DOCTYPE html>
<html>
   <head>
      <title>PCKit</title>
      <link rel="stylesheet" href="../stylesheets/main.css">
      <link rel="stylesheet" href="../stylesheets/selectGames.css">
      <link rel="stylesheet" href="../stylesheets/accountNav.css">
      <link rel="stylesheet" href="../stylesheets/existingCartMessage.css">
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
            setPositions();
            $("#overlay").hide();
            hasCart(promptForCart);
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
                     }).done(function(data2) { /*window.location.href = "http://www.pckit.org/OrderSection/selectBuild.jsp";*/
document.write(data2); history.pushState({}, null, "https://www.pckit.org/OrderSection/selectBuild.jsp"); });
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
                     }).done(function(data) { window.location.href = "http://www.pckit.org/OrderSection/checkout.jsp"; });
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
                     $("#overlay").hide();
                 }
              });
           }
           
           function hasCart(callback) {
              var result = "";
               $.ajax({
                 type:"POST",
                 url:"./hasCart/",
                 headers: { "csrf":getCookie('csrf')},
                 success:callback
               });
           }
           
           function promptForCart(isCart) {
             //console.log(hasCart());          
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
                                }
                                else if (data3 =="Reload") {
                                   location.reload();
                                } 
                            });
                         }
                         else if (data2 == "No") {
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
              
              }
           }

        function selectQuality(element) {
           var lastSelected = $(".qualitySelected");
           var isUnselect = false;
           if (lastSelected.length == 1) {
              if ($(lastSelected[0]).is(element)) {
                 isUnselect = true;
              }
              $(lastSelected[0]).hide().removeClass("qualitySelected").addClass("qualityUnselected").show();
           }
           if (isUnselect == false) {
              $(element).hide().removeClass("qualityUnselected").addClass("qualitySelected").show();
           }
        }

        function selectGame(element) {
           var clickedImage = element;
           if ($(clickedImage).hasClass("gameSelected")) {
              $(clickedImage).removeClass("gameSelected");
           }
           else {
              $(clickedImage).addClass("gameSelected");
           }

        }

        function goToNextPage() {
           var errors="";
           var gamesSelected = "";
           var cumMinTier = -1;
           if ($("#gamesTable").length == 1) {
              if ($(".gameSelected").length > 0) {
                 for (i=0; i<$(".gameSelected").length; i++) {
                    var obj = $(".gameSelected").get(i);
                    var gameId = $(obj).parent().attr('id');
                    var hardwareTier = parseInt($(obj).parent("td").attr('value'), 10);
                    //console.log($(obj).parent("td").attr('value'));
                    gameId = parseInt(gameId.replace(/[^0-9\.]/g, ''), 10);
                    //console.log("gameIdi:%d, tier:%d", gameId, hardwareTier);
                    if (gamesSelected.length == 0) {
                       gamesSelected = gamesSelected + gameId;
                    }
                    else {
                       gamesSelected = gamesSelected + "," + gameId;
                    }

                    if (cumMinTier < 0 || (cumMinTier >=0 && hardwareTier > cumMinTier)) {
                       cumMinTier = hardwareTier;
                    }
                 }
              }
              else {
                 errors= errors+"<li class='formErrorReason'>At least one game must be selected.</li>";  
              }
           }
           else {
             gamesSelected = "None";
           }
           
           var qualitySelected=null;
           if ($(".qualitySelected").length == 1) {
              var quality=$(".qualitySelected").html();

              if (quality == "Low") {
                 qualitySelected=-1;
              } 
              else if (quality == "Medium") {
                 qualitySelected=0;
              }
              else if (quality == "High") {
                 qualitySelected=1;
              }
              else if (quality == "Ultra") {
                 qualitySelected=2;
              }
           }
           else {
              errors= errors+"<li class='formErrorReason'>Gameplay quality wasn't selected.</li>";
           }


           //console.log(qualitySelected);
           //console.log(cumMinTier);


           if (errors.length == 0) {
              //max tier = ??? , (5 for testing)
              var adjustedTier = Math.max(1, Math.min(5, cumMinTier+qualitySelected));
              //TODO: create csrf cookie in here to be sure next page is accessed only by this page
              $.ajax({
                 type:"POST",
                 url:"./hasCart/",
                 headers: { "csrf":getCookie('csrf')},
               }).done(function(data) {
               
               if (data =="No") {
              $.ajax({
                 type:"POST",
                 url:"./createCart/",
                 headers: { "csrf":getCookie('csrf')},
                 data:"minTier=" +adjustedTier 
               }).done(function(data2) {
                  if (data2=="Success") {
                     console.log("in here");
                     $.ajax({
                 type:"POST",
                 url:"./selectBuild.jsp",
                 data:JSON.stringify({"minTier": adjustedTier}),
                  error: function (xhr, status, message) {
                     console.log(xhr.responseText );
                     console.log('A jQuery error has occurred. Status: ' + status + ' - Message: ' + message);
                  }
               }).done(function(data3) { /*window.location.href = "http://www.pckit.org/OrderSection/selectBuild.jsp";*/
document.write(data3); history.pushState({}, null, "https://www.pckit.org/OrderSection/selectBuild.jsp"); });
                  }  else {
                    //form errors'
                    
                 
                 }
                
             });
             } else if (data =="Yes") { 
                //enclose in post request 
                $.ajax({
                 type:"POST",
                 url:"./updateCartTier/",
                 headers: { "csrf":getCookie('csrf')},
                 data:"tier=" +adjustedTier 
               }).done(function(data2) {
                  if (data2=="Success") {
                 $.ajax({
                 type:"POST",
                 url:"./selectBuild.jsp",
                 headers: { "csrf":getCookie('csrf')},
                 data:JSON.stringify({"minTier": adjustedTier}),
                  error: function (xhr, status, message) {
                     console.log(xhr.responseText );
                     console.log('A jQuery error has occurred. Status: ' + status + ' - Message: ' + message);
                  }
               }).done(function(data3) { /*window.location.href = "http://www.pckit.org/OrderSection/selectBuild.jsp";*/
document.write(data3); history.pushState({}, null, "https://www.pckit.org/OrderSection/selectBuild.jsp"); });
                  //enclose in post request 
                }
                });
              }
             
             });
            // $.post("./selectBuild.jsp",{"minTier": adjustedTier}).done(function(data) {
     //console.log(data);
     /*window.location.href="https://www.pckit.org/OrderSection/selectBuild.jsp";*/
     // document.write(data);
    /*history.pushState({}, null, "https://www.pckit.org/OrderSection/selectBuild.jsp");*/ 
    //});
             // $("html").load("selectBuild.jsp", {"minTier" : "" + adjustedTier});
                  
           }
           else {
              if ($("#formErrorsDiv").length > 0) {
     	         $("#errorsList").children().remove();
     	          $("#errorsList").html(errors);
     	      }
              else {
     	         fullErrorOutput = '<div id="formErrorsDiv"><p id="formErrorsInfo">Can\'t proceed due to the following errors:</p><ul id="errorsList" type="disc">';
     	         fullErrorOutput = fullErrorOutput + errors + '</ul></div>';
     	         $(fullErrorOutput).insertBefore($("#gameSelect"));
     	      }
              var curHeight = 50;
              console.log("%d", $("#formErrorsDiv").height());

              $("#gameSelect").css("top", curHeight.toString() + "px");
              $("#selectGamesP").css("top", curHeight.toString() + "px");
              curHeight = curHeight + $("#gameSelect").height() + 10;
              $("#selectQualityP").css("top", curHeight + "px");
              curHeight = curHeight + $("#selectQualityP").height() + 30;
              $("#qualitySelect").css("top", curHeight + "px");
              $("#qualitySelect").css("margin-top", curHeight + "px");
           }
        }
         
      </script>
   </head>
   <body>
      <sql:setDataSource var="snapshot" driver="com.mysql.jdbc.Driver"
     url="jdbc:mysql://localhost/PCKitDB" user="root"  password="Potter11a"/>
      <sql:query dataSource="${snapshot}" var="count">SELECT COUNT(*) AS count from Games;</sql:query>
      <c:set var="count" value="${count.rowsByIndex[0][0]}"/>
      <sql:query dataSource="${snapshot}" var="result">SELECT * from Games;</sql:query>
      
   
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
           <a id="accessLoginLink"href="../accounts/Login.jsp" class="accountAccessText">Login/Sign up</a>
        <%}%>
        </div>
         <div class="scrollable" id="mainContentDiv">

            <%if (loggedUser.length() == 0) { %>
            <center><img src="../images/PCkit-logo-trans.png" id="logoImageHeader" alt="">
            <p id="form-description">You must be logged in to view this page.</p>
            </center>

           <% } else { %>
           <!--<p id="descriptionText">Build a custom PC to play the games you want to play at the quality you want to play.</p>
           <button id="BuildPCBuuton" onclick="location.href='selectGames.jsp';">Build your PC</button>-->
           <div id="gameSelect">
              <c:choose>
              <c:when test="${count > 0}">
                <p id="selectGamesP" class="actionText">Select the games you want to play.</p>
                <table id="gamesTable">
                   <% int i =0;
                    int rowNum=1; %>
                   <c:forEach var="row" items="${result.rows}">
                      <% 
                      if (i%8==0) { %>
                        <center><tr id="gameRow<%=rowNum %>" class="gamesTableRow"><center>
                       <% } %>
                         <td id="game<%=i %>" class="gameCell" value="${row.minHardwareTier}"><img onclick="selectGame(this)" src="images/game${row.gameId}.png" width="120" height="200"></td>
                      <% if (i%8==7) { 
                         rowNum++; %>
                         </center></tr></center>
                      <% } 
                      i++;
                      %>
                   </c:forEach>
                 <% if (i%8!=0) { %>
                     </tr>
                 <% } %>
                  </table>
                   <script type="text/javascript"> 
                      function setPositions() { 
                         var curHeight = $("#selectGamesP").offset().top + $("#selectGamesP").height() + 10;
                         $("#gamesTable").css("top", curHeight + "px");
                         var numGames = $(".gameCell").length;
                         var numRows = Math.floor(numGames/8) + ((numGames%8>0)?1:0);
                         var maxRowLength = 0;
                         if (numRows >1) {
                            maxRowLength = 8 * 140;
                         }
                         else {
                            maxRowLength = numGames * 140;
                         }
                         $("#gamesTable").height(numRows * 210).width(maxRowLength).css("margin-top", curHeight+"px");
                         $(".gamesTableRow").height(numRows * 210).width(maxRowLength);
                         $("#gameSelect").css("margin-bottom", 0);
                         $("#selectQualityP").css("margin-top", 20);
                         $("#selectQualityP").css("margin-bottom", 0);
                         $("#selectQualityP").css("padding-bottom", 0);
                         curHeight = curHeight + $("#gamesTable").height();
                         $("#selectQualityP").css("top", curHeight + "px");
                         curHeight = curHeight + $("#selectQualityP").height() + 30;
                         $("#qualitySelect").css("top", curHeight + "px");
                         $("#qualitySelect").css("margin-top", curHeight + "px");
                      }
                   </script>
              </c:when><c:otherwise>
                  <p id="selectGamesP" class="actionText">No games to select from.</p>
              </c:otherwise>
              </c:choose>
           </div>
           <p id="selectQualityP" class="actionText">Choose your preferred graphics quality.</p>
           <div id="qualitySelect"><center>
             <button class="qualityOption qualityUnselected" onclick="selectQuality(this)">Low</button>
             <button class="qualityOption qualityUnselected" onclick="selectQuality(this)">Medium</button>
             <button class="qualityOption qualityUnselected" onclick="selectQuality(this)">High</button>
             <button class="qualityOption qualityUnselected" onclick="selectQuality(this)">Ultra</button></center>
           </div>
           <% } %> 
         </div> 
         <% if (loggedUser.length() > 0) { %>
            <img src="../images/BackArrow.png" id="backButton" class="orderNavButton" onclick="location.href='orderProcess.jsp';"/>
            <img src="../images/NextArrow.png" id="nextButton" class="orderNavButton" onclick="goToNextPage()"/>
         <% } %>
         <div id="siteNavDiv">
            <center><ul id="siteNavLinks">
            	<li class="siteNavItem"><a class="siteNavLink" href="..">Home</a></li>
                <li class="siteNavItem"><a class="siteNavLink" href="../forums/list.page">Forums</a></li>
            	<li class="siteNavItem"><a class="siteNavLink" href="../about.jsp">About PCkit</a></li>
            	<li class="siteNavItem"><a class="siteNavLink" href="../MailingList/">Stay Notified</a></li>
            </ul></center>
         </div>
         
      </div>
      
      
      
      <!--hidden button style = "color: transparent; background-color: transparent; border-color: transparent; cursor: default;"
      <input id="next" type="submit" style="color: red; background-color: red; border-color: transparent; cursor: default;">
      <input id="prev" type="submit" style="color: green; background-color: green; border-color: transparent; cursor: default;">-->
   </body>
</html>
