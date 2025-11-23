/*
  Warnings:

  - The values [IZIN] on the enum `leaves_type` will be removed. If these variants are still used in the database, this will fail.

*/
-- AlterTable
ALTER TABLE `leaves` MODIFY `type` ENUM('CUTI_TAHUNAN', 'CUTI_SAKIT', 'CUTI_MELAHIRKAN', 'CUTI_ALASAN_PENTING') NOT NULL;
