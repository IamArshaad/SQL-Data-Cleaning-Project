-- DATA CLEANING

SELECT * 
FROM layoffs;

-- Steps:
-- 1. Remove duplicates
-- 2. Standardize data
-- 3. NULL values or blank values
-- 4. Remove any columns if irrelavent

-- Creating a copy of the database to work by keeping the row data:

CREATE TABLE layoffs_copy
LIKE layoffs;

SELECT * 
FROM layoffs_copy;

INSERT layoffs_copy
SELECT *
FROM layoffs;

-- 1. Removing duplicates:

SELECT *, 
ROW_NUMBER() OVER(PARTITION BY company, location, industry, 
					total_laid_off, percentage_laid_off, `date`, 
					stage, country, funds_raised_millions) AS row_num
FROM layoffs_copy;

WITH duplicate_cte AS(
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY company, location, industry, 
					total_laid_off, percentage_laid_off, `date`, 
					stage, country, funds_raised_millions) AS row_num
FROM layoffs_copy
)
SELECT * FROM duplicate_cte WHERE row_num>1;

SELECT * 
FROM layoffs_copy where company='Yahoo';




CREATE TABLE `layoffs_copy2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



INSERT INTO layoffs_copy2
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY company, location, industry, 
					total_laid_off, percentage_laid_off, `date`, 
					stage, country, funds_raised_millions) AS row_num
FROM layoffs_copy;

SELECT* FROM layoffs_copy2;

DELETE FROM layoffs_copy2 where row_num>1;



-- 2. Standardizing data

SELECT company, TRIM(company)
FROM layoffs_copy2;

UPDATE layoffs_copy2
SET company = TRIM(company);

SELECT DISTINCT industry 
FROM layoffs_copy2
ORDER BY industry;

UPDATE layoffs_copy2
SET industry='Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT location 
FROM layoffs_copy2
ORDER BY location;

SELECT DISTINCT country 
FROM layoffs_copy2
ORDER BY country;

UPDATE layoffs_copy2
SET country = 'United States'
WHERE country LIKE 'United States%';

SELECT `date`
FROM layoffs_copy2;

UPDATE layoffs_copy2
SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y');

ALTER TABLE layoffs_copy2
MODIFY COLUMN `date` DATE;

SELECT * 
FROM layoffs_copy2;


-- Dealing with NULL values:

SELECT * 
FROM layoffs_copy2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


SELECT * 
FROM layoffs_copy2
WHERE industry IS NULL
OR industry = '';


UPDATE layoffs_copy2
SET industry = NULL
WHERE industry='';

SELECT * 
FROM layoffs_copy2
WHERE company = 'Airbnb';

-- Populating null values

SELECT * 
FROM layoffs_copy2 t1
JOIN layoffs_copy2 t2
	ON t1.company=t2.company
    AND t1.location=t2.location
WHERE (t1.industry IS NULL OR t1.industry='')
AND t2.industry IS NOT NULL;

UPDATE layoffs_copy2 t1
JOIN layoffs_copy2 t2
	ON t1.company=t2.company
    AND t1.location=t2.location
SET t1.industry=t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- NULL values

SELECT * 
FROM layoffs_copy2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE 
FROM layoffs_copy2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT * 
FROM layoffs_copy2;

ALTER TABLE layoffs_copy2
DROP COLUMN row_num;