import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/post_details_viewmodel.dart';
import '../viewmodels/social_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/liquid_background.dart';

class PostDetailsView extends StatefulWidget {
  final dynamic post;

  const PostDetailsView({super.key, required this.post});

  @override
  State<PostDetailsView> createState() => _PostDetailsViewState();
}

class _PostDetailsViewState extends State<PostDetailsView> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostDetailsViewModel>().fetchComments(widget.post['id']);
    });
  }

  Future<void> _submitComment() async {
    final authVm = context.read<AuthViewModel>();
    if (!authVm.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connectez-vous pour commenter')),
      );
      return;
    }

    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    await context.read<PostDetailsViewModel>().createComment(widget.post['id'], text);
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final postDetailsVM = context.watch<PostDetailsViewModel>();

    return Scaffold(
      body: Stack(
        children: [
          const LiquidBackground(),
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  iconTheme: const IconThemeData(color: Colors.white),
                  title: const Text('Publication', style: TextStyle(color: Colors.white)),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildPostCard(context),
                      const SizedBox(height: 20),
                      const Text('Commentaires', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      if (postDetailsVM.isLoading && postDetailsVM.comments.isEmpty)
                        const Center(child: CircularProgressIndicator(color: Colors.white))
                      else if (postDetailsVM.comments.isEmpty)
                        const Text('Aucun commentaire pour le moment.', style: TextStyle(color: Colors.white54))
                      else
                        ...postDetailsVM.comments.map((comment) => _buildCommentCard(context, comment)),
                    ],
                  ),
                ),
                _buildCommentInput(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(BuildContext context) {
    final user = widget.post['user'] ?? {};
    final userName = '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim();
    final authVm = context.read<AuthViewModel>();
    final isMyPost = user['id'] == authVm.userId;
    final profilePic = isMyPost ? authVm.profilePicture : (user['profile_picture'] ?? '');
    final imageUrl = widget.post['image_url'] ?? '';
    final text = widget.post['text'] ?? '';
    
    // We observe likes from socialViewModel so it stays updated if changed outside
    final socialVM = context.watch<SocialViewModel>();
    final postUpdated = socialVM.posts.firstWhere((p) => p['id'] == widget.post['id'], orElse: () => widget.post);
    final likes = postUpdated['likes'] ?? 0;
    final likedByMe = postUpdated['liked_by_me'] ?? false;
    final postId = widget.post['id'];

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.amber,
                    backgroundImage: profilePic.isNotEmpty ? NetworkImage(profilePic) : null,
                    child: profilePic.isEmpty ? const Icon(Icons.person, color: Colors.black) : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      userName.isNotEmpty ? userName : 'Utilisateur',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  if (authVm.isAuthenticated && isMyPost)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white54),
                      color: const Color(0xFF2C2C2E),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditPostDialog(context, widget.post);
                        } else if (value == 'delete') {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: const Color(0xFF2C2C2E),
                              title: const Text('Supprimer le post', style: TextStyle(color: Colors.white)),
                              content: const Text('Voulez-vous vraiment supprimer ce post ?', style: TextStyle(color: Colors.white70)),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Annuler', style: TextStyle(color: Colors.white)),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await context.read<SocialViewModel>().deletePost(widget.post['id']);
                                    if (context.mounted) {
                                      Navigator.pop(ctx);
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: const Text('Supprimer', style: TextStyle(color: Colors.redAccent)),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Modifier', style: TextStyle(color: Colors.white)),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Supprimer', style: TextStyle(color: Colors.redAccent)),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (text.isNotEmpty)
                Text(
                  text,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
              if (text.isNotEmpty && imageUrl.isNotEmpty) const SizedBox(height: 12),
              if (imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      likedByMe ? Icons.favorite : Icons.favorite_border,
                      color: likedByMe ? Colors.redAccent : Colors.white,
                    ),
                    onPressed: () {
                      if (!authVm.isAuthenticated) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Connectez-vous pour aimer ce post')),
                        );
                        return;
                      }
                      context.read<SocialViewModel>().togglePostLike(postId);
                    },
                  ),
                  Text('$likes', style: const TextStyle(color: Colors.white)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentCard(BuildContext context, dynamic comment) {
    final user = comment['user'] ?? {};
    final userName = '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim();
    final authVm = context.read<AuthViewModel>();
    final isMyPost = user['id'] == authVm.userId;
    final profilePic = isMyPost ? authVm.profilePicture : (user['profile_picture'] ?? '');
    final text = comment['text'] ?? '';
    final likes = comment['likes'] ?? 0;
    final likedByMe = comment['liked_by_me'] ?? false;
    final commentId = comment['id'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.amber,
                  backgroundImage: profilePic.isNotEmpty ? NetworkImage(profilePic) : null,
                  child: profilePic.isEmpty ? const Icon(Icons.person, size: 20, color: Colors.black) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName.isNotEmpty ? userName : 'Utilisateur',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
                    ],
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      icon: Icon(
                        likedByMe ? Icons.favorite : Icons.favorite_border,
                        color: likedByMe ? Colors.redAccent : Colors.white,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        if (!authVm.isAuthenticated) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Connectez-vous pour aimer un commentaire')),
                          );
                          return;
                        }
                        context.read<PostDetailsViewModel>().toggleCommentLike(commentId);
                      },
                    ),
                    if (likes > 0)
                      Text('$likes', style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommentInput() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.2))),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Écrire un commentaire...',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.blueAccent),
                onPressed: _submitComment,
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showEditPostDialog(BuildContext context, dynamic post) {
    final textController = TextEditingController(text: post['text'] ?? '');
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        title: const Text('Modifier le post', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: textController,
          maxLines: 4,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Quoi de neuf ?',
            hintStyle: TextStyle(color: Colors.white54),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () async {
              final newText = textController.text.trim();
              if (newText.isNotEmpty) {
                await context.read<SocialViewModel>().updatePost(post['id'], newText);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Sauvegarder', style: TextStyle(color: Colors.blueAccent)),
          ),
        ],
      ),
    );
  }
}
