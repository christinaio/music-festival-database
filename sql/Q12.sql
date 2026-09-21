USE festivalDB;
SELECT 
    d.festival_year,
    d.day_number,
    sd.staff_duty_name,
    COUNT(DISTINCT s.staff_id) AS staff_required
FROM staff s
JOIN staff_duty sd ON s.staff_duty_id = sd.staff_duty_id
JOIN staff_assignment sa ON sa.staff_id = s.staff_id
JOIN stage st ON st.stage_id = sa.stage_id
JOIN events e ON e.stage_id = st.stage_id
JOIN day d ON d.day_id = e.day_id
GROUP BY d.festival_year, d.day_number, sd.staff_duty_name
ORDER BY d.festival_year, d.day_number, sd.staff_duty_name;
