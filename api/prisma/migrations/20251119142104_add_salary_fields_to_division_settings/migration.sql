-- AlterTable
ALTER TABLE `division_settings` ADD COLUMN `baseSalary` DOUBLE NOT NULL DEFAULT 0.0,
    ADD COLUMN `overtimeRateMultiplier` DOUBLE NOT NULL DEFAULT 1.5,
    ADD COLUMN `workingDaysPerMonth` INTEGER NOT NULL DEFAULT 22;

-- AlterTable
ALTER TABLE `system_settings` ADD COLUMN `description` VARCHAR(191) NULL;
