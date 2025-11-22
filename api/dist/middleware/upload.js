"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.uploadSinglePhoto = exports.handleUploadError = void 0;
const multer_1 = __importDefault(require("multer"));
const storage = multer_1.default.memoryStorage();
const fileFilter = (_req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
        cb(null, true);
    }
    else {
        cb(new Error('Hanya file gambar yang diizinkan!'));
    }
};
const upload = (0, multer_1.default)({
    storage: storage,
    fileFilter: fileFilter,
    limits: {
        fileSize: 5 * 1024 * 1024,
    },
});
const handleUploadError = (error, _req, res, next) => {
    if (error instanceof multer_1.default.MulterError) {
        if (error.code === 'LIMIT_FILE_SIZE') {
            res.status(400).json({
                success: false,
                message: 'File terlalu besar. Maksimal 5MB',
            });
            return;
        }
        if (error.code === 'LIMIT_UNEXPECTED_FILE') {
            res.status(400).json({
                success: false,
                message: 'Field file tidak sesuai',
            });
            return;
        }
    }
    else if (error) {
        res.status(400).json({
            success: false,
            message: error.message,
        });
        return;
    }
    return next();
};
exports.handleUploadError = handleUploadError;
exports.uploadSinglePhoto = upload.single('photo');
//# sourceMappingURL=upload.js.map