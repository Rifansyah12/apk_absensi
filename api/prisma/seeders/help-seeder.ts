// prisma/seeders/help-seeder.ts
import { PrismaClient, Division, HelpContentType } from '@prisma/client';

export async function seedHelpContent(prisma: PrismaClient) {
  console.log('📚 Seeding help content...');

  // Hapus semua data help content yang ada
  await prisma.helpContent.deleteMany({});
  console.log('🧹 Cleared existing help content');

  // FAQ Global (untuk semua divisi)
  const globalFaqs = [
    {
      title: 'Bagaimana cara melakukan absensi?',
      content: 'Untuk melakukan absensi, buka menu "Absensi" lalu pilih "Check In" di pagi hari dan "Check Out" di sore hari. Pastikan Anda mengupload foto selfie sebagai bukti kehadiran.',
      type: 'FAQ' as HelpContentType,
      order: 1,
      division: null, // Global content
    },
    {
      title: 'Apa yang harus dilakukan jika lupa melakukan absensi?',
      content: 'Jika lupa melakukan absensi, segera hubungi HRD atau atasan langsung untuk mengajukan permohonan perbaikan absensi. Lampirkan bukti yang mendukung.',
      type: 'FAQ' as HelpContentType,
      order: 2,
      division: null, // Global content
    },
    {
      title: 'Bagaimana cara mengajukan cuti?',
      content: 'Untuk mengajukan cuti, buka menu "Cuti" lalu pilih "Ajukan Cuti". Isi formulir pengajuan cuti dengan lengkap dan tunggu persetujuan dari atasan.',
      type: 'FAQ' as HelpContentType,
      order: 3,
      division: null, // Global content
    },
    {
      title: 'Bagaimana cara mengubah foto profil?',
      content: 'Untuk mengubah foto profil, buka menu "Pengaturan" lalu pilih "Ubah Foto". Anda dapat memilih foto dari galeri atau mengambil foto baru.',
      type: 'FAQ' as HelpContentType,
      order: 4,
      division: null, // Global content
    },
    {
      title: 'Apa yang harus dilakukan jika password lupa?',
      content: 'Jika lupa password, Anda dapat menggunakan fitur "Ubah Password" di menu Pengaturan. Masukkan password lama dan buat password baru.',
      type: 'FAQ' as HelpContentType,
      order: 5,
      division: null, // Global content
    },
  ];

  // Kontak Support Global
  const globalContacts = [
    {
      title: 'HRD Department',
      content: JSON.stringify({
        name: 'Budi Santoso',
        phone: '081234567890',
        email: 'hrd@company.com'
      }),
      type: 'CONTACT' as HelpContentType,
      order: 1,
      division: null, // Global content
    },
    {
      title: 'IT Support',
      content: JSON.stringify({
        name: 'Ahmad Rizki',
        phone: '081234567891',
        email: 'it-support@company.com'
      }),
      type: 'CONTACT' as HelpContentType,
      order: 2,
      division: null, // Global content
    },
  ];

  // App Info Global
  const appInfo = [
    {
      title: 'Informasi Aplikasi',
      content: JSON.stringify({
        version: '1.0.0',
        createdBy: 'Tim IT Perusahaan',
        lastUpdate: 'November 2024',
        platform: 'Android & iOS'
      }),
      type: 'APP_INFO' as HelpContentType,
      order: 1,
      division: null, // Global content
    },
  ];

  // Konten khusus divisi FINANCE
  const financeFaqs = [
    {
      title: 'Kapan gaji biasanya ditransfer?',
      content: 'Gaji biasanya ditransfer pada tanggal 25 setiap bulan. Jika tanggal 25 jatuh pada hari libur, akan diproses pada hari kerja sebelumnya.',
      type: 'FAQ' as HelpContentType,
      order: 6,
      division: 'FINANCE' as Division,
    },
    {
      title: 'Bagaimana cara melihat riwayat gaji?',
      content: 'Riwayat gaji dapat dilihat di menu "Gaji & Potongan". Anda dapat melihat detail gaji untuk setiap periode.',
      type: 'FAQ' as HelpContentType,
      order: 7,
      division: 'FINANCE' as Division,
    },
    {
      title: 'Apa saja komponen gaji yang diterima?',
      content: 'Gaji terdiri dari gaji pokok, tunjangan, lembur, dan potongan. Detailnya dapat dilihat di slip gaji masing-masing bulan.',
      type: 'FAQ' as HelpContentType,
      order: 8,
      division: 'FINANCE' as Division,
    },
  ];

  // Konten khusus divisi ONSITE
  const onsiteFaqs = [
    {
      title: 'Bagaimana absensi untuk karyawan onsite?',
      content: 'Karyawan onsite dapat melakukan absensi dari lokasi project menggunakan fitur GPS. Pastikan lokasi Anda sesuai dengan area project.',
      type: 'FAQ' as HelpContentType,
      order: 6,
      division: 'ONSITE' as Division,
    },
    {
      title: 'Apakah ada tunjangan transportasi?',
      content: 'Ya, karyawan onsite mendapatkan tunjangan transportasi yang akan dibayarkan bersamaan dengan gaji bulanan.',
      type: 'FAQ' as HelpContentType,
      order: 7,
      division: 'ONSITE' as Division,
    },
    {
      title: 'Bagaimana cara melaporkan kegiatan harian?',
      content: 'Kegiatan harian dapat dilaporkan melalui aplikasi dengan mengisi form laporan harian di menu "Laporan Onsite".',
      type: 'FAQ' as HelpContentType,
      order: 8,
      division: 'ONSITE' as Division,
    },
  ];

  // Konten khusus divisi FRONT_DESK
  const frontDeskFaqs = [
    {
      title: 'Bagaimana menangani tamu penting?',
      content: 'Tamu penting harus dicatat dalam buku tamu khusus dan dilaporkan ke supervisor. Pastikan memberikan pelayanan terbaik.',
      type: 'FAQ' as HelpContentType,
      order: 6,
      division: 'FRONT_DESK' as Division,
    },
    {
      title: 'Apa prosedur penerimaan paket?',
      content: 'Semua paket harus dicatat, diberi label, dan disimpan di ruang penyimpanan. Pemilik paket dihubungi via telepon atau email.',
      type: 'FAQ' as HelpContentType,
      order: 7,
      division: 'FRONT_DESK' as Division,
    },
  ];

  // Konten khusus divisi APO
  const apoFaqs = [
    {
      title: 'Bagaimana prosedur pengadaan barang?',
      content: 'Pengadaan barang harus melalui proses approval dari manager. Isi form pengadaan dan lampirkan quotation dari vendor.',
      type: 'FAQ' as HelpContentType,
      order: 6,
      division: 'APO' as Division,
    },
    {
      title: 'Apa saja dokumen yang perlu disiapkan untuk audit?',
      content: 'Siapkan laporan pengadaan, invoice, receipt, dan dokumentasi barang. Semua harus tersusun rapi sesuai periode.',
      type: 'FAQ' as HelpContentType,
      order: 7,
      division: 'APO' as Division,
    },
  ];

  // Gabungkan semua data
  const allHelpContent = [
    ...globalFaqs,
    ...globalContacts,
    ...appInfo,
    ...financeFaqs,
    ...onsiteFaqs,
    ...frontDeskFaqs,
    ...apoFaqs,
  ];

  // Create help content dengan approach yang lebih aman
  for (const content of allHelpContent) {
    try {
      // Gunakan create dengan skip duplicates handling
      await prisma.helpContent.create({
        data: {
          division: content.division,
          title: content.title,
          content: content.content,
          type: content.type,
          order: content.order,
          createdBy: 1, // ID Super Admin pertama
        },
      });
      console.log(`✅ Created help content: ${content.title}`);
    } catch (error: any) {
      if (error.code === 'P2002') {
        // Duplicate entry, skip dan log
        console.log(`⏭️  Skipped duplicate: ${content.title}`);
      } else {
        console.error(`❌ Error creating help content: ${content.title}`, error);
      }
    }
  }

  console.log('✅ Help content seeded');
}