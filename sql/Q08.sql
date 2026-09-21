USE festivalDB;
SELECT s.staff_id, s.name
FROM staff s
JOIN staff_duty sd ON s.staff_duty_id = sd.staff_duty_id
WHERE sd.staff_duty_name = 'Secondary'
  AND s.staff_id NOT IN (
    SELECT sa.staff_id
    FROM staff_assignment sa
    JOIN stage st ON sa.stage_id = st.stage_id
    JOIN events e ON e.stage_id = st.stage_id
    JOIN day d ON e.day_id = d.day_id
    WHERE d.day_date = '2006-07-20'
);
