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
CREATE TABLE patient_allergies (
    PHIN_id INT,
    allergy_id INT,
    PRIMARY KEY (PHIN_id, allergy_id),
    FOREIGN KEY (PHIN_id) REFERENCES patients (PHIN_id),
    FOREIGN KEY (allergy_id) REFERENCES allergies (allergy_id)
);

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
-- Query Challenges
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