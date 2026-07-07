import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const FlipTextApp());
}

class FlipTextApp extends StatelessWidget {
  const FlipTextApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flip Text',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      themeMode: ThemeMode.system,
      home: const FlipTextPage(),
    );
  }
}

class FlipTextPage extends StatefulWidget {
  const FlipTextPage({super.key});

  @override
  State<FlipTextPage> createState() => _FlipTextPageState();
}

class _FlipTextPageState extends State<FlipTextPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  String _flippedText = '';
  bool _isFlipped = false;
  bool _isCopied = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  // Mapping normal a-z, A-Z, 0-9 + common chars to upside-down unicode
  static const Map<String, String> _upsideDownMap = {
    'a': '\u0250', 'b': 'q', 'c': '\u0254', 'd': 'p', 'e': '\u01DD',
    'f': '\u025F', 'g': '\u01F9', 'h': '\u0265', 'i': '\u0131', 'j': '\u027E',
    'k': '\u029E', 'l': '\u05DF', 'm': '\u026F', 'n': 'u', 'o': 'o',
    'p': 'd', 'q': 'b', 'r': '\u0279', 's': 's', 't': '\u0287',
    'u': 'n', 'v': '\u028C', 'w': '\u028D', 'x': 'x', 'y': '\u028E',
    'z': 'z',
    'A': '\u2C6F', 'B': '\u13F4', 'C': '\u0186', 'D': '\u15E1', 'E': '\u018E',
    'F': '\u2132', 'G': '\u05E4', 'H': 'H', 'I': 'I', 'J': '\u017F',
    'K': 'K', 'L': 'L', 'M': 'W', 'N': 'N', 'O': 'O',
    'P': '\u0500', 'Q': 'Q', 'R': 'R', 'S': 'S', 'T': '\u152D',
    'U': '\u2229', 'V': '\u039B', 'W': 'M', 'X': 'X', 'Y': '\u2144',
    'Z': 'Z',
    '0': '0', '1': '\u0196', '2': '\u018F', '3': '\u0190', '4': '\u07C9',
    '5': '5', '6': '9', '7': '\u2C62', '8': '8', '9': '6',
    ',': "'", '.': '\u02D9', '!': 'i', '?': '\u00BF', "'": ',',
    '"': '\u201E', '(': ')', ')': '(', '[': ']', ']': '[',
    '{': '}', '}': '{', '<': '>', '>': '<', '&': '\u214B',
    '_': '\u203E', ';': '\u061B', ':': '\u0589',
    ' ': ' ',
  };

  String _flipVertical(String text) {
    return text
        .split('')
        .map((ch) => _upsideDownMap[ch] ?? ch)
        .toList()
        .reversed
        .join('');
  }

  void _onFlip() {
    final input = _inputController.text;
    if (input.trim().isEmpty) {
      _showSnackBar('Masukkan teks terlebih dahulu');
      return;
    }

    setState(() {
      _flippedText = _flipVertical(input);
      _isFlipped = true;
      _isCopied = false;
    });

    _animController.forward(from: 0);
  }

  void _onCopy() {
    if (_flippedText.isEmpty) return;

    Clipboard.setData(ClipboardData(text: _flippedText));
    setState(() => _isCopied = true);
    _showSnackBar('Teks berhasil disalin!');
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _clearAll() {
    _inputController.clear();
    setState(() {
      _flippedText = '';
      _isFlipped = false;
      _isCopied = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flip Text'),
        centerTitle: true,
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
        actions: [
          if (_isFlipped)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Reset',
              onPressed: _clearAll,
            ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              cs.surface,
              cs.surfaceContainerLowest,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                _buildHeader(cs),
                const SizedBox(height: 32),

                // Input section
                _buildInputSection(cs, theme),
                const SizedBox(height: 20),

                // Flip button
                _buildFlipButton(cs, theme),
                const SizedBox(height: 32),

                // Result section
                if (_isFlipped) _buildResultSection(cs, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme cs) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cs.primary, cs.tertiary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'ab',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Vertical Flip Text',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Masukkan teks, lalu balikkan secara vertikal',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildInputSection(ColorScheme cs, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_rounded, size: 18, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                'Input Teks',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _inputController,
            maxLines: 4,
            minLines: 2,
            style: TextStyle(
              fontSize: 16,
              color: cs.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'Tulis teks di sini...',
              hintStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: cs.surface,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: cs.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlipButton(ColorScheme cs, ThemeData theme) {
    return SizedBox(
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [cs.primary, cs.tertiary],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: _onFlip,
          icon: const Icon(Icons.flip_rounded, size: 22),
          label: const Text(
            'Balikkan Teks',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultSection(ColorScheme cs, ThemeData theme) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                children: [
                  Icon(Icons.output_rounded, size: 18, color: cs.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Hasil Flip Vertikal',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  // Copy button
                  GestureDetector(
                    onTap: _onCopy,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _isCopied
                            ? cs.primaryContainer
                            : cs.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _isCopied
                              ? cs.primary
                              : cs.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isCopied
                                ? Icons.check_rounded
                                : Icons.copy_rounded,
                            size: 16,
                            color: _isCopied ? cs.primary : cs.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isCopied ? 'Tersalin' : 'Salin',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _isCopied ? cs.primary : cs.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Flipped text display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: SelectableText(
                  _flippedText,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface,
                    letterSpacing: 1.2,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Preview original vs flipped
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cs.tertiaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 16, color: cs.tertiary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Teks asli: ${_inputController.text}',
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
