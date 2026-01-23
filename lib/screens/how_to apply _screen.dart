import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../constants/colors.dart';
import '../services/api_service.dart';
import '../widgets/modern_text_field.dart';
import '../widgets/premium_background.dart';

class HowToApplyScreen extends StatefulWidget {
  const HowToApplyScreen({super.key});

  @override
  State<HowToApplyScreen> createState() => _HowToApplyScreenState();
}

class _HowToApplyScreenState extends State<HowToApplyScreen> {
  late YoutubePlayerController _controller;
  final TextEditingController _searchController = TextEditingController();

  // STATE
  bool _isLoading = true;
  bool _isPlayerReady = false;
  bool _isPlaying = false;
  bool _isFullScreen = false;
  double _playbackSpeed = 1.0;

  // CONTROLS
  bool _showControls = false;
  Timer? _controlsTimer;

  // DATA
  List<dynamic> _videoList = [];
  String? _errorMessage;
  String currentTitle = "";
  String currentDescription = "";
  int currentIndex = 0;
  int? currentPlayingId;
  String _currentThumbnailUrl = "";

  @override
  void initState() {
    super.initState();
    _initializeController();
    _fetchVideos();
  }

  void _initializeController() {
    _controller = YoutubePlayerController(
      initialVideoId: '',
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: false,
        hideControls: true, // We draw our own controls
        disableDragSeek: true,
        loop: true,
        isLive: false,
        forceHD: false,
        controlsVisibleAtStart: false,
        // Removed modestBranding as it caused the error
      ),
    )..addListener(_listener);
  }

  void _listener() {
    if (_isPlayerReady && mounted) {
      setState(() {
        _isPlaying = _controller.value.isPlaying;
      });
    }
  }

  Future<void> _fetchVideos({String? query}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await ApiService.getGuidelineVideos(query: query);

    if (mounted) {
      if (response['status'] == 'success') {
        final List<dynamic> videos = response['data'];
        setState(() {
          _videoList = videos;
          _isLoading = false;
        });

        if (videos.isNotEmpty && _isPlayerReady) {
          _playVideo(0);
        }
      } else {
        setState(() {
          _errorMessage = response['message'];
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    _controlsTimer?.cancel();
    _controller.removeListener(_listener);
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // --- FULL SCREEN LOGIC ---
  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    }
  }

  void _cyclePlaybackSpeed() {
    double newSpeed = 1.0;
    if (_playbackSpeed == 1.0) newSpeed = 1.5;
    else if (_playbackSpeed == 1.5) newSpeed = 2.0;
    else if (_playbackSpeed == 2.0) newSpeed = 0.5;
    else newSpeed = 1.0;

    _controller.setPlaybackRate(newSpeed);
    setState(() {
      _playbackSpeed = newSpeed;
    });
  }

  void _playVideo(int index) {
    if (index >= _videoList.length) return;

    final video = _videoList[index];
    String rawId = video['video_id'] ?? "";
    String cleanId = YoutubePlayer.convertUrlToId(rawId.trim()) ?? rawId.trim();

    if (cleanId.isEmpty) return;

    setState(() {
      currentPlayingId = video['id'];
      currentIndex = index;
      currentTitle = video['title'] ?? "Unknown Title";
      currentDescription = video['description'] ?? "";
      _currentThumbnailUrl = video['thumbnail_url'] ?? "";
      _isPlaying = true;
      _showControls = true;
    });

    _startHideTimer();

    if (_isPlayerReady) {
      _controller.load(cleanId);
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) _startHideTimer();
  }

  void _startHideTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _togglePlay() {
    if (_controller.value.isPlaying) {
      _controller.pause();
      setState(() => _showControls = true);
      _controlsTimer?.cancel();
    } else {
      _controller.play();
      _startHideTimer();
    }
  }

  void _seek(int seconds) {
    final current = _controller.value.position;
    final newPos = current + Duration(seconds: seconds);
    _controller.seekTo(newPos);
    _startHideTimer();
  }

  // --- STACK LAYOUT PREVENTS RELOAD ---
  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;
    final double headerHeight = 80 + topPadding;

    // Calculate Player Position & Size
    final double playerTop = _isFullScreen ? 0 : headerHeight + 20;
    final double playerLeft = _isFullScreen ? 0 : 20;
    final double playerRight = _isFullScreen ? 0 : 20;
    final double playerHeight = _isFullScreen
        ? MediaQuery.of(context).size.height
        : 220;

    return PopScope(
      canPop: !_isFullScreen,
      onPopInvoked: (didPop) {
        if (_isFullScreen) _toggleFullScreen();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // 1. BACKGROUND CONTENT (Hidden in Full Screen)
            IgnorePointer(
              ignoring: _isFullScreen,
              child: Opacity(
                opacity: _isFullScreen ? 0 : 1,
                child: PremiumBackground(
                  child: Column(
                    children: [
                      SizedBox(height: playerTop + 220 + 20),

                      Expanded(
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _errorMessage != null
                            ? Center(child: Text(_errorMessage!, style: const TextStyle(color: AppColors.error)))
                            : SingleChildScrollView(
                          padding: EdgeInsets.zero,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildVideoInfo(),
                              _buildVideoList(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 2. THE HEADER (Only in Portrait)
            if (!_isFullScreen)
              Positioned(
                top: 0, left: 0, right: 0,
                child: _buildGlassHeader(topPadding),
              ),

            // 3. THE PLAYER (Animated Position)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              top: playerTop,
              left: playerLeft,
              right: playerRight,
              height: playerHeight,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: _isFullScreen ? BorderRadius.zero : BorderRadius.circular(20),
                  boxShadow: _isFullScreen ? [] : [const BoxShadow(color: Colors.black45, blurRadius: 15, offset: Offset(0, 8))],
                ),
                clipBehavior: Clip.antiAlias,
                child: _buildPlayerStack(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerStack() {
    return Stack(
      fit: StackFit.expand,
      children: [
        YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: false,
          bottomActions: const [], topActions: const [],
          thumbnail: Container(
            color: Colors.black,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_currentThumbnailUrl.isNotEmpty)
                  Image.network(
                    _currentThumbnailUrl, fit: BoxFit.cover, width: double.infinity, height: double.infinity,
                    errorBuilder: (c,o,s) => Container(color: Colors.black),
                  ),
                Container(color: Colors.black.withOpacity(0.3)),
              ],
            ),
          ),
          onReady: () {
            _isPlayerReady = true;
            if (_videoList.isNotEmpty && currentPlayingId == null) {
              _playVideo(0);
            }
          },
        ),

        // TAP DETECTOR
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _toggleControls,
          child: Container(color: Colors.transparent),
        ),

        // CUSTOM CONTROLS OVERLAY
        AnimatedOpacity(
          opacity: _showControls ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: IgnorePointer(
            ignoring: !_showControls,
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Stack(
                children: [
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          iconSize: 36, icon: const Icon(Icons.replay_10_rounded, color: Colors.white),
                          onPressed: () => _seek(-10),
                        ),
                        const SizedBox(width: 25),
                        GestureDetector(
                          onTap: _togglePlay,
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 15)]
                            ),
                            child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow_rounded, color: Colors.white, size: 45),
                          ),
                        ),
                        const SizedBox(width: 25),
                        IconButton(
                          iconSize: 36, icon: const Icon(Icons.forward_10_rounded, color: Colors.white),
                          onPressed: () => _seek(10),
                        ),
                      ],
                    ),
                  ),

                  // PLAYBACK SPEED
                  Positioned(
                    top: 20, right: 20,
                    child: GestureDetector(
                      onTap: _cyclePlaybackSpeed,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white24)),
                        child: Text("${_playbackSpeed}x", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),

                  // BOTTOM BAR
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: _isFullScreen ? 20 : 10),
                      decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [Colors.transparent, Colors.black87], begin: Alignment.topCenter, end: Alignment.bottomCenter)
                      ),
                      child: Row(
                        children: [
                          Text(
                            "${_controller.value.position.inMinutes}:${(_controller.value.position.inSeconds % 60).toString().padLeft(2, '0')}",
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 3,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                                activeTrackColor: AppColors.primary, inactiveTrackColor: Colors.white24, thumbColor: Colors.white,
                              ),
                              child: Slider(
                                value: _controller.value.position.inSeconds.toDouble(),
                                min: 0.0,
                                max: _controller.metadata.duration.inSeconds.toDouble() > 0 ? _controller.metadata.duration.inSeconds.toDouble() : 1.0,
                                onChanged: (value) {
                                  _controller.seekTo(Duration(seconds: value.toInt()));
                                  _startHideTimer();
                                },
                              ),
                            ),
                          ),
                          Text(
                            "${_controller.metadata.duration.inMinutes}:${(_controller.metadata.duration.inSeconds % 60).toString().padLeft(2, '0')}",
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: Icon(_isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen, color: Colors.white),
                            onPressed: _toggleFullScreen,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(currentTitle.isNotEmpty ? currentTitle : "Loading...", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(currentDescription, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
          const SizedBox(height: 20),
          Divider(thickness: 1, color: AppColors.primary.withOpacity(0.1)),
        ],
      ),
    );
  }

  Widget _buildVideoList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Video Tutorials", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
              Text("${_videoList.length} results", style: const TextStyle(color: AppColors.textLight, fontSize: 13))
            ],
          ),
        ),
        _videoList.isEmpty
            ? const Padding(padding: EdgeInsets.all(40.0), child: Center(child: Text("No videos found.")))
            : ListView.builder(
          padding: const EdgeInsets.only(bottom: 20),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _videoList.length,
          itemBuilder: (context, index) {
            final video = _videoList[index];
            final isActive = (video['id'] == currentPlayingId);
            return GestureDetector(
              onTap: () => _playVideo(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary.withOpacity(0.05) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isActive ? AppColors.primary : Colors.transparent, width: 1.5),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.network(
                            video['thumbnail_url'] ?? "", width: 100, height: 60, fit: BoxFit.cover,
                            errorBuilder: (c, o, s) => Container(width: 100, height: 60, color: Colors.grey[200], child: const Icon(Icons.play_circle_outline, color: Colors.grey)),
                          ),
                          if (!isActive)
                            Container(
                              decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
                            )
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        video['title'] ?? "No Title", maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: isActive ? AppColors.primary : AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGlassHeader(double topPadding) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(top: topPadding + 15, bottom: 20, left: 20, right: 20),
          decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.85),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]
          ),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
                  const SizedBox(width: 8),
                  const Text("How to Apply", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                ],
              ),
              const SizedBox(height: 15),
              ModernTextField(
                controller: _searchController, hintText: "Search tutorials...", prefixIcon: Icons.search,
                textInputAction: TextInputAction.search, onFieldSubmitted: (value) => _fetchVideos(query: value),
              ),
            ],
          ),
        ),
      ),
    );
  }
}