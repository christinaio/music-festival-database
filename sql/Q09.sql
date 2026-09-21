USE festivalDB;
WITH visitor_attendance_dates AS (
    SELECT
        v.visitor_id,
        MIN(d.day_date) AS first_perf_date,
        MAX(d.day_date) AS last_perf_date,
        COUNT(*) AS total_performances
    FROM visitors v
    JOIN tickets t ON v.visitor_id = t.visitor_id
    JOIN performances p ON t.performance_id = p.performance_id
    JOIN events e ON p.event_id = e.event_id
    JOIN day d ON e.day_id = d.day_id
    GROUP BY v.visitor_id
    HAVING COUNT(*) > 3
       AND DATEDIFF(MAX(d.day_date), MIN(d.day_date)) <= 365
),
matching_visitors AS (
    SELECT
        v1.visitor_id AS visitor1,
        v2.visitor_id AS visitor2,
        v1.total_performances
    FROM visitor_attendance_dates v1
    JOIN visitor_attendance_dates v2
        ON v1.visitor_id < v2.visitor_id
        AND v1.total_performances = v2.total_performances
)
SELECT DISTINCT visitor1 AS visitor_id, total_performances
FROM matching_visitors
UNION
SELECT DISTINCT visitor2 AS visitor_id, total_performances
FROM matching_visitors
ORDER BY total_performances;


