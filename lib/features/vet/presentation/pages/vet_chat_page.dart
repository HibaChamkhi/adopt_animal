import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:adopt_animal/core/app_icons.dart';
import 'package:adopt_animal/core/app_theme.dart';
import 'package:adopt_animal/core/sample_data.dart';
import 'package:adopt_animal/core/widgets/app_widgets.dart';
import 'package:adopt_animal/features/vet/data/chat_repository.dart';

class VetChatPage extends StatefulWidget {
  final Vet vet;
  const VetChatPage({super.key, required this.vet});

  @override
  State<VetChatPage> createState() => _VetChatPageState();
}

class _VetChatPageState extends State<VetChatPage> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final _repo = ChatRepository();
  late final String _chatId =
      _repo.chatIdFor(widget.vet.name.replaceAll(RegExp(r'\s+'), '_'));

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final t = _controller.text.trim();
    if (t.isEmpty) return;
    _controller.clear();
    try {
      await _repo.send(_chatId, t);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't send — try again")),
        );
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: StreamBuilder<List<ChatMessage>>(
                stream: _repo.watch(_chatId),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final msgs = snap.data ?? const <ChatMessage>[];
                  if (msgs.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          "No messages yet.\nSay hello to ${widget.vet.name.split(' ').first}.",
                          textAlign: TextAlign.center,
                          style: AppText.secondary,
                        ),
                      ),
                    );
                  }
                  return ListView(
                    controller: _scroll,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    children: [
                      _dateChip("Today"),
                      for (final m in msgs) _bubble(m),
                    ],
                  );
                },
              ),
            ),
            _inputBar(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Color(0x0A1F2A44), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: AppIcon(AppIcons.arrowBack, size: 22, color: AppColors.primaryDark),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(widget.vet.initials,
                  style: const TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.vet.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.primaryDark)),
                Row(
                  children: const [
                    SizedBox(
                      width: 8, height: 8,
                      child: DecoratedBox(decoration: BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                    ),
                    SizedBox(width: 6),
                    Text("Online", style: AppText.secondary),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              final uri = Uri(scheme: 'tel', path: widget.vet.phone);
              if (await canLaunchUrl(uri)) await launchUrl(uri);
            },
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: AppIcon(AppIcons.call, size: 22, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateChip(String label) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(color: AppColors.neutralBg, borderRadius: BorderRadius.circular(16)),
        child: Text(label, style: AppText.secondary),
      ),
    );
  }

  Widget _bubble(ChatMessage m) {
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(m.me ? 18 : 4),
      bottomRight: Radius.circular(m.me ? 4 : 18),
    );
    final isImage = m.imageUrl != null;
    Widget content;
    if (isImage) {
      content = ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              width: 200, height: 150,
              child: (m.imageUrl!.isNotEmpty)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(m.imageUrl!, fit: BoxFit.cover),
                    )
                  : StripedPlaceholder(label: m.text, borderRadius: 16),
            ),
            if (m.time.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4, right: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(m.time, style: AppText.secondary),
                    const SizedBox(width: 3),
                    const Icon(Icons.done_all, size: 15, color: AppColors.primary),
                  ],
                ),
              ),
          ],
        ),
      );
    } else {
      content = Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: m.me ? AppColors.primary : AppColors.surface,
          borderRadius: radius,
        ),
        child: Text(
          m.text,
          style: TextStyle(
            color: m.me ? Colors.white : AppColors.primaryDark,
            fontSize: 15, height: 1.3,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: m.me ? Alignment.centerRight : Alignment.centerLeft,
        child: content,
      ),
    );
  }

  Widget _inputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      color: AppColors.background,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.all(6),
              child: AppIcon(AppIcons.addPhoto, size: 24, color: AppColors.textSecondary),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _controller,
                  style: AppText.body,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  decoration: const InputDecoration(
                    hintText: "Message...",
                    hintStyle: AppText.secondary,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _send,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: const AppIcon(AppIcons.send, size: 20, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
