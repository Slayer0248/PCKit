<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>
<%@ taglib uri="http://mvnrepository.com/artifact/javax.servlet/jstl/core" prefix="c"%>
<%@ taglib uri="http://mvnrepository.com/artifact/javax.servlet/jstl/sql" prefix="sql"%>
<!DOCTYPE html>
<html>
   <head>
      <title>PCKit</title>
      <link rel="stylesheet" href="../stylesheets/main.css">
      <link rel="stylesheet" href="../stylesheets/selectGames.css">
      <link rel="stylesheet" href="../stylesheets/fonts.css">
      
      <script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.4/jquery.min.js" type="text/javascript"></script>
      <script type="text/javascript">
         var count = parseInt('<c:out value="${count.rowsByIndex[0][0]}">');
         
      
         var w = Math.max(document.documentElement.clientWidth, window.innerWidth || 0)
         var h = Math.max(document.documentElement.clientHeight, window.innerHeight || 0)
         console.log("%d x %d", w, h);
         $(document).ready(function() {
            var fSize = parseFloat($('#placeholderText').css('font-size'))
            console.log("%f px or %f em", fSize, fSize/16);
        
        });
         
      </script>
   </head>
   <body>
      <sql:setDataSource var="snapshot" driver="com.mysql.jdbc.Driver"
     url="jdbc:mysql://localhost/PCKitDB" user="root"  password="Potter11a"/>
      <sql:query dataSource="${snapshot}" var="count">SELECT COUNT(*) AS count from Games;</sql:query>
      <sql:query dataSource="${snapshot}" var="result">SELECT * from Games;</sql:query>
      
   
      <div class="fill-screen">
         <img class="make-it-fit" src="../images/background.png" id="bgImage" alt="">
         <div class="scrollable" id="mainContentDiv">
            <!--<center><img src="../images/PCkit-logo-trans.png" id="logoImage" alt=""></center>
           <p id="descriptionText">Build a custom PC to play the games you want to play at the quality you want to play.</p>
           <button id="BuildPCBuuton" onclick="location.href='selectGames.jsp';">Build your PC</button>-->
           <div id="gameSelect">
              <% if (count.rowByIndex[0][0] > 0) { %>
                <p id="selectGamesP" class="actionText">Select the games you want to play.</p>
                <table id="gamesTable" border="1" width="100%">
                   <% i =0;
                    rowNum=1; %>
                   <c:forEach var="row" items="${result.rows}">
                      <% if (i%8==0) { %>
                         <tr id="gameRow${rowNum}" class="gamesTableRow">
                      <% } %>
                         <td id="game${i}" class="gameCell"><img src="images/game${row.gameId}.png" width="120" height="200"></td>
                      <% if (i%8==7) { 
                         rowNum++; %>
                         </tr>
                      <% } 
                      i++;
                      %>
                   </c:forEach>
              <% } else { %>
               <p id="selectGamesP" class="actionText">No games to select from.</p>
              <% } %>
           </div>  
           <p id="selectQualityP" class="actionText">Choose your preferred graphics quality.</p>
           <div id="qualitySelect">
             <button class="qualityOption">Low</button>
             <button class="qualityOption">Medium</button>
             <button class="qualityOption">High</button>
             <button class="qualityOption">Ultra</button>
           </div>
         </div> 
         <img src="../images/BackArrow.png" id="backButton" class="orderNavButton" onclick="location.href='orderProcess.html';"/>
         <img src="../images/NextArrow.png" id="nextButton" class="orderNavButton" onclick="location.href='selectBuild.jsp';"/>
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