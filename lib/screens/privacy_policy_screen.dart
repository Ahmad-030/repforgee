import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppTheme.bg)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => setState(() => _isLoading = false),
          onNavigationRequest: (NavigationRequest request) {
            // Block any external links from navigating inside the WebView
            if (request.url.startsWith('http') ||
                request.url.startsWith('https')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    // Load HTML from Flutter assets — no internet required
    _loadFromAssets();
  }

  Future<void> _loadFromAssets() async {
    final String html =
    await rootBundle.loadString('assets/Privacy_policy.html');
    await _controller.loadHtmlString(html, baseUrl: 'about:blank');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppTheme.neonGreen, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'REPFORGE',
          style: GoogleFonts.barlow(
            color: AppTheme.neonGreen,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Text(
                  'PRIVACY',
                  style: GoogleFonts.spaceMono(
                    color: AppTheme.textMuted,
                    fontSize: 8,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.border),
        ),
      ),
      body: Stack(
        children: [
          // WebView renders the HTML asset
          WebViewWidget(controller: _controller)
              .animate()
              .fadeIn(duration: 400.ms),

          // Loading overlay — shown until onPageFinished fires
          if (_isLoading)
            Container(
              color: AppTheme.bg,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        color: AppTheme.neonGreen,
                        strokeWidth: 1.5,
                        backgroundColor: AppTheme.border,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'LOADING...',
                      style: GoogleFonts.spaceMono(
                        color: AppTheme.textMuted,
                        fontSize: 9,
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}