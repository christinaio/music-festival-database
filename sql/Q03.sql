USE festivalDB;
SELECT 
    a.artist_id,
    a.name,
    f.festival_year,
    COUNT(*) AS warmup_count
FROM 
    performances p
JOIN 
    performance_category pc ON p.category_id = pc.category_id
JOIN 
    artists a ON p.artist_id = a.artist_id
JOIN 
    events e ON p.event_id = e.event_id
JOIN 
    festival f ON e.festival_year = f.festival_year
WHERE 
    pc.category = 'Warm up'
GROUP BY 
    a.artist_id, a.name, f.festival_year
HAVING 
    COUNT(*) > 2;

