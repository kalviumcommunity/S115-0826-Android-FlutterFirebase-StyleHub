import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/branch_provider.dart';
import '../../providers/service_provider.dart';
import '../../providers/stylist_provider.dart';
import '../../core/widgets/cards/branch_card.dart';
import '../../core/widgets/cards/service_card.dart';
import '../../core/widgets/cards/stylist_card.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/shimmer_loading.dart';
import '../../models/appointment_model.dart';

class CustomerHomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToAppointments;
  final VoidCallback? onNavigateToHistory;

  const CustomerHomeScreen({
    super.key,
    this.onNavigateToAppointments,
    this.onNavigateToHistory,
  });

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _currentIndex = 0;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Hair', 'Skin', 'Spa', 'Nails', 'Grooming'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.currentUser != null) {
        Provider.of<BookingProvider>(context, listen: false).listenToCustomerAppointments(auth.currentUser!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F5F9), // slate-100
      child: SafeArea(
        child: _buildExactPortDashboard(context),
      ),
    );
  }

  Widget _buildExactPortDashboard(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final bookingProv = Provider.of<BookingProvider>(context);
    final branchProv = Provider.of<BranchProvider>(context);
    final serviceProv = Provider.of<ServiceProvider>(context);
    final stylistProv = Provider.of<StylistProvider>(context);
    final userName = auth.currentUser?.name ?? 'Guest';
    final uid = auth.currentUser?.uid ?? 'GUEST';
    
    final upcoming = bookingProv.customerAppointments.where((a) => a.status == 'confirmed' || a.status == 'pending').toList();
    final nextAppointment = upcoming.isNotEmpty ? upcoming.first : null;

    final filteredBranches = branchProv.branches.where((b) => b.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    final filteredServices = serviceProv.services.where((s) {
      final matchesQuery = s.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCat = _selectedCategory == 'All' || s.category.toLowerCase().contains(_selectedCategory.toLowerCase());
      return matchesQuery && matchesCat;
    }).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header & Greeting
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome, color: Color(0xFFE11D48), size: 14),
                            const SizedBox(width: 4),
                            const Text('STYLEHUB NETWORK', style: TextStyle(color: Color(0xFFE11D48), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text('Hello, ${userName.split(' ').first}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))), // slate-900
                        const Text('Welcome to your centralized salon sanctuary', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))), // slate-500
                      ],
                    ),
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundImage: auth.currentUser?.profileImage != null ? NetworkImage(auth.currentUser!.profileImage!) : null,
                          backgroundColor: Colors.grey[300],
                          child: auth.currentUser?.profileImage == null ? const Icon(Icons.person, color: Colors.white) : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981), // emerald-500
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),

                // Global Customer Pass Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF4C0519)], // slate-900 via slate-800 to rose-950
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                  child: Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      Positioned(
                        right: -20,
                        top: -40,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE11D48).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.shield, color: Color(0xFFFDA4AF), size: 12), // rose-300
                                          const SizedBox(width: 4),
                                          const Text('Universal Salon Pass', style: TextStyle(color: Color(0xFFFDA4AF), fontSize: 10, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text('Multi-Branch Freedom', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                    const SizedBox(height: 4),
                                    Text('Your service history, favorite stylists, and VIP preferences are shared seamlessly across all branches.', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    width: 80,
                                    child: Text('UID: $uid', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontFamily: 'monospace'), overflow: TextOverflow.ellipsis, maxLines: 1, textAlign: TextAlign.right),
                                  ),
                                  const SizedBox(height: 12),
                                  GestureDetector(
                                    onTap: () => widget.onNavigateToHistory?.call(),
                                    child: const Row(
                                      children: [
                                        Text('History', style: TextStyle(color: Color(0xFFFB7185), fontSize: 12, fontWeight: FontWeight.bold)), // rose-400
                                        Icon(Icons.chevron_right, color: Color(0xFFFB7185), size: 16),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Next Upcoming Appointment
                if (nextAppointment != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('UPCOMING APPOINTMENT', style: TextStyle(color: Color(0xFF334155), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)), // slate-700
                      GestureDetector(
                        onTap: () {},
                        child: const Row(
                          children: [
                            Text('View All', style: TextStyle(color: Color(0xFFE11D48), fontSize: 12, fontWeight: FontWeight.bold)),
                            Icon(Icons.chevron_right, color: Color(0xFFE11D48), size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AppCard(
                    backgroundColor: const Color(0xFFFFF1F2), // rose-50
                    borderColor: const Color(0xFFFECDD3), // rose-200
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Color(0xFFF43F5E), size: 14), // rose-500
                                const SizedBox(width: 4),
                                Text(nextAppointment.branchName, style: const TextStyle(color: Color(0xFF1E293B), fontSize: 12, fontWeight: FontWeight.bold)), // slate-800
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(nextAppointment.status.toUpperCase(), style: const TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(nextAppointment.serviceName, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.bold)), // slate-900
                                Text('With ${nextAppointment.stylistName}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)), // slate-500
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, color: Color(0xFF94A3B8), size: 12),
                                    const SizedBox(width: 4),
                                    Text(nextAppointment.appointmentDate, style: const TextStyle(color: Color(0xFF1E293B), fontSize: 12, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Text(nextAppointment.startTime, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)), // slate-200
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)],
                  ),
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Search branches, haircuts, facials, or stylists...',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8), size: 18),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      suffixIcon: _searchQuery.isNotEmpty 
                        ? IconButton(icon: const Icon(Icons.clear, size: 16), onPressed: () => setState(() => _searchQuery = '')) 
                        : null,
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),

                // Quick Book CTA
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE11D48), // rose-600
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Need a Fresh Style?', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                            Text('Select branch, service, and stylist in seconds', style: TextStyle(color: const Color(0xFFFFE4E6), fontSize: 11)), // rose-100
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      AppButton(
                        label: 'Quick Book',
                        variant: AppButtonVariant.secondary, // Assuming secondary is slate or white
                        height: 36,
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.bookingFlow),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Branches Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('StyleHub Branches', style: TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.bold)),
                        Text('Cross-branch appointments available', style: TextStyle(color: const Color(0xFF64748B), fontSize: 11)),
                      ],
                    ),
                    Text('${filteredBranches.length} Outlets', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Branches Grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: branchProv.branches.isEmpty
            ? SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(child: ShimmerLoading(width: double.infinity, height: 260)),
                    const SizedBox(width: 12),
                    Expanded(child: ShimmerLoading(width: double.infinity, height: 260)),
                  ],
                ),
              )
            : SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.52, // Adjust for BranchCard height
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => BranchCard(
                    branch: filteredBranches[index],
                    onSelect: () => Navigator.pushNamed(context, AppRoutes.bookingFlow),
                    onViewDetails: () => Navigator.pushNamed(context, AppRoutes.bookingFlow),
                  ),
                  childCount: filteredBranches.length,
                ),
              ),
        ),

        // Services Section Header & Pills
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0, bottom: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Popular Services', style: TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.bold)),
                Text('Premium hair, skin, and spa treatments', style: TextStyle(color: const Color(0xFF64748B), fontSize: 11)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 32,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = _selectedCategory == cat;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9), // slate-900 : slate-100
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              cat,
                              style: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFF475569), // white : slate-600
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // Services Grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: serviceProv.services.isEmpty
            ? SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(child: ShimmerLoading(width: double.infinity, height: 260)),
                    const SizedBox(width: 12),
                    Expanded(child: ShimmerLoading(width: double.infinity, height: 260)),
                  ],
                ),
              )
            : SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.52, // Adjust for ServiceCard height
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => ServiceCard(
                    service: filteredServices[index],
                    onSelect: () => Navigator.pushNamed(context, AppRoutes.bookingFlow),
                  ),
                  childCount: filteredServices.length,
                ),
              ),
        ),

        // Stylists Section Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0, bottom: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Master Stylists', style: TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.bold)),
                Text('Top rated across outlets', style: TextStyle(color: const Color(0xFF64748B), fontSize: 11)),
              ],
            ),
          ),
        ),

        // Stylists Grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: stylistProv.stylists.isEmpty
            ? SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(child: ShimmerLoading(width: double.infinity, height: 260)),
                    const SizedBox(width: 12),
                    Expanded(child: ShimmerLoading(width: double.infinity, height: 260)),
                  ],
                ),
              )
            : SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.52, // Adjust for StylistCard height
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => StylistCard(
                    stylist: stylistProv.stylists[index],
                    onSelect: () => Navigator.pushNamed(context, AppRoutes.bookingFlow),
                  ),
                  childCount: stylistProv.stylists.length > 4 ? 4 : stylistProv.stylists.length,
                ),
              ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  Widget _buildHistory(BuildContext context) {
    final bookingProv = Provider.of<BookingProvider>(context);
    final history = bookingProv.customerAppointments.where((a) => a.status != 'confirmed' && a.status != 'pending').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Past Appointments'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('No history found', style: TextStyle(fontSize: 18, color: Colors.grey[500], fontWeight: FontWeight.w500)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final apt = history[index];
                final isCancelled = apt.status == 'cancelled' || apt.status == 'rejected';
                return AppCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  borderColor: isCancelled ? Colors.red.withOpacity(0.3) : Colors.green.withOpacity(0.3),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: isCancelled ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                      child: Icon(isCancelled ? Icons.close : Icons.check, color: isCancelled ? Colors.red : Colors.green),
                    ),
                    title: Text(apt.serviceName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${apt.appointmentDate} • ${apt.branchName}'),
                    trailing: Text(apt.status.toUpperCase(), style: TextStyle(color: isCancelled ? Colors.red : Colors.green, fontWeight: FontWeight.w600)),
                  ),
                );
              },
            ),
    );
  }
}
