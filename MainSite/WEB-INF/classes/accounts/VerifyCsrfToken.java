package accounts;

// Import required java libraries
import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.util.*;
 
// Implements Filter class
public class VerifyCsrfToken {
    public VerifyCsrfToken() {
        
        
    }

   public static boolean isValidToken(HttpServletRequest req, HttpServletResponse resp) 
          throws IOException, ServletException {
      
      AuthJWTUtil authUtil = new AuthJWTUtil();
      
      String tokenFromCookie = null;
      Cookie cookies[] = req.getCookies();
      for (int i=0; i<cookies.length; i++) {
         if (cookies[i].getName().equals("csrfCheck")) {
            try {
               tokenFromCookie = authUtil.extractCSRF(cookies[i].getValue());
            }
            catch(Exception e) {
            
            }
            
         }
      }
      if (tokenFromCookie ==null) {
         return false;
      }
      
      //String csrfToken = req.getParameter("csrf");
      String csrfToken = req.getHeader("csrf");
      if (csrfToken == null) {
         return false;
      }
      
      return csrfToken.equals(tokenFromCookie);
   }


}