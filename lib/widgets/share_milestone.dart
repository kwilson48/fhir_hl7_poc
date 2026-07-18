import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/milestone.dart';

/// Renders [MilestoneShareCard] to a PNG and opens the system share sheet.
/// On web (no temp files / native share of files), falls back to sharing text.
Future<void> shareMilestone({
  required BuildContext context,
  required Milestone milestone,
  required int day,
}) async {
  final text = 'Day $day alcohol-free ${milestone.emoji} '
      '"${milestone.title}" unlocked. #Dry30';

  if (kIsWeb) {
    await SharePlus.instance.share(ShareParams(text: text));
    return;
  }

  final boundaryKey = GlobalKey();
  final overlay = OverlayEntry(
    builder: (_) => Positioned(
      // Render off-screen: real layout, invisible to the user.
      left: -1200,
      top: 0,
      child: RepaintBoundary(
        key: boundaryKey,
        child: MilestoneShareCard(milestone: milestone, day: day),
      ),
    ),
  );
  Overlay.of(context, rootOverlay: true).insert(overlay);

  try {
    // Let the overlay complete a frame before capturing.
    await WidgetsBinding.instance.endOfFrame;
    final boundary = boundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return;
    final image = await boundary.toImage(pixelRatio: 3);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) return;

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/dry30-milestone-${milestone.id}.png');
    await file.writeAsBytes(bytes.buffer.asUint8List());

    await SharePlus.instance.share(ShareParams(
      text: text,
      files: [XFile(file.path, mimeType: 'image/png')],
    ));
  } finally {
    overlay.remove();
  }
}

/// The card image itself — fixed size so captures are consistent.
class MilestoneShareCard extends StatelessWidget {
  const MilestoneShareCard({
    super.key,
    required this.milestone,
    required this.day,
  });

  final Milestone milestone;
  final int day;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 400,
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E7D6B), Color(0xFF184F42)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DAY $day ALCOHOL-FREE',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              )),
          const Spacer(),
          Text(milestone.emoji, style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 12),
          Text(milestone.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                height: 1.15,
              )),
          const Spacer(),
          const Row(
            children: [
              Text('🌱', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text('Dry30',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
