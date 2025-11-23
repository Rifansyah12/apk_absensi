// api/src/utils/file-storage.ts
import fs from 'fs';
import path from 'path';
import { v4 as uuidv4 } from 'uuid';

// Buat folder untuk profile photos
const createProfilePhotosDir = (): string => {
  const profileDir = path.join(__dirname, '../../public/uploads/profiles');
  if (!fs.existsSync(profileDir)) {
    fs.mkdirSync(profileDir, { recursive: true });
  }
  return profileDir;
};

// Buat folder untuk selfies (checkin/checkout)
const createSelfiesDir = (): string => {
  const selfiesDir = path.join(__dirname, '../../public/uploads/selfies');
  if (!fs.existsSync(selfiesDir)) {
    fs.mkdirSync(selfiesDir, { recursive: true });
  }
  return selfiesDir;
};

export const saveImageToFile = (imageBuffer: Buffer, userId: number, type: 'checkin' | 'checkout' | 'profile'): string => {
  try {
    let uploadsDir: string;
    let filename: string;

    if (type === 'profile') {
      uploadsDir = createProfilePhotosDir();
      filename = `profile_${userId}_${uuidv4()}.jpg`;
    } else {
      uploadsDir = createSelfiesDir();
      filename = `selfie_${userId}_${type}_${uuidv4()}.jpg`;
    }

    const filepath = path.join(uploadsDir, filename);
    console.log('📁 File disimpan di:', filepath);

    // Simpan file
    fs.writeFileSync(filepath, imageBuffer);
    // Saat menyimpan user
    // Return relative path
    if (type === 'profile') {
      return `/public/uploads/profiles/${filename}`;
    } else {
      return `/public/uploads/selfies/${filename}`;
    }
  } catch (error) {
    console.error('Error saving image file:', error);
    throw new Error('Gagal menyimpan foto');
  }
};

export const deleteImageFile = (filepath: string): void => {
  try {
    if (filepath && filepath.startsWith('/public/uploads/')) {
      const fullPath = path.join(__dirname, '../..', filepath);
      console.log('Deleting file:', fullPath);
      
      if (fs.existsSync(fullPath)) {
        fs.unlinkSync(fullPath);
        console.log('File deleted successfully:', filepath);
      } else {
        console.warn('File not found, cannot delete:', fullPath);
      }
    } else if (filepath) {
      console.warn('Invalid file path, cannot delete:', filepath);
    }
  } catch (error) {
    console.error('Error deleting image file:', error);
    // Jangan throw error di sini agar tidak mengganggu flow utama
  }
};