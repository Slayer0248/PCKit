<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<!DOCTYPE html>
<html>
   <head>
      <title>PCKit</title>
      <link rel="stylesheet" href="../stylesheets/main.css">
      <link rel="stylesheet" href="../stylesheets/selectGames.css">
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
        });

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
                    $(".gameSelected").each(function (i, obj){
                    var gameId = $(obj).parent().attr('id');
                    var hardwareTier = parseInt($(obj).parent().val(), 10);
                    gameId = parseInt(gameId.replace(/[^0-9\.]/g, ''), 10);
                    if (gamesSelected.length == 0) {
                       gamesSelected = gamesSelected + gameId;
                    }
                    else {
                       gamesSelected = gamesSelected + "," + gameId;
                    }

                    if (cumMinTier < 0 || (cumMinTier >=0 && hardwareTier > cumMinTier)) {
                       cumMinTier = hardwareTier;
                    }
                    
                    });
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


           if (errors.length == 0) {
              //max tier = ??? , (5 for testing)
              var adjustedTier = Math.max(1, Math.min(5, cumMinTier+qualitySelected))
              //TODO: create csrf cookie in here to be sure next page is accessed only by this page

              $.ajax({
                 url: './selectBuild.jsp',
                 data: JSON.stringify({"minTier": adjustedTier}),
                 type: 'POST'
              }).done(function(data) { window.location.href="http://www.pckit.org/OrderSection/selectBuild.jsp"; /*document.write(data); history.pushState({}, null, "http://www.pckit.org/OrderSection/selectBuild.jsp");*/ });  

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
         <img class="make-it-fit" src="../images/background.png" id="bgImage" alt="">
         <div class="scrollable" id="mainContentDiv">
            <!--<center><img src="../images/PCkit-logo-trans.png" id="logoImage" alt=""></center>
           <p id="descriptionText">Build a custom PC to play the games you want to play at the quality you want to play.</p>
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
         </div> 
         <img src="../images/BackArrow.png" id="backButton" class="orderNavButton" onclick="location.href='orderProcess.html';"/>
         <img src="../images/NextArrow.png" id="nextButton" class="orderNavButton" onclick="goToNextPage()"/>
         
         <div id="siteNavDiv">
            <center><ul id="siteNavLinks">
            	<li class="siteNavItem"><a class="siteNavLink" href="..">Home</a></li>
            	<li class="siteNavItem"><a class="siteNavLink" href="../about.html">About PCkit</a></li>
            	<li class="siteNavItem"><a class="siteNavLink" href="../MailingList/">Stay Notified</a></li>
            </ul></center>
         </div>
         
      </div>
      
      
      
      <!--hidden button style = "color: transparent; background-color: transparent; border-color: transparent; cursor: default;"
      <input id="next" type="submit" style="color: red; background-color: red; border-color: transparent; cursor: default;">
      <input id="prev" type="submit" style="color: green; background-color: green; border-color: transparent; cursor: default;">-->
   </body>
</html>
