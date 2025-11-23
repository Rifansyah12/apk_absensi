"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.uploadSinglePhoto = exports.handleUploadError = void 0;
const multer_1 = __importDefault(require("multer"));
const path_1 = __importDefault(require("path"));
const fs_1 = __importDefault(require("fs"));
const uploadPath = path_1.default.join(__dirname, '../../public/uploads/profiles');
if (!fs_1.default.existsSync(uploadPath)) {
    fs_1.default.mkdirSync(uploadPath, { recursive: true });
}
const storage = multer_1.default.diskStorage({
    destination: function (_req, _file, cb) {
        cb(null, uploadPath);
    },
    filename: function (req, file, cb) {
        const ext = path_1.default.extname(file.originalname);
        const unique = Date.now() + '-' + Math.round(Math.random() * 1e9);
        cb(null, `profile_${req.params.id || 'new'}_${unique}${ext}`);
    },
});
const fileFilter = (_req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
        cb(null, true);
    }
    else {
        cb(new Error('Hanya file gambar yang diizinkan!'));
    }
};
const upload = (0, multer_1.default)({
    storage,
    fileFilter,
    limits: { fileSize: 5 * 1024 * 1024 },
});
const handleUploadError = (error, _req, res, next) => {
    console.log('Upload error:', error);
    if (error instanceof multer_1.default.MulterError) {
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
exports.handleUploadError = handleUploadError;
exports.uploadSinglePhoto = upload.single('photo');
//# sourceMappingURL=upload.js.map