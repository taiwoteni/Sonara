import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gap/gap.dart';
import 'package:sonara/core/utils/colors.dart';
import 'package:sonara/core/utils/theme.dart';
import 'package:sonara/core/utils/types.dart';

class CreatePlaylistDialog extends StatefulWidget {
  final VoidCallback? onCancel;
  final void Function(String text, BoolCallback load)? onCreate;

  const CreatePlaylistDialog({super.key, this.onCancel, this.onCreate});

  @override
  State<CreatePlaylistDialog> createState() => _CreatePlaylistDialogState();
}

class _CreatePlaylistDialogState extends State<CreatePlaylistDialog> {
  final TextEditingController _nameController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.background_2,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New Playlist',
            style: context.spaceGroteskBold.copyWith(
              color: Colors.white,
              fontSize: 20.0,
            ),
          ),
          Gap(10),
          const Text(
            'Enter a name for your new playlist',
            style: TextStyle(color: Colors.white70, fontSize: 14.0),
          ),
          const SizedBox(height: 20.0),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Playlist name..',
              hintStyle: context.spaceGroteskRegular.copyWith(
                color: Colors.white54,
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.03),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
            ),
            style: context.spaceGroteskRegular.copyWith(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  if (widget.onCancel != null) {
                    widget.onCancel!();
                  }
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 13, color: Colors.white60),
                ),
              ),
              const SizedBox(width: 16.0),
              ElevatedButton(
                onPressed: () {
                  final name = _nameController.text.trim();
                  if (name.isNotEmpty && widget.onCreate != null) {
                    widget.onCreate!(
                      name,
                      (_) => setState(() => isLoading = !isLoading),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  enableFeedback: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: isLoading
                    ? SpinKitFadingFour(color: Colors.black, size: 16)
                    : Text(
                        'Create',
                        style: context.lufgaSemiBold.copyWith(
                          fontSize: 13,
                          color: Colors.black,
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
