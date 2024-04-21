import 'package:flutter/material.dart';
import 'package:honey_and_thyme/utils/constants.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:shimmer/shimmer.dart';

class FadeInImageWithPlaceHolder extends StatefulWidget {
  final String imageUrl;
  final Size size;
  final bool isSelected;
  final void Function()? onSelected;
  final void Function()? onTapped;

  const FadeInImageWithPlaceHolder({
    super.key,
    required this.imageUrl,
    required this.size,
    required this.isSelected,
    this.onSelected,
    this.onTapped,
  });

  @override
  State<FadeInImageWithPlaceHolder> createState() =>
      _FadeInImageWithPlaceHolderState();
}

class _FadeInImageWithPlaceHolderState extends State<FadeInImageWithPlaceHolder>
    with TickerProviderStateMixin {
  bool _hovering = false;
  bool _selectorHovering = false;

  double selectorOpacity() {
    if (_selectorHovering || widget.isSelected) {
      return 1;
    } else if (_hovering) {
      return 0.5;
    } else {
      return 0;
    }
  }

  final DecorationTween decorationTween = DecorationTween(
    begin: const BoxDecoration(),
    end: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.black.withOpacity(0.8),
          Colors.transparent,
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        stops: const [0, 0.2],
      ),
    ),
  );

  late final AnimationController boxDecorationController = AnimationController(
    duration: const Duration(milliseconds: 200),
    vsync: this,
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.size.height,
      width: widget.size.width,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            enabled: true,
            child: Container(
              height: widget.size.height,
              width: widget.size.width,
              color: Colors.white,
            ),
          ),
          MouseRegion(
            onEnter: widget.onSelected != null
                ? (_) {
                    if (_selectorHovering) return;
                    setState(() => _hovering = true);
                    boxDecorationController.forward();
                  }
                : null,
            onExit: widget.onSelected != null
                ? (_) {
                    if (_selectorHovering) return;
                    setState(() => _hovering = false);
                    boxDecorationController.reverse();
                  }
                : null,
            child: GestureDetector(
              onTap: widget.onTapped,
              child: DecoratedBoxTransition(
                position: DecorationPosition.foreground,
                decoration: decorationTween.animate(boxDecorationController),
                child: FadeInImage.memoryNetwork(
                  height: widget.size.height,
                  width: widget.size.width,
                  placeholder: kTransparentImage,
                  image: widget.imageUrl,
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 500),
                ),
              ),
            ),
          ),
          if (_hovering || _selectorHovering || widget.isSelected)
            Positioned(
              top: 5,
              right: 5,
              child: MouseRegion(
                onEnter: widget.onSelected != null
                    ? (_) => setState(() => _selectorHovering = true)
                    : null,
                onExit: widget.onSelected != null
                    ? (_) => setState(() => _selectorHovering = false)
                    : null,
                child: IconButton(
                  icon: Icon(
                    widget.isSelected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: Constants.goldColor.withOpacity(selectorOpacity()),
                  ),
                  onPressed: widget.onSelected,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
