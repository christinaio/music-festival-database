USE festivalDB;
WITH genre_per_year AS (
    SELECT 
        ag.genre_id,
        g.genre,
        f.festival_year,
        COUNT(*) AS appearances
    FROM performances p
    JOIN artists a ON a.artist_id = p.artist_id
    JOIN artist_genre ag ON ag.artist_id = a.artist_id
    JOIN genre g ON g.genre_id = ag.genre_id
    JOIN events e ON e.event_id = p.event_id
    JOIN festival f ON f.festival_year = e.festival_year
    GROUP BY ag.genre_id, g.genre, f.festival_year
    HAVING COUNT(*) >= 3
),
consecutive_years_same_appearances AS (
    SELECT 
        g1.genre_id,
        g1.genre,
        g1.festival_year AS year1,
        g2.festival_year AS year2,
        g1.appearances
    FROM genre_per_year g1
    JOIN genre_per_year g2 
        ON g1.genre_id = g2.genre_id 
        AND g2.festival_year = g1.festival_year + 1
        AND g1.appearances = g2.appearances
)
SELECT 
    genre,
    appearances,
    year1 AS first_year,
    year2 AS second_year
FROM consecutive_years_same_appearances
ORDER BY genre, first_year;


