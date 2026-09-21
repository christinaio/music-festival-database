CREATE DATABASE festivalDB;
USE festivalDB;


CREATE TABLE coordinates(
    coordinate_id int AUTO_INCREMENT,
    latitude float,
    longitude float,
    PRIMARY KEY(coordinate_id)
);


CREATE TABLE location(
    location_id int AUTO_INCREMENT,
    location_name varchar(45),
    coordinate_id int UNIQUE NOT NULL,
    location_address varchar(45) NOT NULL,
    city varchar(45) NOT NULL,
    country varchar(45) NOT NULL,
    continent varchar(45) NOT NULL,
    PRIMARY KEY(location_id),
	FOREIGN KEY(coordinate_id) REFERENCES coordinates(coordinate_id)
);



CREATE TABLE festival(
    festival_year int NOT NULL CHECK (festival_year > 0),
    duration int NOT NULL CHECK (duration > 0),  -- Duration of the festival in days
    location_id int NOT NULL,
    image varchar(255),
    image_description varchar(45),
    PRIMARY KEY(festival_year),
    FOREIGN KEY(location_id) REFERENCES location(location_id)
);

CREATE TABLE genre(
	genre_id int AUTO_INCREMENT,
    genre varchar(45),
    PRIMARY KEY(genre_id)
);

INSERT INTO genre(genre)
VALUES
('Έντεχνο'),
('Λαικό'),
('Pop'),
('Hip-Hop'),
('R&B');


CREATE TABLE subgenre(
	subgenre_id int AUTO_INCREMENT,
    subgenre varchar(45),
    PRIMARY KEY(subgenre_id)
);


INSERT INTO subgenre(subgenre)
VALUES
('Έντεχνο'),
('Ελαφρολαικό'),
('Pop rock'),
('Acoustic pop'),
('Soft rock'),
('Rap');

CREATE TABLE artists(
	artist_id int AUTO_INCREMENT,
    name varchar(45),
    nickname varchar(45),
    birthdate date,
    website varchar(45),
    instagram varchar(45),
    genre_id int,
    subgenre_id int, 
    image varchar(255),
    image_description varchar(45),
    PRIMARY KEY(artist_id),
    FOREIGN KEY(genre_id) REFERENCES genre(genre_id),
    FOREIGN KEY(subgenre_id) REFERENCES subgenre(subgenre_id)
);


CREATE TABLE day(
	day_id int AUTO_INCREMENT,
    festival_year int NOT NULL,
    day_number INT NOT NULL CHECK (day_number >=1 ),
    day_date DATE, 
    PRIMARY KEY(day_id),
    FOREIGN KEY(festival_year) REFERENCES festival(festival_year) ON DELETE CASCADE
);

DELIMITER $$

CREATE TRIGGER check_days_against_duration
BEFORE INSERT ON day
FOR EACH ROW
BEGIN
  DECLARE day_count INT;
  SELECT COUNT(*) INTO day_count
  FROM day
  WHERE festival_year = NEW.festival_year;

  DECLARE allowed_duration INT;
  SELECT duration INTO allowed_duration
  FROM festival
  WHERE festival_year = NEW.festival_year;

  IF day_count >= allowed_duration THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Exceeded allowed number of days for this festival year';
  END IF;
END;

DELIMITER ;


CREATE TABLE stage(
    stage_id int AUTO_INCREMENT,
    stage_name varchar(45) NOT NULL,
    stage_description varchar(45),
    audience_capacity INT,
    PRIMARY KEY(stage_id)
);

CREATE TABLE events(
	event_id int AUTO_INCREMENT,
    festival_year int NOT NULL CHECK (festival_year > 0),
    stage_id int NOT NULL,
	event_start int,
    event_end int,
    day_id int,
    PRIMARY KEY(event_id),
    FOREIGN KEY(festival_year) REFERENCES festival(festival_year) ON DELETE CASCADE,
    FOREIGN KEY(stage_id) REFERENCES stage(stage_id) ON DELETE CASCADE,
    FOREIGN KEY(day_id) REFERENCES day(day_id) ON DELETE CASCADE
);

DELIMITER $$

