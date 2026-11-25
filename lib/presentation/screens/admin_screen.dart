

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../providers/app_provider.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),
      appBar: AppBar(
        title: const Text(
          'Administrator paneli',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.errorMessage != null
              ? Center(
                  child: Text(
                    provider.errorMessage!,
                    textAlign: TextAlign.center,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    // Murojaatlar Firestore orqali real vaqtda yangilanadi.
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text(
                        'Umumiy statistika',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          _StatCard(
                            title: 'Jami',
                            count: provider.totalComplaints,
                            color: AppColors.primary,
                            icon: Icons.assignment,
                          ),
                          const SizedBox(width: 10),
                          _StatCard(
                            title: 'Yangi',
                            count: provider.newComplaints,
                            color: Colors.orange,
                            icon: Icons.fiber_new,
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          _StatCard(
                            title: 'Jarayonda',
                            count: provider.pendingComplaints,
                            color: Colors.blue,
                            icon: Icons.sync,
                          ),
                          const SizedBox(width: 10),
                          _StatCard(
                            title: 'Yakunlangan',
                            count: provider.completedComplaints,
                            color: Colors.green,
                            icon: Icons.check_circle_outline,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Barcha murojaatlar',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      if (provider.complaints.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(
                              child: Text('Hozircha murojaatlar mavjud emas.'),
                            ),
                          ),
                        ),

                      ...provider.complaints.map(
                        (complaint) => Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  complaint.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text('Kategoriya: ${complaint.category}'),
                                Text('Manzil: ${complaint.address}'),
                                const SizedBox(height: 8),
                                Text(
                                  complaint.description,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 12),

                                Row(
                                  children: [
                                    const Text(
                                      'Holati:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: DropdownButton<String>(
                                        value: complaint.status,
                                        isExpanded: true,
                                        items: const [
                                          DropdownMenuItem(
                                            value: 'Yangi',
                                            child: Text('Yangi'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Jarayonda',
                                            child: Text('Jarayonda'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Yakunlangan',
                                            child: Text('Yakunlangan'),
                                          ),
                                        ],
                                        onChanged: (value) async {
                                          if (value == null ||
                                              value == complaint.status) {
                                            return;
                                          }

                                          try {
                                            await provider.updateComplaintStatus(
                                              complaintId: complaint.id,
                                              newStatus: value,
                                            );

                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Murojaat holati yangilandi.',
                                                  ),
                                                ),
                                              );
                                            }
                                          } catch (error) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Xatolik: $error',
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 27),
              const SizedBox(height: 12),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
