import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/models/taut_app_state.dart';
import '../../../shared/widgets/taut_illustrations.dart';

/// Healthcare Finder Screen strictly implementing the TAUT HTML prototype design:
/// - Screen title: "Fasilitas kesehatan"
/// - Heading: "Temukan bantuan di sekitarmu."
/// - Subtitle: "Tempat yang tepat, lebih mudah dijangkau."
/// - Search input: "Cari nama fasilitas…"
/// - Category Chips: "Semua", "Klinik", "Rumah sakit", "Puskesmas"
/// - Map illustration: "Peta ilustrasi · bukan posisi nyata"
/// - List of facilities with hospital icon, category, name, distance ("jarak contoh")
/// - Empty state: "Tidak ada fasilitas yang sesuai. Coba kata lain."
/// - Bottom hint: "Nama, alamat, dan jarak di sini fiktif untuk peninjauan desain."
class HealthcareFinderScreen extends StatefulWidget {
  const HealthcareFinderScreen({super.key});

  @override
  State<HealthcareFinderScreen> createState() => _HealthcareFinderScreenState();
}

class _HealthcareFinderScreenState extends State<HealthcareFinderScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: TautAppState().facilitySearchQuery,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = TautAppState();

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final filteredList = state.filteredFacilities;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: (Navigator.canPop(context) || state.canPopPage)
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: AppColors.darkGreen,
                    onPressed: () {
                      if (state.canPopPage) {
                        state.popPage();
                      } else if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                  )
                : null,
            title: const Text(
              'Fasilitas kesehatan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.darkGreen,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Headline & Subtitle
                  const Text(
                    'Temukan bantuan\ndi sekitarmu.',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGreen,
                      height: 1.2,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Tempat yang tepat, lebih mudah dijangkau.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Search input
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => state.setFacilitySearchQuery(val),
                    decoration: InputDecoration(
                      hintText: 'Cari nama fasilitas…',
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.textSecondary,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                state.setFacilitySearchQuery('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFD9E2D5)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFD9E2D5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Chips: 'Semua', 'Klinik', 'Rumah sakit', 'Puskesmas'
                  _buildCategoryChips(state),
                  const SizedBox(height: 16),

                  // Map Preview Card
                  _buildMapPreview(),
                  const SizedBox(height: 24),

                  // Section Title + Amber Tag
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pilihan di sekitar',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkGreen,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6ECDA),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Text(
                          'Data contoh',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF825D24),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Facilities Stack
                  if (filteredList.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE4E9E1)),
                      ),
                      child: const Center(
                        child: Text(
                          'Tidak ada fasilitas yang sesuai. Coba kata lain.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = filteredList[index];
                        return _buildFacilityCard(context, state, item, index);
                      },
                    ),

                  const SizedBox(height: 14),
                  const Text(
                    'Nama, alamat, dan jarak di sini fiktif untuk peninjauan desain.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.6,
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

  Widget _buildCategoryChips(TautAppState state) {
    const categories = ['Semua', 'Klinik', 'Rumah sakit', 'Puskesmas'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = state.facilityCategoryFilter == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => state.setFacilityCategoryFilter(cat),
              borderRadius: BorderRadius.circular(24),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : const Color(0xFFE4E9E1),
                  ),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.darkGreen,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMapPreview() {
    return Container(
      height: 170,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE9EEE3),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDAE3D3)),
      ),
      child: Stack(
        children: [
          // SVG / Illustration Background
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: TautIllustration.mapPlaceholder(),
            ),
          ),
          Positioned(
            left: 12,
            top: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xF0FFFFFF),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x10263D2F),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                'Peta ilustrasi · bukan posisi nyata',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGreen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityCard(
    BuildContext context,
    TautAppState state,
    FacilityItem item,
    int index,
  ) {
    return InkWell(
      onTap: () {
        state.setSelectedFacilityIndex(index);
        state.navigateTo('detail');
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE4E9E1)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x05263D2F),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.local_hospital_rounded,
                color: AppColors.primary,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.type,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${item.distance} · jarak contoh',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF9EAFA3),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