CREATE TRIGGER check_event_stage_overlap
BEFORE INSERT ON events
FOR EACH ROW
BEGIN
    DECLARE conflict_count INT;

    SELECT COUNT(*) INTO conflict_count
    FROM events
    WHERE stage_id = NEW.stage_id
      AND day_id = NEW.day_id
      AND (
            (NEW.event_start BETWEEN event_start AND event_end) OR
            (NEW.event_end BETWEEN event_start AND event_end) OR
            (event_start BETWEEN NEW.event_start AND NEW.event_end)
          );

    IF conflict_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Υπάρχει ήδη event σε αυτή τη σκηνή την ίδια χρονική περίοδο.';
    END IF;
END$$

DELIMITER ;

CREATE TABLE bands(
	band_id int AUTO_INCREMENT,
    band_name varchar(45),
    formation_date DATE,
    genre_id int,
    subgenre_id int,
    website varchar(45),
    instagram varchar(45),
    PRIMARY KEY(band_id),
    FOREIGN KEY(genre_id) REFERENCES genre(genre_id),
    FOREIGN KEY(subgenre_id) REFERENCES subgenre(subgenre_id)
);

CREATE TABLE band_genre(
	band_id int,
    genre_id int,
    PRIMARY KEY (band_id, genre_id),
    FOREIGN KEY (band_id) REFERENCES bands(band_id),
    FOREIGN KEY (genre_id) REFERENCES genre(genre_id)
);

CREATE TABLE band_subgenre(
	band_id int,
    subgenre_id int,
    PRIMARY KEY (band_id, subgenre_id),
    FOREIGN KEY (band_id) REFERENCES bands(band_id),
    FOREIGN KEY (subgenre_id) REFERENCES subgenre(subgenre_id)
);


CREATE TABLE band_members(
	band_id int,
	artist_id int,
    PRIMARY KEY (band_id, artist_id),
    FOREIGN KEY (band_id) REFERENCES bands(band_id),
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
);


CREATE TABLE performance_category(
	category_id int AUTO_INCREMENT,
    category varchar(45),
    PRIMARY KEY(category_id)
);

INSERT INTO performance_category(category) VALUES('Warm up'), ('Special guest'), ('Headline');

CREATE TABLE performances(
	performance_id int AUTO_INCREMENT,
    start_time int CHECK(start_time >= 0 AND start_time <= 1440), 
    end_time int CHECK(end_time >= 0 AND end_time <= 1440),
    CHECK(start_time < end_time AND end_time - start_time <= 180),
    category_id int,
    duration int NOT NULL,
    event_id int,
    artist_id int,
    band_id int,
    PRIMARY KEY(performance_id),
    FOREIGN KEY(event_id) REFERENCES events(event_id) ON DELETE CASCADE,
    FOREIGN KEY(category_id) REFERENCES performance_category(category_id),
	FOREIGN KEY(artist_id) REFERENCES artists(artist_id),
    FOREIGN KEY(band_id) REFERENCES bands(band_id)
);

DELIMITER $$

CREATE TRIGGER check_performance_within_event_time
BEFORE INSERT ON performances
FOR EACH ROW
BEGIN
    DECLARE evt_start INT;
    DECLARE evt_end INT;

    -- Πάρε τα χρονικά όρια του event
    SELECT event_start, event_end INTO evt_start, evt_end
    FROM events
    WHERE event_id = NEW.event_id;

    -- Έλεγξε αν το performance είναι εντός του χρονικού διαστήματος του event
    IF NEW.start_time < evt_start OR NEW.end_time > evt_end THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Η εμφάνιση πρέπει να είναι εντός της χρονικής διάρκειας του event.';
    END IF;
END$$

DELIMITER ;


CREATE TABLE performance_sequence (
    event_id INT NOT NULL,
    previous_performance_id INT NOT NULL,
    next_performance_id INT NOT NULL,
    break_duration INT NOT NULL CHECK (break_duration BETWEEN 5 AND 30), 
    PRIMARY KEY(event_id, previous_performance_id, next_performance_id),
    FOREIGN KEY(event_id) REFERENCES events(event_id) ON DELETE CASCADE,
    FOREIGN KEY(previous_performance_id) REFERENCES performances(performance_id) ON DELETE CASCADE,
    FOREIGN KEY(next_performance_id) REFERENCES performances(performance_id) ON DELETE CASCADE
);

DELIMITER $$

