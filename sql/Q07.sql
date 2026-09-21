USE festivalDB;
SELECT 
    f.festival_year,
    CASE
        WHEN AVG(e.experience_id) BETWEEN 0 AND 1.5 THEN 'Beginner'
        WHEN AVG(e.experience_id) > 1.5 AND AVG(e.experience_id) <= 2.5 THEN 'Intermediate'
        WHEN AVG(e.experience_id) > 2.5 AND AVG(e.experience_id) <= 3.5 THEN 'Advanced'
        WHEN AVG(e.experience_id) > 3.5 AND AVG(e.experience_id) <= 4.5 THEN 'Expert'
        WHEN AVG(e.experience_id) > 4.5 THEN 'Master'
        ELSE 'Unknown'
    END AS experience_level_label
FROM 
    staff s
JOIN 
    technical_staff ts ON s.staff_id = ts.staff_id
JOIN 
    staff_assignment sa ON s.staff_id = sa.staff_id
JOIN 
    stage st ON sa.stage_id = st.stage_id
JOIN 
    events ev ON st.stage_id = ev.stage_id
JOIN 
    festival f ON ev.festival_year = f.festival_year
JOIN 
    experience e ON s.experience_id = e.experience_id
GROUP BY 
    f.festival_year
ORDER BY 
    AVG(e.experience_id) ASC
LIMIT 1;
