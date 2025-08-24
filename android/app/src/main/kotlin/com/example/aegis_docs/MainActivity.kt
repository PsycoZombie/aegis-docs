package com.example.aegis_docs

import android.app.ActivityManager
import android.app.ActivityManager.MemoryInfo
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Environment
import android.util.Log
import com.artifex.mupdf.fitz.ColorSpace
import com.artifex.mupdf.fitz.Document
import com.artifex.mupdf.fitz.Matrix
import com.itextpdf.text.Document as iTextDocument
import com.itextpdf.text.Image as iTextImage
import com.itextpdf.text.pdf.*
import com.itextpdf.text.pdf.parser.PdfImageObject
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.*
import java.util.*
import kotlin.math.min
import kotlinx.coroutines.*
import kotlinx.coroutines.sync.Semaphore
import kotlinx.coroutines.sync.withPermit

/**
 * The main and only activity for the Aegis Docs Android application.
 *
 * This class serves as the bridge between the Flutter UI and native Android
 * capabilities. It sets up a [MethodChannel] to handle performance-critical
 * tasks like PDF compression, file cleanup, and direct file saving, which are
 * more efficient when implemented in native code.
 */
class MainActivity : FlutterFragmentActivity() {
    // Loads the compiled MuPDF native library required for PDF rendering.
    init {
        System.loadLibrary("mupdf_java")
    }

    /**
     * The channel name for communication with Flutter. IMPORTANT: This must
     * match the string used in your Dart code.
     */
    private val CHANNEL = "com.aegis_docs.platform"

