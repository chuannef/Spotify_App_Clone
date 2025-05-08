import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class ScrollableSection extends StatefulWidget {
  final String title;
  final List<Widget> children;
  final double height;

  const ScrollableSection({
    super.key,
    required this.title,
    required this.children,
    required this.height,
  });

  @override
  State<ScrollableSection> createState() => _ScrollableSectionState();
}

class _ScrollableSectionState extends State<ScrollableSection> {
  final ScrollController _scrollController = ScrollController();
  bool _showLeftArrow = false;
  bool _showRightArrow = true;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateArrows);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateArrows);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateArrows() {
    setState(() {
      _showLeftArrow = _scrollController.offset > 10;
      _showRightArrow = _scrollController.offset < 
          _scrollController.position.maxScrollExtent - 10;
    });
  }

  void _scrollLeft() {
    final currentPosition = _scrollController.offset;
    final scrollAmount = currentPosition - 200.0 < 0 ? 0.0 : currentPosition - 200.0;
    _scrollController.animateTo(
      scrollAmount,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    final currentPosition = _scrollController.offset;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final scrollAmount = currentPosition + 200.0 > maxScroll ? maxScroll : currentPosition + 200.0;
    _scrollController.animateTo(
      scrollAmount,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: AppTextStyles.subHeading.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 16),
        MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          child: Stack(
            children: [
              SizedBox(
                height: widget.height,
                child: ListView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  children: widget.children,
                ),
              ),
              if (_isHovering && _showLeftArrow)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          AppColors.spotifyBlack.withOpacity(0.8),
                          AppColors.spotifyBlack.withOpacity(0.0),
                        ],
                      ),
                    ),
                    child: Center(
                      child: FloatingActionButton.small(
                        heroTag: "left_${widget.title}",
                        backgroundColor: AppColors.spotifyWhite,
                        foregroundColor: AppColors.spotifyBlack,
                        elevation: 2,
                        onPressed: _scrollLeft,
                        child: const Icon(
                          Icons.chevron_left,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              if (_isHovering && _showRightArrow)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          AppColors.spotifyBlack.withOpacity(0.8),
                          AppColors.spotifyBlack.withOpacity(0.0),
                        ],
                      ),
                    ),
                    child: Center(
                      child: FloatingActionButton.small(
                        heroTag: "right_${widget.title}",
                        backgroundColor: AppColors.spotifyWhite,
                        foregroundColor: AppColors.spotifyBlack,
                        elevation: 2,
                        onPressed: _scrollRight,
                        child: const Icon(
                          Icons.chevron_right,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}