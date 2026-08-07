import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../../../profile/data/repositories/events_repository.dart';
import '../../../feed/presentation/providers/feed_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/buttons/primary_button.dart';

class CreateEventScreen extends ConsumerStatefulWidget {
  final File? initialMedia;
  final bool isInitialMediaImage;

  const CreateEventScreen({
    super.key,
    this.initialMedia,
    this.isInitialMediaImage = false,
  });

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  bool _isLoading = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();
  final TextEditingController _captionController = TextEditingController();
  
  File? _selectedImage;
  File? _selectedVideo;
  VideoPlayerController? _videoController;
  final ImagePicker _picker = ImagePicker();
  bool _isPickingMedia = false;

  final List<Map<String, dynamic>> _tiers = [
    {'name': 'General Admission', 'price': '5000', 'capacity': '100'}
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialMedia != null) {
      if (widget.isInitialMediaImage) {
        _selectedImage = widget.initialMedia;
      } else {
        _selectedVideo = widget.initialMedia;
        _initializeVideo(_selectedVideo!);
      }
    }
  }

  Future<void> _initializeVideo(File file) async {
    _videoController = VideoPlayerController.file(file);
    await _videoController!.initialize();
    _videoController!.setLooping(true);
    if (mounted) setState(() {});
    _videoController!.play();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _venueController.dispose();
    _captionController.dispose();
    _videoController?.dispose();
    super.dispose();
  }
  
  Future<void> _pickMedia({required bool isVideo}) async {
    setState(() {
      _isPickingMedia = true;
    });
    
    try {
      final XFile? media = isVideo ? await _picker.pickVideo(source: ImageSource.gallery) : await _picker.pickImage(source: ImageSource.gallery);
      
      if (media != null) {
        final file = File(media.path);
        
        setState(() {
          if (isVideo) {
            _selectedVideo = file;
          } else {
            _selectedImage = file;
          }
        });
        
        if (isVideo) {
          if (_videoController != null) {
            await _videoController!.dispose();
            _videoController = null;
          }
          await _initializeVideo(file);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking media: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPickingMedia = false;
        });
      }
    }
  }

  Widget _buildGlassmorphicCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(20),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withAlpha(40), width: 1),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildGlassTextField({
    required String hint, 
    required IconData icon, 
    required TextEditingController controller,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(40),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.white70, size: 20),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white60),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildTicketTier({required Map<String, dynamic> tier, required int index}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(40),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentCta.withAlpha(100), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tier ${index + 1}', style: const TextStyle(color: AppColors.accentCta, fontWeight: FontWeight.bold, fontSize: 14)),
              if (_tiers.length > 1)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _tiers.removeAt(index);
                    });
                  },
                  child: const Icon(Icons.close, color: Colors.white54, size: 20),
                )
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: TextEditingController(text: tier['name'])..selection = TextSelection.collapsed(offset: tier['name'].length),
                    onChanged: (val) => tier['name'] = val,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Tier Name (e.g. VIP)',
                      hintStyle: TextStyle(color: Colors.white38),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: TextEditingController(text: tier['price'])..selection = TextSelection.collapsed(offset: tier['price'].length),
                    onChanged: (val) => tier['price'] = val,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Price (₦)',
                      hintStyle: TextStyle(color: Colors.white38),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. Background Video or Placeholder
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                if (_videoController == null && _selectedImage == null) {
                  _pickMedia(isVideo: false); // Default to picking image if empty
                } else if (_videoController != null) {
                  setState(() {
                    if (_videoController!.value.isPlaying) {
                      _videoController!.pause();
                    } else {
                      _videoController!.play();
                    }
                  });
                }
              },
              child: Container(
                color: const Color(0xFF111111),
                child: _selectedVideo != null && _videoController != null && _videoController!.value.isInitialized
                  ? FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _videoController!.value.size.width,
                        height: _videoController!.value.size.height,
                        child: VideoPlayer(_videoController!),
                      ),
                    )
                  : (_selectedImage != null 
                      ? Image.file(_selectedImage!, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isPickingMedia)
                              const CircularProgressIndicator(color: AppColors.accentCta)
                            else ...[
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withAlpha(15),
                                  border: Border.all(color: Colors.white.withAlpha(30)),
                                ),
                                child: const Icon(Icons.movie_creation_outlined, color: Colors.white, size: 56),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Tap to upload event cover',
                                style: TextStyle(
                                  color: Colors.white, 
                                  fontSize: 18, 
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Vertical media (9:16) performs best',
                                style: TextStyle(color: Colors.white60, fontSize: 13),
                              ),
                            ]
                          ],
                        )),
              ),
            ),
          ),

          // 2. Gradient Overlay for readability
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withAlpha(150), 
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withAlpha(150),
                      Colors.black.withAlpha(240),
                      Colors.black, 
                    ],
                    stops: const [0.0, 0.15, 0.4, 0.7, 0.9, 1.0],
                  ),
                ),
              ),
            ),
          ),
          
          // Show play icon if paused
          if (_videoController != null && _videoController!.value.isInitialized && !_videoController!.value.isPlaying)
            const Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: Icon(Icons.play_arrow_rounded, color: Colors.white54, size: 80),
                ),
              ),
            ),

          // 3. Scrollable Form Content
          SafeArea(
            child: Column(
              children: [
                // Top Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(100),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 24),
                        ),
                      ),
                      const Spacer(),
                      if (_selectedImage != null || _selectedVideo != null)
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) => Container(
                                padding: const EdgeInsets.all(20),
                                decoration: const BoxDecoration(
                                  color: AppColors.surfaceElevated,
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('Change Media', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 20),
                                    ListTile(
                                      leading: const Icon(Icons.image, color: Colors.white),
                                      title: const Text('Change Cover Image (Required)', style: TextStyle(color: Colors.white)),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _pickMedia(isVideo: false);
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.movie, color: Colors.white),
                                      title: const Text('Change Reel Video (Optional)', style: TextStyle(color: Colors.white)),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _pickMedia(isVideo: true);
                                      },
                                    ),
                                    if (_selectedVideo != null)
                                      ListTile(
                                        leading: const Icon(Icons.delete, color: AppColors.error),
                                        title: const Text('Remove Video', style: TextStyle(color: AppColors.error)),
                                        onTap: () {
                                          Navigator.pop(context);
                                          setState(() {
                                            _selectedVideo = null;
                                            _videoController?.dispose();
                                            _videoController = null;
                                          });
                                        },
                                      ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(120),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withAlpha(40)),
                            ),
                            child: const Row(
                              children: [
                                 Icon(Icons.flip_camera_ios_outlined, color: Colors.white, size: 16),
                                 SizedBox(width: 6),
                                 Text('Change', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Drafts', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ],
                  ),
                ),
                
                // Form
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.35), 
                      
                      // Caption
                      TextField(
                        controller: _captionController,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                        maxLines: 4,
                        minLines: 1,
                        decoration: const InputDecoration(
                          hintText: 'Write a captivating caption...\n#LagosNights #Afrobeats',
                          hintStyle: TextStyle(color: Colors.white70, fontSize: 18),
                          border: InputBorder.none,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Glassmorphic Details Card
                      _buildGlassmorphicCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text('Event Details', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildGlassTextField(hint: 'Event Name', icon: Icons.celebration, controller: _nameController),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildGlassTextField(
                                    hint: 'Date', 
                                    icon: Icons.calendar_today, 
                                    controller: _dateController,
                                    readOnly: true,
                                    onTap: () async {
                                      final date = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.now().add(const Duration(days: 365)),
                                      );
                                      if (date != null) {
                                        _dateController.text = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildGlassTextField(
                                    hint: 'Time', 
                                    icon: Icons.access_time, 
                                    controller: _timeController,
                                    readOnly: true,
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        backgroundColor: Colors.transparent,
                                        builder: (BuildContext builder) {
                                          return Container(
                                            height: 280,
                                            decoration: const BoxDecoration(
                                              color: AppColors.surfaceElevated,
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(24),
                                                topRight: Radius.circular(24),
                                              ),
                                            ),
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(right: 16, top: 16),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      TextButton(
                                                        onPressed: () => Navigator.of(context).pop(),
                                                        child: const Text('Done', style: TextStyle(color: AppColors.accentCta, fontSize: 16, fontWeight: FontWeight.bold)),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  child: CupertinoTheme(
                                                    data: const CupertinoThemeData(
                                                      textTheme: CupertinoTextThemeData(
                                                        dateTimePickerTextStyle: TextStyle(color: Colors.white, fontSize: 20),
                                                      ),
                                                    ),
                                                    child: CupertinoDatePicker(
                                                      mode: CupertinoDatePickerMode.time,
                                                      initialDateTime: DateTime.now(),
                                                      onDateTimeChanged: (DateTime newDateTime) {
                                                        final timeStr = TimeOfDay.fromDateTime(newDateTime).format(context);
                                                        _timeController.text = timeStr;
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildGlassTextField(hint: 'Venue or Location', icon: Icons.location_on, controller: _venueController),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tickets Card
                      _buildGlassmorphicCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.local_activity_outlined, color: Colors.white, size: 20),
                                    SizedBox(width: 8),
                                    Text('Tickets', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _tiers.add({'name': '', 'price': '', 'capacity': '100'});
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentCta.withAlpha(40),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppColors.accentCta),
                                      ),
                                      child: const Text('Add Tier', style: TextStyle(color: AppColors.accentCta, fontSize: 12, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ..._tiers.asMap().entries.map((entry) {
                                return _buildTicketTier(tier: entry.value, index: entry.key);
                              }).toList(),
                            ],
                          ),
                        ),
                        
                      const SizedBox(height: 32),

                      // Post Button
                      PrimaryButton(
                        text: _isLoading ? 'Creating Event...' : 'Post & List Event',
                        onPressed: _isLoading ? () {} : () async {
                          if (_nameController.text.isEmpty || _dateController.text.isEmpty || _timeController.text.isEmpty || _selectedImage == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please fill all required details and select a cover image')),
                            );
                            return;
                          }
                          
                          setState(() {
                            _isLoading = true;
                          });
                          
                          final eventsRepo = ref.read(eventsRepositoryProvider);
                          final title = _nameController.text;
                          final description = _captionController.text;
                          final date = _dateController.text;
                          final time = _timeController.text;
                          final location = _venueController.text;
                          
                          try {
                            String? thumbnailUrl;
                            if (_selectedImage != null) {
                              thumbnailUrl = await eventsRepo.uploadMedia(_selectedImage!);
                            }
                            
                            String? mediaUrl;
                            if (_selectedVideo != null) {
                              mediaUrl = await eventsRepo.uploadMedia(_selectedVideo!);
                            }
                            
                            final success = await eventsRepo.createEvent(
                              title: title,
                              description: description,
                              date: date,
                              time: time,
                              location: location,
                              price: _tiers.isNotEmpty ? _tiers.first['price'] : '0',
                              mediaUrl: mediaUrl,
                              thumbnailUrl: thumbnailUrl,
                              tiers: _tiers,
                            );
                            
                            if (success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Event created successfully!')),
                              );
                              // Refresh the feed to show the newly created event
                              ref.invalidate(feedProvider);
                              Navigator.pop(context);
                            } else if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Failed to create event')),
                              );
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          } catch (e) {
                            debugPrint('Event creation failed: $e');
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