CREATE TRIGGER check_break_duration
BEFORE INSERT ON performance_sequence
FOR EACH ROW
BEGIN
    DECLARE prev_end INT;
    DECLARE next_start INT;
    DECLARE calculated_break INT;

    -- Πάρε τις χρονικές τιμές των εμφανίσεων
    SELECT end_time INTO prev_end
    FROM performances
    WHERE performance_id = NEW.previous_performance_id;

    SELECT start_time INTO next_start
    FROM performances
    WHERE performance_id = NEW.next_performance_id;

    -- Υπολόγισε την πραγματική διάρκεια διαλείμματος
    SET calculated_break = next_start - prev_end;

    -- Αν το διάλειμμα δεν ταιριάζει με το πεδίο break_duration ή είναι εκτός ορίων, απόρριψε
    IF calculated_break != NEW.break_duration OR calculated_break < 5 OR calculated_break > 30 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid break duration: must match actual time difference and be between 5 and 30 minutes';
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER check_stage_overlap
BEFORE INSERT ON performances
FOR EACH ROW
BEGIN
    DECLARE stage_conflict INT;

    SELECT COUNT(*) INTO stage_conflict
    FROM performances p
    JOIN events e ON p.event_id = e.event_id
    JOIN events e_new ON NEW.event_id = e_new.event_id
    WHERE e.stage_id = e_new.stage_id
      AND (
            (NEW.start_time BETWEEN p.start_time AND p.end_time) OR
            (NEW.end_time BETWEEN p.start_time AND p.end_time) OR
            (p.start_time BETWEEN NEW.start_time AND NEW.end_time) OR
            (p.end_time BETWEEN NEW.start_time AND NEW.end_time)
         );

    IF stage_conflict > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Υπάρχει ήδη performance σε αυτή τη σκηνή την ίδια ώρα.';
    END IF;
END$$

DELIMITER ;

CREATE TABLE technical_equipment(
    technical_equipment_id int AUTO_INCREMENT,
    equipment_name varchar(45) NOT NULL,
    equipment_quantity int NOT NULL CHECK (equipment_quantity > 0),
    image varchar(255),
    image_description varchar(45),
    PRIMARY KEY(technical_equipment_id)
);

CREATE TABLE stage_technical_equipment( 
    stage_id int,
    technical_equipment_id int,
    equipment_quantity int NOT NULL CHECK (equipment_quantity > 0),
    PRIMARY KEY(stage_id, technical_equipment_id),
    FOREIGN KEY(stage_id) REFERENCES stage(stage_id),
    FOREIGN KEY(technical_equipment_id) REFERENCES technical_equipment(technical_equipment_id) ON DELETE CASCADE
);


DELIMITER $$

CREATE TRIGGER check_equipment_availability
BEFORE INSERT ON stage_technical_equipment
FOR EACH ROW
BEGIN
    DECLARE total_available INT DEFAULT 0;
    DECLARE total_needed INT DEFAULT 0;

    -- Ανάκτηση συνολικού διαθέσιμου εξοπλισμού από τον πίνακα technical_equipment
    SELECT equipment_quantity INTO total_available
    FROM technical_equipment
    WHERE technical_equipment_id = NEW.technical_equipment_id;

    -- Υπολογισμός συνολικού εξοπλισμού που χρησιμοποιείται ήδη ταυτόχρονα στη σκηνή
    SELECT COALESCE(SUM(req.equipment_quantity), 0) INTO total_needed
    FROM stage_technical_equipment req
    WHERE req.technical_equipment_id = NEW.technical_equipment_id
      AND req.stage_id = NEW.stage_id;

    -- Έλεγχος υπέρβασης
    IF (total_needed + NEW.equipment_quantity) > total_available THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Υπέρβαση διαθέσιμου εξοπλισμού για τη σκηνή.';
    END IF;
END$$

DELIMITER ;




CREATE TABLE artist_event (
    artist_id INT,
    event_id INT,
    PRIMARY KEY (artist_id, event_id),
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id),
    FOREIGN KEY (event_id) REFERENCES events(event_id)
);

DELIMITER $$

CREATE TRIGGER prevent_artist_double_booking
BEFORE INSERT ON artist_event
FOR EACH ROW
BEGIN
  DECLARE new_start INT;
  DECLARE new_end INT;
  DECLARE new_stage INT;
  DECLARE new_day INT;
  DECLARE conflict_count INT;

  -- Πάρε πληροφορίες για το νέο event
  SELECT event_start, event_end, stage_id, day_id
  INTO new_start, new_end, new_stage, new_day
  FROM events
  WHERE event_id = NEW.event_id;

  -- Έλεγξε αν υπάρχει άλλη εμφάνιση του καλλιτέχνη την ίδια μέρα με χρονική επικάλυψη και σε άλλη σκηνή
  SELECT COUNT(*) INTO conflict_count
  FROM artist_event ae
  JOIN events e ON ae.event_id = e.event_id
  WHERE ae.artist_id = NEW.artist_id
    AND e.day_id = new_day
    AND e.stage_id <> new_stage
    AND (
      e.event_start < new_end AND e.event_end > new_start
    );

  IF conflict_count > 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Artist already booked on a different stage at the same time.';
  END IF;
