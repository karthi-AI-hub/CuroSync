
import 'package:url_launcher/url_launcher.dart';

void triggerSOS() async {
  final Uri callUri = Uri.parse("tel:9688976383");
  if (await canLaunchUrl(callUri)) {
    await launchUrl(callUri);
  } else {
    print("Could not launch emergency call");
  }
}