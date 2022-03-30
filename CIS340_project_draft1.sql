CREATE DATABASE IF NOT EXISTS WellmeadowsHospital;
USE WellmeadowsHospital;

CREATE TABLE IF NOT EXISTS wards (
	ward_id	INT,
	ward_name	VARCHAR(30) NOT NULL,
	ward_location	VARCHAR(30) NOT NULL,
	charge_nurse_id	VARCHAR(9) NOT NULL,
	ward_bed_tally	INT,
	ward_phone_extn	VARCHAR(4)NOT NULL,
	PRIMARY KEY	(ward_id),
	CONSTRAINT NumBed_Ck CHECK (SUM(ward_bed_tally) <= 240),
		/*checks to make sure the SUM of bed counts across all wards doesn't exceed hospital max of 240*/
	CONSTRAINT WardId_Ck CHECK (ward_id <= 17),
		/*checks to make sure ward number is less than or equal to 17, the total ammount of wards at
		wellmeadows hospital*/
	CONSTRAINT NumWard_Ck CHECK (COUNT(ward_id) <= 17)
		/*checks to make sure the COUNT of wards doesn't exceed 17. After all a ward could be quarantined 
		or under contruction and there would be less than 17, but never more*/
	/*Foreign Key is added after STAFF because WARDS references STAFF which comes after.*/
);
    
CREATE TABLE IF NOT EXISTS staff (
	staff_id	VARCHAR(9),
	staff_first_name	VARCHAR(30) NOT NULL,
	staff_last_name	VARCHAR(30) NOT NULL,
	staff_addr	VARCHAR(255) NOT NULL,
	staff_phone_number	VARCHAR(15) NOT NULL,
	staff_dob	DATE NOT NULL,
	staff_sex	VARCHAR(1) NOT NULL,
	staff_NIN	VARCHAR(9) NOT NULL,
	staff_position	VARCHAR(30) NOT NULL, 
	ward_id	INT NOT NULL,
	current_salary	DECIMAL(15,2) NOT NULL,
	salary_scale	VARCHAR(30) NOT NULL,
	hours_worked_weekly	DECIMAL(5,2) NOT NULL,
	weekly_or_monthly	CHAR(1) NOT NULL,
	temporary_or_permanent	CHAR(1) NOT NULL,
	staff_shift_type	VARCHAR(5) NOT NULL,
	PRIMARY KEY (staff_id),
	FOREIGN KEY (ward_id) REFERENCES wards(ward_id)
);

ALTER TABLE wards
ADD FOREIGN KEY (charge_nurse_id) REFERENCES staff(staff_id);

CREATE TABLE IF NOT EXISTS qualifications (
	staff_id VARCHAR(9),
    qualifiaction_num INT,
	qualification_type	VARCHAR(30) NOT NULL,
	qualification_date	DATE NOT NULL,
	qualification_institution	VARCHAR(30) NOT NULL,
	PRIMARY KEY (staff_id, qualification_num),
	FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
);

CREATE TABLE IF NOT EXISTS experience (
	staff_id VARCHAR(9),
    experience_num INT,
	experience_position	VARCHAR(30) NOT NULL,
	experience_start_date	DATE NOT NULL,
	experience_end_date	DATE,
	experience_organization	VARCHAR(30) NOT NULL,
	PRIMARY KEY (staff_id, experience_num),
	FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
);

CREATE TABLE IF NOT EXISTS local_doctors(
	clinic_phone_number	VARCHAR(15),
	local_doctor_first_name	VARCHAR(30) NOT NULL,
	local_doctor_last_name	VARCHAR(30) NOT NULL,
	clinic_addr	VARCHAR(255) NOT NULL,
    clinic_id	VARCHAR(9),
	PRIMARY KEY (clinic_phone_number)
);

CREATE TABLE IF NOT EXISTS next_of_kin (
	nok_phone_number	VARCHAR(15),
	nok_first_name	VARCHAR(30) NOT NULL,
	nok_last_name	VARCHAR(30) NOT NULL,
	nok_addr	VARCHAR(255) NOT NULL,
	nok_relationship_to_patient	VARCHAR(30) NOT NULL,
	PRIMARY KEY (nok_phone_number)
);

CREATE TABLE IF NOT EXISTS patients (
	patient_id	VARCHAR(9),
	patient_first_name	VARCHAR(30) NOT NULL,
	patient_last_name	VARCHAR(30) NOT NULL,
	patient_addr	VARCHAR(255) NOT NULL,
	patient_phone_number	VARCHAR(15) NOT NULL,
	patient_dob	DATE NOT NULL,
	patient_sex	VARCHAR(1) NOT NULL,
	patient_marital_status	VARCHAR(30) NOT NULL,
	patient_registry_date	DATE NOT NULL,
	nok_phone_number		VARCHAR(15) NOT NULL,
	clinic_phone_number 	VARCHAR(15) NOT NULL,
	PRIMARY KEY (patient_id),
    FOREIGN KEY (clinic_phone_number) REFERENCES local_doctors(clinic_phone_number),
    FOREIGN KEY (nok_phone_number) REFERENCES next_of_kin(nok_phone_number)
);

