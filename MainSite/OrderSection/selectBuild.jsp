<!DOCTYPE html>
<html>
   <head>
      <title>PCKit</title>
      <link rel="stylesheet" href="../stylesheets/main.css">
      <link rel="stylesheet" href="../stylesheets/selectBuild.css">
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
         
      </script>
   </head>
   <body>
      <div class="fill-screen">

         <%
         //TODO: check for csrf cookie and csrf token in POST so we can display the page

         %>

         <img class="make-it-fit" src="../images/background.png" id="bgImage" alt="">
         <div class="scrollable" id="mainContentDiv">
            <!--<center><img src="../images/PCkit-logo-trans.png" id="logoImage" alt=""></center>
           <p id="descriptionText">Build a custom PC to play the games you want to play at the quality you want to play.</p>
           <button id="BuildPCBuuton" onclick="location.href='selectGames.jsp';">Build your PC</button>-->
           <p id="selectPCP" class="actionText">Select a PCKit</p>
           <p id="noticeP" class="subtitleText">Every kit ships with tools and our custom builder's guide!</p>

           <table id="buildsTable" align="center">
              <tr class="buildsTableRow">
                  <td class="buildCell">
                     <p class="buildDescriptionShort">playable</p>
                     <img class="buildIcon" src="images/BuildIcon.png" width="200px" height="140px">
                     <p class="buildPrice">$500</p>
                     <p class="buildDescriptionMed">for casual gamers</p>
                     <hr class="buildDivider">
                     <button class="buyKitButton">BUY THIS KIT</button>
                     <!--<ul></ul>-->
                     <p class="buildSpecs">AMD FX-6300 3.5GHz 6-Core Processor<br><br>
                     G.Skill Ripjaws Series 8GB (2 x 4GB) DDR3-1600 Memory<br><br>
                     Seagate Barracuda 1TB 3.5" 7200RPM Internal Hard Drive<br><br>
                     EVGA GeForce GTX 950 2GB Superclocked Video Card</p>
                  </td>
              </tr>
           </table>

         </div> 
         <img src="../images/BackArrow.png" id="backButton" class="orderNavButton" onclick="location.href='selectGames.jsp';"/>
         <img src="../images/NextArrow.png" id="nextButton" class="orderNavButton" onclick="location.href='orderProcess.html';"/>
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
