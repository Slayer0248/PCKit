<%@ page language="java" pageEncoding="UTF-8" contentType="text/html;charset=utf-8"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*,java.security.SecureRandom" %>
<!DOCTYPE html>
<div id="accountAccessDiv">
   <%
   Cookie cookie = null;
   Cookie[] cookies = null;
   // Get an array of Cookies associated with this domain
   cookies = request.getCookies();
   if( cookies != null ) {
      String loggedUser ="";
      for (int i = 0; i < cookies.length; i++){
         cookie = cookies[i];
         if (cookie.getName() == "pckitName") {
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
                 url:"/accounts/logout/",
                 data:""
              }).done(function(data) { /*Reload current page*/});
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
        
           <a id="accessLoginLink"href="./accounts/Login.jsp" class="accountAccessText">Login/Sign up</a>
          
      <% }

  }else{
      out.println("<h2>No cookies founds</h2>");
  }
   %>
  

</div>