-- Rideau Canal Skateway Monitoring System
-- Stream Analytics Query
-- Processes sensor data in 5-minute tumbling windows

WITH AggregatedData AS (
    SELECT
        location,
        System.Timestamp() AS windowEnd,
        AVG(iceThickness) AS avgIceThickness,
        MIN(iceThickness) AS minIceThickness,
        MAX(iceThickness) AS maxIceThickness,
        AVG(surfaceTemperature) AS avgSurfaceTemperature,
        MIN(surfaceTemperature) AS minSurfaceTemperature,
        MAX(surfaceTemperature) AS maxSurfaceTemperature,
        MAX(snowAccumulation) AS maxSnowAccumulation,
        AVG(externalTemperature) AS avgExternalTemperature,
        COUNT(*) AS readingCount
    FROM
        [rideau-canal-iot-hub-ngab0016] TIMESTAMP BY timestamp
    GROUP BY
        location,
        TumblingWindow(minute, 5)
),
SafetyStatus AS (
    SELECT
        *,
        CASE
            WHEN avgIceThickness >= 30 AND avgSurfaceTemperature <= -2 THEN 'Safe'
            WHEN avgIceThickness >= 25 AND avgSurfaceTemperature <= 0 THEN 'Caution'
            ELSE 'Unsafe'
        END AS safetyStatus
    FROM
        AggregatedData
)

-- Output to Cosmos DB for real-time dashboard queries
SELECT
    CONCAT(location, '-', CAST(windowEnd AS nvarchar(max))) AS id,
    location,
    windowEnd,
    avgIceThickness,
    minIceThickness,
    maxIceThickness,
    avgSurfaceTemperature,
    minSurfaceTemperature,
    maxSurfaceTemperature,
    maxSnowAccumulation,
    avgExternalTemperature,
    readingCount,
    safetyStatus
INTO
    SensorAggregations
FROM
    SafetyStatus;

-- Output to Blob Storage for historical archival
SELECT
    location,
    windowEnd,
    avgIceThickness,
    minIceThickness,
    maxIceThickness,
    avgSurfaceTemperature,
    minSurfaceTemperature,
    maxSurfaceTemperature,
    maxSnowAccumulation,
    avgExternalTemperature,
    readingCount,
    safetyStatus
INTO
    [historical-data]
FROM
    SafetyStatus;