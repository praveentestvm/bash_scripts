CREATE TABLE IF NOT EXISTS departments(
department_id SERIAL PRIMARY KEY,
department_name VARCHAR(50) NOT NULL UNIQUE,
description VARCHAR(300) NOT NULL,
floor VARCHAR(20) NOT NULL,
phone VARCHAR(20) NOT NULL UNIQUE
);
CREATE TABLE IF NOT EXISTS doctors(
doctor_id SERIAL PRIMARY KEY,
first_name VARCHAR(50) NOT NULL,
last_name VARCHAR(50) NOT NULL,
email VARCHAR(100) UNIQUE NOT NULL,
phone VARCHAR(20) UNIQUE NOT NULL,
department_id INTEGER REFERENCES departments(department_id) NOT NULL,
specialization VARCHAR(100) NOT NULL,
experienced_years INTEGER NOT NULL,
joined_on DATE DEFAULT CURRENT_DATE,
status VARCHAR(20) NOT NULL DEFAULT 'active'
);
CREATE TABLE IF NOT EXISTS patients(
patient_id SERIAL PRIMARY KEY,
first_name VARCHAR(50) NOT NULL,
last_name VARCHAR(50) NOT NULL,
gender VARCHAR(15) NOT NULL,
date_of_birth DATE NOT NULL,
phone VARCHAR(20) UNIQUE NOT NULL,
email VARCHAR(100) UNIQUE NOT NULL,
blood_group VARCHAR(5) NOT NULL,
address VARCHAR(255) NOT NULL,
registered_on DATE DEFAULT CURRENT_DATE
CHECK ( gender IN ('Male','Female','Other'))
CHECK ( blood_group IN ( 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'))
);
CREATE TABLE IF NOT EXISTS appointments(
appointment_id SERIAL PRIMARY KEY,
patient_id INTEGER REFERENCES patients(patient_id) NOT NULL,
doctor_id INTEGER REFERENCES doctors(doctor_id) NOT NULL,
appointment_date DATE DEFAULT CURRENT_DATE NOT NULL,
appointment_time TIME DEFAULT CURRENT_TIME NOT NULL,
reason VARCHAR(255) NOT NULL,
status VARCHAR(30) DEFAULT 'scheduled' NOT NULL
CHECK (status IN ('scheduled','completed','cancelled'))
);
CREATE TABLE IF NOT EXISTS wards(
ward_id SERIAL PRIMARY KEY,
ward_name VARCHAR(50) NOT NULL UNIQUE,
floor VARCHAR(15) NOT NULL,
capacity INTEGER NOT NULL
);
CREATE TABLE IF NOT EXISTS admissions(
admission_id SERIAL PRIMARY KEY,
patient_id INTEGER REFERENCES patients(patient_id) NOT NULL,
ward_id INTEGER REFERENCES wards(ward_id) NOT NULL,
doctor_id INTEGER REFERENCES doctors(doctor_id) NOT NULL,
admitted_on DATE DEFAULT CURRENT_DATE NOT NULL,
discharged_on DATE,
bed_no INTEGER NOT NULL,
status VARCHAR(20) DEFAULT 'admitted' NOT NULL
);
CREATE TABLE IF NOT EXISTS medicines(
medicine_id SERIAL PRIMARY KEY,
medicine_name VARCHAR(100) NOT NULL,
manufacturer VARCHAR(150) NOT NULL,
price NUMERIC(10,2) NOT NULL,
stock INTEGER NOT NULL,
expiry_date DATE NOT NULL
);
CREATE TABLE IF NOT EXISTS prescriptions(
prescription_id SERIAL PRIMARY KEY,
appointment_id INTEGER REFERENCES appointments(appointment_id) NOT NULL,
doctor_id INTEGER REFERENCES doctors(doctor_id) NOT NULL,
patient_id INTEGER REFERENCES patients(patient_id) NOT NULL,
created_on DATE DEFAULT CURRENT_DATE NOT NULL,
notes VARCHAR(255) NOT NULL
);
CREATE TABLE IF NOT EXISTS prescription_items(
prescription_item_id SERIAL PRIMARY KEY,
prescription_id INTEGER REFERENCES prescriptions(prescription_id) NOT NULL,
medicine_id INTEGER REFERENCES medicines(medicine_id) NOT NULL,
dosage VARCHAR(20) NOT NULL,
frequency VARCHAR(50) NOT NULL,
duration_days INTEGER NOT NULL
);
CREATE TABLE IF NOT EXISTS bills(
bill_id SERIAL PRIMARY KEY,
patient_id INTEGER REFERENCES patients(patient_id) NOT NULL,
admission_id INTEGER REFERENCES admissions(admission_id) NOT NULL,
amount NUMERIC(10,2) NOT NULL,
payment_method VARCHAR(50) DEFAULT 'cash' NOT NULL,
paid_on DATE DEFAULT CURRENT_DATE NOT NULL,
status VARCHAR(50) DEFAULT 'paid' NOT NULL
);
INSERT INTO departments (department_id, department_name, description, floor, phone)
VALUES (1, 'Casuality', 'It deals with patients who is in emergency situation', '1st', '080 495 6985'),
(2, 'Anaesthetics', 'Doctors in these administer anaesthesia to patients befor varies surgeries', '1st', '080 495 6986'),
(3, 'Cardiology', 'This deals with problems of the human heart or circulation', '2nd', '080 495 6987'),
(4, 'General Surgery', 'This dept treats variety of surgical procedures', '3rd', '080 495 6988'),
(5, 'Gynaecology', 'It treats the problem in female urinary tract', '4th', '080 495 6989'),
(6, 'Neurology', 'This dept concerns with human nevous system', '1st', '080 495 6990'),
(7, 'Psychiatry', 'This dept includes investments and treatment of mental ill patients', '3rd', '080 495 6991'),
(8, 'Urology', 'It is surgical dept', '3rd', '080 495 6992');
INSERT INTO doctors (doctor_id, first_name, last_name, email, phone, department_id, specialization, experienced_years)
VALUES (1, 'Praveen', 'Bokula', 'praveen.b@test.hospitals.org', '080 495 6992', '3', 'Cardiology', '10'),
(2, 'Praveen', 'Dudam', 'praveen.d@test.hospitals.org', '080 495 6993', '3', 'General Surgery', '5'),
(3, 'Naveen', 'Kumar', 'naveen.b@test.hospitals.org', '080 495 6994', '4', 'Neurolgy', '2'),
(4, 'Ganesh', 'Bokula', 'ganesh.b@test.hospitals.org', '080 495 6995', '7', 'Gynaecology', '1'),
(5, 'Ganesh', 'Buddamali', 'ganeshb.b@test.hospitals.org', '080 495 6996', '8', 'Psychiatry', '2'),
(6, 'Bhanu', 'Reddy', 'bhanu.reddy@test.hospitals.org', '080 495 6997', '1', 'Urology', '4'),
(7, 'Shiva', 'B', 'shiva.b@test.hospitals.org', '080 495 6998', '2', 'Anaesthetic', '3'),
(8, 'Karthick', 'Doddi', 'karthick.d@test.hospitals.org', '080 495 6999', '4', 'Psychiatry', '3'),
(9, 'Karunakar', 'Bingi', 'karunakar.b@test.hospitals.org', '080 495 7000', '6', 'Urology', '2'),
(10, 'Vamshi', 'Murga', 'vamshi.m@test.hospitals.org', '080 495 7001', '4', 'Cardiology', '7');
INSERT INTO patients (patient_id, first_name, last_name, gender, date_of_birth, phone, email, blood_group, address)
VALUES (1, 'Revanth', 'Reddy', 'Male', '1987-05-10', '9857486213', 'revanthreddy@gmail.com', 'A+', 'Hyderabad'),
(2, 'Balvanth', 'Reddy', 'Male', '1985-10-11', '9741236489', 'balvanthreddy@gmail.com', 'A-', 'Secunderabad'),
(3, 'Kumar', 'Bandha', 'Male', '1975-12-23', '9789458952', 'kumarbandha@gmail.com', 'AB+', 'Malkajgiri'),
(4, 'Shamantha', 'Bokula', 'Female', '1982-02-28', '9784567897', 'shamanthabokula@gmail.com', 'O+', 'L B Nagar'),
(5, 'Anusha', 'Reddy', 'Female', '2002-10-15', '9712478975', 'anusha@gmail.com', 'O-', 'Vanasthalipuram'),
(6, 'Pooja', 'Mallela', 'Female', '2000-08-05', '9707894871', 'poojamallela@gmail.com', 'B+', 'B N Reddy'),
(7, 'Srisailam', 'Goud', 'Male', '1995-01-30', '9787843216', 'srisailamgoud@gmail.com', 'AB-', 'Shadnagar'),
(8, 'Prashanth', 'Sheelam', 'Male', '1999-02-15', '9874781236', 'sheelamprashanth@gmail.com', 'B-', 'Kukatpally'),
(9, 'Kamlesh', 'Patel', 'Male', '1979-09-28', '7845971236', 'kamleshpatel@gmail.com', 'O+', 'Narsingi'),
(10, 'Santosh', 'Khanjee', 'Male', '1984-07-24', '8712459785', 'santosh@gmail.com', 'O-', 'Midani');
INSERT INTO appointments (appointment_id, patient_id, doctor_id, reason, status)
VALUES (1, '1', '3', 'Heart Problem', 'scheduled'),
(2, '3', '7', 'For opertion', 'completed'),
(3, '2', '10', 'Mental illness', 'scheduled'),
(4, '5', '5', 'Personal problem', 'cancelled'),
(5, '9', '3', 'For leg surgery', 'completed'),
(6, '6', '8', 'Personal problem', 'scheduled'),
(7, '4', '8', 'Persoanl Problem', 'cancelled');
INSERT INTO wards (ward_id, ward_name, floor, capacity)
VALUES (1, 'general', '1st', '100'),
(2, 'out patients', '1st', '100'),
(3, 'ICU', '2nd', '30'),
(4, 'in patients', '2nd', '50'),
(5, 'Operation theatre', '3rd', '20');
INSERT INTO admissions (admission_id, patient_id, ward_id, doctor_id, bed_no, status)
VALUES (1, '2', '3', '1', '10', 'admitted'),
(2, '4', '4', '9', '20', 'admitted'),
(3, '3', '2', '8', '30', 'admitted'),
(4, '9', '5', '5', '25', 'discharged'),
(5, '10', '5', '3', '35', 'admitted');
INSERT INTO medicines (medicine_id, medicine_name, manufacturer, price, stock, expiry_date)
VALUES (1, 'Paractomol', 'Sun Pharma pvt ltd', '100.00', '10000', '2027-03-31'),
(2, 'Acrivastine', 'Sun Pharma pvt ltd', '10000.00', '500', '2030-12-31'),
(3, 'Adalimumab', 'Suven', '100', '50000', '2026-08-10'),
(4, 'Allopurinol', 'Oman', '500', '10500', '2026-10-30'),
(5, 'Alogliptin.', 'Reddy labs', '100000', '15', '2029-01-01');
INSERT INTO prescriptions (prescription_id, appointment_id, doctor_id, patient_id, notes)
VALUES (1, '3', '8', '7', 'Daily three times'),
(2, '7', '4', '9', 'Daily Morning'),
(3, '2', '3', '4', 'Daily night'),
(4, '4', '6', '5', 'Daily afternoon');
INSERT INTO prescription_items (prescription_item_id, prescription_id, medicine_id, dosage, frequency, duration_days)
VALUES (1, '2', '2', '10mg', 'daily', '5'),
(2, '4', '3', '100mg', 'daily', '10'),
(3, '3', '5', '50mg', 'weekly', '1');
INSERT INTO bills (bill_id, patient_id, admission_id, amount, payment_method, status)
VALUES (1, '10', '2', '1000000', 'cash', 'paid'),
(2, '7', '3', '1500000', 'card', 'paid');
