USE festivalDB;
SELECT 
    a.artist_id,
    a.name,
    ec.criteria_name,
    ROUND(AVG(pr.rating), 2) AS average_rating
FROM 
    performance_reviews pr
JOIN 
    evaluation_criteria ec ON pr.criteria_id = ec.criteria_id
JOIN 
    tickets t ON pr.EAN_13 = t.EAN_13
JOIN 
    performances p ON t.performance_id = p.performance_id
JOIN 
    artists a ON p.artist_id = a.artist_id
WHERE 
    a.name = 'Celine Marie Claudette Dion'
    AND ec.criteria_name IN ('Artist performance', 'Overall impression')
GROUP BY 
    a.artist_id, a.name, ec.criteria_name;



