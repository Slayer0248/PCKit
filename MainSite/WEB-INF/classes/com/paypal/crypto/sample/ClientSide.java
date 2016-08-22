/*
 *
 */
package com.paypal.crypto.sample;

import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.security.InvalidAlgorithmParameterException;
import java.security.KeyStore;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.PrivateKey;
import java.security.UnrecoverableKeyException;
import java.security.cert.CertStore;
import java.security.cert.CertStoreException;
import java.security.cert.CertificateException;
import java.security.cert.CertificateFactory;
import java.security.cert.CollectionCertStoreParameters;
import java.security.cert.X509Certificate;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.*;

import org.bouncycastle.cms.CMSEnvelopedData;
import org.bouncycastle.cms.CMSEnvelopedDataGenerator;
import org.bouncycastle.cms.CMSException;
import org.bouncycastle.cms.CMSProcessableByteArray;
import org.bouncycastle.cms.CMSSignedData;
import org.bouncycastle.cms.CMSSignedDataGenerator;
import org.bouncycastle.openssl.PEMParser;
import org.bouncycastle.util.encoders.Base64;
//import org.bouncycastle.jce.provider.*;
//import org.bouncycastle.jcajce.util.*;
//import org.bouncycastle.jcajce.provider.keystore.pkcs12.*;
import org.bouncycastle.util.*;
//import java.security.*;
//import javax.crypto.*;
import org.bouncycastle.cert.jcajce.*;
import org.bouncycastle.operator.*;
import org.bouncycastle.operator.jcajce.*;
import org.bouncycastle.cms.jcajce.*;
import org.bouncycastle.cms.*;

/**
 */
public class ClientSide 
{
	private String 	keyPath;
	private String 	certPath;
	private String 	paypalCertPath;
	private String 	keyPass;

	public ClientSide( String keyPath, String certPath, String paypalCertPath, String keyPass )
	{
		this.keyPath = keyPath;
		this.certPath = certPath;
		this.paypalCertPath = paypalCertPath;
		this.keyPass = keyPass;
	}	
	
	public String getButtonEncryptionValue(
		String _data,
		String _privateKeyPath,
		String _certPath,
		String _payPalCertPath,
		String _keyPass)
		throws
			IOException,
			CertificateException,
			KeyStoreException,
			UnrecoverableKeyException,
			InvalidAlgorithmParameterException,
			NoSuchAlgorithmException,
			NoSuchProviderException,
			CertStoreException,
			CMSException, OperatorCreationException
	{
	    //Security.addProvider(new BouncyCastleProvider());
		_data = _data.replace(',', '\n');
		CertificateFactory cf = CertificateFactory.getInstance("X509", "BC");

		// Read the Private Key
		KeyStore ks = KeyStore.getInstance("PKCS12", "BC");
		ks.load( new FileInputStream(_privateKeyPath), _keyPass.toCharArray() );

		String keyAlias = null;
		Enumeration aliases = ks.aliases();
		while (aliases.hasMoreElements()) {
			keyAlias = (String) aliases.nextElement();
		}

		PrivateKey privateKey = (PrivateKey) ks.getKey( keyAlias, _keyPass.toCharArray() );

		// Read the Certificate
		X509Certificate certificate = (X509Certificate) cf.generateCertificate( new FileInputStream(_certPath) );

		// Read the PayPal Cert
		X509Certificate payPalCert = (X509Certificate) cf.generateCertificate( new FileInputStream(_payPalCertPath) );

		// Create the Data
		byte[] data = _data.getBytes();
		
		// Sign the Data with my signing only key pair
		CMSSignedDataGenerator signedGenerator = new CMSSignedDataGenerator();

		 List<X509Certificate> certList = new ArrayList<X509Certificate>();
    certList.add(certificate);

    //deprecated: Store certStore = CertStore.getInstance("Collection", new CollectionCertStoreParameters(certList));
    Store certStore = new JcaCertStore(certList);

    // deprecated: signedGenerator.addCertificatesAndCRLs(certStore);
    signedGenerator.addCertificates(certStore);

    // deprecated: signedGenerator.addSigner(privateKey, certificate, CMSSignedDataGenerator.DIGEST_SHA1);

    ContentSigner sha1Signer = new JcaContentSignerBuilder("SHA1withRSA").setProvider("BC").build(privateKey);
    signedGenerator.addSignerInfoGenerator(new JcaSignerInfoGeneratorBuilder(
            new JcaDigestCalculatorProviderBuilder().setProvider("BC").build()).build(sha1Signer, certificate));


		/*ArrayList certList = new ArrayList();
		certList.add(certificate);
		CertStore certStore = CertStore.getInstance( "Collection", new CollectionCertStoreParameters(certList) );
		signedGenerator.addCertificatesAndCRLs(certStore);*/

		CMSProcessableByteArray cmsByteArray = new CMSProcessableByteArray(data);
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		cmsByteArray.write(baos);
		System.out.println( "CMSProcessableByteArray contains [" + baos.toString() + "]" );

		CMSSignedData signedData = signedGenerator.generate(cmsByteArray, true); //, "BC"
		
		byte[] signed = signedData.getEncoded();

		CMSEnvelopedDataGenerator envGenerator = new CMSEnvelopedDataGenerator();
		// deprecated: envGenerator.addKeyTransRecipient(payPalCert);
    envGenerator.addRecipientInfoGenerator(new JceKeyTransRecipientInfoGenerator(payPalCert).setProvider("BC"));

    // deprecated: CMSEnvelopedData envData = envGenerator.generate(new CMSProcessableByteArray(signed),
    // CMSEnvelopedDataGenerator.DES_EDE3_CBC, "BC");
    CMSEnvelopedData envData = envGenerator.generate(new CMSProcessableByteArray(signed),
            new JceCMSContentEncryptorBuilder(CMSAlgorithm.DES_EDE3_CBC).setProvider("BC").build());

		byte[] pkcs7Bytes = envData.getEncoded();

		
		return new String( DERtoPEM(pkcs7Bytes, "PKCS7") );

	}

	public static byte[] DERtoPEM(byte[] bytes, String headfoot) 
	{
		ByteArrayOutputStream pemStream = new ByteArrayOutputStream();
		PrintWriter writer = new PrintWriter(pemStream);
		
		byte[] stringBytes = Base64.encode(bytes);
		
		System.out.println("Converting " + stringBytes.length + " bytes");
		
		String encoded = new String(stringBytes);

		if (headfoot != null) {
			writer.print("-----BEGIN " + headfoot + "-----\n");
		}

		// write 64 chars per line till done
		int i = 0;
		while ((i + 1) * 64 < encoded.length()) {
			writer.print(encoded.substring(i * 64, (i + 1) * 64));
			writer.print("\n");
			i++;
		}
		if (encoded.length() % 64 != 0) {
			writer.print(encoded.substring(i * 64)); // write remainder
			writer.print("\n");
		}
		if (headfoot != null) {
			writer.print("-----END " + headfoot + "-----\n");
		}
		writer.flush();
		return pemStream.toByteArray();
	}

}
