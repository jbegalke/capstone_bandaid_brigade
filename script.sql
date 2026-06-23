
DROP DATABASE IF EXISTS rrc_clinic;

CREATE DATABASE IF NOT EXISTS rrc_clinic;

USE rrc_clinic;

-- LAYER 0 BEGIN

DROP TABLE IF EXISTS patients;

CREATE TABLE patients (
    PHIN_id INT PRIMARY KEY,
    first_name VARCHAR(10),
    last_name VARCHAR(10),
    address VARCHAR(60),
    phone_number VARCHAR(10),
    email_address VARCHAR(30)
);

LOAD DATA INFILE 'C:\\_data\\capstone_bandaid_brigade\\patients.csv' INTO
TABLE patients FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (
    PHIN_id,
    first_name,
    last_name,
    address,
    phone_number,
    email_address
);

DROP TABLE IF EXISTS allergies;

CREATE TABLE allergies (
    allergy_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255)
);

-- TODO: fix this
LOAD DATA INFILE 'C:\\_data\\capstone_bandaid_brigade\\allergies.csv' INTO
TABLE allergies FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (allergy_id, name)

DROP TABLE IF EXISTS insurance_providers;

CREATE TABLE IF NOT EXISTS insurance_providers (
    insurance_provider_id INT AUTO_INCREMENT PRIMARY KEY,
    company_name VARCHAR(100),
    address VARCHAR(100),
    email_address VARCHAR(50),
    phone_number VARCHAR(20)
);

LOAD DATA INFILE 'C:\\_data\\capstone_bandaid_brigade\\insurance_providers.csv' INTO
TABLE insurance_providers FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (
    insurance_provider_id,
    company_name,
    address,
    email_address,
    phone_number
);

DROP TABLE IF EXISTS diagnoses;

CREATE TABLE IF NOT EXISTS diagnoses (
    diagnosis_id INT AUTO_INCREMENT PRIMARY KEY,
    diagnosis_code VARCHAR(100) NOT NULL,
    name VARCHAR(255)
);

LOAD DATA INFILE 'C:\\_data\\capstone_bandaid_brigade\\diagnoses.csv' INTO
TABLE diagnoses FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (
    diagnosis_id,
    diagnosis_code,
    name
);

DROP TABLE IF EXISTS medical_specialties;

CREATE TABLE IF NOT EXISTS medical_specialties (
    medical_specialty_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    responsibilities TEXT
);

LOAD DATA INFILE 'C:\\_data\\capstone_bandaid_brigade\\medical_specialties.csv' INTO
TABLE medical_specialties FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 LINES (
    name,
    responsibilities
);

DROP TABLE IF EXISTS fee_schedules;

CREATE TABLE IF NOT EXISTS fee_schedules (
    fee_schedule_id INT AUTO_INCREMENT PRIMARY KEY,
    duration INT UNSIGNED,
    consultation_cost DECIMAL(10, 2)
);

LOAD DATA INFILE 'C:\\_data\\capstone_bandaid_brigade\\fee_schedules.csv' INTO
TABLE fee_schedules FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (
    fee_schedule_id,
    duration,
    consultation_cost
);

-- LAYER 1 BEGIN
DROP TABLE IF EXISTS patient_allergies ;

CREATE TABLE IF NOT EXISTS patient_allergies (
    PHIN_id INT,
    allergy_id INT,
    PRIMARY KEY (PHIN_id, allergy_id),
    FOREIGN KEY (PHIN_id) REFERENCES patients (PHIN_id),
    FOREIGN KEY (allergy_id) REFERENCES allergies (allergy_id)
);

LOAD DATA INFILE 'C:\\_data\\capstone_bandaid_brigade\\patient_allergies.csv'
IGNORE
INTO TABLE patient_allergies
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(PHIN_id, allergy_id);

DROP TABLE IF EXISTS doctors;

CREATE TABLE IF NOT EXISTS doctors (
    licence_id CHAR(19) PRIMARY KEY,
    first_name VARCHAR(30),
    last_name VARCHAR(30),
    medical_specialty_id INT REFERENCES medical_specialties(medical_specialty_id)
);

LOAD DATA INFILE 'C:\\_data\\capstone_bandaid_brigade\\doctors.csv' INTO
TABLE doctors FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (
    licence_id,
    first_name,
    last_name,
    medical_specialty_id
);

SELECT * FROM medical_specialties

CREATE TABLE IF NOT EXISTS appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    start_date DATE,
    duration_mins SMALLINT,
    status VARCHAR(15),
    appointment_type VARCHAR(50),
    reason VARCHAR(100),
    notice TEXT,
    cancel_minutes_before INT,
    PHIN_id INT,
    FOREIGN KEY (PHIN_id) REFERENCES patients (PHIN_id)
);

