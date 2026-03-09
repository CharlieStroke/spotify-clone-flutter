import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PageLayout extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final bool useScroll;
  final EdgeInsetsGeometry? padding;

  const PageLayout({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.useScroll = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 25, bottom: 20, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (actions != null) Row(children: actions!),
                ],
              ),
            ),
            Expanded(
              child: useScroll
                  ? SingleChildScrollView(
                      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
                      child: child,
                    )
                  : Padding(
                      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
                      child: child,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