END$$

DELIMITER ;



DELIMITER $$
CREATE TRIGGER check_artist_max_consecutive_years
BEFORE INSERT ON artist_event
FOR EACH ROW
BEGIN
  DECLARE current_year INT;
  DECLARE count_prev_years INT;

  -- Παίρνουμε το έτος του event που πάμε να εισάγουμε
  SELECT festival_year
  INTO current_year
  FROM events
  WHERE event_id = NEW.event_id;

  -- Ελέγχουμε αν ο καλλιτέχνης έχει εμφανιστεί ΚΑΙ τα 3 προηγούμενα συνεχόμενα έτη
  SELECT COUNT(DISTINCT f.festival_year) INTO count_prev_years
  FROM artist_event ae
  JOIN events e ON ae.event_id = e.event_id
  JOIN festival f ON e.festival_year = f.festival_year
  WHERE ae.artist_id = NEW.artist_id
    AND f.festival_year IN (current_year - 1, current_year - 2, current_year - 3);

  IF count_prev_years = 3 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Artist cannot perform more than 3 consecutive years.';
  END IF;
END$$

DELIMITER ;


CREATE TABLE artist_genre(
	artist_id int,
    genre_id int,
    PRIMARY KEY (artist_id, genre_id),
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id),
    FOREIGN KEY (genre_id) REFERENCES genre(genre_id)
);

CREATE TABLE artist_subgenre(
	artist_id int,
    subgenre_id int,
    PRIMARY KEY (artist_id, subgenre_id),
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id),
    FOREIGN KEY (subgenre_id) REFERENCES subgenre(subgenre_id)
);




CREATE TABLE experience(
	experience_id int AUTO_INCREMENT,
    experience varchar(45),
    PRIMARY KEY(experience_id)
);

INSERT INTO experience(experience) VALUES('Beginner'), ('Intermediate'), ('Advanced'), ('Expert'), ('Master');

CREATE TABLE staff_duty(
    staff_duty_id int AUTO_INCREMENT,
    staff_duty_name varchar(45) NOT NULL,
    PRIMARY KEY(staff_duty_id)
);

INSERT INTO staff_duty(staff_duty_name) VALUES('Technician'),('Security'),('Secondary');


CREATE TABLE staff(
	staff_id int AUTO_INCREMENT,
    name varchar(45),
    birth_date DATE,
    experience_id int,
    staff_duty_id int,
    image varchar(255),
    PRIMARY KEY(staff_id),
    FOREIGN KEY(staff_duty_id) REFERENCES staff_duty(staff_duty_id),
    FOREIGN KEY(experience_id) REFERENCES experience(experience_id)
);

CREATE TABLE staff_assignment (
    assignment_id INT AUTO_INCREMENT,
    staff_id INT,
    stage_id INT,
    PRIMARY KEY(assignment_id),
    FOREIGN KEY(staff_id) REFERENCES staff(staff_id),
    FOREIGN KEY(stage_id) REFERENCES stage(stage_id)
);

DELIMITER $$