-- Super secret strategies
SET FOREIGN_KEY_CHECKS=0;

ALTER TABLE patients
ADD COLUMN rand_index FLOAT NULL,
ADD INDEX idx_rand_index (rand_index);

UPDATE patients
SET rand_index = RAND()
WHERE TRUE;

LOAD DATA INFILE 'C:\\_data\\capstone_bandaid_brigade\\appointments.csv' INTO
TABLE appointments FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (
    appointment_id,
    start_date,
    duration_mins,
    status,
    appointment_type,
    reason,
    notice,
    cancel_minutes_before
);

UPDATE appointments
SET PHIN_id = (
    SELECT PHIN_id
    FROM patients
    WHERE rand_index > RAND()
    ORDER BY rand_index
    LIMIT 1
)
WHERE TRUE;

ALTER TABLE patients
DROP INDEX idx_rand_index,
DROP COLUMN rand_index;

SET FOREIGN_KEY_CHECKS=1;

-- LAYER 2 BEGIN
DROP TABLE IF EXISTS billing_records;

CREATE TABLE IF NOT EXISTS billing_records (
    billing_record_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT UNIQUE,
    insurance_provider_id INT,
    total_fee DECIMAL(10, 2) NOT NULL,
    insurance_covered DECIMAL(10, 2) NOT NULL,
    patient_balance DECIMAL(10, 2) NOT NULL,
    payment_status VARCHAR(20) NOT NULL,
    notes TEXT,
    payment_type VARCHAR(4),
    FOREIGN KEY (insurance_provider_id) REFERENCES insurance_providers (insurance_provider_id),
    FOREIGN KEY (appointment_id) REFERENCES appointments (appointment_id)
);

-- TODO: Add 20k more records to match the appointments table count
LOAD DATA INFILE 'C:\\_data\\capstone_bandaid_brigade\\billing_records2.csv' INTO
TABLE billing_records FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (
    billing_record_id,
    appointment_id,
    insurance_provider_id,
    total_fee,
    insurance_covered,
    patient_balance,
    payment_status,
    notes,
    payment_type
);

CREATE TABLE IF NOT EXISTS doctor_appointments (
    doctor_appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    licence_id CHAR(19) REFERENCES doctors (licence_id),
    appointment_id INT,
    FOREIGN KEY (appointment_id) REFERENCES appointments (appointment_id)
);

LOAD DATA INFILE 'C:\\_data\\capstone_bandaid_brigade\\doctor_appointment.csv' INTO
TABLE doctor_appointments FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (
     doctor_appointment_id, 
     licence_id,
     appointment_id
 );


-- Todo: get doctor appointments data. 

DROP TABLE IF EXISTS doctor_schedules;

CREATE TABLE IF NOT EXISTS doctor_schedules (
    schedule_id INT AUTO_INCREMENT PRIMARY KEY,
    licence_id CHAR(19) REFERENCES doctors (licence_id),
    shift_start DATETIME,
    shift_length_mins SMALLINT
);

LOAD DATA INFILE 'C:\\_data\\capstone_bandaid_brigade\\doctor_schedules.csv'
INTO TABLE doctor_schedules
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    licence_id,
    shift_start,
    shift_length_mins
);

-- LAYER 3 BEGIN
DROP TABLE IF EXISTS fee_schedule_billing_records;

CREATE TABLE IF NOT EXISTS fee_schedule_billing_records (
    billing_record_id INT,
    fee_schedule_id INT,
    PRIMARY KEY (
        billing_record_id,
        fee_schedule_id
    ),
    FOREIGN KEY (billing_record_id) REFERENCES billing_records (billing_record_id),
    FOREIGN KEY (fee_schedule_id) REFERENCES fee_schedules (fee_schedule_id)
);

DROP TABLE IF EXISTS prescriptions;

CREATE TABLE IF NOT EXISTS prescriptions (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    drug_name VARCHAR(100) NOT NULL,
    dosage VARCHAR(60),
    start_date DATE,
    end_date DATE,
    doctor_appointment_id INT,
    FOREIGN KEY (doctor_appointment_id) REFERENCES doctor_appointments (doctor_appointment_id)
);

-- 
LOAD DATA INFILE 'C:\\_data\\capstone_bandaid_brigade\\prescriptions.csv' INTO
TABLE prescriptions FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (
     prescription_id,
     drug_name,
     dosage,
     start_date,
     end_date,
     doctor_appointment_id
 );

DROP TABLE IF EXISTS appointment_diagnoses;

