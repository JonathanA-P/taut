import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/models/taut_app_state.dart';
import '../../../shared/widgets/taut_open_street_map.dart';
import '../data/healthcare_repository_impl.dart';
import '../domain/healthcare_facility.dart';

class HealthcareDetailScreen extends StatelessWidget {
  final FacilityItem? facilityItem;
  final HealthcareFacility? facility;

  const HealthcareDetailScreen({
    super.key,
    this.facilityItem,
    this.facility,
  });

  @override
  Widget build(BuildContext context) {
    final name = facilityItem?.name ??
        facility?.name ??
        TautAppState().selectedFacility.name;
    final type = facilityItem?.type ??
        facility?.category ??
        TautAppState().selectedFacility.type;
    final address = facilityItem?.address ??
        facility?.address ??
        TautAppState().selectedFacility.address;
    final distance = facilityItem?.distance ??
        (facility != null
            ? '${(facility!.distanceMeters / 1000).toStringAsFixed(1)} km'
            : TautAppState().selectedFacility.distance);

    final lat = facilityItem?.latitude ??
        facility?.latitude ??
        TautAppState().selectedFacility.latitude;
    final lon = facilityItem?.longitude ??
        facility?.longitude ??
        TautAppState().selectedFacility.longitude;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: (Navigator.canPop(context) || TautAppState().canPopPage)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                color: AppColors.darkGreen,
                onPressed: () {
                  final state = TautAppState();
                  if (state.canPopPage) {
                    state.popPage();
                  } else if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              )
            : null,
        title: const Text(
          'Detail fasilitas',
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileHero(name, type, distance),
              const SizedBox(height: 20),

              _buildMapPreview(lat: lat, lon: lon, label: name),
              const SizedBox(height: 20),

              _buildInfoCard(address),
              const SizedBox(height: 24),

              _buildActionButtons(context, name, address, lat, lon),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHero(String name, String type, String distance) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
      decoration: BoxDecoration(
        color: AppColors.sageGreen,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFD0DDD0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0C263D2F),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.local_hospital_rounded,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              type,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4C6551),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGreen,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                distance,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapPreview({
    double lat = -7.9723,
    double lon = 112.6318,
    String label = 'Fasilitas Kesehatan',
  }) {
    return TautOpenStreetMap(
      initialCenter: LatLng(lat, lon),
      initialZoom: 15.2,
      height: 180,
      markers: [
        TautMapMarker(
          point: LatLng(lat, lon),
          label: label,
          icon: Icons.local_hospital_rounded,
          color: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildInfoCard(String address) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEDF0E9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05263D2F),
            blurRadius: 16,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi lokasi',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            address,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: const Color(0xFFC8E6C9)),
            ),
            child: const Text(
              'Layanan Ramah Aksesibilitas',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D32),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Color(0xFFE4E9E1), height: 1),
          ),
          const Text(
            'Jam buka, layanan, dan aksesibilitas',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Informasi belum tersedia',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.darkGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    String name,
    String address,
    double lat,
    double lon,
  ) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () => _showDirectionsModal(context, name, lat, lon),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: const Text(
              'Petunjuk Arah',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () => _showShareModal(context, name, address),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.darkGreen,
              side: const BorderSide(color: Color(0xFFB9C9B6)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.location_on_outlined, size: 18),
            label: const Text(
              'Bagikan lokasi fasilitas',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  void _showDirectionsModal(BuildContext context, String name, double lat, double lon) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rute ke $name',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGreen,
                ),
              ),
              const SizedBox(height: 14),
              _buildMapPreview(lat: lat, lon: lon, label: name),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () {
                    const HealthcareRepositoryImpl().openDirections(
                      destinationLat: lat,
                      destinationLon: lon,
                      label: name,
                    );
                    Navigator.pop(ctx);
                  },
                  icon: const Icon(Icons.navigation_rounded, size: 18),
                  label: const Text(
                    'Buka Navigasi Google Maps',
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showShareModal(BuildContext context, String name, String address) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bagikan fasilitas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGreen,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Ini membagikan informasi fasilitas, bukan lokasi langsungmu.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F3EB),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '$name - $address\nDATA DEMO - bukan fasilitas nyata.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF5B6E55),
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(
                        text: '$name - $address',
                      ),
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Alamat faskes berhasil disalin.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Salin Alamat Faskes'),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

