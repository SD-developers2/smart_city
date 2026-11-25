
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../../domain/entities/complaint.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<_CategoryData> _categories = [
    _CategoryData('Yo‘llar', Icons.route_rounded, Color(0xFF2878E8)),
    _CategoryData('Suv', Icons.water_drop_rounded, Color(0xFF1599C7)),
    _CategoryData('Chiqindi', Icons.delete_sweep_rounded, Color(0xFF15A879)),
    _CategoryData('Yoritish', Icons.lightbulb_rounded, Color(0xFFE6A126)),
    _CategoryData('Ekologiya', Icons.eco_rounded, Color(0xFF20A36B)),
    _CategoryData('Obodonlik', Icons.apartment_rounded, Color(0xFF7865D8)),
    _CategoryData('Xavfsizlik', Icons.security_rounded, Color(0xFFE05B63)),
    _CategoryData('Boshqa', Icons.more_horiz_rounded, Color(0xFF718096)),
  ];

  void _openComplaintDialog(
    BuildContext context, {
    String category = 'Boshqa',
  }) {
    showDialog(
      context: context,
      builder: (_) => ComplaintDialog(
        initialCategory: category,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 25),
      children: [
        Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.location_city_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SMART CITY',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: AppColors.navy,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    'TERMEZ • SMART SERVICES',
                    style: TextStyle(
                      fontSize: 9,
                      color: AppColors.grey,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                context.read<AppProvider>().changeTab(3);
              },
              icon: const Icon(
                Icons.notifications_none_rounded,
                size: 27,
                color: AppColors.navy,
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),

        // MAIN BANNER
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF1765E8),
                Color(0xFF102A56),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.18),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Xush kelibsiz!',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Aqlli shahar.\nYagona yechim.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  height: 1.2,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Termiz shahridagi muammolarni '
                'birgalikda hal qilamiz!',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 49,
                child: ElevatedButton.icon(
                  onPressed: () => _openComplaintDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text(
                    'Muammo yuborish',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 27),

        const _SectionHeader(
          title: 'Muammo kategoriyalari',
          subtitle: 'Kerakli yo‘nalishni tanlang',
        ),
        const SizedBox(height: 15),

        GridView.builder(
          itemCount: _categories.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 18,
            crossAxisSpacing: 10,
            childAspectRatio: 0.82,
          ),
          itemBuilder: (context, index) {
            final item = _categories[index];

            return _CategoryItem(
              icon: item.icon,
              title: item.title,
              color: item.color,
              onTap: () => _openComplaintDialog(
                context,
                category: item.title,
              ),
            );
          },
        ),
        const SizedBox(height: 25),

        const _SectionHeader(
          title: 'Murojaatlar statistikasi',
          subtitle: 'Sizning murojaatlaringiz',
        ),
        const SizedBox(height: 14),

        Row(
          children: [
            _StatCard(
              value: '${provider.totalComplaints}',
              title: 'Jami',
              color: AppColors.primary,
            ),
            const SizedBox(width: 9),
            _StatCard(
              value: '${provider.pendingComplaints}',
              title: 'Jarayonda',
              color: AppColors.orange,
            ),
            const SizedBox(width: 9),
            _StatCard(
              value: '${provider.completedComplaints}',
              title: 'Yakunlangan',
              color: AppColors.green,
            ),
          ],
        ),
        const SizedBox(height: 25),

        const _SectionHeader(
          title: 'So‘nggi murojaatlar',
          subtitle: 'Oxirgi yuborilgan xabarlar',
        ),
        const SizedBox(height: 12),

        if (provider.complaints.isEmpty)
          _EmptyComplaints()
        else
          ...provider.complaints.take(3).map(
            (complaint) => _ComplaintCard(
              complaint: complaint,
            ),
          ),

        const SizedBox(height: 20),
        const Center(
          child: Text(
            'SMART CITY TERMEZ © 2026',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.grey,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}

// CATEGORY MODEL
class _CategoryData {
  final String title;
  final IconData icon;
  final Color color;

  const _CategoryData(this.title, this.icon, this.color);
}

// SECTION HEADER
class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.grey,
          ),
        ),
      ],
    );
  }
}

