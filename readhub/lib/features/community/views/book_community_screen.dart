import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../viewmodels/community_viewmodel.dart';
import '../models/comment_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shimmer_loading.dart';

class BookCommunityScreen extends StatefulWidget {
  final String bookId;
  final String bookTitle;

  const BookCommunityScreen({
    super.key,
    required this.bookId,
    this.bookTitle = '',
  });

  @override
  State<BookCommunityScreen> createState() => _BookCommunityScreenState();
}

class _BookCommunityScreenState extends State<BookCommunityScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isSpoiler = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityViewModel>().loadDiscussion(
            widget.bookId,
            title: widget.bookTitle,
          );
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    await context.read<CommunityViewModel>().addComment(text, _isSpoiler);
    _commentController.clear();
    if (mounted) setState(() => _isSpoiler = false);
    if (mounted) FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CommunityViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Topluluk Tartışması'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // ── Bölüm Seçimi ───────────────────────────────────────────
          SizedBox(
            height: 52,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: viewModel.chapters.length,
              itemBuilder: (context, index) {
                final chapter = viewModel.chapters[index];
                final isSelected = chapter == viewModel.selectedChapter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                  child: ChoiceChip(
                    label: Text(chapter),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) viewModel.selectChapter(chapter);
                    },
                    selectedColor: Theme.of(context).colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.black87),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                    backgroundColor: isDark ? AppColors.surfaceDark : Colors.grey.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    side: BorderSide.none,
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1),

          // ── Yorum Listesi ───────────────────────────────────────────
          Expanded(
            child: viewModel.isLoading
                ? ShimmerLoading(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: 6,
                      separatorBuilder: (_, __) => const SizedBox(height: 24),
                      itemBuilder: (context, index) => const ListTileShimmer(),
                    ),
                  )
                : viewModel.comments.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        itemCount: viewModel.comments.length,
                        separatorBuilder: (_, __) => const Divider(height: 24),
                        itemBuilder: (context, index) {
                          return _CommentTile(
                            comment: viewModel.comments[index],
                            bookId: widget.bookId,
                          );
                        },
                      ),
          ),

          // ── Yorum Yazma Alanı ───────────────────────────────────────
          _buildInputArea(context, isDark),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.messageSquare, size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Henüz yorum yok.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Bu bölümde tartışmayı başlatan sen ol!',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Spoiler toggle
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _isSpoiler = !_isSpoiler),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _isSpoiler
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
                        : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isSpoiler
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isSpoiler ? LucideIcons.eyeOff : LucideIcons.eye,
                        size: 14,
                        color: _isSpoiler
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade500,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isSpoiler ? 'Spoiler İşaretlendi' : 'Spoiler Değil',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _isSpoiler
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Metin girişi + gönder
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  maxLines: 4,
                  minLines: 1,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: '${viewModel.selectedChapter} hakkında yaz...',
                    filled: true,
                    fillColor: isDark ? AppColors.backgroundDark : Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                radius: 22,
                child: IconButton(
                  icon: const Icon(LucideIcons.send, color: Colors.white, size: 18),
                  onPressed: _submitComment,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  CommunityViewModel get viewModel => context.read<CommunityViewModel>();
}

// ════════════════════════════════════════════════════════════════════════════
// YORUM KARTI (Ana yorum + yanıtlar)
// ════════════════════════════════════════════════════════════════════════════

class _CommentTile extends StatefulWidget {
  final CommentModel comment;
  final String bookId;
  final bool isReply;

  const _CommentTile({
    Key? key,
    required this.comment,
    required this.bookId,
    this.isReply = false,
  }) : super(key: key);

  @override
  State<_CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<_CommentTile> {
  bool _revealed = false;
  bool _showReplyInput = false;
  bool _showReplies = false;
  final TextEditingController _replyCtrl = TextEditingController();
  bool _replySpoiler = false;

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} ay önce';
    if (diff.inDays > 0) return '${diff.inDays} gün önce';
    if (diff.inHours > 0) return '${diff.inHours} saat önce';
    if (diff.inMinutes > 0) return '${diff.inMinutes} dk önce';
    return 'Az önce';
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<CommunityViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final comment = widget.comment;
    final isLiked = comment.isLikedBy(vm.currentUserId);
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        if (widget.isReply) const SizedBox(width: 40),
        _Avatar(initials: comment.avatarInitials, size: widget.isReply ? 30 : 36),
        const SizedBox(width: 10),

