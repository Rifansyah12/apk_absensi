"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateGPSLocation = exports.calculateDistance = void 0;
const calculateDistance = (lat1, lon1, lat2, lon2) => {
    const R = 6371e3;
    const φ1 = (lat1 * Math.PI) / 180;
    const φ2 = (lat2 * Math.PI) / 180;
    const Δφ = ((lat2 - lat1) * Math.PI) / 180;
    const Δλ = ((lon2 - lon1) * Math.PI) / 180;
    const a = Math.sin(Δφ / 2) * Math.sin(Δφ / 2) +
        Math.cos(φ1) * Math.cos(φ2) *
            Math.sin(Δλ / 2) * Math.sin(Δλ / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
};
exports.calculateDistance = calculateDistance;
const validateGPSLocation = (latitude, longitude, targetLatitude, targetLongitude, radius = 100) => {
    const distance = (0, exports.calculateDistance)(latitude, longitude, targetLatitude, targetLongitude);
    return {
        isValid: distance <= radius,
        distance,
        message: distance <= radius
            ? 'Lokasi valid'
            : `Lokasi diluar radius. Jarak: ${Math.round(distance)} meter`
    };
};
exports.validateGPSLocation = validateGPSLocation;
//# sourceMappingURL=gps.js.map