import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../domain/healthcare_facility.dart';
import 'healthcare_detail_screen.dart';

/// Healthcare Finder Screen inspired by Screen 2 of the Dribbble design reference.
/// Features:
/// - Clear page title: "Fasilitas Kesehatan Terdekat"
/// - Rounded search bar with integrated search button
/// - Category selection cards (Rumah Sakit, Klinik, Dokter, Puskesmas/Apotek)
/// - Stylized map preview card with 10 km radius indicator
/// - Facility information cards with category pill, verified distance, and navigation to details
class HealthcareFinderScreen extends StatefulWidget {
  const HealthcareFinderScreen({super.key});

  @override
  State<HealthcareFinderScreen> createState() => _HealthcareFinderScreenState();
}

class _HealthcareFinderScreenState extends State<HealthcareFinderScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Semua';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Semua',
      'icon': Icons.local_hospital_rounded,
      'bg': AppColors.lightGreen,
      'color': AppColors.darkGreen,
    },
    {
      'name': 'Rumah Sakit',
      'icon': Icons.domain_rounded,
      'bg': AppColors.accentHealthcareBg,
      'color': AppColors.accentHealthcare,
    },
    {
      'name': 'Klinik',
      'icon': Icons.medical_services_rounded,
      'bg': AppColors.accentSttBg,
      'color': AppColors.accentStt,
    },
    {
      'name': 'Praktik Dokter',
      'icon': Icons.person_rounded,
      'bg': AppColors.accentMtsBg,
      'color': AppColors.accentMts,
    },
    {
      'name': 'Apotek',
      'icon': Icons.medication_rounded,
      'bg': AppColors.accentLocationBg,
      'color': AppColors.accentLocation,
    },
  ];

  // Authentic sample facilities based on Malang coordinates (-7.9526, 112.6144)
  final List<HealthcareFacility> _allFacilities = const [
    HealthcareFacility(
      id: 'osm-101',
      name: 'RSUD Dr. Saiful Anwar',
      category: 'Rumah Sakit',
      address: 'Jl. Jaksa Agung Suprapto No. 2, Klojen, Malang',
      latitude: -7.9723,
      longitude: 112.6318,
      distanceMeters: 1250,
      isWheelchairAccessible: true,
    ),
    HealthcareFacility(
      id: 'osm-102',
      name: 'Klinik UB Medika',
      category: 'Klinik',
      address: 'Jl. MT Haryono No. 169, Lowokwaru, Malang',
      latitude: -7.9512,
      longitude: 112.6135,
      distanceMeters: 450,
      isWheelchairAccessible: true,
    ),
    HealthcareFacility(
      id: 'osm-103',
      name: 'Puskesmas Dinoyo',
      category: 'Puskesmas',
      address: 'Jl. MT Haryono IX No. 13, Lowokwaru, Malang',
      latitude: -7.9480,
      longitude: 112.6075,
      distanceMeters: 1800,
      isWheelchairAccessible: false,
    ),
    HealthcareFacility(
      id: 'osm-104',
      name: 'RS Hermina Tangkubanprahu',
      category: 'Rumah Sakit',
      address: 'Jl. Tangkubanprahu No. 31-33, Kauman, Malang',
      latitude: -7.9780,
      longitude: 112.6240,
      distanceMeters: 3200,
      isWheelchairAccessible: true,
    ),
    HealthcareFacility(
      id: 'osm-105',
      name: 'Praktik Dokter Spesialis THT',
      category: 'Praktik Dokter',
      address: 'Jl. Ijen No. 42, Klojen, Malang',
      latitude: -7.9690,
      longitude: 112.6220,
      distanceMeters: 2100,
      isWheelchairAccessible: true,
    ),
    HealthcareFacility(
      id: 'osm-106',
      name: 'Apotek Kimia Farma Sutoyo',
      category: 'Apotek',
      address: 'Jl. Letjen Sutoyo No. 88, Lowokwaru, Malang',
      latitude: -7.9580,
      longitude: 112.6300,
      distanceMeters: 1950,
      isWheelchairAccessible: null,
    ),
  ];

  List<HealthcareFacility> get _filteredFacilities {
    final query = _searchController.text.toLowerCase().trim();
    return _allFacilities.where((f) {
      final matchesQuery = query.isEmpty ||
          f.name.toLowerCase().contains(query) ||
          (f.address?.toLowerCase().contains(query) ?? false);
      final matchesCat = _selectedCategory == 'Semua' ||
          f.category.toLowerCase().contains(_selectedCategory.toLowerCase());
      return matchesQuery && matchesCat;
    }).toList();
  }

  void _searchNearby() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final facilities = _filteredFacilities;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Fasilitas Kesehatan Terdekat'),
        actions: [
          IconButton(
            tooltip: 'Perbarui Lokasi GPS',
            icon: const Icon(Icons.my_location_rounded),
            onPressed: _searchNearby,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        children: [
          // Subtitle & Status Badge
          Row(
            children: [
              StatusBadge.active(label: 'Radius 10 km • OpenStreetMap'),
              const Spacer(),
              Text(
                '${facilities.length} Ditemukan',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 1. ROUNDED SEARCH BAR (Dribbble Screen 2 inspired)
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.lightGreen, width: 1.2),
              boxShadow: AppColors.cardShadow,
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Cari rumah sakit, klinik, atau dokter...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 20, color: AppColors.textMuted),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                      });
                    },
                  ),
                Container(
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.darkGreen,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
                    tooltip: 'Filter',
                    onPressed: _searchNearby,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2. CATEGORY SELECTION CARDS (Dribbble Screen 2 inspired category tiles)
          const Text(
            'Kategori Faskes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 94,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = cat['name'] == _selectedCategory;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat['name'] as String;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 86,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.darkGreen : AppColors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.darkGreen
                            : (cat['color'] as Color).withValues(alpha: 0.25),
                        width: 1.2,
                      ),
                      boxShadow: isSelected ? AppColors.heroShadow : AppColors.cardShadow,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.15)
                                : cat['bg'] as Color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            cat['icon'] as IconData,
                            size: 20,
                            color: isSelected ? Colors.white : cat['color'] as Color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cat['name'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : AppColors.darkGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // 3. MAP PREVIEW VISUAL CARD
          _buildMapPreviewCard(context),
          const SizedBox(height: 22),

          // 4. NEARBY HEALTHCARE FACILITY LIST
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daftar Fasilitas Sekitar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGreen,
                ),
              ),
              if (_isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Facility Cards (Dribbble Top Doctor cards hierarchy)
          if (facilities.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: Center(
                child: Text(
                  'Tidak ada fasilitas kesehatan yang cocok dengan kriteria pencarian.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13.5),
                ),
              ),
            )
          else
            ...facilities.map((facility) => _buildFacilityCard(context, facility)),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // MAP PREVIEW CARD
  // -------------------------------------------------------------------------
  Widget _buildMapPreviewCard(BuildContext context) {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.sageGreen, width: 1.2),
        boxShadow: AppColors.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Abstract Map Grid Lines
          CustomPaint(
            size: Size.infinite,
            painter: _MapGridPainter(),
          ),
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.darkGreen.withValues(alpha: 0.8),
                  AppColors.darkGreen.withValues(alpha: 0.4),
                ],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Peta Lokasi Saat Ini',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Malang (-7.9526, 112.6144)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Pencarian aktif hingga radius 10 km',
                        style: TextStyle(
                          color: AppColors.lightGreen,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: AppColors.heroShadow,
                  ),
                  child: const Icon(
                    Icons.fmd_good_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // FACILITY INFORMATION CARD (Inspired by Dribbble Doctor Card)
  // -------------------------------------------------------------------------
  Widget _buildFacilityCard(BuildContext context, HealthcareFacility facility) {
    final distanceKm = (facility.distanceMeters / 1000).toStringAsFixed(1);

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HealthcareDetailScreen(facility: facility),
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Avatar with soft pastel background
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.local_hospital_rounded,
              color: AppColors.primaryGreen,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.sageGreen.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        facility.category,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkGreen,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.near_me_rounded,
                          size: 13,
                          color: AppColors.primaryGreen,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$distanceKm km',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  facility.name,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGreen,
                    letterSpacing: -0.2,
                  ),
                ),
                if (facility.address != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    facility.address!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (facility.isWheelchairAccessible == true)
                      Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.successBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.accessible_rounded, size: 12, color: AppColors.success),
                            SizedBox(width: 4),
                            Text(
                              'Akses Kursi Roda',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Spacer(),
                    const Text(
                      'Lihat Detail',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 1.5;

    for (double i = 0; i < size.width; i += 30) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), linePaint);
    }
    for (double i = 0; i < size.height; i += 30) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
