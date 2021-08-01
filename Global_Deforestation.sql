# SQL queries used

# 1. Create a View called “forestation” by joining all three tables - forest_area,
land_area and regions in the workspace.
# 2. The forest_area and land_area tables join on both country_code AND year.
# 3. The regions table joins these based on only country_code
# 4. In the ‘forestation’ View, include the following:
# All of the columns of the origin tables
# A new column that provides the percent of the land area that is designated as forest.

CREATE OR REPLACE VIEW forestation AS
SELECT f.country_code,
       f.country_name,
       f.year,f.forest_area_sqkm,
       l.total_area_sq_mi*2.59 as total_area_sqkm,
       ((f.forest_area_sqkm / (l.total_area_sq_mi*2.59)) * 100) AS percent_of_the_land_area_as_forest,
       r.region,
       r.income_group
FROM forest_area f
JOIN land_area l
ON f.country_code=l.country_code AND f.year=l.year
JOIN regions r
ON r.country_code=l.country_code;




# This produces the total forest area of the World in 1990.

SELECT region,
       year,
       forest_area_sqkm
FROM forestation
WHERE region='World' AND year=1990;




# This produces the total forest area of the World in 2016.

SELECT region,
       year,
       forest_area_sqkm
FROM forestation
WHERE region='World' AND year=2016;




# What was the change (in sq km) in the forest area of the world from 1990 to 2016?
# The value 1324449 produced as forest sq km decrease.

SELECT year,
       forest_area_sqkm,
       LEAD(forest_area_sqkm) OVER (ORDER BY year)-forest_area_sqkm AS change
FROM forestation
WHERE region='World' AND (year=1990 OR year=2016);




# What was the percent change in forest area of the world between 1990 and 2016?
# This produces the forest area values in 2016 and 1990, the forest loss, and the percent change between 1990 and 2016.

WITH forest_1990 AS (
  SELECT year,
         region,
         forest_area_sqkm,
         percent_of_the_land_area_as_forest AS percent
  FROM forestation
  WHERE region='World' AND year=1990
),
forest_2016 AS (
  SELECT year,
         region,
         forest_area_sqkm,
         percent_of_the_land_area_as_forest AS percent
FROM forestation
WHERE region='World' AND year=2016
)

SELECT *,
       (forest_1990.forest_area_sqkm - forest_2016.forest_area_sqkm) As loss,
       ((forest_1990.forest_area_sqkm - forest_2016.forest_area_sqkm)/forest_1990.forest_area_sqkm)*100 As percent_decrease
FROM forest_1990
JOIN forest_2016
ON forest_1990.region=forest_2016.region




# This produces Peru as the country with the total land area closet to the amount of forest area lost between 1990 and 2016.

WITH forest_1990 AS (
  SELECT year,
         country_name,
         region,
         forest_area_sqkm,
         total_area_sqkm,
         percent_of_the_land_area_as_forest AS percent
  FROM forestation
  WHERE year=1990
),
forest_2016 AS (
  SELECT year,
         country_name,
         region,
         forest_area_sqkm,
         total_area_sqkm,
         percent_of_the_land_area_as_forest AS percent
  FROM forestation
  WHERE year=2016
)

SELECT forest_2016.country_name,
       forest_2016.total_area_sqkm
FROM forest_2016
JOIN forest_1990
ON forest_2016.region=forest_1990.region
WHERE forest_2016.total_area_sqkm <=
        (SELECT (forest_1990.forest_area_sqkm-forest_2016.forest_area_sqkm) As loss_forest
         FROM forest_1990
         JOIN forest_2016
         ON forest_1990.region=forest_2016.region
         WHERE forest_2016.region='World')
AND forest_2016.region!='World'
GROUP BY 1,2
ORDER BY 2 DESC




# Create a table that shows the Regions and their percent forest area (sum of forest area divided by sum of land area) in 1990 and 2016.
# (Note that 1 sq mi = 2.59 sq km)

WITH forest AS (
  SELECT year,
         region,
         (SUM(forest_area_sqkm)/SUM(total_area_sqkm))*100 AS percent_forest_area
  FROM forestation
  WHERE (year=1990 OR year=2016)
  GROUP BY 1,2
)

SELECT *
FROM forest




# This returns the percent of the forest area of the entire World in 2016 as 31.38

SELECT percent_forest_area
FROM forest
WHERE year=2016 AND region='World'




# This produces Latin America & Caribbean as the region with the highest forest percentage in 2016.

SELECT region,
       percent_forest_area
FROM forest
WHERE year=2016 AND region != 'World'
ORDER BY percent_forest_area DESC
LIMIT 1




# This produces Middle East & North Africa as the region with the lowest forest percentage in 2016.

SELECT region,
       percent_forest_area
FROM forest
WHERE year=2016 AND region != 'World'
ORDER BY percent_forest_area
LIMIT 1




