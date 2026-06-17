DROP DATABASE IF EXISTS rrc_clinic;

CREATE DATABASE IF NOT EXISTS rrc_clinic;

USE rrc_clinic;

-- Doctors table
DROP TABLE IF EXISTS doctors;

CREATE TABLE IF NOT EXISTS doctors(
    licence_id CHAR(19) PRIMARY KEY,
    first_name VARCHAR(30),
    last_name VARCHAR(30),
);
LOAD DATA
INFILE 'C:\\Users\\keren\\Documents\\capstone\\doctors.csv'
INTO TABLE doctors
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 0 LINES
(licence_id, first_name, last_name, medical_specialty_id)

CREATE TABLE IF NOT EXISTS appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    start_date DATE,
    duration_mins SMALLINT,
    status VARCHAR(15),
    appointment_type VARCHAR(50),
    reason VARCHAR(100),
    notice varchar(250),
    PHIN_id INT,
    FOREIGN KEY (PHIN_id) REFERENCES patients(PHIN_id)
);

LOAD DATA
INFILE 'C:\\Users\\keren\\Documents\\capstone\\appointments.csv'
INTO TABLE appointments
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 0 LINES
(appointment_id, start_date,
    duration_mins, status, appointment_type, reason,
    notice, PHIN_id);

CREATE TABLE IF NOT EXISTS doctor_appointments (
    doctor_appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    doctor_licence_id INT, 
    appointment_id INT,
    FOREIGN KEY (doctor_licence_id) REFERENCES doctors(doctor_licence_id),
    FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id)
);

-- Diagnosis table

DROP TABLE IF EXISTS diagnoses;

CREATE TABLE IF NOT EXISTS diagnoses (
    diagnosis_id INT AUTO_INCREMENT PRIMARY KEY,
    diagnosis_code VARCHAR(100) NOT NULL,
    name VARCHAR(255)
);
LOAD DATA
INFILE 'C:\\Users\\keren\\Documents\\capstone\\diagnoses.csv'
INTO TABLE diagnoses
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 0 LINES (
    diagnosis_id INT AUTO_INCREMENT PRIMARY KEY,
    diagnosis_code VARCHAR(100) NOT NULL,
    name VARCHAR(255)
)

-- Prescriptions

DROP TABLE IF EXIST prescription;

CREATE TABLE IF NOT EXIST prescriptions (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    drug_name VARCHAR(100) NOT NULL,
    dosage VARCHAR(50),
    start_date DATE,
    end_date DATE,
    doctor_appointment_id INT NOT NULL,

    FOREIGN KEY (doctor_appointment_id)
        REFERENCES doctor_appointments(doctor_appointment_id)
);
LOAD DATA
INFILE 'C:\\Users\\keren\\Documents\\capstone\\prescriptions.csv'
INTO TABLE prescriptions
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 0 LINES (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    drug_name VARCHAR(100) NOT NULL,
    dosage VARCHAR(50),
    start_date DATE,
    end_date DATE,
    doctor_appointment_id INT NOT NULL,
)

-- BRIDGE TABLE: Appointment_diagnoses

DROP TABLE IF EXISTS appointment_diagnoses; 

CREATE TABLE IF NOT EXISTS appointment_diagnoses (
    diagnosis_id INT NOT NULL,
    doctor_appointment_id INT NOT NULL,

        PRIMARY KEY (diagnosis_id, doctor_appointment_id),

        FOREIGN KEY (diagnosis_id) REFERENCES diagnoses(diagnosis_id),

        FOREIGN KEY (doctor_appointment_id) REFERENCES doctor_appointments(doctor_appointment_id)
);

-- Medical specialties table
DROP TABLE IF EXISTS medical_specialties;

CREATE TABLE IF NOT EXISTS medical_specialties(
    medical_specialty_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100)
    responsibilities TINYTEXT
);
LOAD DATA
INFILE 'C:\\Users\\keren\\Documents\\capstone\\medical_specialties.csv'
INTO TABLE medical_specialties
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 0 LINES (
    medical_specialty_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100)
    responsibilities TINYTEXT
)

-- Doctor Schedules
DROP TABLE IF EXISTS doctor_schedules;

CREATE TABLE IF NOT EXISTS doctor_schedules(
    schedule_id INT AUTO_INCREMENT PRIMARY KEY,
    licence_id INT AUTO_INCREMENT REFERENCES
        doctors(licence_id INT AUTO_INCREMENT),
    shift_start DATETIME,
    shift_length_mins SMALLINT
);

-- Fee Schedule
DROP TABLE IF EXISTS fee_schedules;

CREATE TABLE IF NOT EXISTS fee_schedules (
    fee_schedule_id INT AUTO_INCREMENT PRIMARY KEY,
    duration UNSIGNED INT,
    consultation_cost DECIMAL(10, 2)
);
LOAD DATA
INFILE 'C:\\Users\\keren\\Documents\\capstone\\fee_schedules.csv'
INTO TABLE fee_schedules
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 0 LINES (
    fee_schedule_id INT AUTO_INCREMENT PRIMARY KEY,
    duration UNSIGNED INT,
    consultation_cost DECIMAL(10, 2)
)

