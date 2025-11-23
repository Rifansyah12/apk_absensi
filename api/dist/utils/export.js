"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ExportUtils = void 0;
const exceljs_1 = __importDefault(require("exceljs"));
class ExportUtils {
    static async exportToExcel(data, columns, filename, res) {
        try {
            const workbook = new exceljs_1.default.Workbook();
            const worksheet = workbook.addWorksheet('Sheet 1');
            worksheet.columns = columns;
            worksheet.addRows(data);
            worksheet.getRow(1).font = { bold: true };
            worksheet.getRow(1).fill = {
                type: 'pattern',
                pattern: 'solid',
                fgColor: { argb: 'FFE6E6FA' }
            };
            res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
            res.setHeader('Content-Disposition', `attachment; filename=${filename}.xlsx`);
            await workbook.xlsx.write(res);
            res.end();
        }
        catch (error) {
            throw new Error(`Excel export failed: ${error.message}`);
        }
    }
    static exportToPDF(data, columns, filename, res) {
        const PDFDocument = require("pdfkit");
        const fs = require("fs");
        const path = require("path");
        const doc = new PDFDocument({
            margin: 20,
            size: "A4",
            layout: "landscape",
            bufferPages: true
        });
        res.setHeader("Content-Type", "application/pdf");
        res.setHeader("Content-Disposition", `attachment; filename=${filename}.pdf`);
        doc.pipe(res);
        const headerColor = "#1E3A8A";
        doc.rect(0, 0, doc.page.width, 70).fill(headerColor);
        const logoPath = path.join(process.cwd(), "public", "logo.png");
        if (fs.existsSync(logoPath)) {
            doc.image(logoPath, 25, 15, { width: 45 });
        }
        doc
            .fillColor("#FFFFFF")
            .font("Helvetica-Bold")
            .fontSize(22)
            .text(filename.replace(/_/g, " "), 90, 22);
        doc.fillColor("#FFFFFF").fontSize(10).text("Generated: " + new Date().toLocaleDateString("id-ID"), 90, 50);
        const startY = 100;
        let y = startY;
        const totalWidth = doc.page.width - 40;
        const totalWeight = columns.reduce((s, c) => s + c.width, 0);
        const colWidths = columns.map(c => (c.width / totalWeight) * totalWidth);
        const rowHeight = 20;
        let x = 20;
        doc.font("Helvetica-Bold").fontSize(9);
        columns.forEach((col, i) => {
            doc.rect(x, y, colWidths[i], rowHeight).fill("#4F81BD");
            doc
                .fillColor("#FFFFFF")
                .text(col.header, x + 4, y + 6, { width: colWidths[i] - 8, align: "left" });
            x += colWidths[i];
        });
        y += rowHeight;
        doc.font("Helvetica").fontSize(8);
        data.forEach((row, index) => {
            let x = 20;
            if (y + rowHeight > doc.page.height - 40) {
                doc.addPage();
                y = startY;
                let xx = 20;
                doc.font("Helvetica-Bold").fontSize(9);
                columns.forEach((col, i) => {
                    doc.rect(xx, y, colWidths[i], rowHeight).fill("#4F81BD");
                    doc
                        .fillColor("#FFFFFF")
                        .text(col.header, xx + 4, y + 6, { width: colWidths[i] - 8 });
                    xx += colWidths[i];
                });
                y += rowHeight;
                doc.font("Helvetica").fontSize(8);
            }
            doc.fillColor(index % 2 === 0 ? "#F8F9FA" : "#FFFFFF");
            doc.rect(20, y, totalWidth, rowHeight).fill();
            x = 20;
            columns.forEach((col, i) => {
                const value = row[col.key] ?? "";
                doc.fillColor("#000000").text(String(value), x + 4, y + 6, {
                    width: colWidths[i] - 8,
                    align: "left"
                });
                x += colWidths[i];
            });
            y += rowHeight;
        });
        doc.end();
    }
}
exports.ExportUtils = ExportUtils;
//# sourceMappingURL=export.js.map