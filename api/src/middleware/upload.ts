// api/src/middleware/upload.ts
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { Request, Response, NextFunction } from 'express';

const uploadPath = path.join(__dirname, '../../public/uploads/profiles');

// Pastikan folder ada
if (!fs.existsSync(uploadPath)) {
  fs.mkdirSync(uploadPath, { recursive: true });
}

// ✅ PERBAIKAN: Gunakan memoryStorage agar buffer tersedia
const storage = multer.memoryStorage();

const fileFilter = (_req: Request, file: Express.Multer.File, cb: multer.FileFilterCallback) => {
  if (file.mimetype.startsWith('image/')) {
    cb(null, true);
  } else {
    cb(new Error('Hanya file gambar yang diizinkan!'));
  }
};

const upload = multer({
  storage, // ✅ Gunakan memoryStorage
  fileFilter,
  limits: { fileSize: 5 * 1024 * 1024 },
});

export const handleUploadError = (
  error: any,
  _req: Request,
  res: Response,
  next: NextFunction
): void => {
  console.log('Upload error:', error);

  if (error instanceof multer.MulterError) {
    if (error.code === 'LIMIT_FILE_SIZE') {
      res.status(400).json({
        success: false,
        message: 'File terlalu besar. Maksimal 5MB',
      });
      return;
    }

    res.status(400).json({
      success: false,
      message: 'Error upload file',
    });
    return;
  }

  if (error) {
    res.status(400).json({
      success: false,
      message: error.message || 'Upload error',
    });
    return;
  }

  next();
};

export const uploadSinglePhoto = upload.single('photo');