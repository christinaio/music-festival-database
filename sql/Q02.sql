USE festivalDB;
SELECT 
    a.artist_id,
    a.name,
    a.nickname,
    g.genre,
    CASE 
        WHEN e.festival_year = 2003 THEN 'ΝΑΙ'
        ELSE 'ΟΧΙ'
    END AS participated_in_2003
FROM 
    artists a
JOIN 
    artist_genre ag ON a.artist_id = ag.artist_id
JOIN 
    genre g ON ag.genre_id = g.genre_id
LEFT JOIN 
    performances p ON a.artist_id = p.artist_id
LEFT JOIN 
    events e ON p.event_id = e.event_id
WHERE 
    g.genre = 'Έντεχνο'
GROUP BY 
    a.artist_id, a.name, a.nickname, g.genre, participated_in_2003;