CREATE TABLE IF NOT EXISTS appointment_diagnoses (
    diagnosis_id INT NOT NULL,
    doctor_appointment_id INT NOT NULL,
    PRIMARY KEY (
        diagnosis_id,
        doctor_appointment_id
    ),
    FOREIGN KEY (diagnosis_id) REFERENCES diagnoses (diagnosis_id),
    FOREIGN KEY (doctor_appointment_id) REFERENCES doctor_appointments (doctor_appointment_id)
);

LOAD DATA INFILE 'C:\\_data\\capstone_bandaid_brigade\\appointment_diagnoses.csv' INTO
TABLE appointment_diagnoses FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (
    diagnosis_id,
    doctor_appointment_id
 );

-- Query Challenges
-- Q1: List all the appointments that “Dr. Langford” attended in the last year.

-- Define tables FROM -  appointment table 
-- connections
-- JOIN - doctor_appointment, doctors, patients 
-- filter WHERE - last_name, appointment_status, date 
-- GROUP BY 
-- HAVING
-- ORDER BY start_date
-- LIMIT - 
-- SELECT

SELECT a.appointment_id, p.`PHIN_id`, p.first_name, p.last_name, a.start_date
FROM appointments a 
JOIN doctor_appointments da ON da.appointment_id = a.appointment_id 
JOIN doctors d ON d.licence_id = da.licence_id 
JOIN patients p ON p.PHIN_id = a.PHIN_id
WHERE d.last_name = 'Langford'
AND a.status = 'Completed'
AND a.start_date BETWEEN '2025-06-21' AND '2026-06-21'
ORDER BY a.start_date;

-- Q2. Count the number of times that the patient “Sofia Q Singh - 102193780” has cancelled an appointment with less than 24 hours notice 
-- (cancelled an appointment less than 24 hours before the appointment was due to occur).
 
-- Define tables FROM - patient table, appointment  table 
-- connections
-- JOIN patients and appointment 
-- filter WHERE x = cancelled 
-- GROUP BY status
-- HAVING
-- ORDER BY desc
-- LIMIT - (24 hrs in minutes is 1440) less than 1440
-- SELECT

SELECT first_name, last_name, cancel_minutes_before, status
FROM patients p
JOIN appointments a ON p.PHIN_id = a.PHIN_id
WHERE p.`PHIN_id` = 102193780
 
SELECT * FROM patients
WHERE `PHIN_id` = 102193780

-- Q3. MINA - Sort the doctors by the 
-- number of prescriptions of the drug “Amoxicillin” they’ve given to patients.
-- doctor TABLE
-- prescription table 
-- patients TABLE
-- where = dug.name = "Amoxicillin"
-- order BY

-- SELECT d.first_name, d.last_name, prescription_id
-- FROM doctors d
-- JOIN doctor_appointments da ON d.licence_id = da.licence_id
-- JOIN prescriptions p ON da.appointment_id = p.doctor_appointment_id
-- WHERE p.drug_name = "Amoxicillin"
-- GROUP BY d.first_name, d.last_name
-- HAVING COUNT(prescription_id)
-- ORDER BY prescription_id DESC

SELECT dr.first_name, dr.last_name, 
    COUNT(p.prescription_id) 
FROM doctors dr
JOIN doctor_appointments da 
    ON da.licence_id = dr.licence_id
JOIN prescriptions p 
    ON p.doctor_appointment_id = da.doctor_appointment_id
WHERE p.drug_name = 'Amoxicillin'
GROUP BY dr.first_name, dr.last_name
Order BY COUNT(p.prescription_id)



--Q4: Find the most expensive appointment.
    -- Thinking Order
        -- Tables: appointments, billing records
        -- JOIN between ^ at appointment_id
        -- ORDER BY DESC to see highest to lowest appointment costs
        -- LIMIT to only see most expensive
SELECT br.total_fee, a.appointment_id
FROM appointments a
JOIN billing_records br
    ON a.appointment_id = br.appointment_id
ORDER BY total_fee DESC
LIMIT 1;

-- Q5: Which appointment type had the highest average duration over the past 6 months?

-- appointment type
-- Average duration
-- filter for past 6 months
-- 2022-11-01 calculating  6 months back from 2023-05-01 ( so in question alex may ask in any time frame )

-- Group by appointment type

-- Define appointment table
-- connections
--  
-- filter WHERE  start_date > 2022-11-01
-- GROUP BY appointment_type
-- average duration
-- ORDER BY desc
-- LIMIT - 10

SELECT appointment_type,
AVG(duration_mins) AS avg_duration
FROM appointments
WHERE start_date > '2022-11-01'
GROUP BY appointment_type
ORDER BY avg_duration DESC;

SELECT a.appointment_type, AVG(a.duration_mins)
FROM appointments a
WHERE a.start_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY a.appointment_type
ORDER BY AVG(a.duration_mins) DESC -- solving highest
LIMIT 1 -- show only one resolve

