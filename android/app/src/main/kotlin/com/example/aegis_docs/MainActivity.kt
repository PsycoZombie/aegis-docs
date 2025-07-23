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
import kotlinx.coroutines.*
import kotlinx.coroutines.sync.Semaphore
import kotlinx.coroutines.sync.withPermit
import java.io.*
import java.util.*
import kotlin.math.min

class MainActivity : FlutterFragmentActivity() {
    // Loads the compiled MuPDF native library.
    init {
        System.loadLibrary("mupdf_java")
    }

    // The channel name for communication with Flutter.
    // IMPORTANT: This must match the string used in your Dart code.
    private val CHANNEL = "com.aegis_docs.compress"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "compressPdf" -> {
                    // Extract arguments from the Flutter call
                    val filePath = call.argument<String>("filePath")!!
                    val sizeLimit = call.argument<Int>("sizeLimit")!!
                    val preserveText = call.argument<Int>("preserveText")!!

                    // Launch a coroutine to handle the heavy processing off the main thread.
                    CoroutineScope(Dispatchers.Main).launch {
                        val output = withContext(Dispatchers.IO) {
                            if (preserveText == 0) {
                                compressByRasterization(filePath, sizeLimit)
                            } else {
                                compressWithTextPreservation(filePath, sizeLimit.toLong())
                            }
                        }
                        // Send the result (the new file path or an error message) back to Flutter.
                        result.success(output)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    // --- All of your compression logic from the old file is below ---

    private fun compressByRasterization(inputPath: String, sizeLimitKB: Int): String {
        var reader: PdfReader? = null
        var fos: FileOutputStream? = null
        var outDoc: iTextDocument? = null
        return try {
            reader = PdfReader(inputPath)
            val outputFile = File(
                Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS),
                "compressed_${UUID.randomUUID()}.pdf"
            )
            fos = FileOutputStream(outputFile)
            outDoc = iTextDocument()
            val pdfCopy = PdfCopy(outDoc, fos)
            outDoc.open()
            val pageCount = reader.numberOfPages
            val semaphore = Semaphore(determineConcurrency())
            runBlocking(Dispatchers.Default) {
                coroutineScope {
                    (1..pageCount).map { pageNum ->
                        async {
                            semaphore.withPermit {
                                processPageRaster(inputPath, pdfCopy, pageNum, sizeLimitKB, pageCount)
                            }
                        }
                    }.awaitAll()
                }
            }
            outDoc.close()
            fos.close()
            reader.close()
            if (outputFile.length() <= sizeLimitKB * 1024) {
                outputFile.absolutePath
            } else {
                "Compressed but size ${outputFile.length() / 1024}KB > $sizeLimitKB KB"
            }
        } catch (e: Exception) {
            Log.e("PDFCompression", "Error in compressByRasterization", e)
            "Error: ${e.message}"
        } finally {
            reader?.close()
            fos?.close()
            outDoc?.close()
        }
    }

    private fun processPageRaster(inputPath: String, pdfCopy: PdfCopy, pageNum: Int, sizeLimitKB: Int, pageCount: Int) {
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
            bitmap = Bitmap.createBitmap(pixmap.width, pixmap.height, Bitmap.Config.ARGB_8888)

            val pixels = IntArray(pixmap.width * pixmap.height)
            val data = pixmap.samples
            val pixelSize = if (pixmap.alpha) 4 else 3
            for (i in 0 until min(data.size / pixelSize, pixels.size)) {
                val base = i * pixelSize
                val r = data[base].toInt() and 0xFF
                val g = data[base + 1].toInt() and 0xFF
                val b = data[base + 2].toInt() and 0xFF
                val a = if (pixmap.alpha) data[base + 3].toInt() and 0xFF else 0xFF
                pixels[i] = (a shl 24) or (r shl 16) or (g shl 8) or b
            }
            bitmap.setPixels(pixels, 0, pixmap.width, 0, 0, pixmap.width, pixmap.height)

            val imgBytes = findBestQualityJPEG(bitmap, (sizeLimitKB * 1024L) / pageCount)

            tempReader = PdfReader(createTempPdfWithImage(imgBytes))
            synchronized(pdfCopy) { pdfCopy.addPage(pdfCopy.getImportedPage(tempReader, 1)) }
        } finally {
            bitmap?.recycle()
            pixmap?.destroy()
            page?.destroy()
            muDoc?.destroy()
            tempReader?.close()
        }
    }

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
        return best ?: ByteArrayOutputStream().apply {
            bitmap.compress(Bitmap.CompressFormat.JPEG, 25, this)
        }.toByteArray()
    }

    private fun compressWithTextPreservation(inputPath: String, sizeLimitKb: Long): String {
        val sizeLimitBytes = sizeLimitKb * 1024L
        val originalFile = File(inputPath)
        if (originalFile.length() <= sizeLimitBytes) {
            return copyToDownloads(inputPath)
        }

        val textOnlyBytes = try {
            stripAllImagesToBytes(inputPath)
        } catch (e: Exception) {
            Log.e("PDFCompression", "Failed to strip images", e)
            return "Error: Failed to process PDF structure. ${e.message}"
        }

        if (textOnlyBytes.size > sizeLimitBytes) {
            Log.w("PDFCompression", "The PDF with only text is larger than the size limit.")
            val finalFile = File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS), "stripped_${UUID.randomUUID()}.pdf")
            FileOutputStream(finalFile).use { it.write(textOnlyBytes) }
            return "Could not meet size limit. Text content alone is ${textOnlyBytes.size / 1024}KB. Saved image-stripped version at: ${finalFile.absolutePath}"
        }

        var low = 1
        var high = 99
        var bestBytes: ByteArray? = null

        while (low <= high) {
            val mid = (low + high) / 2
            Log.d("PDFCompression", "Text-Preserving: Trying quality $mid")
            val trialBytes = try {
                recompressImagesToBytes(inputPath, mid)
            } catch (e: Exception) {
                Log.e("PDFCompression", "Failed to recompress at quality $mid", e)
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
            bestBytes = try {
                recompressImagesToBytes(inputPath, 0)
            } catch (e: Exception) {
                Log.e("PDFCompression", "Failed to recompress at lowest quality", e)
                textOnlyBytes
            }
        }

        val finalFile = File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS), "compressed_text_${UUID.randomUUID()}.pdf")
        FileOutputStream(finalFile).use { it.write(bestBytes!!) }

        return if (finalFile.length() <= sizeLimitBytes) {
            finalFile.absolutePath
        } else {
            "Compressed but size ${finalFile.length() / 1024}KB > $sizeLimitKb KB"
        }
    }

    private fun recompressImagesToBytes(inputPath: String, quality: Int): ByteArray {
        val reader = PdfReader(inputPath)
        val baos = ByteArrayOutputStream()
        val stamper = PdfStamper(reader, baos).apply {
            setFullCompression()
        }

        val imageObjectNumbers = mutableListOf<Int>()
        for (i in 0 until reader.xrefSize) {
            val pdfObject = reader.getPdfObject(i) ?: continue
            if (pdfObject.isStream) {
                val stream = pdfObject as PRStream
                if (stream.getAsName(PdfName.SUBTYPE) == PdfName.IMAGE) {
                    val bitsPerComponent = stream.getAsNumber(PdfName.BITSPERCOMPONENT)
                    if (bitsPerComponent == null || bitsPerComponent.intValue() != 1) {
                        imageObjectNumbers.add(i)
                    }
                }
            }
        }

        val semaphore = Semaphore(determineConcurrency())
        val compressedImagesData = runBlocking(Dispatchers.Default) {
            imageObjectNumbers.map { objectNumber ->
                async {
                    semaphore.withPermit {
                        try {
                            val stream = reader.getPdfObject(objectNumber) as PRStream
                            val imageObject = PdfImageObject(stream)
                            val imageBytes = imageObject.imageAsBytes
                            val bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
                            if (bitmap != null) {
                                val compressedStream = ByteArrayOutputStream()
                                bitmap.compress(Bitmap.CompressFormat.JPEG, quality, compressedStream)
                                val newBytes = compressedStream.toByteArray()
                                bitmap.recycle()
                                Pair(objectNumber, newBytes)
                            } else {
                                null
                            }
                        } catch (e: Exception) {
                            Log.w("PDFCompression", "Could not process image object: $objectNumber", e)
                            null
                        }
                    }
                }
            }.awaitAll().filterNotNull()
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

    private fun copyToDownloads(src: String): String {
        val dest = File(
            Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS),
            "${File(src).nameWithoutExtension}_copy_${UUID.randomUUID()}.pdf"
        )
        return try {
            FileInputStream(File(src)).use { inF -> FileOutputStream(dest).use { outF -> inF.copyTo(outF) } }
            dest.absolutePath
        } catch (e: IOException) {
            Log.e("PDFCompression", "Copy failed.", e)
            src
        }
    }

    private fun determineConcurrency(): Int {
        val cores = Runtime.getRuntime().availableProcessors()
        val ram = (getSystemService(ACTIVITY_SERVICE) as ActivityManager).run {
            MemoryInfo().apply { getMemoryInfo(this) }.totalMem / (1024 * 1024)
        }
        return when {
            ram < 3000 -> min(cores, 2)
            ram < 6000 -> min(cores, 4)
            else -> min(cores, 6)
        }
    }
}