CREATE TRIGGER check_staffing_requirements
AFTER INSERT ON staff_assignment
FOR EACH ROW
BEGIN
  DECLARE total_staff INT;
  DECLARE security_count INT;
  DECLARE secondary_count INT;
  DECLARE stage_capacity INT;

  -- Υπολογισμός συνολικού προσωπικού για τη σκηνή
  SELECT COUNT(*) INTO total_staff
  FROM staff_assignment
  WHERE stage_id = NEW.stage_id;

  -- Αν δεν έχουν ανατεθεί τουλάχιστον 10 άτομα, μην ελέγχεις ακόμα
  IF total_staff >= 3 THEN

    -- Πάρε τη χωρητικότητα της σκηνής
    SELECT audience_capacity INTO stage_capacity
    FROM stage
    WHERE stage_id = NEW.stage_id;

    -- Πόσοι είναι "Security"
    SELECT COUNT(*) INTO security_count
    FROM staff_assignment sa
    JOIN staff s ON sa.staff_id = s.staff_id
    JOIN staff_duty sd ON s.staff_duty_id = sd.staff_duty_id
    WHERE sa.stage_id = NEW.stage_id AND sd.staff_duty_name = 'Security';

    -- Πόσοι είναι "Secondary"
    SELECT COUNT(*) INTO secondary_count
    FROM staff_assignment sa
    JOIN staff s ON sa.staff_id = s.staff_id
    JOIN staff_duty sd ON s.staff_duty_id = sd.staff_duty_id
    WHERE sa.stage_id = NEW.stage_id AND sd.staff_duty_name = 'Secondary';

    -- Έλεγχος ελάχιστων ορίων
    IF security_count < stage_capacity * 0.05 THEN
      SIGNAL SQLSTATE '45000' 
      SET MESSAGE_TEXT = 'Not enough Security staff for this stage (after threshold)';
    END IF;

    IF secondary_count < stage_capacity * 0.02 THEN
      SIGNAL SQLSTATE '45000' 
      SET MESSAGE_TEXT = 'Not enough Secondary staff for this stage (after threshold)';
    END IF;
  END IF;
END$$

DELIMITER ;




CREATE TABLE technical_role(
    technical_role_id INT AUTO_INCREMENT,
    role_name VARCHAR(45) NOT NULL,
    PRIMARY KEY(technical_role_id)
);


INSERT INTO technical_role(role_name) VALUES ('Ηχολήπτης'), ('Φωτιστής'), ('Stage Manager');


CREATE TABLE technical_staff(
    technical_staff_id INT AUTO_INCREMENT,
    staff_id INT NOT NULL, 
    technical_role_id INT NOT NULL,
    PRIMARY KEY(technical_staff_id),
    FOREIGN KEY(staff_id) REFERENCES staff(staff_id) ON DELETE CASCADE,
    FOREIGN KEY(technical_role_id) REFERENCES technical_role(technical_role_id)
);

CREATE TABLE visitors(
	visitor_id int AUTO_INCREMENT,
    name varchar(45) NOT NULL,
    surname varchar(45) NOT NULL,
	birth_date DATETIME,
    PRIMARY KEY(visitor_id)
);
    
    
CREATE TABLE visitors_info(
	info_id int AUTO_INCREMENT,
    visitor_id int, 
    mobile_number int,
    email varchar(45),
    PRIMARY KEY(info_id),
    FOREIGN KEY(visitor_id) REFERENCES visitors(visitor_id) ON DELETE CASCADE
);

    

CREATE TABLE ticket_category(
	category_id int AUTO_INCREMENT,
    category varchar(45),
    PRIMARY KEY(category_id)
);

INSERT INTO ticket_category(category)
VALUES ('VIP'), ('BACKSTAGE'), ('Γενική Είσοδος');



CREATE TABLE payment_type(
	payment_type_id int AUTO_INCREMENT,
    payment_type varchar(45),
    PRIMARY KEY(payment_type_id)
);

INSERT INTO payment_type(payment_type) VALUES ('Πιστωτική Κάρτα'), ('Χρεωστική Κάρτα'), ('Τραπεζικός Λογαριασμός');


CREATE TABLE tickets(
	EAN_13 bigint NOT NULL CHECK (EAN_13 > 0),
    category_id int,
    visitor_id int,
    performance_id int,
    used BOOLEAN,
    payment_type_id int,
    purchase_date DATE, 
    PRIMARY KEY(EAN_13),
    FOREIGN KEY(category_id) REFERENCES ticket_category(category_id),
    FOREIGN KEY(performance_id) REFERENCES performances(performance_id),
    FOREIGN KEY(visitor_id) REFERENCES visitors(visitor_id),
    FOREIGN KEY(payment_type_id) REFERENCES payment_type(payment_type_id),
	UNIQUE(visitor_id, performance_id)
);

DELIMITER $$

CREATE TRIGGER check_ticket_purchase_before_festival
BEFORE INSERT ON tickets
FOR EACH ROW
BEGIN
  DECLARE perf_day DATE;

  -- Βρίσκουμε την ημερομηνία της παράστασης (μέσω events → day)
  SELECT d.day_date INTO perf_day
  FROM performances p
  JOIN events e ON p.event_id = e.event_id
  JOIN day d ON e.day_id = d.day_id
  WHERE p.performance_id = NEW.performance_id;

  -- Αν η ημερομηνία αγοράς είναι μετά ή ίση με την ημερομηνία της εμφάνισης, απορρίπτουμε
  IF NEW.purchase_date >= perf_day THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Η αγορά εισιτηρίου δεν επιτρέπεται μετά την ημερομηνία της εμφάνισης.';
  END IF;
