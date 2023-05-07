5. APPENDIX: SQL Queries Used

DROP VIEW IF EXISTS forestation; CREATE VIEW forestation
AS
(SELECT
f.country_code,
f.country_name,
f.year,
r.region,
r.income_group,
ROUND(f.forest_area_sqkm::numeric,2) as forest_area_sqkm, ROUND(l.total_area_sq_mi::numeric,2) as total_area_sq_mi,
ROUND((l.total_area_sq_mi * 2.59)::numeric,2) AS total_area_sqkm, ROUND(((f.forest_area_sqkm) /(l.total_area_sq_mi * 2.59) * 100)::numeric, 2) AS forest_percent FROM forest_area f
JOIN land_area l
ON f.country_code = l.country_code AND f.year = l.Year
JOIN regions r
ON l.country_code = r.country_code)
  

 1A)
SELECT ROUND(SUM(forest_area_sqkm),2) FROM forestation
WHERE year = 1990
AND country_name = 'World'

1B)
SELECT ROUND(SUM(forest_area_sqkm),2) FROM forestation
WHERE year = 2016
AND country_name = 'World'

1C)
SELECT
((SELECT ROUND(SUM(forest_area_sqkm),2)
FROM forestation
WHERE year = 1990
AND country_name = 'World')-(SELECT ROUND(SUM(forest_area_sqkm),2) FROM forestation
WHERE year = 2016
AND country_name = 'World')) AS forest_change
FROM forestation
LIMIT 1

1D)
SELECT
ROUND((SELECT ROUND(SUM(forest_area_sqkm),2)
FROM forestation
WHERE year = 1990
AND country_name = 'World')-
(SELECT ROUND(SUM(forest_area_sqkm),2) FROM forestation
WHERE year = 2016
AND country_name = 'World')) / ((SELECT ROUND(SUM(forest_area_sqkm),2)
FROM forestation
WHERE year = 1990
AND country_name = 'World'))*100 AS percent_change
FROM forestation LIMIT 1

1E)
SELECT country_name, total_area_sqkm FROM forestation
WHERE total_area_sqkm <= 1324449.00 GROUP BY 1,2
ORDER BY 2 DESC LIMIT 1


 2A)
SELECT country_name, ROUND(((SUM(forest_area_sqkm)/SUM(total_area_sqkm))*100),2) AS pct_forest_area
FROM forestation
WHERE year = 2016
AND country_name = 'World' GROUP BY country_name
SELECT region, ROUND(((SUM(forest_area_sqkm)/SUM(total_area_sqkm))*100),2) AS pct_forest_area FROM forestation
WHERE year = 2016
GROUP BY region
ORDER BY pct_forest_area DESC LIMIT 1
SELECT region, ROUND(((SUM(forest_area_sqkm)/SUM(total_area_sqkm))*100),2) AS pct_forest_area FROM forestation
WHERE year = 2016
GROUP BY region
ORDER BY pct_forest_area ASC LIMIT 1

2B)
SELECT country_name, ROUND(((SUM(forest_area_sqkm)/SUM(total_area_sqkm))*100),2) AS pct_forest_area
FROM forestation
WHERE year = 1990
AND country_name = 'World' GROUP BY country_name
SELECT region, ROUND(((SUM(forest_area_sqkm)/SUM(total_area_sqkm))*100),2) AS pct_forest_area FROM forestation
WHERE year = 1990
GROUP BY region
ORDER BY pct_forest_area DESC LIMIT 1
SELECT region, ROUND(((SUM(forest_area_sqkm)/SUM(total_area_sqkm))*100),2) AS pct_forest_area FROM forestation
WHERE year = 1990
GROUP BY region
ORDER BY pct_forest_area ASC LIMIT 1


 Table 2.1
SELECT region, ROUND(((SUM(forest_area_sqkm)/SUM(total_area_sqkm))*100),2) AS pct_forest_area FROM forestation
WHERE year = 1990
GROUP BY region
ORDER BY pct_forest_area DESC
SELECT region, ROUND(((SUM(forest_area_sqkm)/SUM(total_area_sqkm))*100),2) AS pct_forest_area FROM forestation
WHERE year = 2016
GROUP BY region
ORDER BY pct_forest_area DESC 

______________________________________________________
3A)
CREATE VIEW f2016 AS
SELECT country_name, forest_area_sqkm as forest2016 from forestation
WHERE year = 2016
AND forest_area_sqkm IS NOT NULL
GROUP BY country_name, forest_area_sqkm
ORDER BY forest_area_sqkm DESC
CREATE VIEW f1990 AS
SELECT country_name, forest_area_sqkm as forest1990 from forestation
WHERE year = 1990
AND forest_area_sqkm IS NOT NULL
GROUP BY country_name, forest_area_sqkm
ORDER BY forest_area_sqkm DESC
SELECT a.country_name , c.region, SUM(forest2016-forest1990) as forest_change FROM f2016 as a
JOIN f1990 as b
ON a.country_name =b.country_name
JOIN regions c
ON c.country_name =b.country_name GROUP BY 1,2
ORDER BY forest_change DESC


 TABLE 3.1
SELECT a.country_name , c.region, SUM(forest2016-forest1990) as forest_change FROM f2016 as a
JOIN f1990 as b
ON a.country_name =b.country_name
JOIN regions c
ON c.country_name =b.country_name WHERE NOT a.country_name = 'World' GROUP BY a.country_name, c.region ORDER BY 3
LIMIT 5


3A.2)
CREATE VIEW pct2016 AS
SELECT country_name, region, year, (SUM(forest_area_sqkm)/SUM(total_area_sqkm)*100) as pct_forest2016
FROM forestation
WHERE year = 2016
GROUP BY 1,2,3
CREATE VIEW pct1990 AS
SELECT country_name, region, year, (SUM(forest_area_sqkm)/SUM(total_area_sqkm)*100) as pct_forest1990
FROM forestation
WHERE year = 1990
GROUP BY 1,2,3
SELECT a.country_name , a.region, ROUND((((pct_forest1990-pct_forest2016)/pct_forest1990)*100),2) as pct_forest_change FROM pct2016 as a
JOIN pct1990 as b
ON a.country_name =b.country_name
WHERE pct_forest1990 IS NOT NULL AND pct_forest2016 IS NOT NULL
GROUP BY 1,2,3
ORDER BY pct_forest_change asc
TABLE 3.2
SELECT a.country_name , a.region, ROUND((((pct_forest1990-pct_forest2016)/pct_forest1990)*100),2) as pct_forest_change
FROM pct2016 as a
JOIN pct1990 as b
ON a.country_name =b.country_name
WHERE pct_forest1990 IS NOT NULL AND pct_forest2016 IS NOT NULL GROUP BY 1,2,3
ORDER BY pct_forest_change DESC
LIMIT 5


TABLE 3.3
SELECT DISTINCT(quartiles), COUNT(country_name) OVER (PARTITION BY quartiles) AS country_count
FROM
(SELECT country_name,
CASE
WHEN pct_forest2016 < 25 THEN '0-25'
WHEN pct_forest2016 >= 25 AND pct_forest2016 < 50 THEN '25-50' WHEN pct_forest2016 >= 50 AND pct_forest2016 < 75 THEN '50-75' ELSE '75-100'
END AS quartiles
FROM pct2016
WHERE pct_forest2016 IS NOT NULL ) sub
GROUP BY quartiles, country_name ORDER BY country_count DESC


TABLE 3.4
SELECT country_name, ROUND(pct_forest2016, 2) FROM pct2016
WHERE pct_forest2016 IS NOT NULL
ORDER BY pct_forest2016 DESC
LIMIT 9