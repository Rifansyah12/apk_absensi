import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:apk_absensi/services/help_service.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final HelpService _helpService = HelpService();
  late Future<HelpResponse> _helpDataFuture;

  @override
  void initState() {
    super.initState();
    _helpDataFuture = _helpService.getHelpData();
  }

  Future<void> _launchPhone(String phone) async {
    final Uri url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri url = Uri.parse('mailto:$email');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bantuan & Dukungan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.greenAccent[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<HelpResponse>(
        future: _helpDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          } else if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          } else if (snapshot.hasData) {
            return _buildContent(snapshot.data!);
          } else {
            return _buildErrorState('Tidak ada data bantuan');
          }
        },
      ),
    );
  }

  Widget _buildContent(HelpResponse helpData) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _helpDataFuture = _helpService.getHelpData();
        });
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeaderSection(),
          const SizedBox(height: 24),
          if (helpData.faqs.isNotEmpty) ...[
            _buildFaqSection(helpData.faqs),
            const SizedBox(height: 24),
          ],
          if (helpData.contacts.isNotEmpty) ...[
            _buildContactSection(helpData.contacts),
            const SizedBox(height: 24),
          ],
          if (helpData.appInfo.isNotEmpty) ...[
            _buildAppInfoSection(helpData.appInfo),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.help_outline,
              size: 64,
              color: Colors.greenAccent[700],
            ),
            const SizedBox(height: 16),
            const Text(
              'Butuh Bantuan?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Temukan jawaban untuk pertanyaan umum atau hubungi tim support kami untuk bantuan lebih lanjut.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqSection(List<HelpContent> faqs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pertanyaan Umum (FAQ)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Temukan jawaban untuk pertanyaan yang sering diajukan',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: faqs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            return _buildFaqItem(faqs[index]);
          },
        ),
      ],
    );
  }

  Widget _buildFaqItem(HelpContent faq) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        leading: Icon(
          Icons.help,
          color: Colors.greenAccent[700],
        ),
        title: Text(
          faq.title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Text(
              faq.content,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(List<HelpContent> contacts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hubungi Support',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tim support kami siap membantu Anda',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: contacts.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _buildContactCard(contacts[index]);
          },
        ),
      ],
    );
  }

  Widget _buildContactCard(HelpContent contact) {
    final contactInfo = contact.contactInfo;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent[700]?.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    color: Colors.greenAccent[700],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (contactInfo['name'] != null) ...[
                        Text(
                          contactInfo['name'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (contactInfo['phone'] != null) ...[
              _buildContactInfo(
                Icons.phone,
                contactInfo['phone'],
                () => _launchPhone(contactInfo['phone']),
              ),
              const SizedBox(height: 8),
            ],
            if (contactInfo['email'] != null) ...[
              _buildContactInfo(
                Icons.email,
                contactInfo['email'],
                () => _launchEmail(contactInfo['email']),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.greenAccent[700],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoSection(List<HelpContent> appInfoList) {
    if (appInfoList.isEmpty) return const SizedBox();
    
    final appInfo = appInfoList.first.appInfo;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Aplikasi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (appInfo['version'] != null) ...[
              _buildAppInfoItem('Versi Aplikasi', appInfo['version']),
            ],
            if (appInfo['createdBy'] != null) ...[
              _buildAppInfoItem('Dibuat Oleh', appInfo['createdBy']),
            ],
            if (appInfo['lastUpdate'] != null) ...[
              _buildAppInfoItem('Update Terakhir', appInfo['lastUpdate']),
            ],
            if (appInfo['platform'] != null) ...[
              _buildAppInfoItem('Platform', appInfo['platform']),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Memuat data bantuan...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          const Text(
            'Gagal memuat data bantuan',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _helpDataFuture = _helpService.getHelpData();
              });
            },
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}