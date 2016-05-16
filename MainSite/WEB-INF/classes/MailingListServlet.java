import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;

//@WebServlet("/mailingList")
public class MailingListServlet extends HttpServlet {
   @Override
   public void doGet(HttpServletRequest request, HttpServletResponse response)
         throws IOException, ServletException {
        String address = "/WEB-INF/mailingList.jsp";
        request.getRequestDispatcher(address).forward(request, response);
   }
   
   @Override
   public void doPost(HttpServletRequest request, HttpServletResponse response)
         throws IOException, ServletException {
   }
   
}