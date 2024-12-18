/* 
Title: Company Layoff Data Cleaning
Author: Aron Kim
Date: 11/28/2024

This is the first part of the layoff project where data cleaning will be done
*/

SELECT *
FROM layoffs;


-- Creating a copy of the data so that I do not delete any of the real data while keeping the new info that I am adding
CREATE TABLE layoffs_copy
LIKE layoffs;

INSERT layoffs_copy
SELECT *
FROM layoffs;

-- Checking if it worked
SELECT *
FROM layoffs_copy;


-- Making sure there are no duplicate values
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised) as row_num
FROM layoffs_copy;


-- Creating cte to find rows that are duplicates by seeing if they have a unique row number > 1
WITH dup_cte as 
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised) as row_num
FROM layoffs_copy
)
DELETE *  		-- Was originally SELECT statement, but I found two duplicates so I changed to DELETE statement to erase the duplicates
FROM dup_cte
WHERE row_num > 1;


-- Creating new table because DELETE statement is not working

CREATE TABLE `layoffs_copy2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised` double DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Table copy 2 worked but data is empty
SELECT *
FROM layoffs_copy2;

-- Inserting data into the empty table
INSERT INTO layoffs_copy2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised) as row_num
FROM layoffs_copy;

-- New table is filled with the data I want now
SELECT *
FROM layoffs_copy2;

-- Can now delete the duplicates using DELETE statement
-- Had to also go to preferences to turn off safe mode
DELETE
FROM layoffs_copy2
WHERE row_num > 1;

-- Duplicates are now gone
SELECT *
FROM layoffs_copy2
WHERE row_num > 1;


-- Beginning standardizing data
-- Going one by one through columns to check for any problems with data


-- Cleaning name of companies
SELECT company, TRIM(company)
FROM layoffs_copy2;

UPDATE layoffs_copy2
SET company = TRIM(company);

SELECT DISTINCT location
FROM layoffs_copy2
ORDER BY 1;

SELECT DISTINCT industry
FROM layoffs_copy2
ORDER BY 1;

SELECT DISTINCT country
FROM layoffs_copy2
ORDER BY 1;

-- Date seems like the standardized date, but the definition is a text column instead of date
SELECT `date`
FROM layoffs_copy2;

ALTER TABLE layoffs_copy2
MODIFY COLUMN `date` DATE;


-- Looking at null values in laid off columns
-- The null values are most likely N/A instead of null so looking for blank values seems to work instead of IS NULL statement
-- Cannot fill in percent laid off because there is no total employee amount
SELECT *
FROM layoffs_copy2
WHERE total_laid_off IS NULL;

SELECT *
FROM layoffs_copy2
WHERE total_laid_off = '';

SELECT *
FROM layoffs_copy2
WHERE percentage_laid_off IS NULL;

SELECT *
FROM layoffs_copy2
WHERE percentage_laid_off = '';


-- Trying to see if I can fill in null value for industry
-- Appsmith doesn't show what industry it is in another value so cannot
SELECT *
FROM layoffs_copy2
WHERE industry = ''
OR industry IS NULL;

SELECT *
FROM layoffs_copy2;
WHERE company = 'Appsmith';


-- Removing row_num that I added in the beginning which we do not need anymore
ALTER TABLE layoffs_copy2
DROP COLUMN row_num;

SELECT *
FROM layoffs_copy2;