CREATE TABLE IF NOT EXISTS patient_appointments (
	appt_id	VARCHAR(9),
	patient_id	VARCHAR(9) NOT NULL,
	staff_id	VARCHAR(9) NOT NULL,
	exam_appt_date	DATE NOT NULL,
	exam_appt_time	TIME NOT NULL,
	appt_exam_room	VARCHAR(5) NOT NULL,
	PRIMARY KEY (appt_id),
	FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
	FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
);

CREATE TABLE IF NOT EXISTS outpatients (
	patient_id	VARCHAR(9),
	outpatient_appt_date	DATE NOT NULL,
	outpatient_appt_time	TIME NOT NULL,
	PRIMARY KEY (patient_id),
	FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
);

CREATE TABLE IF NOT EXISTS inpatients (
	patient_id	VARCHAR(9),
	ward_id	INT NOT NULL,
	bed_id INT UNIQUE,
	inpatient_waitlisted_date	DATE NOT NULL,
	inpatient_checkin_date	DATE,
	exp_stay_duration	INT NOT NULL,
	exp_checkout_date	DATE,
	actual_checkout_date	DATE,
	PRIMARY KEY(patient_id),
	FOREIGN KEY(patient_id) REFERENCES patients(patient_id),
	FOREIGN KEY(ward_id) REFERENCES wards(ward_id),
	CONSTRAINT BedExists_Ck CHECK (bed_id <= 240 AND bed_id > 0)
);

CREATE TABLE IF NOT EXISTS suppliers (
	supplier_id	VARCHAR(9) NOT NULL UNIQUE,
	supplier_name	VARCHAR(30) NOT NULL,
	supplier_addr	VARCHAR(255) NOT NULL,
	supplier_phone_number	VARCHAR(15) NOT NULL,
	supplier_fax_line_1	VARCHAR(15) NOT NULL,
	supplier_fax_line_2	VARCHAR(15),
	PRIMARY KEY (supplier_id)
);

CREATE TABLE IF NOT EXISTS surgical_and_nonsurgical_supplies (
	item_id	VARCHAR(9),
	item_name	VARCHAR(30) NOT NULL,
	item_description	VARCHAR(255) NOT NULL,
	item_quantity_in_stock	INT NOT NULL,
	item_reorder_level	INT NOT NULL,
	item_cost_per_unit	DECIMAL(15,2) NOT NULL,
	supplier_id	VARCHAR(9) NOT NULL,
	PRIMARY KEY(item_id),
	FOREIGN KEY(supplier_id) REFERENCES suppliers(supplier_id)
);

CREATE TABLE IF NOT EXISTS pharmaceutical_supplies (
	drug_id VARCHAR(9),
	drug_name VARCHAR(30) NOT NULL,
	drug_description VARCHAR(255) NOT NULL,
	dosage	VARCHAR(30) NOT NULL,
	drug_administration_method	VARCHAR(30) NOT NULL,
	drug_quantity_in_stock	INT NOT NULL,
	drug_reorder_level	INT NOT NULL,
	drug_cost_per_unit	DECIMAL(15,2) NOT NULL,
	supplier_id	VARCHAR(9) NOT NULL,
	PRIMARY KEY(drug_id),
	FOREIGN KEY(supplier_id) REFERENCES suppliers(supplier_id)
);

CREATE TABLE IF NOT EXISTS patient_medication (
	patient_id	VARCHAR(9),
	drug_id	VARCHAR(9) NOT NULL,
	total_doses_distributed_tally	INT NOT NULL,
	medication_start_date	DATE NOT NULL,
	medication_end_date	DATE,
	PRIMARY KEY(patient_id),
	FOREIGN KEY(patient_id) REFERENCES patients(patient_id),
	FOREIGN KEY(drug_id) REFERENCES pharmaceutical_supplies(drug_id)
);

CREATE TABLE IF NOT EXISTS ward_requisitions (
	requisition_id VARCHAR(9),
	ward_id INT NOT NULL,
	requisitioner VARCHAR(9) NOT NULL,
	requisition_date DATE NOT NULL,
	item_id VARCHAR(9),
	drug_id VARCHAR(9),
	item_quanitity INT NOT NULL DEFAULT 0,
	drug_quanitity INT NOT NULL DEFAULT 0,
	rec_charge_nurse VARCHAR(9),
	received_on_date DATE,
	PRIMARY KEY (requisition_id),
	FOREIGN KEY (ward_id) REFERENCES wards(ward_id),
	FOREIGN KEY (requisitioner) REFERENCES staff(staff_id),
	FOREIGN KEY (drug_id) REFERENCES pharmaceutical_supplies(drug_id),
	FOREIGN KEY (item_id) REFERENCES surgical_and_nonsurgical_supplies(item_id),
	FOREIGN KEY (rec_charge_nurse) REFERENCES staff(staff_id),
	CONSTRAINT RecievedOrNot_Ck CHECK ( (rec_charge_nurse=null AND received_on_date=null) OR (rec_charge_nurse!=null AND received_on_date!=null))
		/*The above constraint makes sure that ward requisitions are filled out properly
		It checks to make sure that either BOTH the charge nurse that received the requisition 
		AND a recieval date are present OR neither are present. The check doesn't allow for a
		signature without a date and vice versa*/
);
	
