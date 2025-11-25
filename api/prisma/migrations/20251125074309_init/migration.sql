/*
  Warnings:

  - A unique constraint covering the columns `[division,title,type]` on the table `help_contents` will be added. If there are existing duplicate values, this will fail.

*/
-- AlterTable
ALTER TABLE `users` MODIFY `role` ENUM('USER', 'SUPER_ADMIN', 'SUPER_ADMIN_FINANCE', 'SUPER_ADMIN_APO', 'SUPER_ADMIN_FRONT_DESK', 'SUPER_ADMIN_ONSITE') NOT NULL DEFAULT 'USER';

-- CreateTable
CREATE TABLE `onsite_locations` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(191) NOT NULL,
    `address` VARCHAR(191) NOT NULL,
    `latitude` DOUBLE NOT NULL,
    `longitude` DOUBLE NOT NULL,
    `radius` INTEGER NOT NULL DEFAULT 100,
    `division` ENUM('FINANCE', 'APO', 'FRONT_DESK', 'ONSITE') NOT NULL,
    `isActive` BOOLEAN NOT NULL DEFAULT true,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    UNIQUE INDEX `onsite_locations_name_key`(`name`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `work_shifts` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(191) NOT NULL,
    `startTime` VARCHAR(191) NOT NULL,
    `endTime` VARCHAR(191) NOT NULL,
    `division` ENUM('FINANCE', 'APO', 'FRONT_DESK', 'ONSITE') NOT NULL,
    `isActive` BOOLEAN NOT NULL DEFAULT true,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    UNIQUE INDEX `work_shifts_name_division_key`(`name`, `division`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateIndex
CREATE UNIQUE INDEX `help_contents_division_title_type_key` ON `help_contents`(`division`, `title`, `type`);
