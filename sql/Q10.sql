USE festivalDB;
SELECT 
    g.genre,
    sg.subgenre,
    COUNT(*) AS appearances
FROM artist_genre ag
JOIN artist_subgenre asg ON ag.artist_id = asg.artist_id
JOIN genre g ON ag.genre_id = g.genre_id
JOIN subgenre sg ON asg.subgenre_id = sg.subgenre_id
JOIN artists a ON a.artist_id = ag.artist_id
JOIN performances p ON p.artist_id = a.artist_id
JOIN events e ON e.event_id = p.event_id
JOIN festival f ON f.festival_year = e.festival_year
GROUP BY g.genre, sg.subgenre
ORDER BY appearances DESC
LIMIT 3;
