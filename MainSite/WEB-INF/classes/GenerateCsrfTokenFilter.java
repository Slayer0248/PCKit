// Import required java libraries
import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.util.*;
import java.security.SecureRandom;
 
// Implements Filter class
public class GenerateCsrfTokenFilter implements Filter  {
   public void doFilter(ServletRequest req, ServletResponse resp,
            FilterChain chain) throws IOException, ServletException {
      HttpServletRequest httpReq = (HttpServletRequest) req;
      HttpServletResponse httpResp = (HttpServletResponse) resp;
      
      
      SecureRandom random = new SecureRandom();
      Cookie cookie = new Cookie("csrf", "" + random.nextLong());
      httpResp.addCookie(cookie);
      chain.doFilter(httpReq, httpResp);
        
   }
   public void destroy() {
   
   }


}