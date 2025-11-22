import fs from 'fs';
import path from 'path';
import { v4 as uuidv4 } from 'uuid';

export const saveImageToFile = (imageBuffer: Buffer, userId: number, type: 'checkin' | 'checkout'): string => {
  try {
    const uploadsDir = path.join(__dirname, '../../uploads/selfies');
    
    // Buat directory jika belum ada
    if (!fs.existsSync(uploadsDir)) {
      fs.mkdirSync(uploadsDir, { recursive: true });
    }

    const filename = `selfie_${userId}_${type}_${uuidv4()}.jpg`;
    const filepath = path.join(uploadsDir, filename);

    // Simpan file
    fs.writeFileSync(filepath, imageBuffer);
    
    return `/uploads/selfies/${filename}`;
  } catch (error) {
    console.error('Error saving image file:', error);
    throw new Error('Gagal menyimpan foto');
  }
};

export const deleteImageFile = (filepath: string): void => {
  try {
    if (filepath) {
      const fullPath = path.join(__dirname, '../..', filepath);
      if (fs.existsSync(fullPath)) {
        fs.unlinkSync(fullPath);
      }
    }
  } catch (error) {
    console.error('Error deleting image file:', error);
  }
};