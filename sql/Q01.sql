USE festivalDB;

SELECT 
    e.festival_year,
    pt.payment_type,
    SUM(tp.price) AS total_revenue
FROM tickets t
JOIN ticket_category tc ON t.category_id = tc.category_id
JOIN payment_type pt ON t.payment_type_id = pt.payment_type_id
JOIN performances p ON t.performance_id = p.performance_id
JOIN events e ON p.event_id = e.event_id
JOIN day d ON e.day_id = d.day_id
JOIN ticket_price tp ON tp.day_id = d.day_id AND tp.category_id = tc.category_id
GROUP BY e.festival_year, pt.payment_type
ORDER BY e.festival_year, pt.payment_type;
