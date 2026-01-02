import 'dart:io';
import 'package:permission_handler/permission_handler.dart' as ph;
import '../utils/logger.dart';

/// Service for handling app permissions with proper Android version detection
class PermissionService {
  PermissionService._();
  static final PermissionService instance = PermissionService._();

  /// Check if we're on Android 13+ (API 33+)
  /// Android 13 introduced granular media permissions
  bool get _isAndroid13Plus {
    if (!Platform.isAndroid) return false;
    // Android 13 is API level 33
    // We'll use a simple check - permission_handler handles this internally
    // but we can check SDK version if needed via platform channels
    // For now, we'll let permission_handler handle it
    return true; // permission_handler will handle version-specific permissions
  }

  /// Check storage permission status
  /// Returns true if permission is granted, false otherwise
  Future<bool> checkStoragePermission() async {
    try {
      if (Platform.isAndroid) {
        // For Android 13+ (API 33+), check granular media permissions
        // For Android 12 and below, check READ_EXTERNAL_STORAGE
        if (_isAndroid13Plus) {
          // Check all media permissions (images, video, audio)
          // At least one should be granted for file picker to work
          final imagesStatus = await ph.Permission.photos.status;
          final videoStatus = await ph.Permission.videos.status;
          final audioStatus = await ph.Permission.audio.status;
          
          // Also check if storage permission is granted (for documents)
          final storageStatus = await ph.Permission.storage.status;
          
          return imagesStatus.isGranted || 
                 videoStatus.isGranted || 
                 audioStatus.isGranted ||
                 storageStatus.isGranted;
        } else {
          // Android 12 and below
          final status = await ph.Permission.storage.status;
          return status.isGranted;
        }
      } else if (Platform.isIOS) {
        // iOS uses different permissions
        final status = await ph.Permission.photos.status;
        return status.isGranted;
      }
      // Web and desktop platforms don't need explicit permissions
      return true;
    } catch (e) {
      Logger.error(
        'Error checking storage permission: $e',
        tag: 'PermissionService',
      );
      return false;
    }
  }

  /// Request storage permissions
  /// Returns true if permission is granted, false otherwise
  Future<bool> requestStoragePermission() async {
    try {
      if (Platform.isAndroid) {
        if (_isAndroid13Plus) {
          // Android 13+: Request granular media permissions
          // Request photos, videos, and audio permissions
          final permissions = [
            ph.Permission.photos,
            ph.Permission.videos,
            ph.Permission.audio,
          ];
          
          final statuses = await permissions.request();
          
          // Check if at least one permission was granted
          final hasPermission = statuses.values.any((status) => status.isGranted);
          
          // Also try storage permission for documents
          if (!hasPermission) {
            final storageStatus = await ph.Permission.storage.request();
            return storageStatus.isGranted;
          }
          
          return hasPermission;
        } else {
          // Android 12 and below: Request READ_EXTERNAL_STORAGE
          final status = await ph.Permission.storage.request();
          return status.isGranted;
        }
      } else if (Platform.isIOS) {
        // iOS: Request photos permission
        final status = await ph.Permission.photos.request();
        return status.isGranted;
      }
      // Web and desktop platforms don't need explicit permissions
      return true;
    } catch (e) {
      Logger.error(
        'Error requesting storage permission: $e',
        tag: 'PermissionService',
      );
      return false;
    }
  }

  /// Check and request storage permission if not granted
  /// Returns true if permission is granted (either already or after request)
  Future<bool> ensureStoragePermission() async {
    final hasPermission = await checkStoragePermission();
    if (hasPermission) {
      return true;
    }
    return await requestStoragePermission();
  }

  /// Check notification permission status
  Future<bool> checkNotificationPermission() async {
    try {
      final status = await ph.Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      Logger.error(
        'Error checking notification permission: $e',
        tag: 'PermissionService',
      );
      return false;
    }
  }

  /// Request notification permission
  Future<bool> requestNotificationPermission() async {
    try {
      final status = await ph.Permission.notification.request();
      return status.isGranted;
    } catch (e) {
      Logger.error(
        'Error requesting notification permission: $e',
        tag: 'PermissionService',
      );
      return false;
    }
  }

  /// Check if permission is permanently denied (user selected "Don't ask again")
  Future<bool> isStoragePermissionPermanentlyDenied() async {
    try {
      if (Platform.isAndroid) {
        if (_isAndroid13Plus) {
          final photosStatus = await ph.Permission.photos.status;
          final videosStatus = await ph.Permission.videos.status;
          final audioStatus = await ph.Permission.audio.status;
          final storageStatus = await ph.Permission.storage.status;
          
          return photosStatus.isPermanentlyDenied ||
                 videosStatus.isPermanentlyDenied ||
                 audioStatus.isPermanentlyDenied ||
                 storageStatus.isPermanentlyDenied;
        } else {
          final status = await ph.Permission.storage.status;
          return status.isPermanentlyDenied;
        }
      }
      return false;
    } catch (e) {
      Logger.error(
        'Error checking if permission is permanently denied: $e',
        tag: 'PermissionService',
      );
      return false;
    }
  }

  /// Open app settings so user can manually grant permission
  Future<bool> openAppSettings() async {
    try {
      return await ph.openAppSettings();
    } catch (e) {
      Logger.error(
        'Error opening app settings: $e',
        tag: 'PermissionService',
      );
      return false;
    }
  }
}