    /**
     * Configures the Flutter engine and sets up the [MethodChannel] handler.
     */
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "compressPdf" -> {
                        val filePath = call.argument<String>("filePath")!!
                        val outputPath = call.argument<String>("outputPath")!!
                        val sizeLimit = call.argument<Int>("sizeLimit")!!
                        val preserveText = call.argument<Int>("preserveText")!!

                        CoroutineScope(Dispatchers.Main).launch {
                            val output =
                                withContext(Dispatchers.IO) {
                                    if (preserveText == 0) {
                                        compressByRasterization(
                                            filePath,
                                            outputPath,
                                            sizeLimit
                                        )
                                    } else {
                                        compressWithTextPreservation(
                                            filePath,
                                            outputPath,
                                            sizeLimit.toLong()
                                        )
                                    }
                                }
                            result.success(output)
                        }
                    }
                    "saveToDownloads" -> {
                        val fileName = call.argument<String>("fileName")!!
                        val data = call.argument<ByteArray>("data")!!

                        CoroutineScope(Dispatchers.Main).launch {
                            val outputPath =
                                withContext(Dispatchers.IO) {
                                    saveBytesToDownloads(fileName, data)
                                }
                            result.success(outputPath)
                        }
                    }
                    "cleanupExportedFiles" -> {
                        val expirationInMinutes =
                            call.argument<Int>("expirationInMinutes")!!
                        CoroutineScope(Dispatchers.Main).launch {
                            withContext(Dispatchers.IO) {
                                cleanupFiles(expirationInMinutes)
                            }
                            result.success(null) // Fire-and-forget
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /**
     * Deletes files from the app's public "AegisDocs" directory that are older
     * than the specified expiration time.
     *
     * @param expirationInMinutes The age in minutes after which a file is
     *   considered expired.
     */
    private fun cleanupFiles(expirationInMinutes: Int) {
        try {
            Log.d(
                "Cleanup",
                "Starting cleanup with expiration of $expirationInMinutes minutes."
            )
            val downloadsDir =
                Environment.getExternalStoragePublicDirectory(
                    Environment.DIRECTORY_DOWNLOADS
                )
            val aegisDir = File(downloadsDir, "AegisDocs")

            if (!aegisDir.exists() || !aegisDir.isDirectory) {
                Log.d(
                    "Cleanup",
                    "AegisDocs directory not found. No cleanup needed."
                )
                return
            }

            val expirationInMillis = expirationInMinutes * 60 * 1000L
            val currentTime = System.currentTimeMillis()
            var deletedCount = 0

            aegisDir.listFiles()?.forEach { file ->
                if (file.isFile) {
                    val lastModified = file.lastModified()
                    if (currentTime - lastModified > expirationInMillis) {
                        if (file.delete()) {
                            deletedCount++
                            Log.d(
                                "Cleanup",
                                "Deleted expired file: ${file.name}"
                            )
                        } else {
                            Log.w(
                                "Cleanup",
                                "Failed to delete file: ${file.name}"
                            )
                        }
                    }
                }
            }
            Log.d(
                "Cleanup",
                "Cleanup complete. Deleted $deletedCount expired file(s)."
            )
        } catch (e: Exception) {
            Log.e("Cleanup", "Error during cleanup process", e)
        }
    }

    /**
     * Saves a byte array to a file in the public "Downloads/AegisDocs"
     * directory.
     *
     * @param fileName The name of the file to save.
     * @param data The byte data of the file.
     * @return The absolute path of the saved file, or an error message on
     *   failure.
     */
    private fun saveBytesToDownloads(
        fileName: String,
        data: ByteArray
    ): String {
        return try {
            val downloadsDir =
                Environment.getExternalStoragePublicDirectory(
                    Environment.DIRECTORY_DOWNLOADS
                )
            val aegisDir = File(downloadsDir, "AegisDocs")
            if (!aegisDir.exists()) {
                aegisDir.mkdirs()
            }
            val outputFile = File(aegisDir, fileName)
            FileOutputStream(outputFile).use { it.write(data) }
            Log.d(
                "FileSave",
                "File saved successfully at ${outputFile.absolutePath}"
            )
            outputFile.absolutePath
        } catch (e: Exception) {
            Log.e("FileSave", "Error saving file to downloads", e)
            "Error: ${e.message}"
        }
    }

    /**
     * Compresses a PDF by converting each page into a compressed JPEG image.
     *
     * @return A Map containing the status and either a file path or an error
     *   message.
     */
    private fun compressByRasterization(
        inputPath: String,
        outputPath: String,
        sizeLimitKB: Int
    ): Map<String, String> {
        var reader: PdfReader? = null
        var fos: FileOutputStream? = null
        var outDoc: iTextDocument? = null
        return try {
            reader = PdfReader(inputPath)
            val outputFile = File(outputPath)
            fos = FileOutputStream(outputFile)
            outDoc = iTextDocument()
            val pdfCopy = PdfCopy(outDoc, fos)
            outDoc.open()
            val pageCount = reader.numberOfPages
            val semaphore = Semaphore(determineConcurrency())
            runBlocking(Dispatchers.Default) {
                coroutineScope {
                    (1..pageCount)
                        .map { pageNum ->
                            async {
                                semaphore.withPermit {
                                    processPageRaster(
                                        inputPath,
                                        pdfCopy,
                                        pageNum,
                                        sizeLimitKB,
                                        pageCount
                                    )
                                }
                            }
                        }
                        .awaitAll()
                }
            }
            outDoc.close()
            fos.close()
            reader.close()

            if (outputFile.length() <= sizeLimitKB * 1024) {
                mapOf("status" to "success", "path" to outputPath)
            } else {
                mapOf(
                    "status" to "error",
                    "message" to
                        "Compressed but size ${outputFile.length() / 1024}KB > $sizeLimitKB KB"
                )
            }
        } catch (e: Exception) {
            Log.e("PDFCompression", "Error in compressByRasterization", e)
            mapOf(
                "status" to "error",
                "message" to (e.message ?: "An unknown error occurred.")
            )
        } finally {
            try {
                reader?.close()
            } catch (e: IOException) {}
            try {
                fos?.close()
            } catch (e: IOException) {}
            try {
                outDoc?.close()
            } catch (e: Exception) {}
        }
    }

    /**
     * Processes a single page of a PDF by rendering it to a bitmap, compressing
     * it as a JPEG, and adding it to a new PDF document.
     *
     * @param inputPath The path to the source PDF.
     * @param pdfCopy The iText PdfCopy instance to add the new page to.
     * @param pageNum The page number to process.
     * @param sizeLimitKB The overall size limit for the final PDF.
     * @param pageCount The total number of pages in the PDF.
     */
    private fun processPageRaster(
        inputPath: String,
        pdfCopy: PdfCopy,
        pageNum: Int,
        sizeLimitKB: Int,
        pageCount: Int
    ) {
        var muDoc: Document? = null
        var page: com.artifex.mupdf.fitz.Page? = null
        var pixmap: com.artifex.mupdf.fitz.Pixmap? = null
        var bitmap: Bitmap? = null
        var tempReader: PdfReader? = null

        try {
            muDoc = Document.openDocument(inputPath)
            page = muDoc.loadPage(pageNum - 1)
            val matrix = Matrix(72f / 72f, 72f / 72f)
            pixmap = page.toPixmap(matrix, ColorSpace.DeviceRGB, false)
            bitmap =
                Bitmap.createBitmap(
                    pixmap.width,
                    pixmap.height,
                    Bitmap.Config.ARGB_8888
                )

            val pixels = IntArray(pixmap.width * pixmap.height)
            val data = pixmap.samples
            val pixelSize = if (pixmap.alpha) 4 else 3
            for (i in 0 until min(data.size / pixelSize, pixels.size)) {
                val base = i * pixelSize
                val r = data[base].toInt() and 0xFF
                val g = data[base + 1].toInt() and 0xFF
                val b = data[base + 2].toInt() and 0xFF
                val a =
                    if (pixmap.alpha) data[base + 3].toInt() and 0xFF else 0xFF
                pixels[i] = (a shl 24) or (r shl 16) or (g shl 8) or b
            }
            bitmap.setPixels(
                pixels,
                0,
                pixmap.width,
                0,
                0,
                pixmap.width,
                pixmap.height
            )

            val imgBytes =
                findBestQualityJPEG(bitmap, (sizeLimitKB * 1024L) / pageCount)

            tempReader = PdfReader(createTempPdfWithImage(imgBytes))
            synchronized(pdfCopy) {
                pdfCopy.addPage(pdfCopy.getImportedPage(tempReader, 1))
            }
        } finally {
            bitmap?.recycle()
            pixmap?.destroy()
            page?.destroy()
            muDoc?.destroy()
            tempReader?.close()
        }
    }

    /**
     * Creates a temporary, single-page PDF in memory from a given byte array of
     * an image.
     *
     * @param imageBytes The byte data of the image.
     * @return A byte array representing the new PDF.
     */
    private fun createTempPdfWithImage(imageBytes: ByteArray): ByteArray {
        val baos = ByteArrayOutputStream()
        val doc = iTextDocument()
        val writer = PdfWriter.getInstance(doc, baos)
        doc.open()
        val img = iTextImage.getInstance(imageBytes)
        doc.setPageSize(img)
        doc.newPage()
        img.setAbsolutePosition(0f, 0f)
        doc.add(img)
        doc.close()
        writer.close()
        return baos.toByteArray()
    }

    /**
     * Finds the optimal JPEG quality setting to compress a bitmap to be under a
     * target size.
     *
     * @param bitmap The source bitmap.
     * @param maxBytes The target maximum size in bytes.
     * @return A byte array of the compressed JPEG.
     */
    private fun findBestQualityJPEG(bitmap: Bitmap, maxBytes: Long): ByteArray {
        var low = 25
        var high = 95
        var best: ByteArray? = null
        while (low <= high) {
            val mid = (low + high) / 2
            val os = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.JPEG, mid, os)
            val b = os.toByteArray()
            os.close()
            if (b.size <= maxBytes) {
                best = b
                low = mid + 1
            } else {
                high = mid - 1
            }
        }
        return best
            ?: ByteArrayOutputStream()
                .apply { bitmap.compress(Bitmap.CompressFormat.JPEG, 25, this) }
                .toByteArray()
    }

    /**
     * Compresses a PDF by re-compressing only the images within it.
     *
     * @return A Map containing the status and either a file path or an error
     *   message.
     */
    private fun compressWithTextPreservation(
        inputPath: String,
        outputPath: String,
        sizeLimitKb: Long
    ): Map<String, String> {
        val sizeLimitBytes = sizeLimitKb * 1024L
        val originalFile = File(inputPath)
        if (originalFile.length() <= sizeLimitBytes) {
            return try {
                copyTo(inputPath, outputPath)
                mapOf("status" to "success", "path" to outputPath)
            } catch (e: IOException) {
                mapOf(
                    "status" to "error",
                    "message" to "Copy failed: ${e.message}"
                )
            }
        }

        val textOnlyBytes =
            try {
                stripAllImagesToBytes(inputPath)
            } catch (e: Exception) {
                Log.e("PDFCompression", "Failed to strip images", e)
                return mapOf(
                    "status" to "error",
                    "message" to "Failed to process PDF structure: ${e.message}"
                )
            }

        if (textOnlyBytes.size > sizeLimitBytes) {
            Log.w(
                "PDFCompression",
                "The PDF with only text is larger than the size limit."
            )
            return mapOf(
                "status" to "error",
                "message" to
                    "Could not meet size limit. Text content alone is ${textOnlyBytes.size / 1024}KB."
            )
        }

        var low = 1
        var high = 99
        var bestBytes: ByteArray? = null

        while (low <= high) {
            val mid = (low + high) / 2
            Log.d("PDFCompression", "Text-Preserving: Trying quality $mid")
            val trialBytes =
                try {
                    recompressImagesToBytes(inputPath, mid)
                } catch (e: Exception) {
                    Log.e(
                        "PDFCompression",
                        "Failed to recompress at quality $mid",
                        e
                    )
                    null
                }

            if (trialBytes != null && trialBytes.size <= sizeLimitBytes) {
                bestBytes = trialBytes
                low = mid + 1
            } else {
                high = mid - 1
            }
        }

        if (bestBytes == null) {
            bestBytes =
                try {
                    recompressImagesToBytes(
                        inputPath,
                        1
                    ) // Try with lowest quality
                } catch (e: Exception) {
                    Log.e(
                        "PDFCompression",
                        "Failed to recompress at lowest quality",
                        e
                    )
                    textOnlyBytes
                }
        }

        val finalFile = File(outputPath)
        FileOutputStream(finalFile).use { it.write(bestBytes) }

        return if (finalFile.length() <= sizeLimitBytes) {
            mapOf("status" to "success", "path" to outputPath)
        } else {
            mapOf(
                "status" to "error",
                "message" to
                    "Compressed but size ${finalFile.length() / 1024}KB > $sizeLimitKb KB"
            )
        }
    }

    /**
     * Copies a file from a source path to a destination path.
     *
     * @param srcPath The source file path.
     * @param destPath The destination file path.
     * @return The destination path, or an error message on failure.
     */
    private fun copyTo(srcPath: String, destPath: String): String {
        return try {
            FileInputStream(File(srcPath)).use { inF ->
                FileOutputStream(File(destPath)).use { outF ->
                    inF.copyTo(outF)
                }
            }
            destPath
        } catch (e: IOException) {
            Log.e("PDFCompression", "Copy failed.", e)
            "Error: Copy failed. ${e.message}"
        }
    }

    /**
     * Re-compresses all images within a PDF to a specified JPEG quality.
     *
     * @param inputPath The path to the source PDF.
     * @param quality The target JPEG quality (0-100).
     * @return A byte array of the new PDF with re-compressed images.
     */
    private fun recompressImagesToBytes(
        inputPath: String,
        quality: Int
    ): ByteArray {
        val reader = PdfReader(inputPath)
        val baos = ByteArrayOutputStream()
        val stamper = PdfStamper(reader, baos).apply { setFullCompression() }

        val imageObjectNumbers = mutableListOf<Int>()
        for (i in 0 until reader.xrefSize) {
            val pdfObject = reader.getPdfObject(i) ?: continue
            if (pdfObject.isStream) {
                val stream = pdfObject as PRStream
                if (stream.getAsName(PdfName.SUBTYPE) == PdfName.IMAGE) {
                    val bitsPerComponent =
                        stream.getAsNumber(PdfName.BITSPERCOMPONENT)
                    if (
                        bitsPerComponent == null ||
                            bitsPerComponent.intValue() != 1
                    ) {
                        imageObjectNumbers.add(i)
                    }
                }
            }
        }

        val semaphore = Semaphore(determineConcurrency())
        val compressedImagesData =
            runBlocking(Dispatchers.Default) {
                imageObjectNumbers
                    .map { objectNumber ->
                        async {
                            semaphore.withPermit {
                                try {
                                    val stream =
                                        reader.getPdfObject(objectNumber)
                                            as PRStream
                                    val imageObject = PdfImageObject(stream)
                                    val imageBytes = imageObject.imageAsBytes
                                    val bitmap =
                                        BitmapFactory.decodeByteArray(
                                            imageBytes,
                                            0,
                                            imageBytes.size
                                        )
                                    if (bitmap != null) {
                                        val compressedStream =
                                            ByteArrayOutputStream()
                                        bitmap.compress(
                                            Bitmap.CompressFormat.JPEG,
                                            quality,
                                            compressedStream
                                        )
                                        val newBytes =
                                            compressedStream.toByteArray()
                                        bitmap.recycle()
                                        Pair(objectNumber, newBytes)
                                    } else {
                                        null
                                    }
                                } catch (e: Exception) {
                                    Log.w(
                                        "PDFCompression",
                                        "Could not process image object: $objectNumber",
                                        e
                                    )
                                    null
                                }
                            }
                        }
                    }
                    .awaitAll()
                    .filterNotNull()
            }

        for ((objectNumber, newBytes) in compressedImagesData) {
            val stream = reader.getPdfObject(objectNumber) as PRStream
            val newImage = iTextImage.getInstance(newBytes)
            stream.clear()
            stream.setData(newBytes, false, PRStream.NO_COMPRESSION)
            stream.put(PdfName.TYPE, PdfName.XOBJECT)
            stream.put(PdfName.SUBTYPE, PdfName.IMAGE)
            stream.put(PdfName.FILTER, PdfName.DCTDECODE)
            stream.put(PdfName.WIDTH, PdfNumber(newImage.plainWidth))
            stream.put(PdfName.HEIGHT, PdfNumber(newImage.plainHeight))
            stream.put(PdfName.BITSPERCOMPONENT, PdfNumber(8))
            stream.put(PdfName.COLORSPACE, PdfName.DEVICERGB)
        }

        stamper.close()
        reader.close()
        return baos.toByteArray()
    }

    /**
     * Strips all images from a PDF, leaving only text and vector content.
     *
     * @param inputPath The path to the source PDF.
     * @return A byte array of the image-stripped PDF.
     */
    private fun stripAllImagesToBytes(inputPath: String): ByteArray {
        val baos = ByteArrayOutputStream()
        val reader = PdfReader(inputPath)
        reader.removeUnusedObjects()
        for (i in 0 until reader.xrefSize) {
            val pdfObject = reader.getPdfObject(i) ?: continue
            if (!pdfObject.isStream) continue
            val stream = pdfObject as PRStream
            if (PdfName.IMAGE == stream.getAsName(PdfName.SUBTYPE)) {
                stream.clear()
                stream.setData(ByteArray(0), false)
            }
        }
        val stamper = PdfStamper(reader, baos)
        stamper.close()
        reader.close()
        return baos.toByteArray()
    }

    /**
     * A utility function to copy a file to the public "Downloads" directory
     * with a unique name to avoid conflicts.
     *
     * This is primarily a debugging helper for the text-preservation
     * compression method to save intermediate files.
     *
     * @param src The source file path.
     * @return The absolute path of the newly created copy.
     */
    private fun copyToDownloads(src: String): String {
        val dest =
            File(
                Environment.getExternalStoragePublicDirectory(
                    Environment.DIRECTORY_DOWNLOADS
                ),
                "${File(src).nameWithoutExtension}_copy_${UUID.randomUUID()}.pdf"
            )
        return try {
            FileInputStream(File(src)).use { inF ->
                FileOutputStream(dest).use { outF -> inF.copyTo(outF) }
            }
            dest.absolutePath
        } catch (e: IOException) {
            Log.e("PDFCompression", "Copy failed.", e)
            src
        }
    }

    /**
     * Determines an optimal level of concurrency for parallel tasks based on
     * the device's CPU cores and available RAM.
     *
     * @return The number of parallel tasks to run.
     */
    private fun determineConcurrency(): Int {
        val cores = Runtime.getRuntime().availableProcessors()
        val ram =
            (getSystemService(ACTIVITY_SERVICE) as ActivityManager).run {
                MemoryInfo().apply { getMemoryInfo(this) }.totalMem /
                    (1024 * 1024)
            }
        return when {
            ram < 3000 -> min(cores, 2)
            ram < 6000 -> min(cores, 4)
            else -> min(cores, 6)
        }
    }
}