INSERT INTO fee_schedules
VALUES 



-- Insurance Provider
DROP TABLE IF EXISTS insurance_providers;

CREATE TABLE IF NOT EXISTS insurance_providers (
    insurance_provider_id INT AUTO_INCREMENT PRIMARY KEY,
    company_name VARCHAR(100),
    address VARCHAR(100),
    email_address VARCHAR(50),
    phone_number VARCHAR(20)
);

LOAD DATA
INFILE 'C:\\Users\\keren\\Documents\\capstone\\insurance_providers.csv'
INTO TABLE insurance_providers
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 0 LINES
(    insurance_provider_id INT AUTO_INCREMENT PRIMARY KEY,
    company_name VARCHAR(100),
    address VARCHAR(100),
    email_address VARCHAR(50),
    phone_number VARCHAR(20))

INSERT INTO insurance_providers 
VALUES


DROP TABLE IF EXISTS billing_records ;

CREATE TABLE IF NOT EXISTS billing_records (
    billing_records_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT UNIQUE,
    insurance_provider_id INT,
    total_fee DECIMAL(10, 2)  NOT NULL,
    insurance_covered DECIMAL(10, 2) NOT NULL,
    patient_balance DECIMAL(10, 2)  NOT NULL,
    payment_status VARCHAR(20) NOT NULL,
    notes SMALL TEXT,
    payment_type VARCHAR(4),
    
    Foreign Key (insurance_provider_id) 
        REFERENCES insurance_providers(insurance_provider_id)

    Foreign Key (appointment_id) 
        REFERENCES appointments(appointment_id)
    
);
LOAD DATA
INFILE 'C:\\Users\\keren\\Documents\\capstone\\billing_records.csv'
INTO TABLE billing_records
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 0 LINES

(billing_records_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT UNIQUE,
    insurance_provider_id INT,
    total_fee DECIMAL(10, 2)  NOT NULL,
    insurance_covered DECIMAL(10, 2) NOT NULL,
    patient_balance DECIMAL(10, 2)  NOT NULL,
    payment_status VARCHAR(20) NOT NULL,
    notes SMALL TEXT,
    payment_type VARCHAR(4),);

INSERT INTO billing_records
values

-- Bridge table: fee_schedule_billing_records
DROP TABLE IF EXISTS  fee_schedule_billing_records;

CREATE TABLE IF NOT EXISTS fee_schedule_billing_records(
    billing_record_id INT,
    fee_schedule_id INT,

    PRIMARY KEY (billing_record_id, fee_schedule_id)

    Foreign Key (billing_record_id) 
        REFERENCES billing_records(billing_record_id)

    Foreign Key (fee_schedule_id) 
        REFERENCES fee_schedules(fee_schedule_id)
);

INSERT INTO fee_schedule_billing_records
VALUES

-- Allergy

LOAD DATA
INFILE 'C:\\Users\\keren\\Documents\\capstone\\allergies.csv'
INTO TABLE billing_records
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 0 LINES


-- Create Patients Table

CREATE TABLE patients (

    
    PHIN_id INT PRIMARY KEY,
    first_name VARCHAR(10),
    last_name VARCHAR(10),
    address VARCHAR(30),
    phone_number VARCHAR(10),
    email_number VARCHAR(30)

);

LOAD DATA
INFILE 'C:\\Users\\YourName\\Documents\\capstone\\patients_data.csv'
INTO TABLE patients
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(PHIN_id, first_name, last_name, address, phone_number, email_address);


-- Create Allergies Table

CREATE TABLE allergies (

  
    allergy_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255)

);

LOAD DATA
INFILE 'C:\\Users\\YourName\\Documents\\capstone\\allergies.csv'
INTO TABLE allergies
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(allergy_id, name);


-- Create Patient_Allergies Table
-- This connects patients and allergies

CREATE TABLE patient_allergies (

    PHIN_id INT,
    allergy_id INT,
    PRIMARY KEY (PHIN_id, allergy_id),

    FOREIGN KEY (PHIN_id)
        REFERENCES patients(PHIN_id),

    FOREIGN KEY (allergy_id)
        REFERENCES allergies(allergy_id)

);


-- Patient Allergies Bridge Table


DROP TABLE IF EXISTS patient_allergies;

CREATE TABLE IF NOT EXISTS patient_allergies (

    PHIN_id INT,
    allergy_id INT,

    PRIMARY KEY (PHIN_id, allergy_id),

    FOREIGN KEY (PHIN_id)
        REFERENCES patients(PHIN_id),

    FOREIGN KEY (allergy_id)
        REFERENCES allergies(allergy_id)

);