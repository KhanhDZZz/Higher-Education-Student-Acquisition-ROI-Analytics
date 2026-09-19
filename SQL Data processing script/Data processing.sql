--_______________________________________________
--|                                              |
--|       TẠO CÁC BẢNG PHỤ VÀ XỬ LÝ DỮ LIỆU RAW  |
--|                                              |
--_______________________________________________

--Drop view nếu có
DROP VIEW IF EXISTS vw_CleanedPerformance_Advanced CASCADE;
--chuẩn hoá và xử lý null
CREATE VIEW vw_CleanedPerformance_Advanced AS
WITH RawCleaned AS (
    SELECT 
        CAST("Date" AS DATE) AS "Date",
        "CampaignID",
        "CampaignName",
        "Platform",
        "TargetAudience",
        COALESCE("Region", 'Unknown') AS "Region",
        COALESCE("Impressions", 0) AS "Impressions",
        COALESCE("Clicks", 0) AS "Clicks",
        COALESCE("Leads", 0) AS "Leads",
        COALESCE("Applications", 0) AS "Applications",
        COALESCE("Enrollments", 0) AS "Enrollments",
        CAST(REGEXP_REPLACE("Cost (₹)", '[^0-9.]', '', 'g') AS DECIMAL(18,2)) AS "Cost_Raw",
        CAST(REGEXP_REPLACE("Revenue (₹)", '[^0-9.]', '', 'g') AS DECIMAL(18,2)) AS "Revenue_Raw"
    FROM public."campaignperformance"
),
NullFilled AS (
    SELECT 
        "Date", "CampaignID", "CampaignName", "Platform", "TargetAudience", "Region",
        "Impressions", "Clicks", "Leads", "Applications", "Enrollments",
        COALESCE("Cost_Raw", AVG("Cost_Raw") OVER (PARTITION BY "Platform")) AS "Cost",
        COALESCE("Revenue_Raw", 0) AS "Revenue"
    FROM RawCleaned
),
Deduplicated AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY "Date", "CampaignID", "Platform", "Region", "TargetAudience" 
            ORDER BY "Revenue" DESC, "Cost" DESC
        ) AS "row_num"
    FROM NullFilled
)
SELECT 
    "Date", "CampaignID", "CampaignName", "Platform", "TargetAudience", "Region",
    "Impressions", "Clicks", "Leads", "Applications", "Enrollments", "Cost", "Revenue"
FROM Deduplicated
WHERE "row_num" = 1;


--Drop view nếu có
DROP VIEW IF EXISTS vw_cleanedmeta CASCADE;
--chuẩn hoá và fill null
CREATE VIEW vw_cleanedmeta AS
SELECT 
    "CampaignID",
    COALESCE("Objective", 'N/A') AS Objective,
    CAST("StartDate" AS DATE) AS StartDate,
    CAST("EndDate" AS DATE) AS EndDate,
    COALESCE("Campaign Type", 'Unknown') AS CampaignType,
    COALESCE("Creative Type", 'Unknown') AS CreativeType,
    COALESCE("Manager", 'Unassigned') AS Manager,
    "Channel",
    COALESCE("Conversion Goal", 'N/A') AS ConversionGoal,
    CAST(REGEXP_REPLACE("Budget (₹)", '[^0-9.]', '', 'g') AS DECIMAL(18,2)) AS Budget
FROM public."campaignmeta";