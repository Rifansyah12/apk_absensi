"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getStartAndEndOfDay = getStartAndEndOfDay;
exports.isSameDay = isSameDay;
function getStartAndEndOfDay(date) {
    const start = new Date(date);
    start.setHours(0, 0, 0, 0);
    const end = new Date(date);
    end.setHours(23, 59, 59, 999);
    return { start, end };
}
function isSameDay(date1, date2) {
    return (date1.getFullYear() === date2.getFullYear() &&
        date1.getMonth() === date2.getMonth() &&
        date1.getDate() === date2.getDate());
}
//# sourceMappingURL=date-utils.js.map