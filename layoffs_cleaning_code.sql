CREATE DATABASE world_layoffs;

-- REMOVING THE DUPLICATES OFF THE DATA
-- Temporarily disable safe update mode
SET SQL_SAFE_UPDATES = 0;

-- Create a table where records contains no duplicates
CREATE TABLE layoffs_duplicates_removed AS
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off,
                              percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
    FROM layoffs
)
WHERE row_num = 1;

-- Inspect the count of the records from the layoffs_duplicates_removed
SELECT COUNT(*) FROM layoffs_duplicates_removed;

-- Validate whether there are actually no duplicate records
SELECT company, COUNT(*) AS cnt
FROM layoffs_duplicates_removed
GROUP BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
HAVING cnt > 1;



-- STANDARDIZING THE DATA

-- Duplicate the data of layoffs_duplicates_removed and create another table: layoffs_standardized
CREATE TABLE layoffs_standardized
LIKE layoffs_duplicates_removed;

INSERT INTO layoffs_standardized
SELECT * FROM layoffs_duplicates_removed;

-- Inspect the data
SELECT * FROM layoffs_standardized;

-- Standardize company column
SELECT DISTINCT industry FROM layoffs_standardized;

UPDATE layoffs_standardized
SET company = TRIM(company);

-- Standardize industry column
SELECT DISTINCT industry FROM layoffs_standardized;

UPDATE layoffs_standardized
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Standardize country column
SELECT DISTINCT country FROM layoffs_standardized;

UPDATE layoffs_standardized
SET country = 'United States'
WHERE country LIKE 'United States%';

-- Standardize date column
UPDATE layoffs_stalayoffs_standardizedndardized
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_standardized
MODIFY COLUMN `date` DATE;



-- HANDLING MISSING VALUES

-- Create duplicate table of the layoffs_standardized: layoffs_missings
CREATE TABLE layoffs_missings
LIKE layoffs_standardized;

INSERT INTO layoffs_missings
SELECT * FROM layoffs_standardized;

SELECT * FROM layoffs_missings;

-- Handle missing values in the industry column
SELECT DISTINCT industry FROM layoffs_missings;

-- Returns rows where industry is either null or blank
SELECT *
FROM layoffs_missings
WHERE industry IS NULL
	OR industry = '';
    
-- Attempt to populate these rows by searching similar records that contains the industry of the company
-- For Airbnb
SELECT * FROM layoffs_missings
WHERE company = 'Airbnb'; -- Airbnb's industry is Travel

UPDATE layoffs_missings
SET industry = 'Travel'
WHERE company = 'Airbnb'
	AND (industry IS NULL OR industry = '');

-- For Juul
SELECT * FROM layoffs_missings
WHERE company = 'Juul'; -- Juul's industry is Consumer

UPDATE layoffs_missings
SET industry = 'Consumer'
WHERE company = 'Juul'
	AND (industry IS NULL OR industry = '');
    
-- For Carvana
SELECT * FROM layoffs_missings
WHERE company = 'Carvana'; -- Carvana's industry is Transportation

UPDATE layoffs_missings
SET industry = 'Transportation'
WHERE company = 'Carvana'
	AND (industry IS NULL OR industry = '');
    
-- Delete all rows where both total_laid_off and percentage_laid_off are nulls
DELETE FROM layoffs_missings
WHERE total_laid_off IS NULL
	AND percentage_laid_off IS NULL;

-- Drop the row_num column
ALTER TABLE layoffs_missings
DROP COLUMN row_num;
