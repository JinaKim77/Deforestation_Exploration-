# SQL queries used
# Global Situation

# 1. Create a View called “forestation” by joining all three tables - forest_area, land_area and regions in the workspace.
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
          ((f.forest_area_sqkm / (l.total_area_sq_mi*2.59)) * 100) AS     percent_of_the_land_area_as_forest,
          r.region,
          r.income_group
FROM forest_area f
JOIN land_area l
ON f.country_code=l.country_code AND f.year=l.year
JOIN regions r
ON r.country_code=l.country_code;


# What was the total forest area (in sq km) of the world in 1990?
# Please keep in mind that you can use the country record denoted as World in the region table

SELECT region,
               year,
               forest_area_sqkm
FROM forestation
WHERE region='World' AND year=1990;


# What was the total forest area (in sq km) of the world in 2016?
# Please keep in mind that you can use the country record in the table is denoted as “World.”

SELECT region,
               year,
                forest_area_sqkm
FROM forestation
WHERE region='World' AND year=2016;

# What was the change (in sq km) in the forest area of the world from 1990 to 2016?

SELECT year,
    forest_area_sqkm,
    LEAD(forest_area_sqkm) OVER (ORDER BY year)-forest_area_sqkm AS change
FROM forestation
WHERE region='World' AND (year=1990 OR year=2016);

# What was the percent change in forest area of the world between 1990 and 2016?

SELECT year,
    	         forest_area_sqkm,
              LEAD(forest_area_sqkm) OVER (ORDER BY year)-forest_area_sqkm AS change,
        forest_area_sqkm/LEAD(forest_area_sqkm) OVER (ORDER BY year) AS percent_change
FROM forestation
WHERE region='World' AND (year=1990 OR year=2016);


# If you compare the amount of forest area lost between 1990 and 2016,
# to which countrys total area in 2016 is it closest to?

# ????????????

# 2. Regional Outlook


# Create a table that shows the Regions and their percent forest area (sum of forest area divided by sum of land area)
# in 1990 and 2016. (Note that 1 sq mi = 2.59 sq km)

SELECT year,region,
              (forest_area_sqkm/total_area_sqkm)*100 AS percent_forest_area
FROM forestation
WHERE year=1990 OR year=2016


# What was the percent forest of the entire world in 2016? Which region had the HIGHEST percent forest
# in 2016, and which had the LOWEST, to 2 decimal places?

SELECT year,region,
               (forest_area_sqkm/total_area_sqkm)*100 AS percent_forest_area
FROM forestation
WHERE year=2016 AND region='World'

# Which region had the HIGHEST percent forest in 2016

SELECT region, percent_of_the_land_area_as_forest
FROM forestation
JOIN (SELECT MAX(percent_of_the_land_area_as_forest) AS max
      FROM forestation
      WHERE year=2016) sub
ON forestation.country_code=forestation.country_code
WHERE forestation.percent_of_the_land_area_as_forest>=sub.max AND year=2016;

# and which had the LOWEST

SELECT region, percent_of_the_land_area_as_forest
FROM forestation
JOIN (SELECT MIN(percent_of_the_land_area_as_forest) AS min
      FROM forestation
      WHERE year=2016) sub
ON forestation.country_code=forestation.country_code
WHERE forestation.percent_of_the_land_area_as_forest<=sub.min AND year=2016;




# What was the percent forest of the entire world in 1990? Which region had the HIGHEST percent forest in 1990, and which had the LOWEST, to 2 decimal places?

SELECT year,region,
               (forest_area_sqkm/total_area_sqkm)*100 AS percent_forest_area
FROM forestation
WHERE year=1990 AND region='World'


# Which region had the HIGHEST percent forest in 1990,

SELECT region, percent_of_the_land_area_as_forest
FROM forestation
JOIN (SELECT MAX(percent_of_the_land_area_as_forest) AS max
      FROM forestation
      WHERE year=2016) sub
ON forestation.country_code=forestation.country_code
WHERE forestation.percent_of_the_land_area_as_forest>=sub.max AND year=1990;


# and which had the LOWEST,

SELECT region, percent_of_the_land_area_as_forest
FROM forestation
JOIN (SELECT MIN(percent_of_the_land_area_as_forest) AS min
      FROM forestation
      WHERE year=1990) sub
ON forestation.country_code=forestation.country_code
WHERE forestation.percent_of_the_land_area_as_forest<=sub.min AND year=1990;


# Based on the table you created, which regions of the world DECREASED
# in forest area from 1990 to 2016?
