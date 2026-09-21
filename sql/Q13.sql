USE festivalDB;
SELECT 
    a.artist_id,
    a.name,
    COUNT(DISTINCT l.continent) AS continents_participated
FROM artists a
JOIN performances p ON p.artist_id = a.artist_id
JOIN events e ON e.event_id = p.event_id
JOIN festival f ON f.festival_year = e.festival_year
JOIN location l ON l.location_id = f.location_id
GROUP BY a.artist_id, a.name
HAVING COUNT(DISTINCT l.continent) >= 3;