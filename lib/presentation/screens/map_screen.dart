
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../providers/app_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController =
      TextEditingController();

  static const LatLng termezLocation = LatLng(37.2242, 67.2783);

  LatLng _selectedLocation = termezLocation;
  String? _selectedPlaceName;

  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;

  // JOY QIDIRISH
  Future<void> _searchPlace() async {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      setState(() {
        _errorMessage = 'Joy nomini kiriting';
        _searchResults = [];
      });
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _searchResults = [];
    });

    try {
      final uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/search',
        {
          'q': '$query, Termiz, Uzbekistan',
          'format': 'jsonv2',
          'limit': '5',
          'countrycodes': 'uz',
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'SmartCityTermez/1.0',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Qidiruv xizmatida xatolik yuz berdi');
      }

      final List<dynamic> data = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      if (!mounted) return;

      if (data.isEmpty) {
        setState(() {
          _errorMessage =
              'Bu joy topilmadi. Boshqa nom kiriting.';
        });
        return;
      }

      setState(() {
        _searchResults = data.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage =
            'Internet yoki qidiruv xizmatini tekshiring.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // QIDIRUV NATIJASINI TANLASH
  void _selectPlace(Map<String, dynamic> place) {
    final latitude = double.tryParse(
      place['lat'].toString(),
    );
    final longitude = double.tryParse(
      place['lon'].toString(),
    );

    if (latitude == null || longitude == null) return;

    final location = LatLng(latitude, longitude);

    setState(() {
      _selectedLocation = location;
      _selectedPlaceName =
          place['display_name']?.toString();
      _searchResults = [];
      _errorMessage = null;
    });

    _mapController.move(location, 16);
    FocusScope.of(context).unfocus();
  }

  // MUROJAAT HAQIDA MA'LUMOT
  void _showComplaintDetails(
    BuildContext context,
    dynamic complaint,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Murojaat maʼlumotlari',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 18),

                  Text(
                    complaint.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _detailRow(
                    Icons.category_outlined,
                    'Kategoriya',
                    complaint.category,
                  ),
                  _detailRow(
                    Icons.location_on_outlined,
                    'Manzil',
                    complaint.address,
                  ),
                  _detailRow(
                    Icons.info_outline,
                    'Holati',
                    complaint.status,
                  ),
                  _detailRow(
                    Icons.description_outlined,
                    'Tavsif',
                    complaint.description,
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                      },
                      child: const Text('Yopish'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 21,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.grey,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // PROVIDERDAN MUROJAATLARNI OLISH
    final complaints =
        context.watch<AppProvider>().complaints;

    // FAQAT KOORDINATASI MAVJUD MUROJAATLAR
    final mappedComplaints = complaints.where(
      (complaint) =>
          complaint.latitude != null &&
          complaint.longitude != null,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Termiz xaritasi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Center(
              child: Text(
                '${mappedComplaints.length} ta murojaat',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // XARITA
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: termezLocation,
              initialZoom: 13,
              minZoom: 5,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName:
                    'com.example.smart_city',
              ),

              // MARKERLAR
              MarkerLayer(
                markers: [
                  // QIDIRUV ORQALI TANLANGAN JOY
                  Marker(
                    point: _selectedLocation,
                    width: 60,
                    height: 60,
                    child: const Icon(
                      Icons.location_on,
                      color: AppColors.red,
                      size: 45,
                    ),
                  ),

                  // MUROJAATLAR JOYLASHUVI
                  ...mappedComplaints.map(
                    (complaint) => Marker(
                      point: LatLng(
                        complaint.latitude!,
                        complaint.longitude!,
                      ),
                      width: 50,
                      height: 55,
                      child: GestureDetector(
                        onTap: () {
                          _showComplaintDetails(
                            context,
                            complaint,
                          );
                        },
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.green,
                          size: 43,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                  ),
                ],
              ),
            ],
          ),

          // QIDIRUV PANELI
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Column(
              children: [
                Material(
                  elevation: 5,
                  borderRadius: BorderRadius.circular(15),
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _searchPlace(),
                    decoration: InputDecoration(
                      hintText:
                          'Ko‘cha, mahalla yoki joy nomini kiriting',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.primary,
                      ),
                      suffixIcon: IconButton(
                        onPressed:
                            _isLoading ? null : _searchPlace,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.arrow_forward,
                                color: AppColors.primary,
                              ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                    ),
                  ),
                ),

                if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: AppColors.red,
                      ),
                    ),
                  ),

                // QIDIRUV NATIJALARI
                if (_searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    constraints: const BoxConstraints(
                      maxHeight: 260,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _searchResults.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final place =
                            _searchResults[index];

                        return ListTile(
                          leading: const Icon(
                            Icons.location_on_outlined,
                            color: AppColors.primary,
                          ),
                          title: Text(
                            place['name']
                                        ?.toString()
                                        .isNotEmpty ==
                                    true
                                ? place['name'].toString()
                                : place['display_name']
                                    .toString(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            place['display_name'].toString(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _selectPlace(place),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // TANLANGAN JOY MA'LUMOTI
          if (_selectedPlaceName != null)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: 0.12,
                      ),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.place,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _selectedPlaceName!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedPlaceName = null;
                          _selectedLocation = termezLocation;
                        });
                        _mapController.move(
                          termezLocation,
                          13,
                        );
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
            ),

          // MARKERLAR HAQIDA ESLATMA
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.10,
                    ),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppColors.red,
                        size: 18,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Tanlangan joy',
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.green,
                        size: 18,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Murojaatlar',
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
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
