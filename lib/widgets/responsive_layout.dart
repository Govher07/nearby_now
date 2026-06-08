import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? web;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.web,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWebSize = constraints.maxWidth >= 700;

        if (isWebSize && web != null) {
          return web!;
        }

        return mobile;
      },
    );
  }
}