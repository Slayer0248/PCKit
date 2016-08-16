package util;

import java.io.IOException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.InvalidKeyException;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.BadPaddingException;
import javax.crypto.NoSuchPaddingException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

import javax.crypto.Cipher;
import java.security.Key;
import javax.crypto.spec.SecretKeySpec;
import javax.xml.bind.DatatypeConverter;

public class SecureEncrypt {

   /*Works for AES*/

   //32 byte key
   private String secret = "2B040l36KNN48qFIsF2RuwbRVdzB721D";
   
   public SecureEncrypt() {
   
   }

   private byte[] encrypt(byte[] text, String algorithm, String theSecret) 
    throws NoSuchAlgorithmException, InvalidKeyException, IllegalBlockSizeException, BadPaddingException, NoSuchPaddingException  { 
      Key key = new SecretKeySpec(theSecret.getBytes(), algorithm);
      
      Cipher cipher = Cipher.getInstance(algorithm);
      cipher.init(Cipher.ENCRYPT_MODE, key);
      byte[] encryptedData = cipher.doFinal(text);
      //System.out.println(encryptedData.length);
      
      return encryptedData;
   }
   
   private byte[] decrypt(byte[] text, String algorithm, String theSecret) 
    throws NoSuchAlgorithmException, InvalidKeyException, IllegalBlockSizeException, BadPaddingException, NoSuchPaddingException  { 
      Key key = new SecretKeySpec(theSecret.getBytes(), algorithm);
      
      Cipher cipher = Cipher.getInstance(algorithm);
      cipher.init(Cipher.DECRYPT_MODE, key);
      byte[] decryptedData = cipher.doFinal(text);
      return decryptedData;
   } 
   
   
   public String encryptToString(String text, String algorithm) 
    throws NoSuchAlgorithmException, InvalidKeyException, IllegalBlockSizeException, BadPaddingException, NoSuchPaddingException  { 
      byte[] encryptedData = encrypt(text.getBytes(), algorithm, secret);
      //String result = new String(Base64.getEncoder().encode(encryptedData)); 
      String result = DatatypeConverter.printBase64Binary(encryptedData);
      return result;
   }
   
   public byte[] encryptToBytes(String text, String algorithm) 
    throws NoSuchAlgorithmException, InvalidKeyException, IllegalBlockSizeException, BadPaddingException, NoSuchPaddingException  { 
      return encrypt(text.getBytes(), algorithm, secret);
   }
   
   public String decryptToString(String text, String algorithm)
    throws NoSuchAlgorithmException, InvalidKeyException, IllegalBlockSizeException, BadPaddingException, NoSuchPaddingException  {
      //byte[] dataBase64 = Base64.getDecoder().decode(text.getBytes());
      String inText = new String(text);
      byte[] dataBase64 = DatatypeConverter.parseBase64Binary(inText);
      String result = new String(decrypt(dataBase64, algorithm, secret));
      return result;
   }
   
   public byte[] decryptRawToBytes(byte[] text, String algorithm)
    throws NoSuchAlgorithmException, InvalidKeyException, IllegalBlockSizeException, BadPaddingException, NoSuchPaddingException  { 
      //byte[] dataBase64 = Base64.getDecoder().decode(Base64.getEncoder().encode(text));
      byte[] dataBase64 = DatatypeConverter.parseBase64Binary(DatatypeConverter.printBase64Binary(text));
      return decrypt(dataBase64, algorithm, secret);
      
   }

   public String decryptRawToString(byte[] text, String algorithm)
    throws NoSuchAlgorithmException, InvalidKeyException, IllegalBlockSizeException, BadPaddingException, NoSuchPaddingException  {
      String result = new String(decrypt(text, algorithm, secret));
      return result;
   }
   
   public byte[] recrypt(byte[] text, String algorithm, String nextKey)
    throws NoSuchAlgorithmException, InvalidKeyException, IllegalBlockSizeException, BadPaddingException, NoSuchPaddingException  { 
      //byte[] dataBase64 = Base64.getDecoder().decode(Base64.getEncoder().encode(text));
      byte[] dataBase64 = DatatypeConverter.parseBase64Binary(DatatypeConverter.printBase64Binary(text));
      byte[] decrypted = decrypt(dataBase64, algorithm, secret);
      return encrypt(decrypted, algorithm, nextKey);
   }
   
}
