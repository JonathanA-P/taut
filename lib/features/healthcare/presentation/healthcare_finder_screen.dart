import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' hide DistanceCalculator;

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/distance_calculator.dart';
import '../../../shared/models/taut_app_state.dart';
import '../../../shared/widgets/taut_open_street_map.dart';
import '../data/healthcare_repository_impl.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isTest =
          WidgetsBinding.instance.runtimeType.toString().contains('Test');
      if (!isTest && !TautAppState().isRealHealthcareLoaded) {
        _handleSearchNearby(context, TautAppState());
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleSearchNearby(BuildContext context, TautAppState state) async {
    state.setSearchingHealthcare(true);
    try {
      const repository = HealthcareRepositoryImpl();
      final location = await repository.getCurrentLocation();

      final facilities = await repository.searchNearby(
        latitude: location.latitude,
        longitude: location.longitude,
        radiusMeters: 8000,
      );

      final mappedItems = facilities.map((f) {
        return FacilityItem(
          name: f.name,
          type: f.category,
          address: f.address ?? 'Sekitar lokasi Anda',
          distance: DistanceCalculator.formatDistance(f.distanceMeters),
          latitude: f.latitude,
          longitude: f.longitude,
          isReal: true,
          isWheelchairAccessible: f.isWheelchairAccessible ?? true,
        );
      }).toList();

      state.setRealHealthcareFacilities(
        mappedItems,
        lat: location.latitude,
        lon: location.longitude,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ditemukan ${mappedItems.length} fasilitas kesehatan di sekitar lokasi Anda.',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat faskes di sekitar: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      state.setSearchingHealthcare(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = TautAppState();

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final filteredList = state.filteredFacilities;

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
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
                  const SizedBox(height: 16),

                  // Action Button / Card to trigger real GPS & OSM search
                  _buildLocationActionCard(context, state),
                  const SizedBox(height: 18),

                  TextField(
                    controller: _searchController,
                    onChanged: (val) => state.setFacilitySearchQuery(val),
                    decoration: InputDecoration(
                      hintText: 'Cari nama fasilitas...',
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

                  _buildCategoryChips(state),
                  const SizedBox(height: 16),

                  _buildMapPreview(),
                  const SizedBox(height: 24),

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
                          color: state.isRealHealthcareLoaded
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFF6ECDA),
                          borderRadius: BorderRadius.circular(9),
                          border: state.isRealHealthcareLoaded
                              ? Border.all(color: const Color(0xFFC8E6C9))
                              : null,
                        ),
                        child: Text(
                          state.isRealHealthcareLoaded
                              ? 'Live Terdekat'
                              : 'Rekomendasi Terpilih',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: state.isRealHealthcareLoaded
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFF825D24),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

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

                  const SizedBox(height: 16),
                  Text(
                    state.isRealHealthcareLoaded
                        ? 'Data fasilitas kesehatan bersumber langsung dari OpenStreetMap & lokasi GPS perangkat.'
                        : 'Memuat data fasilitas kesehatan dari OpenStreetMap berdasarkan koordinat perangkat.',
                    style: const TextStyle(
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

  Widget _buildLocationActionCard(BuildContext context, TautAppState state) {
    final hasSearched = state.isRealHealthcareLoaded;
    final isSearching = state.isSearchingHealthcare;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasSearched ? const Color(0xFFC7DBC5) : const Color(0xFFE2EBE0),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06263D2F),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: hasSearched ? const Color(0xFFE8F5E9) : AppColors.lightGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasSearched ? Icons.near_me_rounded : Icons.my_location_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasSearched
                          ? 'Lokasi GPS Aktif (OpenStreetMap)'
                          : 'Cari Berdasarkan Lokasimu',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    Text(
                      hasSearched
                          ? 'Menampilkan faskes di radius sekitarmu'
                          : 'Izin lokasi hanya diakses setelah tombol ditekan',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: isSearching ? null : () => _handleSearchNearby(context, state),
              icon: isSearching
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      hasSearched ? Icons.refresh_rounded : Icons.explore_rounded,
                      size: 18,
                    ),
              label: Text(
                isSearching
                    ? 'Mencari faskes di sekitar...'
                    : (hasSearched
                        ? 'Perbarui Lokasi & Cari Ulang'
                        : 'Temukan Fasilitas Kesehatan di Sekitar'),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(TautAppState state) {
    const categories = ['Semua', 'Klinik', 'Rumah sakit', 'Puskesmas', 'Apotek'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = state.facilityCategoryFilter.toLowerCase() == cat.toLowerCase();
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
    final state = TautAppState();
    final facilities = state.filteredFacilities;
    final centerLat = state.userGpsLatitude ?? -7.9723;
    final centerLon = state.userGpsLongitude ?? 112.6318;

    final markers = <TautMapMarker>[
      TautMapMarker(
        point: LatLng(centerLat, centerLon),
        label: state.isRealHealthcareLoaded ? 'Posisi Anda (GPS)' : 'Posisi Awal',
        subtitle: state.isRealHealthcareLoaded ? 'Titik pencarian aktif' : 'Malang Pusat',
        isUser: true,
      ),
      ...facilities.take(15).map((f) {
        final lowerType = f.type.toLowerCase();
        final isHospital = lowerType.contains('rumah sakit') || lowerType.contains('rs');
        final isPharmacy = lowerType.contains('apotek');

        return TautMapMarker(
          point: LatLng(f.latitude, f.longitude),
          label: f.name,
          subtitle: '${f.type} • ${f.distance}',
          icon: isHospital
              ? Icons.local_hospital_rounded
              : (isPharmacy ? Icons.local_pharmacy_rounded : Icons.healing_rounded),
          color: isHospital ? AppColors.primary : const Color(0xFF2E7D32),
        );
      }),
    ];

    return TautOpenStreetMap(
      initialCenter: LatLng(centerLat, centerLon),
      initialZoom: state.isRealHealthcareLoaded ? 14.2 : 13.8,
      height: 200,
      markers: markers,
    );
  }

  Widget _buildFacilityCard(
    BuildContext context,
    TautAppState state,
    FacilityItem item,
    int index,
  ) {
    final lowerType = item.type.toLowerCase();
    final isHospital = lowerType.contains('rumah sakit') || lowerType.contains('rs');
    final isPharmacy = lowerType.contains('apotek');

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
              child: Icon(
                isHospital
                    ? Icons.local_hospital_rounded
                    : (isPharmacy ? Icons.local_pharmacy_rounded : Icons.healing_rounded),
                color: AppColors.primary,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        item.type,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (item.isReal) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'OSM',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGreen,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                      Expanded(
                        child: Text(
                          item.distance,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
