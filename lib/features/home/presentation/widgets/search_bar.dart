import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class SonaraSearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final void Function(String)? onSubmit;
  final EdgeInsets? margin;
  final String hintText;

  const SonaraSearchBar({
    super.key,
    this.controller,
    this.onSubmit,
    this.margin,
    this.onChanged,
    this.hintText = "Search for songs...",
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: TextField(
        maxLines: 1,
        onChanged: onChanged,
        onSubmitted: onSubmit,
        controller: controller,
        style: const TextStyle(color: Colors.white, fontFamily: 'SpaceGrotesk'),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 5),
            child: const Icon(
              IconsaxPlusLinear.search_normal,
              color: Colors.white70,
            ),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.06),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 32,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
