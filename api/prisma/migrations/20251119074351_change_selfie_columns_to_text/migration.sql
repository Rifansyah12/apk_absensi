-- AlterTable
ALTER TABLE `attendances` MODIFY `locationCheckIn` VARCHAR(255) NULL,
    MODIFY `locationCheckOut` VARCHAR(255) NULL,
    MODIFY `selfieCheckIn` TEXT NULL,
    MODIFY `selfieCheckOut` TEXT NULL;
