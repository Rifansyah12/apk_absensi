"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.deleteImageFile = exports.saveImageToFile = void 0;
const fs_1 = __importDefault(require("fs"));
const path_1 = __importDefault(require("path"));
const uuid_1 = require("uuid");
const saveImageToFile = (imageBuffer, userId, type) => {
    try {
        const uploadsDir = path_1.default.join(__dirname, '../../uploads/selfies');
        if (!fs_1.default.existsSync(uploadsDir)) {
            fs_1.default.mkdirSync(uploadsDir, { recursive: true });
        }
        const filename = `selfie_${userId}_${type}_${(0, uuid_1.v4)()}.jpg`;
        const filepath = path_1.default.join(uploadsDir, filename);
        fs_1.default.writeFileSync(filepath, imageBuffer);
        return `/uploads/selfies/${filename}`;
    }
    catch (error) {
        console.error('Error saving image file:', error);
        throw new Error('Gagal menyimpan foto');
    }
};
exports.saveImageToFile = saveImageToFile;
const deleteImageFile = (filepath) => {
    try {
        if (filepath) {
            const fullPath = path_1.default.join(__dirname, '../..', filepath);
            if (fs_1.default.existsSync(fullPath)) {
                fs_1.default.unlinkSync(fullPath);
            }
        }
    }
    catch (error) {
        console.error('Error deleting image file:', error);
    }
};
exports.deleteImageFile = deleteImageFile;
//# sourceMappingURL=file-storage.js.map