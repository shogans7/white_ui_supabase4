import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageRepository {
  final supabase = Supabase.instance.client;

  Future<String?> uploadFile(XFile? xFile) async {}

  Future<String?> uploadGroupPhoto(XFile? xFile) async {
    try {
      if (xFile != null) {
        final bytes = await xFile.readAsBytes();
        final fileExt = xFile.path.split('.').last;
        final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
        final filePath = fileName;
        await supabase.storage.from('group_avatars').uploadBinary(
              filePath,
              bytes,
              fileOptions: FileOptions(contentType: xFile.mimeType),
            );
        final imageUrlResponse = await supabase.storage.from('group_avatars').createSignedUrl(filePath, 60 * 60 * 24 * 365 * 10);

        return imageUrlResponse;
      }
    } catch (e) {
      rethrow;
    }
  }
}
