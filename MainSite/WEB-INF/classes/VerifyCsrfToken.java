// Import required java libraries
import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.util.*;
 
// Implements Filter class
public class VerifyCsrfToken {
   public static boolean isValidToken(HttpServletRequest req, HttpServletResponse resp) 
          throws IOException, ServletException {
      
      String tokenFromCookie = null;
      Cookie cookies[] = req.getCookies();
      for (int i=0; i<cookies.length(); i++) {
         if (cookies[i].getName().equals("csrf")) {
            tokenFromCookie = cookies[i].getValue();
         }
      }
      if (tokenFromCookie ==null) {
         return false;
      }
      
      String csrfToken = req.getParameter("csrf");
      if (csrfToken == null) {
         return false;
      }
      
      return csrfToken.equals(tokenFromCookie);
   }


}