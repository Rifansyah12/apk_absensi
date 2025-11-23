import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { Request, Response, NextFunction } from 'express';

const uploadPath = path.join(__dirname, '../../public/uploads/profiles');

// Pastikan folder ada
if (!fs.existsSync(uploadPath)) {
  fs.mkdirSync(uploadPath, { recursive: true });
}

const storage = multer.diskStorage({
  destination: function (_req, _file, cb) {
    cb(null, uploadPath);
  },
  filename: function (req, file, cb) {
    const ext = path.extname(file.originalname);
    const unique = Date.now() + '-' + Math.round(Math.random() * 1e9);
    cb(null, `profile_${req.params.id || 'new'}_${unique}${ext}`);
  },
});

const fileFilter = (_req: Request, file: Express.Multer.File, cb: multer.FileFilterCallback) => {
  if (file.mimetype.startsWith('image/')) {
    cb(null, true);
  } else {
    cb(new Error('Hanya file gambar yang diizinkan!'));
  }
};

const upload = multer({
  storage,
  fileFilter,
  limits: { fileSize: 5 * 1024 * 1024 },
});

// 🔥 PENTING: Export ulang fungsi ini
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

  next(); // lanjut kalau tidak ada error
};


export const uploadSinglePhoto = upload.single('photo');
