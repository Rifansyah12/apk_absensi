"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.deleteImageFile = exports.saveImageToFile = void 0;
const fs_1 = __importDefault(require("fs"));
const path_1 = __importDefault(require("path"));
const uuid_1 = require("uuid");
const createProfilePhotosDir = () => {
    const profileDir = path_1.default.join(__dirname, '../../public/uploads/profiles');
    if (!fs_1.default.existsSync(profileDir)) {
        fs_1.default.mkdirSync(profileDir, { recursive: true });
    }
    return profileDir;
};
const createSelfiesDir = () => {
    const selfiesDir = path_1.default.join(__dirname, '../../public/uploads/selfies');
    if (!fs_1.default.existsSync(selfiesDir)) {
        fs_1.default.mkdirSync(selfiesDir, { recursive: true });
    }
    return selfiesDir;
};
const saveImageToFile = (imageBuffer, userId, type) => {
    try {
        let uploadsDir;
        let filename;
        if (type === 'profile') {
            uploadsDir = createProfilePhotosDir();
            filename = `profile_${userId}_${(0, uuid_1.v4)()}.jpg`;
        }
        else {
            uploadsDir = createSelfiesDir();
            filename = `selfie_${userId}_${type}_${(0, uuid_1.v4)()}.jpg`;
        }
        const filepath = path_1.default.join(uploadsDir, filename);
        console.log('📁 File disimpan di:', filepath);
        fs_1.default.writeFileSync(filepath, imageBuffer);
        if (type === 'profile') {
            return `/public/uploads/profiles/${filename}`;
        }
        else {
            return `/public/uploads/selfies/${filename}`;
        }
    }
    catch (error) {
        console.error('Error saving image file:', error);
        throw new Error('Gagal menyimpan foto');
    }
};
exports.saveImageToFile = saveImageToFile;
const deleteImageFile = (filepath) => {
    try {
        if (filepath && filepath.startsWith('/public/uploads/')) {
            const fullPath = path_1.default.join(__dirname, '../..', filepath);
            console.log('Deleting file:', fullPath);
            if (fs_1.default.existsSync(fullPath)) {
                fs_1.default.unlinkSync(fullPath);
                console.log('File deleted successfully:', filepath);
            }
            else {
                console.warn('File not found, cannot delete:', fullPath);
            }
        }
        else if (filepath) {
            console.warn('Invalid file path, cannot delete:', filepath);
        }
    }
    catch (error) {
        console.error('Error deleting image file:', error);
    }
};
exports.deleteImageFile = deleteImageFile;
//# sourceMappingURL=file-storage.js.map