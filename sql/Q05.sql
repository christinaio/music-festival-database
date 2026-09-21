USE festivalDB;
SELECT 
    a.artist_id,
    a.name,
    FLOOR(DATEDIFF(CURDATE(), a.birthdate) / 365.25) AS age,
    COUNT(DISTINCT f.festival_year) AS festival_participations
FROM 
    artists a
JOIN 
    performances p ON a.artist_id = p.artist_id
JOIN 
    events e ON p.event_id = e.event_id
JOIN 
    festival f ON e.festival_year = f.festival_year
WHERE 
    FLOOR(DATEDIFF(CURDATE(), a.birthdate) / 365.25) < 30
GROUP BY 
    a.artist_id, a.name, a.birthdate
HAVING 
    COUNT(DISTINCT f.festival_year) = (
        SELECT MAX(fest_count)
        FROM (
            SELECT 
                COUNT(DISTINCT f2.festival_year) AS fest_count
            FROM 
                artists a2
            JOIN 
                performances p2 ON a2.artist_id = p2.artist_id
            JOIN 
                events e2 ON p2.event_id = e2.event_id
            JOIN 
                festival f2 ON e2.festival_year = f2.festival_year
            WHERE 
                FLOOR(DATEDIFF(CURDATE(), a2.birthdate) / 365.25) < 30
            GROUP BY 
                a2.artist_id
        ) AS subquery
    );


