import 'package:flutter/material.dart';
import 'dart:ui';

import '../../util/screen_size.dart';



class BuildAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Color? titleColor;
  final Color? iconColor;
  final bool enableFrostEffect;
  final bool showSideButton;
  final VoidCallback? onSideButtonPressed;
  final IconData sideButtonIcon;
  final bool showBackButton;
  final Color? backgroundColor;
  final double? titleSize;
  final FontWeight? fontWeight;
  final VoidCallback? onBackButtonPressed;
  final bool useCircularBackButton; // New parameter for circular style
  final Color? circularButtonColor; // Color for circular button
  final double? circularButtonSize; // Size for circular button
  final IconData backButtonIcon; // Customizable back icon

  const BuildAppBar({
    super.key,
    this.title,
    this.titleColor,
    this.iconColor,
    this.enableFrostEffect = false,
    this.showSideButton = false,
    this.onSideButtonPressed,
    this.sideButtonIcon = Icons.more_vert,
    this.showBackButton = true,
    this.backgroundColor,
    this.titleSize,
    this.fontWeight,
    this.onBackButtonPressed,
    this.useCircularBackButton = false, // Default to false for backward compatibility
    this.circularButtonColor,
    this.circularButtonSize,
    this.backButtonIcon = Icons.arrow_back,
  });

  @override
  Widget build(BuildContext context) {
    // Custom circular back button widget
    Widget buildCircularBackButton() {
      final size = circularButtonSize ?? context.responsiveSize(50);
      final color = circularButtonColor ?? const Color(0xFF0047AB);

      return Padding(
        padding: EdgeInsets.only(
          left: context.responsiveSize(16),
          top: context.responsiveSize(8),
          bottom: context.responsiveSize(8),
        ),
        child: GestureDetector(
          onTap: onBackButtonPressed ?? (){Navigator.pop(context);},
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                backButtonIcon,
                color: iconColor ?? Colors.black,
                size: context.responsiveSize(24),
              ),
            ),
          ),
        ),
      );
    }

    // Standard back button widget
    Widget buildStandardBackButton() {
      return IconButton(
        icon: Icon(backButtonIcon, color: iconColor ?? Colors.black),
        onPressed: onBackButtonPressed ?? () {Navigator.pop(context);},
      );
    }

    final appBarContent = AppBar(
      backgroundColor: backgroundColor ??
          (enableFrostEffect
              ? Colors.white.withOpacity(0.15)
              : Colors.transparent),
      elevation: 0,
      automaticallyImplyLeading: false, // Set to false to use custom leading
      leading: showBackButton
          ? (useCircularBackButton
          ? buildCircularBackButton()
          : buildStandardBackButton())
          : null,
      leadingWidth: useCircularBackButton
          ? context.responsiveSize(74) // Extra space for circular button
          : null,
      title: title != null
          ? Text(
        title!,
        style: TextStyle(
          color: titleColor ?? Colors.white,
          fontSize: titleSize ?? 24,
          fontWeight: fontWeight ?? FontWeight.normal,
        ),
      )
          : null,
      centerTitle: true,
      actions: showSideButton
          ? [
        IconButton(
          icon: Icon(sideButtonIcon, color: iconColor ?? Colors.white),
          onPressed: onSideButtonPressed,
          iconSize: 24,
        )
      ]
          : null,
    );

    return enableFrostEffect
        ? ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: backgroundColor?.withOpacity(0.2) ?? Colors.transparent,
          child: appBarContent,
        ),
      ),
    )
        : appBarContent;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}