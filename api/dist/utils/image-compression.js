"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.compressAndResizeImage = void 0;
const sharp_1 = __importDefault(require("sharp"));
const compressAndResizeImage = async (imageBuffer) => {
    try {
        const compressedBuffer = await (0, sharp_1.default)(imageBuffer)
            .resize(800, 600, {
            fit: 'inside',
            withoutEnlargement: true
        })
            .jpeg({
            quality: 80,
            mozjpeg: true
        })
            .toBuffer();
        return compressedBuffer.toString('base64');
    }
    catch (error) {
        console.error('Image compression error:', error);
        return imageBuffer.toString('base64');
    }
};
exports.compressAndResizeImage = compressAndResizeImage;
//# sourceMappingURL=image-compression.js.map