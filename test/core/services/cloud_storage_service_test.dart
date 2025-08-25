import 'package:aegis_docs/core/services/cloud_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'cloud_storage_service_test.mocks.dart';

// We only need to mock the top-level DriveApi.
@GenerateMocks([drive.DriveApi])
// A "Fake" implementation of the FilesResource.
class FakeFilesResource extends Fake implements drive.FilesResource {
  drive.FileList? listResult;
  // The delete method does not return a value,
  // so we don't need a result variable.

  // The method signature now exactly matches the
  // real FilesResource.list method,
  // including all optional named parameters.
  @override
  Future<drive.FileList> list({
    String? q,
    String? spaces,
    String? $fields,
    String? corpora,
    String? corpus,
    String? driveId,
    bool? includeItemsFromAllDrives,
    String? includeLabels,
    String? includePermissionsForView,
    bool? includeTeamDriveItems,
    String? orderBy,
    int? pageSize,
    String? pageToken,
    bool? supportsAllDrives,
    bool? supportsTeamDrives,
    String? teamDriveId,
  }) async {
    return listResult ?? drive.FileList(files: []);
  }

  // The method signature now exactly matches
  // the real FilesResource.delete method.
  // The return type is Future<void>.
  @override
  Future<void> delete(
    String fileId, {
    String? $fields,
    bool? enforceSingleParent,
    bool? supportsAllDrives,
    bool? supportsTeamDrives,
  }) async {
    // This fake method does nothing, as the real one returns void.
    return;
  }
}

void main() {
  late CloudStorageService cloudStorageService;
  late MockDriveApi mockDriveApi;
  late FakeFilesResource fakeFilesResource;

  setUp(() {
    mockDriveApi = MockDriveApi();
    fakeFilesResource = FakeFilesResource();

    when(mockDriveApi.files).thenReturn(fakeFilesResource);

    cloudStorageService = CloudStorageService(driveApi: mockDriveApi);
  });

  group('CloudStorageService', () {
    test(
      'deleteBackup should call drive.files.delete if file exists',
      () async {
        // Arrange: Configure our fake to return a file list with one item.
        fakeFilesResource.listResult = drive.FileList(
          files: [drive.File(id: 'fake-id')],
        );

        // Act
        final result = await cloudStorageService.deleteBackup('test.zip');

        // Assert
        expect(result, isTrue);
      },
    );

    test('deleteBackup should return null if no file exists', () async {
      // Arrange: Configure our fake to return an empty file list.
      fakeFilesResource.listResult = drive.FileList(files: []);

      // Act
      final result = await cloudStorageService.deleteBackup('test.zip');

      // Assert
      expect(result, isNull);
    });
  });
}