END$$

DELIMITER ;


DELIMITER $$

CREATE TRIGGER prevent_duplicate_use
BEFORE UPDATE ON tickets
FOR EACH ROW
BEGIN
    -- Αν προσπαθείς να ενεργοποιήσεις ξανά ήδη χρησιμοποιημένο εισιτήριο
    IF OLD.used = TRUE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Το εισιτήριο έχει ήδη χρησιμοποιηθεί.';
    END IF;
END$$

DELIMITER ;


CREATE TABLE ticket_price (
    day_id INT,
    category_id INT,
    price DECIMAL(6,2) NOT NULL,
    PRIMARY KEY(day_id, category_id),
    FOREIGN KEY(day_id) REFERENCES day(day_id),
    FOREIGN KEY(category_id) REFERENCES ticket_category(category_id)
);




DELIMITER $$

CREATE TRIGGER check_stage_capacity
BEFORE INSERT ON tickets
FOR EACH ROW
BEGIN
  DECLARE current_count INT;
  DECLARE max_capacity INT;

  -- Πλήθος εισιτηρίων που έχουν ήδη πωληθεί για αυτή την παράσταση
  SELECT COUNT(*) INTO current_count
  FROM tickets
  WHERE performance_id = NEW.performance_id;

  -- Χωρητικότητα της σκηνής στην οποία γίνεται η παράσταση
  SELECT s.audience_capacity INTO max_capacity
  FROM performances p
  JOIN events e ON p.event_id = e.event_id
  JOIN stage s ON e.stage_id = s.stage_id
  WHERE p.performance_id = NEW.performance_id;

  -- Αν το όριο έχει φτάσει, μπλόκαρε την εισαγωγή
  IF current_count >= max_capacity THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Stage capacity exceeded. Cannot sell more tickets.';
  END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER check_vip_limit_on_insert
BEFORE INSERT ON tickets
FOR EACH ROW
BEGIN
  DECLARE vip_count INT DEFAULT 0;
  DECLARE max_vip_allowed INT DEFAULT 0;
  DECLARE stage_capacity INT;
  DECLARE stage_id INT;
  DECLARE vip_category_id INT;

  -- Πάρε το ID της κατηγορίας VIP
  SELECT category_id INTO vip_category_id
  FROM ticket_category
  WHERE category = 'VIP';

  -- Αν το νέο εισιτήριο είναι VIP
  IF NEW.category_id = vip_category_id THEN

    -- Πάρε το stage_id της παράστασης
    SELECT e.stage_id INTO stage_id
    FROM performances p
    JOIN events e ON p.event_id = e.event_id
    WHERE p.performance_id = NEW.performance_id;

    -- Πάρε τη χωρητικότητα της σκηνής
    SELECT s.audience_capacity INTO stage_capacity
    FROM stage s
    WHERE s.stage_id = stage_id;

    -- Υπολόγισε μέγιστο επιτρεπτό VIP για τη συγκεκριμένη παράσταση
    SET max_vip_allowed = FLOOR(stage_capacity * 0.10);

    -- Υπολόγισε πόσα VIP εισιτήρια υπάρχουν για αυτή την παράσταση
    SELECT COUNT(*) INTO vip_count
    FROM tickets t
    WHERE t.category_id = vip_category_id
      AND t.performance_id = NEW.performance_id;

    -- Αν ξεπερνά το επιτρεπτό όριο
    IF vip_count >= max_vip_allowed THEN
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Έχει συμπληρωθεί το όριο των VIP εισιτηρίων για αυτή την παράσταση.';
    END IF;

  END IF;
END$$

DELIMITER ;




CREATE TABLE buyers(
	buyer_id int AUTO_INCREMENT,
    name varchar(45) NOT NULL,
    surname varchar(45) NOT NULL,
    birth_date DATE,
    PRIMARY KEY(buyer_id)
);

CREATE TABLE buyers_info(
	info_id int AUTO_INCREMENT,
    buyer_id int, 
    mobile_number int,
    email varchar(45),
    PRIMARY KEY(info_id),
    FOREIGN KEY(buyer_id) REFERENCES buyers(buyer_id) ON DELETE CASCADE
);
	