# This returns the percent of the forest area of the entire World in 1990 as 32.42

SELECT percent_forest_area
FROM forest
WHERE year=1990 AND region='World'




# This produces Latin America & Caribbean as the region with the highest forest percentage in 1990.

SELECT region,
       percent_forest_area
FROM forest
WHERE year=1990 AND region != 'World'
ORDER BY percent_forest_area DESC
LIMIT 1




# This produces Middle East & North Africa as the region with the lowest forest percentage in 1990.

SELECT region,
       percent_forest_area
FROM forest
WHERE year=1990 AND region != 'World'
ORDER BY percent_forest_area
LIMIT 1




# Based on the table you created, which regions of the world DECREASED in forest area from 1990 to 2016?
# Only Sub-Saharan Africa and Latin America & Caribbean regions decreased in forest area between 1990 and 2016.

WITH forest_1990 AS (
  SELECT year,
         region,
         (SUM(forest_area_sqkm)/SUM(total_area_sqkm))*100 AS percent_per_region
  FROM forestation
  WHERE region!='World' AND year=1990
  GROUP BY 1,2
),
forest_2016 AS (
  SELECT year,
         region,
         (SUM(forest_area_sqkm)/SUM(total_area_sqkm))*100 AS percent_per_region
FROM forestation
WHERE region!='World' AND year=2016
GROUP BY 1,2
)

SELECT region,
       percent_1990,
       percent_2016,
       (percent_1990-percent_2016) AS diff
FROM (SELECT forest_2016.region AS region,
             forest_1990.percent_per_region AS "percent_1990",
             forest_2016.percent_per_region AS "percent_2016"
      FROM forest_1990
      JOIN forest_2016
      ON forest_1990.region=forest_2016.region) sub
ORDER BY diff DESC;




# the percent forest area of the world decreased over this time period from __32.4222035575689__% to __31.3755709643095__%.

SELECT year,
       region,
       (SUM(forest_area_sqkm)/SUM(total_area_sqkm))*100 AS percent_per_region
FROM forestation
WHERE region='World' AND (year=1990 OR year=2016)
GROUP BY 1,2;




# This produces China and United States as the top two countries in terms of forest area increase in terms of sq km.

WITH forest_1990 AS(
  SELECT country_name,
         forest_area_sqkm,
         SUM(forest_area_sqkm) forest_area,
         percent_of_the_land_area_as_forest
  FROM forestation
  WHERE forest_area_sqkm IS NOT NULL AND country_name != 'World' AND year=1990
  GROUP BY 1,2,4
  ORDER BY 2 DESC),
forest_2016 AS(
  SELECT country_name,
         forest_area_sqkm,
         SUM(forest_area_sqkm) forest_area, percent_of_the_land_area_as_forest
  FROM forestation
  WHERE forest_area_sqkm IS NOT NULL AND country_name != 'World' AND year=2016
  GROUP BY 1,2,4
  ORDER BY 2 DESC)

SELECT forest_1990.country_name,
       forest_1990.forest_area AS "forest_1990",
       forest_2016.forest_area AS "forest_2016",
       (forest_1990.forest_area_sqkm-forest_2016.forest_area_sqkm) AS difference,
       ((forest_1990.forest_area_sqkmforest_2016.forest_area_sqkm)/forest_1990.forest_area_sqkm)*100 As percent_decreased
FROM forest_1990
JOIN forest_2016
ON forest_1990.country_name = forest_2016.country_name
ORDER BY difference;




# large countries in total land area

SELECT *
FROM (SELECT country_name,
             SUM(total_area_sqkm) AS total_area
      FROM forestation
      GROUP BY 1
      ORDER BY 2 DESC) sub
WHERE total_area IS NOT NULL AND country_name != 'World'




# when we look at the largest percent change in forest area from 1990 to 2016, we aren’t surprised to find a much smaller country listed at the top.
# __ Iceland__ increased in forest area by __ 213.664588870028__% from 1990 to 2016.
# This produces Iceland as the top country in terms of percentage change increase in forest area.

WITH forest_1990 AS(
  SELECT country_name,
         region,
         forest_area_sqkm
  FROM forestation
  WHERE forest_area_sqkm IS NOT NULL AND country_name != 'World' AND year=1990
  GROUP BY 1,2,3
  ORDER BY 3 DESC),
forest_2016 AS(
  SELECT country_name,
         region,
         forest_area_sqkm
  FROM forestation
  WHERE forest_area_sqkm IS NOT NULL AND country_name != 'World' AND year=2016
  GROUP BY 1,2,3
  ORDER BY 3 DESC)

SELECT forest_1990.country_name,
       forest_1990.forest_area_sqkm AS forest_1990,
       forest_2016.forest_area_sqkm AS forest_2016,
       ((forest_1990.forest_area_sqkmforest_2016.forest_area_sqkm)/forest_1990.forest_area_sqkm)*100 AS percent_decrease
