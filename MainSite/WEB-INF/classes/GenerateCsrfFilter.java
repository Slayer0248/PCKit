
import java.security.SecureRandom;
import java.math.BigInteger;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Cookie;
import javax.servlet.http.*;
import javax.servlet.*;
import java.io.*;
import java.util.*;

//Code by Clay Jacobs
public class GenerateCsrfFilter implements Filter {

    public void init(FilterConfig filterConfig) throws ServletException {
    }

    public void doFilter(ServletRequest request, ServletResponse response,
                         FilterChain filterChain)
    throws IOException, ServletException {
        SecureRandom random = new SecureRandom();
        String token = new BigInteger(130, random).toString(32);
        Cookie cookie = new Cookie("csrf",token);
        cookie.setSecure(true);
        HttpServletResponse res= (HttpServletResponse) response;
        res.addCookie(cookie);

        filterChain.doFilter(request, res);

    }

    public void destroy() {
    }
}

