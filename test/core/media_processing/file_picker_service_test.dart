import 'dart:typed_data';

import 'package:aegis_docs/core/media_processing/file_picker_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress_platform_interface/flutter_image_compress_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// Import the generated mock file.
import 'file_picker_service_test.mocks.dart';

// This annotation tells build_runner to generate mocks
// for our plugin dependencies.
@GenerateMocks([ImagePicker, FilePicker, XFile])
// A fake implementation of the image compress platform interface
// to prevent native calls.
class FakeImageCompress extends Fake
    with MockPlatformInterfaceMixin
    implements FlutterImageCompressPlatform {
  @override
  Future<Uint8List> compressWithList(
    Uint8List image, {
    int minHeight = 1920,
    int minWidth = 1080,
    int quality = 95,
    int rotate = 0,
    int inSampleSize = 1,
    bool autoCorrectionAngle = true,
    CompressFormat format = CompressFormat.jpeg,
    bool keepExif = false,
  }) async {
    // For the test, we just return a simple, non-empty byte list to
    // simulate a successful compression.
    return Uint8List.fromList([1, 2, 3]);
  }
}

void main() {
  late FilePickerService filePickerService;
  late MockImagePicker mockImagePicker;
  late MockFilePicker mockFilePicker;
  late MockXFile mockXFile;

  // This runs before each test, ensuring a clean state.
  setUp(() {
    // Set the platform interface to our fake implementation before each test.
    FlutterImageCompressPlatform.instance = FakeImageCompress();
    mockImagePicker = MockImagePicker();
    mockFilePicker = MockFilePicker();
    mockXFile = MockXFile();
    // Inject the mock dependencies into the service.
    filePickerService = FilePickerService(
      imagePicker: mockImagePicker,
      filePicker: mockFilePicker,
    );
  });

  group('FilePickerService', () {
    test(
      'pickImage should call ImagePicker.pickImage and return a file',
      () async {
        // Arrange: Configure the mock XFile to behave like a real one.
        when(mockXFile.path).thenReturn('test.jpg');
        when(mockXFile.name).thenReturn('test.jpg');
        when(mockXFile.readAsBytes()).thenAnswer((_) async => Uint8List(0));
        // When pickImage is called, return our fully configured mock XFile.
        when(
          mockImagePicker.pickImage(source: anyNamed('source')),
        ).thenAnswer((_) async => mockXFile);

        // Act: Call the method we are testing.
        final result = await filePickerService.pickImage();

        // Assert: Verify that the method on the mock was called exactly once.
        verify(
          mockImagePicker.pickImage(source: ImageSource.gallery),
        ).called(1);
        // Verify that the result contains the correct, unprocessed file data.
        expect(result.$1?.name, 'test.jpg');
        expect(result.$2, isFalse); // wasConverted should be false
      },
    );

    test(
      'pickPdf should call FilePicker.pickFiles and return a file',
      () async {
        // Arrange: Create a fake FilePickerResult.
        final fakePlatformFile = PlatformFile(
          name: 'test.pdf',
          size: 0,
          bytes: Uint8List(0), // Provide bytes for the withData: true case
        );
        final fakeResult = FilePickerResult([fakePlatformFile]);
        // The stub now includes withData: true to match the real call.
        when(
          mockFilePicker.pickFiles(
            type: anyNamed('type'),
            allowedExtensions: anyNamed('allowedExtensions'),
            withData: anyNamed('withData'),
          ),
        ).thenAnswer((_) async => fakeResult);

        // Act
        final result = await filePickerService.pickPdf();

        // Assert
        verify(
          mockFilePicker.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['pdf'],
            withData: true,
          ),
        ).called(1);
        expect(result?.name, 'test.pdf');
      },
    );

    test(
      'pickImage with an unsupported format should trigger conversion',
      () async {
        // Arrange: Configure the mock XFile with an unsupported extension.
        when(mockXFile.path).thenReturn('test.webp');
        when(mockXFile.name).thenReturn('test.webp');
        when(mockXFile.readAsBytes()).thenAnswer((_) async => Uint8List(0));
        when(
          mockImagePicker.pickImage(source: anyNamed('source')),
        ).thenAnswer((_) async => mockXFile);

        // Act
        final result = await filePickerService.pickImage();

        // Assert
        // Verify that the file name was changed to .jpg.
        expect(result.$1?.name, 'test.jpg');
        // Verify that the wasConverted flag is now true.
        expect(result.$2, isTrue);
      },
    );
  });
}
