import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_theme.dart';
import 'responsive_sizing.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  String appVersion = '1.1.0';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAppInfo() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
        });
      }
    } catch (e) {
      // Keep default version if package info fails
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final sizing = ResponsiveSizing(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeader(sizing),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: sizing.horizontalPadding),
            sliver: SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: sizing.sectionSpacing - 8),
                        _buildSectionHeader(
                          sizing: sizing,
                          icon: Icons.contact_mail_rounded,
                          title: 'Kontak Kami',
                        ),
                        SizedBox(height: sizing.itemSpacing),
                        _buildContactCards(sizing),
                        SizedBox(height: sizing.sectionSpacing),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(sizing),
    );
  }

  Widget _buildHeader(ResponsiveSizing sizing) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          color: bpsBlue,
          boxShadow: [BPSShadows.headerShadow],
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              sizing.horizontalPadding,
              sizing.horizontalPadding,
              sizing.horizontalPadding,
              sizing.horizontalPadding + 4,
            ),
            child: SizedBox(
              // Match home header content height exactly:
              // logo container + gap + actual search bar height (without the extra horizontalPadding baked into searchBarHeight)
              height: (sizing.headerLogoPadding * 2 + sizing.headerLogoSize) +
                  sizing.horizontalPadding +
                  (sizing.searchPadding * 2 + 20),
              child: Stack(
                children: [
                  // Back button at top left
                  Positioned(
                    left: 0,
                    top: 0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      iconSize: 20,
                    ),
                  ),
                  // Logo centered vertically and horizontally
                  Center(
                    child: Image.asset(
                      'assets/images/logo_white.png',
                      width: (sizing.headerLogoSize * 2) + 8,
                      height: (sizing.headerLogoSize * 2) + 8,
                      filterQuality: FilterQuality.medium,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.account_balance_rounded,
                          color: Colors.white,
                          size: (sizing.headerLogoSize * 2) + 8,
                        );
                      },
                    ),
                  ),
                  // Version at bottom right
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Text(
                      'V$appVersion',
                      style: TextStyle(
                        fontSize: sizing.headerSubtitleSize,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required ResponsiveSizing sizing,
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: bpsBlue,
          size: sizing.sectionIconSize,
        ),
        SizedBox(width: sizing.itemSpacing),
        Text(
          title,
          style: TextStyle(
            fontSize: sizing.sectionTitleSize,
            fontWeight: FontWeight.w700,
            color: bpsTextPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildContactCards(ResponsiveSizing sizing) {
    final contacts = [
      {
        'icon': Icons.language_rounded,
        'title': 'Website',
        'value': 'semarangkota.bps.go.id',
        'color': bpsContactColors['Website']!,
      },
      {
        'icon': Icons.email_rounded,
        'title': 'Email',
        'value': 'bps3374@bps.go.id',
        'color': bpsContactColors['Email']!,
      },
      {
        'icon': Icons.phone_rounded,
        'title': 'Telepon',
        'value': '(024) 3546713',
        'color': bpsContactColors['Telepon']!,
      },
      {
        'icon': Icons.location_on_rounded,
        'title': 'Alamat',
        'value': 'Jl. Inspeksi Kali Semarang No.1, Sekayu',
        'color': bpsContactColors['Alamat']!,
      },
    ];

    return Column(
      children: contacts.map((contact) {
        return Padding(
          padding: EdgeInsets.only(bottom: sizing.gridSpacing),
          child: _buildContactCard(
            sizing: sizing,
            icon: contact['icon'] as IconData,
            title: contact['title'] as String,
            value: contact['value'] as String,
            color: contact['color'] as Color,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContactCard({
    required ResponsiveSizing sizing,
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Material(
      color: bpsCardBg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () async {
          HapticFeedback.lightImpact();
          await _handleContactTap(title, value);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(sizing.categoryCardPadding),
          decoration: BoxDecoration(
            color: bpsCardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: bpsBorder,
              width: 1,
            ),
            boxShadow: [BPSShadows.cardShadow],
          ),
          child: Row(
            children: [
              Container(
                padding:
                    EdgeInsets.all(sizing.categoryIconContainerPadding - 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: sizing.categoryIconSize,
                ),
              ),
              SizedBox(width: sizing.itemSpacing + 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: sizing.categorySubLabelFontSize,
                        fontWeight: FontWeight.w500,
                        color: bpsTextSecondary,
                      ),
                    ),
                    SizedBox(height: sizing.itemSpacing - 6),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: sizing.categoryLabelFontSize - 1,
                        fontWeight: FontWeight.w600,
                        color: bpsTextPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.open_in_new_rounded,
                color: bpsTextLabel,
                size: sizing.categoryArrowSize,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleContactTap(String title, String value) async {
    try {
      if (title == 'Website') {
        final url = Uri.parse('https://$value');
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else if (title == 'Email') {
        final emailUrl = Uri.parse('mailto:$value');
        await launchUrl(emailUrl, mode: LaunchMode.externalApplication);
      } else if (title == 'Telepon') {
        final telUrl =
            Uri.parse('tel:${value.replaceAll(RegExp(r'[^\d+]'), '')}');
        await launchUrl(telUrl);
      } else if (title == 'Alamat') {
        final address = Uri.encodeComponent(
            'Jalan Inspeksi Kali Semarang No.1, Sekayu, Kec. Semarang Tengah, Kota Semarang, Jawa Tengah 50132');
        final mapsUrl = Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=$address');
        await launchUrl(mapsUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak dapat membuka $title'),
            backgroundColor: bpsRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Widget _buildBottomNav(ResponsiveSizing sizing) {
    return Container(
      decoration: BoxDecoration(
        color: bpsCardBg,
        boxShadow: [BPSShadows.bottomNavShadow],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: sizing.bottomNavHeight,
          padding: EdgeInsets.symmetric(
            horizontal: sizing.bottomNavPadding,
            vertical: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isSelected: false,
                sizing: sizing,
                onTap: _navigateToHome,
              ),
              _buildNavItem(
                icon: Icons.info_rounded,
                label: 'About Us',
                isSelected: true,
                sizing: sizing,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required ResponsiveSizing sizing,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          highlightColor: bpsBlue.withOpacity(0.1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? bpsBlue : bpsTextLabel,
                size: sizing.bottomNavIconSize,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: sizing.bottomNavLabelSize,
                  color: isSelected ? bpsBlue : bpsTextLabel,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