        // İçerik
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kullanıcı adı + tarih + üç nokta menüsü (yalnızca kendi yorumu)
              Row(
                children: [
                  Text(
                    comment.username,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _timeAgo(comment.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const Spacer(),
                  // Kendi yorumuysa sil seçeneği göster
                  if (comment.userId == vm.currentUserId)
                    SizedBox(
                      height: 24,
                      width: 28,
                      child: PopupMenuButton<String>(
                        iconSize: 16,
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          LucideIcons.moreHorizontal,
                          size: 16,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(LucideIcons.trash2, size: 15, color: Colors.red.shade400),
                                const SizedBox(width: 8),
                                Text(
                                  'Yorumu Sil',
                                  style: TextStyle(color: Colors.red.shade400, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) async {
                          if (value == 'delete') {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                title: const Text('Yorumu Sil', style: TextStyle(fontWeight: FontWeight.bold)),
                                content: const Text('Bu yorumu silmek istediğine emin misin? Bu işlem geri alınamaz.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Vazgeç'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                                    child: const Text('Sil', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true && context.mounted) {
                              await context.read<CommunityViewModel>().deleteComment(comment.id);
                            }
                          }
                        },
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),

              // Spoiler veya metin
              if (comment.isSpoiler && !_revealed)
                GestureDetector(
                  onTap: () => setState(() => _revealed = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.eyeOff, size: 15, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        const Text(
                          'Spoiler uyarısı — görmek için dokun',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Text(comment.text, style: const TextStyle(height: 1.45, fontSize: 14)),

              const SizedBox(height: 8),

              // Aksiyon butonları
              Row(
                children: [
                  // Beğeni
                  _ActionButton(
                    icon: isLiked ? Icons.favorite : LucideIcons.heart,
                    label: comment.likeCount > 0 ? '${comment.likeCount}' : '',
                    color: isLiked ? Colors.red : null,
                    onTap: () => vm.toggleCommentLike(comment.id, isLiked),
                  ),
                  const SizedBox(width: 16),

                  // Yanıtla
                  if (!widget.isReply)
                    _ActionButton(
                      icon: LucideIcons.messageCircle,
                      label: comment.replyCount > 0
                          ? '${comment.replyCount} yanıt'
                          : 'Yanıtla',
                      onTap: () {
                        setState(() {
                          _showReplyInput = !_showReplyInput;
                          if (comment.replyCount > 0) _showReplies = true;
                        });
                      },
                    ),
                ],
              ),

              // Yanıt yazma alanı
              if (_showReplyInput) ...[
                const SizedBox(height: 10),
                _ReplyInput(
                  controller: _replyCtrl,
                  isSpoiler: _replySpoiler,
                  onSpoilerToggle: (val) => setState(() => _replySpoiler = val),
                  onSubmit: () async {
                    if (_replyCtrl.text.trim().isEmpty) return;
                    await vm.addReply(
                      parentCommentId: comment.id,
                      text: _replyCtrl.text.trim(),
                      isSpoiler: _replySpoiler,
                    );
                    _replyCtrl.clear();
                    setState(() {
                      _showReplyInput = false;
                      _showReplies = true;
                      _replySpoiler = false;
                    });
                  },
                ),
              ],

              // Yanıt listesi (Stream)
              if (_showReplies && !widget.isReply) ...[
                const SizedBox(height: 10),
                StreamBuilder<List<CommentModel>>(
                  stream: vm.repliesStream(comment.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.only(left: 40),
                        child: LinearProgressIndicator(),
                      );
                    }
                    final replies = snapshot.data ?? [];
                    if (replies.isEmpty) return const SizedBox();
                    return Column(
                      children: replies
                          .map((reply) => Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: _CommentTile(
                                  comment: reply,
                                  bookId: widget.bookId,
                                  isReply: true,
                                ),
                              ))
                          .toList(),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── Avatar Widget ──────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String initials;
  final double size;

  const _Avatar({Key? key, required this.initials, this.size = 36}) : super(key: key);

  static const _colors = [
    Color(0xFF6C63FF), Color(0xFFFF6B6B), Color(0xFF43AA8B),
    Color(0xFFFF9F43), Color(0xFF54A0FF), Color(0xFFE056FD),
  ];

  Color get _color => _colors[initials.codeUnitAt(0) % _colors.length];

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: _color,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.38,
        ),
      ),
    );
  }
}

// ── Aksiyon Butonu ─────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _ActionButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color ?? defaultColor),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color ?? defaultColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Yanıt Yazma Kutusu ─────────────────────────────────────────────────────

class _ReplyInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isSpoiler;
  final ValueChanged<bool> onSpoilerToggle;
  final VoidCallback onSubmit;

  const _ReplyInput({
    Key? key,
    required this.controller,
    required this.isSpoiler,
    required this.onSpoilerToggle,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Spoiler toggle
          GestureDetector(
            onTap: () => onSpoilerToggle(!isSpoiler),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSpoiler ? LucideIcons.eyeOff : LucideIcons.eye,
                  size: 13,
                  color: isSpoiler ? colorScheme.primary : Colors.grey.shade500,
                ),
                const SizedBox(width: 5),
                Text(
                  isSpoiler ? 'Spoiler' : 'Normal',
                  style: TextStyle(
                    fontSize: 11,
                    color: isSpoiler ? colorScheme.primary : Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Yanıtını yaz...',
                    hintStyle: const TextStyle(fontSize: 13),
                    filled: true,
                    fillColor: isDark ? AppColors.backgroundDark : Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onSubmit,
                borderRadius: BorderRadius.circular(20),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: colorScheme.primary,
                  child: const Icon(LucideIcons.send, color: Colors.white, size: 15),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
