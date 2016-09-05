package accounts;

import javax.servlet.http.HttpServletRequest;
import javax.crypto.spec.SecretKeySpec;
import javax.xml.bind.DatatypeConverter;
import java.security.Key;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.SignatureException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtBuilder;

import java.sql.*;

import java.util.Date;

import java.util.StringTokenizer;    
import util.SecureEncrypt;
 
public class AuthJWTUtil {

    private String jwtKey = "J+tPyNi6T2KP4cHF/Z1HTGCsWQutvAe2cQDUqcTgheU=";
    private SecureEncrypt seTest;
    private LoginTracker loginTracker;
    
    
    private UserLogin userLogin;
    private String outputToken;

    public AuthJWTUtil() {
       seTest = new SecureEncrypt();
       loginTracker = new LoginTracker();
       userLogin =null;
       outputToken = null;
    }
    
    public String getUserIP(HttpServletRequest request) {
        String ip = request.getHeader("X-Pounded-For");

		if (ip != null) {
			return ip;
		}

        ip = request.getHeader("x-forwarded-for");

        if (ip == null) {
        	return request.getRemoteAddr();
        }
        else {
        	// Process the IP to keep the last IP (real ip of the computer on the net)
            StringTokenizer tokenizer = new StringTokenizer(ip, ",");

            // Ignore all tokens, except the last one
            for (int i = 0; i < tokenizer.countTokens() -1 ; i++) {
            	tokenizer.nextElement();
            }

            ip = tokenizer.nextToken().trim();

            if (ip.equals("")) {
            	ip = null;
            }
        }

        // If the ip is still null, we put 0.0.0.0 to avoid null values
        if (ip == null) {
        	ip = "0.0.0.0";
        }

        return ip;
    }
    
    public String createJWT(String id, String issuer, String subject, long nowMillis, long ttlMillis) {
       //The JWT signature algorithm we will be using to sign the token
       //SignatureAlgorithm signatureAlgorithm = SignatureAlgorithm.HS256;
       
       //long nowMillis = System.currentTimeMillis();
       Date now = new Date(nowMillis);
       
       //We will sign our JWT with our jwtKey secret
       byte[] apiKeySecretBytes = DatatypeConverter.parseBase64Binary(jwtKey);
       Key signingKey = new SecretKeySpec(apiKeySecretBytes, "HmacSHA256");
       
       
       JwtBuilder builder = Jwts.builder();
       builder.setId(id).setIssuedAt(now).setSubject(subject).setIssuer(issuer).setNotBefore(now).claim("test", "blah").signWith(SignatureAlgorithm.HS256, signingKey);
            
            //.setNotBefore(now).claim("test", "Hello")                    
        //if it has been specified, let's add the expiration
        if (ttlMillis >= 0) {
           long expMillis = nowMillis + ttlMillis;
           Date exp = new Date(expMillis);
           builder.setExpiration(exp);
        }
        
        //Builds the JWT and serializes it to a compact, URL-safe string
        return seTest.encryptToString(builder.compact(), "AES");
    
    }
    
    
    public Claims parseJWT(String jwt) throws SignatureException {
       //This line will throw an exception if it is not a signed JWS (as expected)
       //System.out.println("Encrypted jwt: " + jwt);
       String rawJwt = seTest.decryptToString(jwt, "AES");
       //System.out.println("Raw jwt: " + rawJwt);
       Claims claims = Jwts.parser()         
         .setSigningKey(DatatypeConverter.parseBase64Binary(jwtKey))
         .parseClaimsJws(rawJwt).getBody();
       
       /*System.out.println("ID: " + claims.getId());
       System.out.println("Subject: " + claims.getSubject());
       System.out.println("Issuer: " + claims.getIssuer());
       System.out.println("Expiration: " + claims.getExpiration());
       System.out.println("test: " + claims.get("test", String.class));*/
       return claims;
    }
    
    public String validateToken(String token, Date now, Connection conn) throws Exception {
        // Check if it was issued by the server and if it's not expired
        // Throw an Exception if the token is invalid
        String result = "Validation error";
        Claims claims = parseJWT(jwt);
        String sessionId  = claims.getId();
        if (!loginTracker.userLoginExpired(sessionId, now, conn)) {
           
           userLogin = loginTracker.getUserInfo(sessionId, conn);
           result = "Valid";
        }
        else {
           loginTracker.logoutUserSession(sessionId, conn);
           result = "Reload";
        }
        
        return result;
    }
    
    public void authorize(int userId, long nowMillis, int mins, Connection conn) throws Exception {
        // Authenticate against a database, LDAP, file or whatever
        // Throw an Exception if the credentials are invalid
        String result = "Validation error";
        Date now = new Date(nowMillis);
        long lengthMillis = (long)mins;
        lengthMillis = lengthMillis * 60 * 1000;
        String curSessionId = loginTracker.nextSessionId(now, conn);
        userLogin = loginTracker.createLogin(userId, curSessionId, now, mins, conn);
        outputToken =createJWT(curSessionId,"https://www.pckit.org", "PCKitData", nowMillis, lengthMillis);
        
        
        
    }
    
    public void deauthorize(String token, Connection conn) throws Exception {
        // Authenticate against a database, LDAP, file or whatever
        // Throw an Exception if the credentials are invalid
        Claims claims = parseJWT(jwt);
        String sessionId  = claims.getId();
        loginTracker.logoutUserSession(sessionId, conn);
        
    }
    
    public void refreshAll(Date now, Connection conn)  throws Exception {
        loginTracker.refreshAllLogins(now, conn);
    }

    
    public UserLogin getLoginResult() {
        return userLogin;
    }
    
    public String getJWTResult() {
        return outputToken;
    }
    
	
	
}