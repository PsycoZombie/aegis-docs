# Keep Bouncy Castle
-keep class org.bouncycastle.** { *; }

# Keep iText crypto classes
-keep class com.itextpdf.text.pdf.crypto.** { *; }
-keep class com.itextpdf.text.pdf.PdfEncryptor { *; }
