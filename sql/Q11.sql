USE festivalDB;
WITH artist_counts AS (
    SELECT 
        a.artist_id,
        a.name,
        COUNT(DISTINCT e.festival_year) AS festival_participations
    FROM artists a
    JOIN performances p ON p.artist_id = a.artist_id
    JOIN events e ON e.event_id = p.event_id
    GROUP BY a.artist_id, a.name
),
max_participations AS (
    SELECT MAX(festival_participations) AS max_count FROM artist_counts
)
SELECT 
    ac.artist_id,
    ac.name,
    ac.festival_participations
FROM artist_counts ac, max_participations mp
WHERE ac.festival_participations <= mp.max_count - 5;

