import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final BoxShape shape;

  const ShimmerSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white10,
      highlightColor: Colors.white24,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: shape == BoxShape.rectangle ? BorderRadius.circular(borderRadius) : null,
          shape: shape,
        ),
      ),
    );
  }
}

class PlaylistDetailSkeleton extends StatelessWidget {
  const PlaylistDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ShimmerSkeleton(width: 200, height: 200, borderRadius: 12),
        const SizedBox(height: 24),
        const ShimmerSkeleton(width: 250, height: 24),
        const SizedBox(height: 12),
        const ShimmerSkeleton(width: 150, height: 16),
        const SizedBox(height: 32),
        Expanded(
          child: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  ShimmerSkeleton(width: 52, height: 52, borderRadius: 4),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerSkeleton(width: 150, height: 14),
                      SizedBox(height: 8),
                      ShimmerSkeleton(width: 100, height: 12),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          // Grid 2x2
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 6,
            itemBuilder: (context, index) => const ShimmerSkeleton(width: double.infinity, height: 60),
          ),
          const SizedBox(height: 32),
          const ShimmerSkeleton(width: 200, height: 24),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder: (context, index) => const Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: ShimmerSkeleton(width: 150, height: 200),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const ShimmerSkeleton(width: 200, height: 24),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder: (context, index) => const Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: ShimmerSkeleton(width: 130, height: 180),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LibrarySkeleton extends StatelessWidget {
  const LibrarySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: ShimmerSkeleton(width: double.infinity, height: 80, borderRadius: 12),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 15,
              mainAxisSpacing: 25,
              childAspectRatio: 0.65,
            ),
            itemCount: 9,
            itemBuilder: (context, index) => const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: ShimmerSkeleton(width: double.infinity, height: double.infinity, borderRadius: 4)),
                SizedBox(height: 8),
                ShimmerSkeleton(width: 80, height: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
