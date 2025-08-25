# Keep Bouncy Castle
-keep class org.bouncycastle.** { *; }

# Keep iText crypto classes
-keep class com.artifex.mupdf.** { *; }
-keep class com.itextpdf.text.pdf.crypto.** { *; }
-keep class com.itextpdf.text.pdf.PdfEncryptor { *; }
-keep class com.yalantis.ucrop.** { *; }
-keep interface com.yalantis.ucrop.** { *; }

# Bouncy Castle / MuPDF references desktop Java classes not present in Android.
# This tells R8 to ignore them, as they are not used at runtime.
-dontwarn java.awt.**
-dontwarn javax.activation.**
-dontwarn javax.mail.**
-dontwarn javax.naming.**
-dontwarn org.bouncycastle.mail.**
-dontwarn org.bouncycastle.cert.dane.**
-dontwarn org.bouncycastle.jce.provider.X509LDAPCertStoreSpi
