import accounts.AuthJWTUtil;
import io.jsonwebtoken.SignatureException;

public class TestJWTs {
   public static void main(String[] args) {
      AuthJWTUtil jwtUtil = new AuthJWTUtil();
      try {
         String jwtStr = jwtUtil.createJWT("1", "https://www.pckit.org", "PCKitData", 30 * 60 * 1000);
         jwtUtil.parseJWT(jwtStr);
      }
      catch (Exception e) {
         e.printStackTrace();
      }
   }
}