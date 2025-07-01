import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:file_picker/file_picker.dart'; // Import the file_picker package
import 'package:path/path.dart' as p; // Import path package for extension
import '../utilities/bg.dart';
import '../utilities/globalvar.dart' as global;
import '../utilities/morphsimcontainer.dart';

// Define a simple class to hold file information
// This makes it easier to manage file name, path, and type together.
class AttachedFile {
  final String name;
  final String path;
  final String type; // e.g., 'file', 'image', 'video', 'audio'
  final String? extension; // Added to store file extension for better icon selection

  AttachedFile({required this.name, required this.path, required this.type, this.extension});
}

class Response extends StatefulWidget {
  const Response({super.key});

  @override
  State<Response> createState() => _ResponseState();
}

class _ResponseState extends State<Response> {
  final TextEditingController _response = TextEditingController();
  // List to store instances of our custom AttachedFile class
  final List<AttachedFile> _attachedFiles = [];

  @override
  void initState() {
    super.initState();
    _response.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _response.removeListener(_onTextChanged);
    _response.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  // Function to show the attachment options menu
  void _showAttachmentOptions(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Attach Media'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context); // Close the action sheet
              _pickFiles(); // Call the new file picker function
            },
            child: const Text('Files'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _handleAttachmentSelection(
                  'Photo/Video'); // Placeholder for image/video picker
            },
            child: const Text('Photos/Videos'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _handleAttachmentSelection(
                  'Voice Note'); // Placeholder for voice note recorder
            },
            child: const Text('Voice Notes'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showCameraOptions(context); // Show nested camera options
            },
            child: const Text('Camera'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context); // Close the action sheet
          },
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  // Function to show nested camera options
  void _showCameraOptions(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Camera Options'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context); // Close camera options
              _handleAttachmentSelection(
                  'Camera Photo'); // Simulate taking a photo
            },
            child: const Text('Take Photo'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context); // Close camera options
              _handleAttachmentSelection(
                  'Camera Video'); // Simulate taking a video
            },
            child: const Text('Record Video'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context); // Close camera options
          },
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  // New function to pick files using file_picker
  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true, // Allow selecting multiple files
        type: FileType.any, // Allow any file type
      );

      if (result != null) {
        setState(() {
          for (PlatformFile platformFile in result.files) {
            // Add the selected file to our _attachedFiles list
            // We ensure platformFile.path is not null before adding
            if (platformFile.path != null) {
              final String? extension = p.extension(platformFile.name).toLowerCase();
              String fileType = 'file';
              if (['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'].contains(extension)) {
                fileType = 'image_video'; // Treat common image formats as image_video for thumbnail
              } else if (['.mp3', '.wav', '.aac', '.flac'].contains(extension)) {
                fileType = 'audio';
              }

              _attachedFiles.add(AttachedFile(
                name: platformFile.name,
                path: platformFile.path!,
                type: fileType,
                extension: extension,
              ));
            }
          }
        });
        print('Selected files: ${_attachedFiles.map((f) => f.name).join(', ')}');
      } else {
        // User canceled the picker
        print('File picking canceled by user.');
      }
    } catch (e) {
      print('Error picking files: $e');
      // You might want to show a user-friendly error message here
    }
  }

  // Placeholder function for other attachment types (e.g., image_picker)
  void _handleAttachmentSelection(String type) {
    setState(() {
      // For demonstration, we'll just add a placeholder.
      // In a real app, you'd integrate with specific pickers (e.g., image_picker).
      String detectedType = 'unknown';
      String? fileExtension; // No real extension for dummy files

      if (type.toLowerCase().contains('photo') ||
          type.toLowerCase().contains('video') ||
          type.toLowerCase().contains('camera')) {
        detectedType = 'image_video';
        // For dummy images, let's pretend it's a PNG for testing the issue
        fileExtension = '.png';
      } else if (type.toLowerCase().contains('voice')) {
        detectedType = 'audio';
      }
      // You can add more specific dummy files with extensions if needed for testing different icons
      if (type == 'Files') {
        fileExtension = '.txt'; // Example for dummy text file
      }

      _attachedFiles.add(AttachedFile(
        name: '$type: ${DateTime.now().second}',
        path: 'dummy_path_${DateTime.now().millisecondsSinceEpoch}',
        type: detectedType,
        extension: fileExtension,
      ));
    });
    print('Attached: $type');
  }

  // Function to remove an attached file
  void _removeAttachedFile(int index) {
    setState(() {
      _attachedFiles.removeAt(index);
    });
  }

  // Helper function to get a HugeIconData based on file type and extension
  IconData _getHugeIconForFileType(AttachedFile file) {
    // Check if the file is truly an image and has a valid path to try to load
    final bool isActualImage = file.type == 'image_video' && File(file.path).existsSync();

    if (isActualImage) {
      // If it's a real image that can be loaded, we return a general image icon if no preview is shown
      return HugeIcons.strokeRoundedImage01;
    } else if (file.type == 'audio') {
      return HugeIcons.strokeRoundedMic01;
    } else if (file.type == 'file') {
      switch (file.extension) {
        case '.pdf':
          return HugeIcons.strokeRoundedPdf02;
        case '.txt':
          return HugeIcons.strokeRoundedQuillWrite02; // A generic document icon for TXT
        case '.doc':
        case '.docx':
          return HugeIcons.strokeRoundedDocumentAttachment;
        case '.xls':
        case '.xlsx':
          return HugeIcons.strokeRoundedChartColumn;
        case '.ppt':
        case '.pptx':
          return HugeIcons.strokeRoundedPresentation03;
        case '.zip':
        case '.rar':
          return HugeIcons.strokeRoundedFileZip;
        case '.dart': // Specific for .dart files
          return HugeIcons.strokeRoundedCode; // Assuming a code-related icon
        case '.json': // Specific for .json files
          return HugeIcons.strokeRoundedCodeCircle; // Another code-related icon
        default:
          return HugeIcons.strokeRoundedFile01; // Generic file icon
      }
    }
    return HugeIcons.strokeRoundedFileUnknown; // Default fallback icon
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: MorphedContainer(
        color: CupertinoColors.black,
        border: Border.all(color: CupertinoColors.black),
        width: double.maxFinite,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              // Display attached files if any
              if (_attachedFiles.isNotEmpty)
                SizedBox(
                  height: 120, // Give a fixed height for the horizontal list
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _attachedFiles.length,
                    itemBuilder: (context, index) {
                      final AttachedFile file = _attachedFiles[index];
                      // Determine if it's an image that can actually be loaded from a file path
                      final bool canShowImagePreview =
                          file.type == 'image_video' && File(file.path).existsSync();

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Stack(
                          children: [
                            Container(
                              width: 100, // Fixed width for each attachment card
                              height: 100, // Fixed height for each attachment card
                              decoration: BoxDecoration(
                                color: CupertinoColors.systemGrey5.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                                // Add a border to visually define the card
                                border: Border.all(
                                  color: CupertinoColors.systemGrey4.withOpacity(0.7),
                                  width: 1.0,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (canShowImagePreview)
                                  // Image.file for actual image previews
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(file.path),
                                        width: 80,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        // Add a background color to the image's "canvas"
                                        // This helps with transparency issues by providing a solid base
                                        // For PNGs, if there are transparent areas, they will show this color.
                                        // Make sure this color matches your desired aesthetic.
                                        color: CupertinoColors.systemGrey5.withOpacity(0.5),
                                        colorBlendMode: BlendMode.dstATop, // Or other blend modes like screen, overlay
                                        errorBuilder: (context, error, stackTrace) =>
                                            HugeIcon(
                                              icon: HugeIcons.strokeRoundedImage01, // Fallback to general image icon
                                              color: CupertinoColors.white,
                                              size: 40,
                                            ),
                                      ),
                                    )
                                  else
                                  // HugeIcon for other file types or failed image loading
                                    HugeIcon(
                                      icon: _getHugeIconForFileType(file),
                                      color: CupertinoColors.white,
                                      size: 40,
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    file.name.length > 10
                                        ? '${file.name.substring(0, 7)}...'
                                        : file.name,
                                    style: const TextStyle(
                                      color: CupertinoColors.white,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // Cross button always visible
                            Positioned(
                              top: 5,
                              right: 5,
                              child: GestureDetector(
                                onTap: () => _removeAttachedFile(index),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: CupertinoColors.systemGrey, // Darker background for visibility
                                    shape: BoxShape.circle,
                                  ),
                                  child: const HugeIcon(
                                    icon: HugeIcons.strokeRoundedCancel01,
                                    color: CupertinoColors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Attachment/Link icon
                  GestureDetector(
                    onTap: () => _showAttachmentOptions(context),
                    child: Container(
                      color: CupertinoColors.black,
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedLink02,
                        color: CupertinoColors.activeBlue,
                        size: global.SizeConfig.screenHeight * 0.03,
                      ),
                    ),
                  ),
                  Flexible(
                    child: CupertinoTextField(
                      onTapOutside: (value) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      style: const TextStyle(
                        fontFamily: 'SF',
                        fontSize: 16,
                        fontStyle: FontStyle.normal,
                        color: CupertinoColors.white,
                      ),
                      autocorrect: true,
                      minLines: 1,
                      placeholder: "Express Your Feelingsss..!!",
                      placeholderStyle: const TextStyle(
                        color: CupertinoColors.systemGrey,
                      ),
                      decoration: BoxDecoration(
                        color: CupertinoColors.darkBackgroundGray.withAlpha(50),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      controller: _response,
                      maxLines: 6,
                    ),
                  ),
                  // Conditional microphone/send icon
                  _response.text.isEmpty
                      ? GestureDetector(
                    onTap: () {
                      print('Microphone icon tapped');
                      // Implement voice recording logic here
                    },
                    child: Container(
                      color: CupertinoColors.black,
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedMic01,
                        color: CupertinoColors.activeBlue,
                        size: global.SizeConfig.screenHeight * 0.03,
                      ),
                    ),
                  )
                      : GestureDetector(
                    onTap: () {
                      print('Send icon tapped. Message: ${_response.text}');
                      // Implement send message logic here
                      _response.clear(); // Clear text after sending
                      if (_attachedFiles.isNotEmpty) {
                        setState(() {
                          _attachedFiles.clear(); // Clear attachments after sending
                        });
                      }
                    },
                    child: Container(
                      color: CupertinoColors.black,
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedSent,
                        color: CupertinoColors.activeBlue,
                        size: global.SizeConfig.screenHeight * 0.03,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}