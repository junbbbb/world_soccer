import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/capture.dart';
import '../../../../core/utils/snackbar.dart';
import '../../../../shared/widgets/inline_spinner.dart';

/// 인스타그램 스타일 정사각 크롭 + 원형 가이드.
///
/// 드래그/핀치로 영역 조정. 사각 프레임 = 프로필카드 노출,
/// 인스크립트 원형 = 아바타(멤버·채팅 등) 노출.
class CropImageScreen extends StatefulWidget {
  const CropImageScreen({super.key, required this.imageBytes});

  final Uint8List imageBytes;

  @override
  State<CropImageScreen> createState() => _CropImageScreenState();
}

class _CropImageScreenState extends State<CropImageScreen> {
  static const double _cropSize = 320;

  final GlobalKey _cropKey = GlobalKey();
  final TransformationController _controller = TransformationController();

  ui.Image? _image;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void dispose() {
    _controller.dispose();
    _image?.dispose();
    super.dispose();
  }

  Future<void> _loadImage() async {
    final codec = await ui.instantiateImageCodec(widget.imageBytes);
    final frame = await codec.getNextFrame();
    if (!mounted) {
      frame.image.dispose();
      return;
    }
    setState(() => _image = frame.image);
    _applyInitialCover();
  }

  void _applyInitialCover() {
    final img = _image;
    if (img == null) return;
    final scale = math.max(
      _cropSize / img.width.toDouble(),
      _cropSize / img.height.toDouble(),
    );
    final dx = (_cropSize - img.width * scale) / 2;
    final dy = (_cropSize - img.height * scale) / 2;
    _controller.value = Matrix4.identity()
      ..translate(dx, dy)
      ..scale(scale);
  }

  Future<void> _confirm() async {
    if (_processing) return;
    HapticFeedback.mediumImpact();
    setState(() => _processing = true);
    try {
      final bytes = await captureWidgetAsPng(_cropKey, pixelRatio: 3);
      if (!mounted) return;
      Navigator.of(context).pop(bytes);
    } catch (e) {
      if (!mounted) return;
      context.showError('크롭 실패: $e');
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Center(
                  child: _image == null
                      ? const CircularProgressIndicator(strokeWidth: 2)
                      : _buildCropStack(),
                ),
              ),
              _buildHint(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 52,
      child: Row(
        children: [
          GestureDetector(
            onTap: _processing ? null : () => Navigator.of(context).pop(),
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.base),
              child: Icon(
                Icons.close_rounded,
                size: 24,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _processing || _image == null ? null : _confirm,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: _processing
                  ? const InlineSpinner(size: 18)
                  : Text(
                      '완료',
                      style: AppTextStyles.label.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropStack() {
    return SizedBox(
      width: _cropSize,
      height: _cropSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RepaintBoundary(
            key: _cropKey,
            child: SizedBox(
              width: _cropSize,
              height: _cropSize,
              child: ClipRect(
                child: InteractiveViewer(
                  transformationController: _controller,
                  constrained: false,
                  minScale: 0.2,
                  maxScale: 5,
                  child: RawImage(image: _image),
                ),
              ),
            ),
          ),
          IgnorePointer(
            child: SizedBox(
              width: _cropSize,
              height: _cropSize,
              child: CustomPaint(painter: const _GuidePainter()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHint() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.base,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Column(
        children: [
          Text(
            '드래그로 이동, 핀치로 확대/축소',
            style: AppTextStyles.captionMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '사각 영역은 프로필카드, 원형은 다른 화면 아바타에 노출됩니다',
            style: AppTextStyles.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuidePainter extends CustomPainter {
  const _GuidePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    canvas.drawCircle(
      rect.center,
      size.width / 2,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final thirdsPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final third = size.width / 3;
    canvas.drawLine(Offset(third, 0), Offset(third, size.height), thirdsPaint);
    canvas.drawLine(
      Offset(third * 2, 0),
      Offset(third * 2, size.height),
      thirdsPaint,
    );
    canvas.drawLine(Offset(0, third), Offset(size.width, third), thirdsPaint);
    canvas.drawLine(
      Offset(0, third * 2),
      Offset(size.width, third * 2),
      thirdsPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
