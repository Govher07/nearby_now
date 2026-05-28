import 'package:url_launcher/url_launcher.dart';

import 'location_service.dart';

class DirectionsService {
  static Future<void> openDirectionsToAddress({
    required String destinationAddress,
  }) async {
    final position = await LocationService.getCurrentLocation();

    final String encodedDestination = Uri.encodeComponent(destinationAddress);

    final Uri url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=${position.latitude},${position.longitude}'
      '&destination=$encodedDestination'
      '&travelmode=walking',
    );

    final bool launched = await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      throw Exception('Could not open directions');
    }
  }
}