CREATE TABLE desired_by_type(
    requested_at timestamp DEFAULT CURRENT_TIMESTAMP,
    buyer_id int,
    category_id int,
    performance_id int,
    PRIMARY KEY(buyer_id, category_id, performance_id),
    FOREIGN KEY (buyer_id) REFERENCES buyers(buyer_id),
    FOREIGN KEY (category_id) REFERENCES ticket_category(category_id),
    FOREIGN KEY (performance_id) REFERENCES performances(performance_id)
);


CREATE TABLE reselling_tickets(
    reselling_ticket_id int AUTO_INCREMENT,
    EAN_13 bigint NOT NULL,
    PRIMARY KEY(reselling_ticket_id),
    FOREIGN KEY(EAN_13) REFERENCES tickets(EAN_13) ON DELETE CASCADE
);


CREATE TABLE desired_by_ticketID(
	reselling_ticket_id int,
    buyer_id int, 
    requested_at timestamp,
    PRIMARY KEY(buyer_id, reselling_ticket_id),
    FOREIGN KEY (buyer_id) REFERENCES buyers(buyer_id),
    FOREIGN KEY(reselling_ticket_id) REFERENCES reselling_tickets(reselling_ticket_id)
);
    
DELIMITER $$

CREATE TRIGGER check_purchase_before_request
BEFORE INSERT ON tickets
FOR EACH ROW
BEGIN
  DECLARE req_time1 TIMESTAMP;
  DECLARE req_time2 TIMESTAMP;

  -- Ελέγχουμε αν υπάρχει καταχώρηση στη desired_by_ticketID
  SELECT requested_at INTO req_time1
  FROM desired_by_ticketID
  WHERE reselling_ticket_id = NEW.EAN_13 AND buyer_id = NEW.visitor_id
  LIMIT 1;

  -- Ελέγχουμε αν υπάρχει καταχώρηση στη desired_by_type
  SELECT requested_at INTO req_time2
  FROM desired_by_type
  WHERE category_id = NEW.category_id AND buyer_id = NEW.visitor_id AND performance_id = NEW.performance_id
  LIMIT 1;

  -- Έλεγχος: purchase_date να είναι πριν από οποιοδήποτε σχετικό requested_at
  IF (req_time1 IS NOT NULL AND NEW.purchase_date >= req_time1)
     OR (req_time2 IS NOT NULL AND NEW.purchase_date >= req_time2) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Δεν μπορείς να κάνεις αίτημα αγοράς';
  END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE match_resale_ticket(IN in_reselling_ticket_id INT)
BEGIN
    DECLARE v_ticket_id BIGINT;
    DECLARE v_category_id INT;
    DECLARE v_performance_id INT;
    DECLARE v_buyer_id INT;

    -- 1. Βρίσκουμε το EAN_13 και χαρακτηριστικά εισιτηρίου
    SELECT t.EAN_13, t.category_id, t.performance_id
    INTO v_ticket_id, v_category_id, v_performance_id
    FROM reselling_tickets r
    JOIN tickets t ON r.EAN_13 = t.EAN_13
    WHERE r.reselling_ticket_id = in_reselling_ticket_id;

    -- 2. Βρίσκουμε τον παλαιότερο ενδιαφερόμενο αγοραστή (FIFO)
    SELECT buyer_id
    INTO v_buyer_id
    FROM desired_by_type
    WHERE category_id = v_category_id AND performance_id = v_performance_id
    ORDER BY requested_at ASC
    LIMIT 1;

    -- 3. Αν βρέθηκε αγοραστής, κάνουμε μεταπώληση
    IF v_buyer_id IS NOT NULL THEN
        -- Ενημερώνουμε τον κάτοχο του εισιτηρίου
        UPDATE tickets
        SET visitor_id = v_buyer_id
        WHERE EAN_13 = v_ticket_id;

        -- Διαγράφουμε την προσφορά μεταπώλησης και το αίτημα αγοράς
        DELETE FROM reselling_tickets WHERE reselling_ticket_id = in_reselling_ticket_id;
        DELETE FROM desired_by_type
        WHERE buyer_id = v_buyer_id
          AND category_id = v_category_id
          AND performance_id = v_performance_id;

    END IF;
END$$

DELIMITER ;

    
CREATE TABLE evaluation_criteria (
    criteria_id INT AUTO_INCREMENT,
    criteria_name VARCHAR(45) NOT NULL,
    PRIMARY KEY(criteria_id)
);

