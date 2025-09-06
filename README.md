# 🌍 World Layoffs Exploratory Data Analysis Project
This project takes a closer look at global layoff trends using real-world data. The dataset covers companies across different industries, countries, and funding stages, giving us a chance to dig into how layoffs have impacted the workforce over time. The dataset used in this project was imported from Kaggle: https://www.kaggle.com/datasets/happyude/world-layoffs.

As part of this analysis, I cleaned and prepared the data (handling duplicates, standardizing the data, and handling missing values) and then explored it with SQL to answer questions like: Which industries were hit the hardest? Which companies laid off the most employees? How do layoffs vary by country and over time?

The goal is both to practice solid data cleaning and EDA skills, and to uncover meaningful insights about how layoffs have shaped different parts of the world.

# 🛠️ Skills Enchanced by this Project:
1. 🧹 **Data Cleaning using SQL** - I learned the fundamentals on how to clean a dataset in SQL such as handling duplicates, fixing inconsistencies, and handling missing values. Along the cleaning process, I also discovered different tips and tricks like using subqueries to create a new tables from another table given a set of conditions that enhances the efficiency of the query.
2. 📊 **Advanced Querying using SQL for Exploratory Data Analysis** - I have mastered intermediate querying to get results for questions I have in mind. I also had experience creating highly advanced queries to return questions for very specific tasks.

# 🔍 Insights Gathered
Here are some questions answered along with the SQL code and its ouput.

## 1. 🌍 Countries with the most number of layoffs
```sql
-- Which countries had the most layoffs in the entire data?
SELECT country, SUM(total_laid_off) AS country_total_layoffs
FROM layoffs_cleaned
GROUP BY country
ORDER BY country_total_layoffs DESC
LIMIT 10;
```
**Result:**
|country| total_layoffs_count|
|----|----|
|United States|	256559|
|India	|35993
|Netherlands	|17220
|Sweden|	11264|
|Brazil	|10391|
|Germany	|8701|
|United Kingdom|	6398|
|Canada	|6319|
|Singapore	|5995|
|China	|5905|

## 2. 🏢 Companies with the most numberof layoffs
```sql
-- Which companies had the highest layoffs? 
SELECT company, SUM(total_laid_off) AS company_total_layoffs
FROM layoffs_cleaned
GROUP BY company
ORDER BY company_total_layoffs DESC
LIMIT 10;
```
**Result:**
|company| company_total_layoffs|
|----|----|
|Amazon|	18150|
|Google	|12000|
|Meta|	11000|
|Salesforce	|10090
|Microsoft	|10000|
|Philips|	10000|
|Ericsson	|8500|
|Uber|	7585|
|Dell	|6650|
|Booking.com	|4601|

## 3. 📅 Which year had the most number of layoffs?
```sql
-- Which year had the most layoffs?
SELECT YEAR(`date`) AS `year`, SUM(total_laid_off) AS layoff_count_by_year
FROM layoffs_cleaned
GROUP BY YEAR(`date`)
ORDER BY layoff_count_by_year DESC;
```
**Result:**
|year| year_total_layoffs|
|----|----|
|2022	|160661|
|2023	|125677|
|2020	|80998|
|2021	|15823|
| Unknown|	500|

## 4. 🏭 Top 5 most affected industries every year in terms of layoffs
```sql
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
```
**Result:**
|layoff_year|industry|total_laid_off|rank_by_total_layoffs|
|----|----|----|----|
|2020|	Transportation|	14656|	1|
|2020	|Travel|	13983|	2|
|2020|	Finance	|8624	|3|
|2020|	Retail|	8002	|4|
|2020|	Food	|6218	|5|
|2021	|Consumer	|3600	|1|
|2021|	Real Estate|	2900	|2|
|2021|	Food	|2644	|3|
|2021|	Construction|	2434	|4|
|2021	|Education	|1943	|5|
|2022	|Retail	|20914	|1|
|2022|	Consumer	|19856	|2|
|2022|	Transportation	|15227	|3|
|2022	|Healthcare|	15058	|4|
|2022|	Finance|	12684|	5|
|2023|	Other|	28512|	1|
|2023|	Consumer|	15663	|2|
|2023|	Retail	|13609	|3|
|2023|	Hardware|	13223	|4|
|2023	|Healthcare	|9770	|5|

## 5. 🏢 First few companies to layoff all their employees during the start of COVID-19
```sql
-- First few companies to shutdown during the start of COVID-19
SELECT company, (percentage_laid_off) * 100 AS `percentage_laid_off (%)`, `date`
FROM layoffs_cleaned
WHERE percentage_laid_off = 1
ORDER BY `date`
LIMIT 10;
```
**Result:**
|company| percentage_laid_off (%)|date|
|----|----|----|
|Help.com	|100|	2020-03-16|
|Service|	100|	2020-03-16|
|Ejento|	100	|2020-03-19|
|Popin|	100	|2020-03-19|
|Service	|100	|2020-03-20|
|Consider.co	|100	|2020-03-26|
|HOOQ|	100	|2020-03-27|
|Amplero	|100	|2020-03-29|
|The Modist|	100	|2020-04-02|
|Atsu	|100	|2020-04-10|

## 6. 💰 Top countries that raised the most funds (in billions)
```sql
-- Top 5 countries that raised the most funds (in billions)
SELECT country, ROUND(SUM(funds_raised_millions) / 1000.0 ,2) AS total_funds_raised_billions
FROM layoffs_cleaned
GROUP BY country
ORDER BY total_funds_raised_billions DESC
LIMIT 5;
```
**Result:**
|country|total_funds_raised (billions)|
|----|----|
|United States|	1141.29|
|India	|155.87|
|China|	50.00|
|Germany	|46.15|
|United Kingdom	|45.13|


## 7. 🗓️ Breakdown of total layoffs by year and month and their rankings per year
```sql
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
```
**Result:**
|year| month| total_layoffs| rank_per_year|
|----|----|----|---|
|2020|	March|	9628|	3|
|2020|	April	|26710|	1|
|2020|	May	|25804|	2|
|2020|	June|	7627|	4|
|2020|	July	|7112|	5|
|2020|	August	|1969|	6|
|2020|	September|	609	|8|
|2020|	October|	450|	9|
|2020|	November	|237|	10|
|2020|	December|	852|	7|
|2021|	January	|6813|	1|
|2021|	February|	868	|6|
|2021|	March|	47	|10|
|2021|	April	|261	|7|
|2021|	June	|2434	|2|
|2021|	July	|80|	9|
|2021|	August|	1867	|4|
|2021|	September|	161|	8|
|2021|	October	|22	|11|
|2021|	November|	2070|	3|
|2021|	December|	1200|	5|
|2022|	January|	510|	12|
|2022|	February	|3685|	11|
|2022|	March	|5714|	9|
|2022|	April	|4128	|10|
|2022|	May	|12885	|6|
|2022|	June	|17394|	3|
|2022|	July	|16223	|4|
|2022|	August	|13055|	5|
|2022|	September	|5881|	8|
|2022|	October	|17406|	2|
|2022|	November|	53451|	1|
|2022|	December|	10329|	7|
|2023|	January	|84714|	1|
|2023|	February	|36493	|2|
|2023|	March	|4470	|3|










