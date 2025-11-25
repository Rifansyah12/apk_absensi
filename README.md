# APK Absensi

Aplikasi absensi berbasis mobile.

## Setup Proyek

Untuk menjalankan proyek ini, ikuti langkah-langkah berikut:

### API (Express & Prisma)

1.  **Clone repositori:**
    ```bash
    git clone https://github.com/my-repo/apk_absensi.git
    cd apk_absensi
    ```
2.  **Instal dependensi:**
    ```bash
    npm install
    # atau
    yarn install
    ```
3.  **Konfigurasi database:**
    Buat file `.env` di root proyek dan tambahkan konfigurasi database Anda. Contoh untuk PostgreSQL:
    ```
    DATABASE_URL="postgresql://user:password@localhost:5432/mydatabase?schema=public"
    ```
    Sesuaikan dengan database yang Anda gunakan (MySQL, SQLite, dll.).
4.  **Jalankan migrasi Prisma:**
    ```bash
    npx prisma migrate dev --name init
    ```
5.  **Jalankan server pengembangan:**
    ```bash
    npm run dev
    # atau
    yarn dev
    ```
    API akan berjalan di `http://localhost:3000` (atau port yang dikonfigurasi).

### Frontend (Flutter)

1.  **Clone repositori:**
    ```bash
    git clone https://github.com/my-repo/repo-frontend.git
    cd repo-frontend
    ```
2.  **Instal dependensi Flutter:**
    ```bash
    flutter pub get
    ```
3.  **Konfigurasi API URL:**
    Buka file konfigurasi di proyek Flutter Anda (misalnya `lib/config/api_config.dart` atau sejenisnya) dan sesuaikan URL API dengan backend yang sedang berjalan:
    ```dart
    const String API_BASE_URL = 'http://10.0.2.2:3000'; // Untuk emulator Android
    // const String API_BASE_URL = 'http://localhost:3000'; // Untuk iOS simulator atau web
    ```
    (Catatan: `10.0.2.2` adalah alias untuk `localhost` di emulator Android.)
4.  **Jalankan aplikasi Flutter:**
    ```bash
    flutter run
   