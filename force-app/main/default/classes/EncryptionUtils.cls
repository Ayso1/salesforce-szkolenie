public with sharing class EncryptionUtils {
    private static final String SECRET_KEY = 'britenetbritenet';

    public static String encrypt(String plainText) {
        Blob key = Blob.valueOf(SECRET_KEY);
        Blob data = Blob.valueOf(plainText);
        Blob encrypted = Crypto.encryptWithManagedIV('AES128', key, data);
        String encoded = EncodingUtil.base64Encode(encrypted);
        encoded = encoded.replace('+', '-').replace('/', '_');
        return encoded;
    }

    public static String decrypt(String encryptedText) {
        Blob key = Blob.valueOf(SECRET_KEY);
        Blob data = EncodingUtil.base64Decode(encryptedText);
        Blob decrypted = Crypto.decryptWithManagedIV('AES128', key, data);
        return decrypted.toString();
    }
}
