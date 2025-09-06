-- Which country had the most layoffs in the entire data?
SELECT country, SUM(total_laid_off) AS country_total_layoffs
FROM layoffs_cleaned
GROUP BY country
ORDER BY country_total_layoffs DESC
LIMIT 10;

-- Which companies had the highest layoffs? 
SELECT company, SUM(total_laid_off) AS company_total_layoffs
FROM layoffs_cleaned
GROUP BY company
ORDER BY company_total_layoffs DESC
LIMIT 10;

-- Which year had the most layoffs?
SELECT YEAR(`date`) AS `year`, SUM(total_laid_off) AS layoff_count_by_year
FROM layoffs_cleaned
GROUP BY YEAR(`date`)
ORDER BY layoff_count_by_year DESC;

-- Top 5 industries most affected industries every year in terms of layoffs
SELECT 
    layoff_year,
    industry,
    total_laid_off,
    industry_rank
FROM (
    SELECT 
        YEAR(`date`) AS layoff_year,
        industry,
        SUM(total_laid_off) AS total_laid_off,
        RANK() OVER (
            PARTITION BY YEAR(`date`) 
            ORDER BY SUM(total_laid_off) DESC
        ) AS industry_rank
    FROM layoffs_cleaned
    GROUP BY YEAR(`date`), industry
) AS ranked_industries
WHERE industry_rank <= 5
	AND layoff_year IS NOT NULL
ORDER BY layoff_year, industry_rank;


-- Top 5 countries that raised the most funds (in billions)
SELECT country, ROUND(SUM(funds_raised_millions) / 1000.0 ,2) AS total_funds_raised_billions
FROM layoffs_cleaned
GROUP BY country
ORDER BY total_funds_raised_billions DESC
LIMIT 5;

-- First few companies to shutdown during the start of COVID-19
SELECT company, (percentage_laid_off) * 100 AS `percentage_laid_off (%)`, `date`
FROM layoffs_cleaned
WHERE percentage_laid_off = 1
ORDER BY `date`
LIMIT 10;

-- Breakdown of total layoffs by year and month with ranking
SELECT 
    layoff_year,
    layoff_month,
    total_laid_off,
    RANK() OVER (PARTITION BY layoff_year ORDER BY total_laid_off DESC) AS monthly_rank
FROM (
    SELECT 
        YEAR(`date`) AS layoff_year,
        MONTHNAME(`date`) AS layoff_month,
        MONTH(`date`) AS layoff_month_num,
        SUM(total_laid_off) AS total_laid_off
    FROM layoffs_cleaned
    GROUP BY YEAR(`date`), MONTH(`date`), MONTHNAME(`date`)
) AS monthly_totals
WHERE layoff_year IS NOT NULL
ORDER BY layoff_year, layoff_month_num;



