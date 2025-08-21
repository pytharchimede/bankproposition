import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';

class AgencyMapScreen extends StatefulWidget {
  const AgencyMapScreen({super.key});

  @override
  State<AgencyMapScreen> createState() => _AgencyMapScreenState();
}

class _AgencyMapScreenState extends State<AgencyMapScreen>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLoading = true;
  String _selectedFilter = 'Tous';
  _Agency? _selectedAgency;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> _filters = ['Tous', 'Agences', 'DAB', 'Bureaux de change'];

  // Données fictives des agences BDU en Côte d'Ivoire
  final List<_Agency> _agencies = [
    _Agency(
      id: '1',
      name: 'BDU Plateau',
      type: 'Agence',
      address: 'Avenue Chardy, Plateau, Abidjan',
      phone: '+225 27 20 21 20 00',
      hours: 'Lun-Ven: 8h-17h, Sam: 8h-12h',
      services: ['Comptes', 'Crédits', 'Change', 'Coffres'],
      position: LatLng(5.3196, -4.0167),
      distance: 0.0,
      hasATM: true,
      isOpen: true,
    ),
    _Agency(
      id: '2',
      name: 'BDU Marcory',
      type: 'Agence',
      address: 'Boulevard VGE, Marcory, Abidjan',
      phone: '+225 27 21 35 42 10',
      hours: 'Lun-Ven: 8h-17h, Sam: 8h-12h',
      services: ['Comptes', 'Crédits', 'Épargne'],
      position: LatLng(5.2669, -3.9910),
      distance: 0.0,
      hasATM: true,
      isOpen: true,
    ),
    _Agency(
      id: '3',
      name: 'DAB Cocody',
      type: 'DAB',
      address: 'Centre commercial Cocody, Abidjan',
      phone: '',
      hours: '24h/24',
      services: ['Retrait', 'Dépôt', 'Consultation'],
      position: LatLng(5.3458, -4.0103),
      distance: 0.0,
      hasATM: true,
      isOpen: true,
    ),
    _Agency(
      id: '4',
      name: 'BDU Yopougon',
      type: 'Agence',
      address: 'Carrefour Siporex, Yopougon, Abidjan',
      phone: '+225 27 23 45 67 89',
      hours: 'Lun-Ven: 8h-17h, Sam: 8h-12h',
      services: ['Comptes', 'Transferts', 'Mobile Money'],
      position: LatLng(5.3364, -4.0630),
      distance: 0.0,
      hasATM: true,
      isOpen: false,
    ),
    _Agency(
      id: '5',
      name: 'Bureau de Change Treichville',
      type: 'Bureau de change',
      address: 'Rue du Commerce, Treichville, Abidjan',
      phone: '+225 27 21 24 56 78',
      hours: 'Lun-Sam: 8h-18h',
      services: ['Change EUR', 'Change USD', 'Change GBP'],
      position: LatLng(5.2767, -4.0000),
      distance: 0.0,
      hasATM: false,
      isOpen: true,
    ),
  ];

  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _initializeLocation();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    try {
      // Vérifier les permissions
      final permission = await Permission.location.request();
      if (permission != PermissionStatus.granted) {
        setState(() => _isLoading = false);
        _showPermissionDialog();
        return;
      }

      // Obtenir la position actuelle
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Calculer les distances
      _calculateDistances();

      // Créer les marqueurs
      _createMarkers();

      setState(() => _isLoading = false);
      _slideController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog();
    }
  }

  void _calculateDistances() {
    if (_currentPosition == null) return;

    for (var agency in _agencies) {
      agency.distance =
          Geolocator.distanceBetween(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            agency.position.latitude,
            agency.position.longitude,
          ) /
          1000; // Conversion en kilomètres
    }

    // Trier par distance
    _agencies.sort((a, b) => a.distance.compareTo(b.distance));
  }

  void _createMarkers() {
    _markers.clear();

    // Marqueur de position actuelle
    if (_currentPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Ma position'),
        ),
      );
    }

    // Marqueurs des agences filtrées
    final filteredAgencies = _getFilteredAgencies();
    for (var agency in filteredAgencies) {
      _markers.add(
        Marker(
          markerId: MarkerId(agency.id),
          position: agency.position,
          icon: _getMarkerIcon(agency.type),
          infoWindow: InfoWindow(
            title: agency.name,
            snippet: '${agency.distance.toStringAsFixed(1)} km',
          ),
          onTap: () => _selectAgency(agency),
        ),
      );
    }
  }

  BitmapDescriptor _getMarkerIcon(String type) {
    switch (type) {
      case 'Agence':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case 'DAB':
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueOrange,
        );
      case 'Bureau de change':
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueViolet,
        );
      default:
        return BitmapDescriptor.defaultMarker;
    }
  }

  List<_Agency> _getFilteredAgencies() {
    if (_selectedFilter == 'Tous') return _agencies;
    return _agencies
        .where((agency) => agency.type == _selectedFilter.replaceAll('s', ''))
        .toList();
  }

  void _selectAgency(_Agency agency) {
    setState(() => _selectedAgency = agency);

    // Animer vers l'agence sélectionnée
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: agency.position, zoom: 16.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: BduColors.primary,
        title: const Text(
          'Agences & DAB',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.my_location, color: BduColors.primary),
            onPressed: _centerOnCurrentLocation,
          ),
          IconButton(
            icon: Icon(Icons.filter_list, color: BduColors.primary),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeAnimation,
              child: Stack(
                children: [
                  // Carte Google Maps
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentPosition != null
                          ? LatLng(
                              _currentPosition!.latitude,
                              _currentPosition!.longitude,
                            )
                          : const LatLng(5.3196, -4.0167), // Abidjan par défaut
                      zoom: 12.0,
                    ),
                    markers: _markers,
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    mapType: MapType.normal,
                    zoomControlsEnabled: false,
                  ),

                  // Filtre en haut
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: _FilterBar(
                      selectedFilter: _selectedFilter,
                      filters: _filters,
                      onFilterChanged: (filter) {
                        setState(() => _selectedFilter = filter);
                        _createMarkers();
                      },
                    ),
                  ),

                  // Liste des agences en bas
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _AgencyList(
                        agencies: _getFilteredAgencies(),
                        selectedAgency: _selectedAgency,
                        onAgencySelected: _selectAgency,
                      ),
                    ),
                  ),

                  // Détail de l'agence sélectionnée
                  if (_selectedAgency != null)
                    Positioned(
                      top: 80,
                      left: 16,
                      right: 16,
                      child: _AgencyDetailCard(
                        agency: _selectedAgency!,
                        onClose: () => setState(() => _selectedAgency = null),
                        onNavigate: () => _navigateToAgency(_selectedAgency!),
                        onCall: () => _callAgency(_selectedAgency!),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  void _centerOnCurrentLocation() {
    if (_currentPosition != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            ),
            zoom: 15.0,
          ),
        ),
      );
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtrer par type',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ..._filters.map(
              (filter) => ListTile(
                leading: Icon(
                  _getFilterIcon(filter),
                  color: _selectedFilter == filter
                      ? BduColors.primary
                      : Colors.grey,
                ),
                title: Text(filter),
                trailing: _selectedFilter == filter
                    ? Icon(Icons.check, color: BduColors.primary)
                    : null,
                onTap: () {
                  setState(() => _selectedFilter = filter);
                  _createMarkers();
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFilterIcon(String filter) {
    switch (filter) {
      case 'Agences':
        return Icons.account_balance;
      case 'DAB':
        return Icons.local_atm;
      case 'Bureaux de change':
        return Icons.currency_exchange;
      default:
        return Icons.location_on;
    }
  }

  void _navigateToAgency(_Agency agency) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${agency.position.latitude},${agency.position.longitude}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _callAgency(_Agency agency) async {
    if (agency.phone.isNotEmpty) {
      final url = 'tel:${agency.phone}';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission requise'),
        content: const Text(
          'L\'accès à votre localisation est nécessaire pour afficher les agences proches.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Paramètres'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreur'),
        content: const Text(
          'Impossible d\'obtenir votre localisation. Vérifiez vos paramètres GPS.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _Agency {
  final String id;
  final String name;
  final String type;
  final String address;
  final String phone;
  final String hours;
  final List<String> services;
  final LatLng position;
  double distance;
  final bool hasATM;
  final bool isOpen;

  _Agency({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.phone,
    required this.hours,
    required this.services,
    required this.position,
    required this.distance,
    required this.hasATM,
    required this.isOpen,
  });
}

class _FilterBar extends StatelessWidget {
  final String selectedFilter;
  final List<String> filters;
  final Function(String) onFilterChanged;

  const _FilterBar({
    required this.selectedFilter,
    required this.filters,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter == selectedFilter;
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (_) => onFilterChanged(filter),
              backgroundColor: Colors.white,
              selectedColor: BduColors.primary.withValues(alpha: 0.2),
              checkmarkColor: BduColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? BduColors.primary : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? BduColors.primary : Colors.grey[300]!,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AgencyList extends StatelessWidget {
  final List<_Agency> agencies;
  final _Agency? selectedAgency;
  final Function(_Agency) onAgencySelected;

  const _AgencyList({
    required this.agencies,
    required this.selectedAgency,
    required this.onAgencySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: agencies.length,
              itemBuilder: (context, index) {
                final agency = agencies[index];
                return _AgencyCard(
                  agency: agency,
                  isSelected: agency == selectedAgency,
                  onTap: () => onAgencySelected(agency),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AgencyCard extends StatelessWidget {
  final _Agency agency;
  final bool isSelected;
  final VoidCallback onTap;

  const _AgencyCard({
    required this.agency,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? BduColors.primary.withValues(alpha: 0.1)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? BduColors.primary : Colors.grey[200]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getTypeColor(agency.type).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getTypeIcon(agency.type),
            color: _getTypeColor(agency.type),
            size: 20,
          ),
        ),
        title: Text(
          agency.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              agency.address,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.location_on, size: 12, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  '${agency.distance.toStringAsFixed(1)} km',
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: agency.isOpen ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    agency.isOpen ? 'Ouvert' : 'Fermé',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: agency.hasATM
            ? Icon(Icons.local_atm, color: Colors.green[600], size: 20)
            : null,
        onTap: onTap,
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Agence':
        return Icons.account_balance;
      case 'DAB':
        return Icons.local_atm;
      case 'Bureau de change':
        return Icons.currency_exchange;
      default:
        return Icons.location_on;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Agence':
        return Colors.green;
      case 'DAB':
        return Colors.orange;
      case 'Bureau de change':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

class _AgencyDetailCard extends StatelessWidget {
  final _Agency agency;
  final VoidCallback onClose;
  final VoidCallback onNavigate;
  final VoidCallback onCall;

  const _AgencyDetailCard({
    required this.agency,
    required this.onClose,
    required this.onNavigate,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                  color: BduColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getTypeIcon(agency.type),
                  color: BduColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      agency.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      agency.type,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 12),

          _DetailRow(icon: Icons.location_on, text: agency.address),

          if (agency.phone.isNotEmpty)
            _DetailRow(icon: Icons.phone, text: agency.phone),

          _DetailRow(icon: Icons.schedule, text: agency.hours),

          if (agency.services.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: agency.services
                  .map(
                    (service) => Chip(
                      label: Text(
                        service,
                        style: const TextStyle(fontSize: 10),
                      ),
                      backgroundColor: BduColors.primary.withValues(alpha: 0.1),
                      labelStyle: TextStyle(color: BduColors.primary),
                    ),
                  )
                  .toList(),
            ),
          ],

          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onNavigate,
                  icon: const Icon(Icons.directions),
                  label: const Text('Itinéraire'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: BduColors.primary,
                    side: BorderSide(color: BduColors.primary),
                  ),
                ),
              ),
              if (agency.phone.isNotEmpty) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onCall,
                    icon: const Icon(Icons.phone),
                    label: const Text('Appeler'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BduColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Agence':
        return Icons.account_balance;
      case 'DAB':
        return Icons.local_atm;
      case 'Bureau de change':
        return Icons.currency_exchange;
      default:
        return Icons.location_on;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey[700], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