FROM forest_1990
JOIN forest_2016
ON forest_1990.country_name=forest_2016.country_name
ORDER BY percent_decrease




# Which 5 countries saw the largest amount decrease in forest area from 1990 to 2016?
# What was the difference in forest area for each?
# The top five countries in terms of sq km forestation decrease are Brazil, Indonesia, Myanmar, Nigeria, and Tanzania.

WITH forest_1990 AS(
  SELECT country_name,
         forest_area_sqkm,
         region
  FROM forestation
  WHERE year=1990
  ORDER BY country_name
),
forest_2016 AS(
  SELECT country_name,
         forest_area_sqkm,
         region
  FROM forestation
  WHERE year=2016
  ORDER BY country_name
)

SELECT *
FROM (SELECT forest_1990.country_name,
             forest_1990.region,
             forest_1990.forest_area_sqkm as before,
             forest_2016.forest_area_sqkm as later,
             forest_1990.forest_area_sqkm-forest_2016.forest_area_sqkm as difference
      FROM forest_1990
      JOIN forest_2016
      ON forest_1990.country_name=forest_2016.country_name
      WHERE forest_1990.country_name != 'World') sub
      WHERE difference IS NOT NULL
ORDER BY difference DESC
LIMIT 5;




# Which 5 countries saw the largest percent decrease in forest area from 1990 to 2016?
# What was the percent change to 2 decimal places for each?
# The top five countries in terms of percent decrease in forestation are Togo, Nigeria, Uganda, Mauritania, and Honduras.
# Q. How to calculate the percent decrease then you can use the formula?
# (Change in forest_area / Actual forest_area for 1990 )* 100

WITH forest_1990 AS(
  SELECT country_name,
         forest_area_sqkm,
         region,
         percent_of_the_land_area_as_forest
  FROM forestation
  WHERE year=1990
  ORDER BY country_name
),
forest_2016 AS(
  SELECT country_name,
         forest_area_sqkm,
         region,
         percent_of_the_land_area_as_forest
  FROM forestation
  WHERE year=2016
  ORDER BY country_name
)

SELECT *
FROM (SELECT forest_1990.country_name,
             forest_1990.region,
             forest_1990.percent_of_the_land_area_as_forest as before,
             forest_2016.percent_of_the_land_area_as_forest as later,
             ((forest_1990.forest_area_sqkmforest_2016.forest_area_sqkm)/forest_1990.forest_area_sqkm)*100 as percent_decrease
      FROM forest_1990
      JOIN forest_2016
      ON forest_1990.country_name=forest_2016.country_name) sub
WHERE percent_decrease IS NOT NULL
ORDER BY percent_decrease DESC
LIMIT 5;



# If countries were grouped by percent forestation in quartiles, which group had the most
# countries in it in 2016?
# Check each group with this WHERE clause
# WHERE qual.forest_quartile = '?'

WITH qual AS
 (SELECT country_name,
         region,
         ROUND(percent_of_the_land_area_as_forest::DECIMAL,2) AS
         percent_forest,
         CASE WHEN percent_of_the_land_area_as_forest <=25 THEN '1'
              WHEN percent_of_the_land_area_as_forest <=50 THEN '2'
              WHEN percent_of_the_land_area_as_forest <=75 THEN '3'
              ELSE '4' END AS forest_quartile
  FROM forestation
  WHERE year = 2016 and forest_area_sqkm IS NOT NULL and total_area_sqkm IS NOT NULL
  ORDER BY percent_of_the_land_area_as_forest)

SELECT qual.country_name,
       qual.region,
       qual.percent_forest,qual.forest_quartile
FROM qual
ORDER BY 3 DESC


# To get the actual count for the respective columns
SELECT qual.forest_quartile,
       COUNT(qual.country_name)
FROM qual
GROUP BY 1



# Top Quartile Countries, 2016:
# There were _________9_________ countries in the top quartile in 2016. These are countries with a very high percentage of their land area designated as forest.
# 9 countries had a forestation percentage greater than 75% in 2016
WITH qual AS
 (SELECT country_name,
         region,
         ROUND(percent_of_the_land_area_as_forest::DECIMAL,2) AS percent_forest,
         CASE WHEN percent_of_the_land_area_as_forest <=25 THEN '1'
              WHEN percent_of_the_land_area_as_forest <=50 THEN '2'
              WHEN percent_of_the_land_area_as_forest <=75 THEN '3'
              ELSE '4' END AS forest_quartile
  FROM forestation
  WHERE year = 2016 and forest_area_sqkm IS NOT NULL and total_area_sqkm IS NOT NULL
  ORDER BY percent_of_the_land_area_as_forest)

SELECT qual.country_name,
       qual.region,
       qual.percent_forest
FROM qual
WHERE qual.forest_quartile = '4'
ORDER BY 3 DESC;
