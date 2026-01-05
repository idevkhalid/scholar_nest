import 'dart:ui'; // Required for Glass Effect
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../constants/colors.dart';
import '../services/api_service.dart';

class HowToApplyScreen extends StatefulWidget {
  const HowToApplyScreen({super.key});

  @override
  State<HowToApplyScreen> createState() => _HowToApplyScreenState();
}

class _HowToApplyScreenState extends State<HowToApplyScreen> {
  late YoutubePlayerController _controller;
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  List<dynamic> _videoList = [];
  String? _errorMessage;

  // Track current video info
  String currentTitle = "";
  String currentDescription = "";
  int currentIndex = 0;
  int? currentPlayingId;

  @override
  void initState() {
    super.initState();
    _initializeEmptyController();
    _fetchVideos(); // Fetch initial list (empty query)
  }

  // Helper to init controller safely
  void _initializeEmptyController() {
    _controller = YoutubePlayerController(
      initialVideoId: '',
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    );
  }

  // --- 1. Fetch Data (Accepts optional search query) ---
  Future<void> _fetchVideos({String? query}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Call API with search query
    final response = await ApiService.getGuidelineVideos(query: query);

    if (mounted) {
      if (response['status'] == 'success') {
        final List<dynamic> videos = response['data'];

        setState(() {
          _videoList = videos;
          _isLoading = false;
        });

        // Automatically play the first video if list is not empty AND no video is currently playing
        if (videos.isNotEmpty && currentPlayingId == null) {
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
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // --- 2. Switch Video Logic ---
  void _playVideo(int index) {
    if (index >= _videoList.length) return;

    final video = _videoList[index];
    final String newVideoId = video['video_id'] ?? "";
    final int videoId = video['id'];

    if (currentPlayingId == videoId) return; // Already playing

    if (newVideoId.isNotEmpty) {
      _controller.load(newVideoId);
      setState(() {
        currentPlayingId = videoId;
        currentIndex = index;
        currentTitle = video['title'] ?? "Unknown Title";
        currentDescription = video['description'] ?? "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: YoutubePlayerBuilder(
          player: YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: AppColors.primary,
            progressColors: ProgressBarColors(
              playedColor: AppColors.primary,
              handleColor: Colors.amber,
            ),
          ),
          builder: (context, player) {
            return Column(
              children: [
                // --- GLASS HEADER WITH SEARCH ---
                _buildGlassHeader(topPadding),

                // --- CONTENT AREA ---
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage != null
                      ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
                      : SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 20, bottom: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // 1. VIDEO PLAYER
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: currentPlayingId == null
                                ? Container(
                                height: 200,
                                color: Colors.black12,
                                child: const Center(child: Text("Select a video to play"))
                            )
                                : player,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 2. VIDEO INFO
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentTitle.isNotEmpty ? currentTitle : "Select a Video",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currentDescription,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),
                        Divider(thickness: 1, indent: 20, endIndent: 20, color: Colors.grey.withOpacity(0.3)),

                        // 3. LIST HEADER
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Videos List",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                "${_videoList.length} results",
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              )
                            ],
                          ),
                        ),

                        // 4. VIDEO LIST
                        _videoList.isEmpty
                            ? const Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Center(child: Text("No videos found matching your search.")),
                        )
                            : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 20),
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _videoList.length,
                          itemBuilder: (context, index) {
                            final video = _videoList[index];
                            final isActive = (video['id'] == currentPlayingId);
                            final thumbnailUrl = video['thumbnail_url'] ?? "";

                            return GestureDetector(
                              onTap: () => _playVideo(index),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isActive ? AppColors.primary.withOpacity(0.1) : Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  border: isActive
                                      ? Border.all(color: AppColors.primary, width: 1.5)
                                      : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    // Thumbnail
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        thumbnailUrl,
                                        width: 100,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, o, s) => Container(
                                          width: 100, height: 60, color: Colors.grey[300],
                                          child: const Icon(Icons.play_circle_outline, color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    // Text Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            video['title'] ?? "No Title",
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color: isActive ? AppColors.primary : Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isActive)
                                      Icon(Icons.equalizer, color: AppColors.primary),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- REUSABLE GLASS HEADER WITH SEARCH ---
  Widget _buildGlassHeader(double topPadding) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(25),
        bottomRight: Radius.circular(25),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: topPadding + 10,
            bottom: 20,
            left: 20,
            right: 20,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(120),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
            border: Border.all(
              color: Colors.white.withAlpha(60),
            ),
          ),
          child: Column(
            children: [
              // Row 1: Back Button + Title
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "How to Apply",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // Row 2: Search Bar
              Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) => _fetchVideos(query: value),
                  decoration: InputDecoration(
                    hintText: "Search videos...",
                    hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: AppColors.primary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        _fetchVideos(); // Clear search and fetch all
                      },
                    )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  ),
                  onChanged: (val) {
                    setState(() {}); // Updates the UI to show/hide the clear 'x' button
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}