INSERT INTO evaluation_criteria (criteria_name) VALUES
('Artist performance'),
('Sound-Lighting'),
('Stage presence'),
('Level of organization'),
('Overall impression');



CREATE TABLE performance_reviews (
    review_id INT AUTO_INCREMENT,
    EAN_13 BIGINT NOT NULL,  -- Αναφορά στο εισιτήριο του χρήστη
    criteria_id INT NOT NULL,  -- Κριτήριο που βαθμολογείται
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),  -- Κλίμακα Likert
    PRIMARY KEY(review_id),
    FOREIGN KEY(EAN_13) REFERENCES tickets(EAN_13),
    FOREIGN KEY(criteria_id) REFERENCES evaluation_criteria(criteria_id)
);

DELIMITER $$

CREATE TRIGGER prevent_unattended_reviews
BEFORE INSERT ON performance_reviews
FOR EACH ROW
BEGIN
    DECLARE ticket_used BOOLEAN;

    -- Έλεγχος αν το εισιτήριο έχει χρησιμοποιηθεί
    SELECT used INTO ticket_used
    FROM tickets
    WHERE EAN_13 = NEW.EAN_13;

    -- Αν το εισιτήριο δεν έχει χρησιμοποιηθεί ή δεν υπάρχει, απόρριψε την καταχώρηση
    IF ticket_used IS NULL OR ticket_used = FALSE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Δεν επιτρέπεται η αξιολόγηση χωρίς προηγούμενη παρακολούθηση της παράστασης.';
    END IF;
END$$

DELIMITER ;


DELIMITER //
CREATE TRIGGER trg_artist_birth_before_festival
BEFORE INSERT ON artist_event
FOR EACH ROW
BEGIN
  DECLARE artist_birth DATE;
  DECLARE fest_year INT;

  SELECT a.birthdate INTO artist_birth FROM artists a WHERE a.artist_id = NEW.artist_id;
  SELECT e.festival_year INTO fest_year
  FROM events e
  WHERE e.event_id = NEW.event_id;

  IF YEAR(artist_birth) >= fest_year THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Artist birth year must be before the festival year.';
  END IF;
END;
//
DELIMITER ;



DELIMITER //
CREATE TRIGGER trg_staff_birth_before_festival
BEFORE INSERT ON staff_assignment
FOR EACH ROW
BEGIN
  DECLARE staff_birth DATE;
  DECLARE fest_year INT;

  SELECT s.birth_date INTO staff_birth FROM staff s WHERE s.staff_id = NEW.staff_id;
  SELECT f.festival_year INTO fest_year
  FROM events e
  JOIN stage st ON e.stage_id = NEW.stage_id
  JOIN festival f ON f.festival_year = e.festival_year
  LIMIT 1;

  IF YEAR(staff_birth) >= fest_year THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Staff birth year must be before the festival year.';
  END IF;
END;
//
DELIMITER ;


DELIMITER //
CREATE TRIGGER trg_visitor_birth_before_festival
BEFORE INSERT ON tickets
FOR EACH ROW
BEGIN
  DECLARE visitor_birth DATE;
  DECLARE fest_year INT;

  SELECT v.birth_date INTO visitor_birth FROM visitors v WHERE v.visitor_id = NEW.visitor_id;
  SELECT e.festival_year INTO fest_year
  FROM performances p
  JOIN events e ON p.event_id = e.event_id
  WHERE p.performance_id = NEW.performance_id;

  IF YEAR(visitor_birth) >= fest_year THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Visitor birth year must be before the festival year.';
  END IF;
END;
//
DELIMITER ;


DELIMITER //
CREATE TRIGGER trg_buyer_birth_before_festival
BEFORE INSERT ON desired_by_type
FOR EACH ROW
BEGIN
  DECLARE buyer_birth DATE;
  DECLARE fest_year INT;

  SELECT b.birth_date INTO buyer_birth FROM buyers b WHERE b.buyer_id = NEW.buyer_id;
  SELECT e.festival_year INTO fest_year
  FROM performances p
  JOIN events e ON p.event_id = e.event_id
  WHERE p.performance_id = NEW.performance_id;

  IF YEAR(buyer_birth) >= fest_year THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Buyer birth year must be before the festival year.';
  END IF;
END;
//
DELIMITER ;


-- drop database festivalDB;