--Q6: Which day of the week has the highest number of completed appointments in the past 6 months?
    -- Thinking Order
        -- Tables: appointments
        -- WHERE to filter last 6 months and completed appointments
        -- GROUP BY for each weekday to correspond to a total number of appointments
        -- ORDER BY DESC to see the highest to lowest # of appointments
        -- LIMIT to only see the weekday with the highest # of appointment

SELECT 
    DAYNAME(a.start_date) AS weekday, 
    COUNT(*) AS num_of_appointments
FROM appointments a
WHERE 
    start_date > '2025-12-01' 
    AND a.status = "Completed"
GROUP BY weekday
ORDER BY num_of_appointments DESC;

-- Q7. JENN - Which 5 medications are most prescribed for “Type 2 Diabetes Mellitus” diagnoses?

-- Thinking Process
-- Define tables FROM - patient, appointment, diagnosis, appointment_diagnoses, doctor_appointments and prescription
-- JOIN 
    -- d.diagnoses_id ON ad.diagnosis_id
    -- ad.doctor_appointment_id ON da.doctor_appointment_id'
    -- da.doctor_appointment_id ON pr.doctor_appointment_id
    -- da.appointment_id ON a.appointment_id
    -- a.PHIN_id ON pa.PHIN_id
-- filter WHERE 
    -- d.name = X
-- GROUP BY - pr.prescriptions
-- HAVING - count(pr.prescription_id)
-- ORDER BY - DESC
-- LIMIT - 5
-- SELECT - d.name, pr.prescriptions, count AS "num_times_prescribed"

-- TABLE DATA IS MISSING!!!!

SELECT d.name, COUNT(pr.prescription_id) AS total_number_presc
FROM diagnoses d
JOIN appointment_diagnoses ad ON d.diagnosis_id = ad.diagnosis_id
JOIN doctor_appointments da ON ad.doctor_appointment_id = da.doctor_appointment_id
JOIN prescriptions pr ON da.doctor_appointment_id = pr.doctor_appointment_id
JOIN appointments a ON da.appointment_id = a.appointment_id
WHERE d.name = "Type 2 Diabetes Mellitus"
GROUP BY d.name, pr.prescription_id;
-- HAVING count(pr.prescription_id)
-- ORDER BY pr.prescription_id DESC
-- LIMIT 5


-- Q8: Which appointment generated the largest uninsured balance
-- (the highest amount that the patient had to pay after insurance)?

-- Define tables FROM - appointments table, billing_records table, patients table
-- connections
-- JOIN appointments and billing_records
-- JOIN patients
-- filter WHERE -
-- GROUP BY -
-- HAVING -
-- ORDER BY patient_balance DESC
-- LIMIT 1
-- SELECT

SELECT
    a.appointment_id,
    p.PHIN_id,
    p.first_name,
    p.last_name,
    br.total_fee,
    br.insurance_covered,
    br.patient_balance
FROM appointments a
JOIN billing_records br
    ON a.appointment_id = br.appointment_id
JOIN patients p
    ON a.PHIN_id = p.PHIN_id
ORDER BY br.patient_balance DESC
LIMIT 1;

--Q9: For each patient, list their first-ever diagnosis and the doctor that diagnosed it.

-- Define tables FROM -  patient table 
-- connections
-- JOIN - doctor_appointment, doctors, patients, appointments, appointments_diagnoses 
-- filter WHERE -  
-- GROUP BY 
-- HAVING
-- ORDER BY start_date
-- LIMIT - 
-- SELECT

-- Q10: List all the doctors that worked outside their scheduled hours
-- and identify the appointments where it happened.

-- Define tables FROM - doctors table, doctor_schedules table,
-- doctor_appointments table, appointments table
-- connections
-- JOIN doctors and doctor_schedules
-- JOIN doctor_appointments
-- JOIN appointments
-- filter WHERE appointment date is before the doctor's scheduled shift
-- OR appointment date is after the doctor's scheduled shift
-- GROUP BY -
-- HAVING -
-- ORDER BY doctor last name
-- LIMIT -
-- SELECT

SELECT
    d.first_name,
    d.last_name,
    a.appointment_id,
    a.start_date,
    ds.shift_start,
    ds.shift_length_mins
FROM doctors d
JOIN doctor_schedules ds
    ON d.licence_id = ds.licence_id
JOIN doctor_appointments da
    ON d.licence_id = da.licence_id
JOIN appointments a
    ON da.appointment_id = a.appointment_id
WHERE a.start_date < DATE(ds.shift_start)
   OR a.start_date > DATE(ds.shift_start)
ORDER BY d.last_name, d.first_name;