// CATEGORY ITEM
class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

// STATISTIC CARD
class _StatCard extends StatelessWidget {
  final String value;
  final String title;
  final Color color;

  const _StatCard({
    required this.value,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 5,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: const Color(0xFFE9EEF6),
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// EMPTY COMPLAINTS
class _EmptyComplaints extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.assignment_outlined,
            color: AppColors.grey,
            size: 38,
          ),
          SizedBox(height: 10),
          Text(
            'Hozircha murojaatlar mavjud emas.',
            style: TextStyle(
              color: AppColors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// COMPLAINT CARD
class _ComplaintCard extends StatelessWidget {
  final Complaint complaint;

  const _ComplaintCard({
    required this.complaint,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: const CircleAvatar(
          backgroundColor: AppColors.lightBlue,
          child: Icon(
            Icons.assignment_outlined,
            color: AppColors.primary,
          ),
        ),
        title: Text(
          complaint.title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
        subtitle: Text(
          '${complaint.category} • ${complaint.id}',
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.grey,
          ),
        ),
        trailing: Text(
          complaint.status,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// COMPLAINT DIALOG
class ComplaintDialog extends StatefulWidget {
  final String initialCategory;

  const ComplaintDialog({
    super.key,
    required this.initialCategory,
  });

  @override
  State<ComplaintDialog> createState() => _ComplaintDialogState();
}

class _ComplaintDialogState extends State<ComplaintDialog> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();

  LatLng? _selectedLocation;

  late String _selectedCategory;

  static const List<String> _categories = [
    'Yo‘llar',
    'Suv',
    'Chiqindi',
    'Yoritish',
    'Ekologiya',
    'Obodonlik',
    'Xavfsizlik',
    'Boshqa',
  ];

  // XARITADAN JOY TANLASH
  Future<void> _chooseLocation() async {
    final LatLng? result = await showDialog<LatLng>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Muammo joyini belgilang'),
          content: SizedBox(
            width: 400,
            height: 350,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: const LatLng(37.2242, 67.2783),
                initialZoom: 13,
                onTap: (tapPosition, point) {
                  Navigator.pop(dialogContext, point);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.smart_city',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Bekor qilish'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (result != null) {
      setState(() {
        _selectedLocation = result;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _selectedCategory = _categories.contains(widget.initialCategory)
        ? widget.initialCategory
        : 'Boshqa';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // MUROJAATNI SAQLASH
  void _submitComplaint() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AppProvider>().addComplaint(
      title: _titleController.text.trim(),
      category: _selectedCategory,
      address: _addressController.text.trim(),
      description: _descriptionController.text.trim(),
      latitude: _selectedLocation?.latitude,
      longitude: _selectedLocation?.longitude,
    );

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Murojaatingiz muvaffaqiyatli qo‘shildi!'),
        backgroundColor: AppColors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      title: const Text(
        'Muammo haqida xabar berish',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: AppColors.navy,
        ),
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Muammo nomi',
                    prefixIcon: Icon(Icons.edit_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Muammo nomini kiriting';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Kategoriya',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Muammo manzili',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Manzilni kiriting';
                    }
                    return null;
                  },
                ),

                // XARITANI OCHISH TUGMASI
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _chooseLocation,
                    icon: const Icon(Icons.map_outlined),
                    label: Text(
                      _selectedLocation == null
                          ? 'Xaritadan joy tanlash'
                          : 'Joy tanlandi',
                    ),
                  ),
                ),

                if (_selectedLocation != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Kenglik: ${_selectedLocation!.latitude.toStringAsFixed(5)}\n'
                      'Uzunlik: ${_selectedLocation!.longitude.toStringAsFixed(5)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                    ),
                  ),

                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Muammo tavsifi',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Muammoni qisqacha tushuntiring';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Bekor qilish'),
        ),
        ElevatedButton(
          onPressed: _submitComplaint,
          child: const Text('Yuborish'),
        ),
      ],
    );
  }
}
