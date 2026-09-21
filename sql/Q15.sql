USE festivalDB;
SELECT 
    v.name AS visitor_name,
    v.surname AS visitor_surname,
    a.name AS artist_name,
    SUM(pr.rating) AS total_score
FROM performance_reviews pr
JOIN tickets t ON pr.EAN_13 = t.EAN_13
JOIN visitors v ON v.visitor_id = t.visitor_id
JOIN performances p ON t.performance_id = p.performance_id
JOIN artists a ON a.artist_id = p.artist_id
GROUP BY v.visitor_id, a.artist_id
ORDER BY total_score DESC
LIMIT 5;
