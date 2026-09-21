USE festivalDB;
SELECT 
    p.performance_id,
    t.visitor_id,
    CONCAT(v.name, ' ', v.surname) AS visitor_name,
    ROUND(AVG(r.rating), 2) AS average_rating
FROM 
    tickets t
JOIN 
    performances p ON t.performance_id = p.performance_id
JOIN 
    visitors v ON t.visitor_id = v.visitor_id
LEFT JOIN 
    performance_reviews r ON t.EAN_13 = r.EAN_13
LEFT JOIN 
    artists a ON p.artist_id = a.artist_id
WHERE 
    v.visitor_id = 199
GROUP BY 
    p.performance_id, a.name, t.visitor_id, v.name, v.surname;
