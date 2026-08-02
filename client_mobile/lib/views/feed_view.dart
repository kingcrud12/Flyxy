import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/social_viewmodel.dart';
import '../viewmodels/transport_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/liquid_background.dart';
import 'package:html/parser.dart' show parse;

class FeedViewScreen extends StatefulWidget {
  const FeedViewScreen({super.key});

  @override
  State<FeedViewScreen> createState() => _FeedViewScreenState();
}

class _FeedViewScreenState extends State<FeedViewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SocialViewModel>().fetchPosts();
      context.read<TransportViewModel>().fetchDisruptions();
    });
  }

  String _parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    return document.body?.text ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final socialViewModel = context.watch<SocialViewModel>();
    final transportViewModel = context.watch<TransportViewModel>();
    final authVm = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Communauté', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await socialViewModel.fetchPosts();
          await transportViewModel.fetchDisruptions();
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 100, top: 16, left: 16, right: 16),
          children: [
            // Bloc Créer un post
            if (authVm.isAuthenticated) ...[
              GestureDetector(
                onTap: () => context.push('/create-post'),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.amber,
                            backgroundImage: authVm.profilePicture.isNotEmpty ? NetworkImage(authVm.profilePicture) : null,
                            child: authVm.profilePicture.isEmpty ? const Icon(Icons.person, color: Colors.black) : null,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Quoi de neuf ?',
                              style: TextStyle(color: Colors.white70, fontSize: 16),
                            ),
                          ),
                          Icon(Icons.image, color: Colors.blueAccent.shade100),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // Bloc Info Trafic (Disruptions)
            if (transportViewModel.isLoading)
              const Center(child: CircularProgressIndicator(color: Colors.white))
            else if (transportViewModel.disruptions.isNotEmpty) ...[
              const Text('Info Trafic', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: transportViewModel.disruptions.length,
                  itemBuilder: (context, index) {
                    final d = transportViewModel.disruptions[index];
                    final status = d['status'] ?? 'active';
                    final severity = d['severity'] ?? {};
                    final messages = d['messages'] as List<dynamic>? ?? [];
                    final textHtml = messages.isNotEmpty ? (messages.first['text'] ?? '') : 'Perturbation en cours';
                    final textPlain = _parseHtmlString(textHtml);
                    
                    return Container(
                      width: 280,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.redAccent.withOpacity(0.5), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  severity['name'] ?? 'Perturbation',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Text(
                              textPlain,
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            const Text('Fil d\'actualité', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            if (socialViewModel.isLoading && socialViewModel.posts.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(color: Colors.white),
              ))
            else if (socialViewModel.posts.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('Aucun post pour le moment.', style: TextStyle(color: Colors.white70)),
              ))
            else
              ...socialViewModel.posts.map((post) => _buildPostCard(context, post)),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, dynamic post) {
    final user = post['user'] ?? {};
    final userName = '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim();
    final authVm = context.read<AuthViewModel>();
    final isMyPost = user['id'] == authVm.userId;
    final profilePic = isMyPost ? authVm.profilePicture : (user['profile_picture'] ?? '');
    final imageUrl = post['image_url'] ?? '';
    final text = post['text'] ?? '';
    final likes = post['likes'] ?? 0;
    final commentsCount = post['comments_count'] ?? 0;
    final likedByMe = post['liked_by_me'] ?? false;
    final postId = post['id'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
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
                    if (isMyPost)
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white54),
                        color: const Color(0xFF2C2C2E),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditPostDialog(context, post);
                          } else if (value == 'delete') {
                            showDialog(
                              context: context,
                              builder: (ctx) => Dialog(
                                backgroundColor: Colors.transparent,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                    child: Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Supprimer le post', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 16),
                                          const Text('Voulez-vous vraiment supprimer ce post ?', style: TextStyle(color: Colors.white70)),
                                          const SizedBox(height: 24),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(ctx),
                                                child: const Text('Annuler', style: TextStyle(color: Colors.white)),
                                              ),
                                              const SizedBox(width: 8),
                                              TextButton(
                                                onPressed: () {
                                                  context.read<SocialViewModel>().deletePost(postId);
                                                  Navigator.pop(ctx);
                                                },
                                                child: const Text('Supprimer', style: TextStyle(color: Colors.redAccent)),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
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
                            const SnackBar(content: Text('Connectez-vous pour aimer un post')),
                          );
                          return;
                        }
                        context.read<SocialViewModel>().togglePostLike(postId);
                      },
                    ),
                    Text('$likes', style: const TextStyle(color: Colors.white)),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                      onPressed: () {
                        context.push('/post-details', extra: post);
                      },
                    ),
                    Text('$commentsCount', style: const TextStyle(color: Colors.white)),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditPostDialog(BuildContext context, dynamic post) {
    final textController = TextEditingController(text: post['text'] ?? '');
    
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Modifier le post', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: textController,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Quoi de neuf ?',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Annuler', style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 8),
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
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
