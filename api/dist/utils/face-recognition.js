"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.verifyFace = void 0;
const verifyFace = async (_currentSelfie, _storedPhoto) => {
    const confidence = Math.random();
    return {
        isMatch: confidence > parseFloat(process.env.FACE_RECOGNITION_THRESHOLD || '0.8'),
        confidence,
        message: confidence > parseFloat(process.env.FACE_RECOGNITION_THRESHOLD || '0.8')
            ? 'Wajah terverifikasi'
            : 'Wajah tidak cocok'
    };
};
exports.verifyFace = verifyFace;
//# sourceMappingURL=face-recognition.js.map