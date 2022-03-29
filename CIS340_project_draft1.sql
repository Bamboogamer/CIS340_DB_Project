CREATE DATABASE IF NOT EXISTS WellmeadowsHospital;
USE WellmeadowsHospital;

#All phone numbers are varchar(15) to allow for special characters and the maximum length for a national phone number
#All forms of IDs OR numbers in reference to things like staff_id are in VARCHAR(9) form, the length references the length
#	of Employee Identification Numbers and the VARCHAR type allows for letters as do EINs
#All addresses are of the VARCHAR(255) type which is what most webites establish as maximum for address length

CREATE TABLE IF NOT EXISTS wards (
	ward_id INT NOT NULL UNIQUE, 			#the ward_id, unlike other IDs in this database IS a number because it's value can only range from 1-17
    ward_name VARCHAR(30)	NOT NULL,
    ward_location VARCHAR(30)	NOT NULL,
    ward_charge_nurse_id VARCHAR(9) NOT NULL,
	ward_bed_tally	INT 	NOT NULL,
    ward_phone_extn VARCHAR(4)	NOT NULL,
    PRIMARY KEY	(ward_id),
    FOREIGN KEY (ward_charge_nurse_id) REFERENCES staff(staff_id),
    CONSTRAINT NumBed_Ck CHECK (SUM(ward_bed_tally <= 240)),			#checks to make sure total number of beds across all wards doesn't exceed 240
    CONSTRAINT NumWard_Ck CHECK (COUNT(ward_id <= 17))			#checks to make sure there isn't more than 17 wards
	);
    
CREATE TABLE IF NOT EXISTS staff (
	staff_id VARCHAR(9) NOT NULL UNIQUE,
    staff_first_name VARCHAR(30) NOT NULL,
    staff_last_name VARCHAR(30) NOT NULL,
    staff_addr VARCHAR(255) NOT NULL,
    staff_phone_number VARCHAR(15) NOT NULL,
    staff_dob	DATE NOT NULL,
    staff_sex	VARCHAR(1) NOT NULL,
    staff_NIN	VARCHAR(9) NOT NULL,
    staff_position	VARCHAR(30) NOT NULL, 
    staff_assigned_ward	VARCHAR(9) NOT NULL,
    staff_current_salary	DECIMAL(15,2) NOT NULL,
    staff_salary_scale	VARCHAR(30) NOT NULL,
    staff_hours_worked_weekly	DECIMAL(5,2) NOT NULL,
    staff_paid_weekly_or_monthly	CHAR(1) NOT NULL,
    staff_temporary_or_permanent	CHAR(1) NOT NULL,
    staff_shift_type	VARCHAR(5) NOT NULL,
    PRIMARY KEY (staff_id),
    FOREIGN KEY (staff_assigned_ward) REFERENCES wards(ward_id)
);

CREATE TABLE IF NOT EXISTS qualifications (
	qualification_of_staff_id VARCHAR(9) NOT NULL,
    qualification_type	VARCHAR(30) NOT NULL,
    qualification_date	DATE NOT NULL,
	qualification_institution	VARCHAR(30) NOT NULL,
    PRIMARY KEY (qualification_of_staff_id),
    FOREIGN KEY (qualification_of_staff_id) REFERENCES staff(staff_id)
);

CREATE TABLE IF NOT EXISTS work_experience (
	work_experience_of_staff_id VARCHAR(9) NOT NULL,
    work_experience_position	VARCHAR(30) NOT NULL,
    work_experience_start_date	DATE NOT NULL,
    work_experience_end_date	DATE,
	work_experience_organization	VARCHAR(30) NOT NULL,
    PRIMARY KEY (work_experience_of_staff_id),
    FOREIGN KEY (work_experience_of_staff_id) REFERENCES staff(staff_id)
);

CREATE TABLE IF NOT EXISTS patients (
	patient_id	VARCHAR(9) UNIQUE NOT NULL,
    patient_first_name	VARCHAR(30) NOT NULL,
    patient_last_name	VARCHAR(30) NOT NULL,
    patient_addr	VARCHAR(255) NOT NULL,
    patient_phone_number	VARCHAR(15) NOT NULL,
    patient_dob	DATE NOT NULL,
    patient_sex	VARCHAR(1) NOT NULL,
    patient_marital_status	VARCHAR(30) NOT NULL,
    patient_hospital_registry_date	DATE NOT NULL,
    patient_nok_phone_number	VARCHAR(15) NOT NULL,
	PRIMARY KEY (patient_id),
    FOREIGN KEY (patient_nok_phone_number) REFERENCES patients_next_of_kin(nok_phone_number)
);

CREATE TABLE IF NOT EXISTS patients_next_of_kin (
	nok_phone_number	VARCHAR(15) NOT NULL,
	nok_first_name	VARCHAR(30) NOT NULL,
	nok_last_name	VARCHAR(30) NOT NULL,
	nok_relationship_to_patient	VARCHAR(30) NOT NULL,
	nok_addr	VARCHAR(255) NOT NULL,
	nok_associated_patient_id	varchar(9) NOT NULL,		# do we need this? if linked by phone number
	PRIMARY KEY (nok_phone_number),
	FOREIGN KEY	(nok_associated_patient_id) REFERENCES patients(patient_id)
);

CREATE TABLE IF NOT EXISTS local_doctors (
	clinic_id	VARCHAR(9)	UNIQUE, 	#can have letters
    local_doctor_first_name	VARCHAR(30) NOT NULL,
    local_doctor_last_name	VARCHAR(30) NOT NULL,
    clinic_addr	VARCHAR(255) NOT NULL,
    clinic_phone_number	VARCHAR(15) NOT NULL,
    PRIMARY KEY (clinic_id)
);

CREATE TABLE IF NOT EXISTS patient_appointments (
	appt_id	VARCHAR(9) NOT NULL UNIQUE,
    appt_patient_id	VARCHAR(9) NOT NULL,
    appt_staff_id	VARCHAR(9) NOT NULL,
    appt_date	DATE NOT NULL,
    appt_time	TIME NOT NULL,
    appt_exam_room	VARCHAR(5) NOT NULL,
    PRIMARY KEY (appt_id),
    FOREIGN KEY (appt_patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (appt_staff_id) REFERENCES staff(staff_id)
);

CREATE TABLE IF NOT EXISTS outpatients (
	outpatient_id	VARCHAR(9) NOT NULL,
    outpatient_appt_date	DATE NOT NULL,
    outpatient_appt_time	TIME NOT NULL,
    PRIMARY KEY (outpatient_id),
    FOREIGN KEY (outpatient_id) REFERENCES patients(patient_id)
);

CREATE TABLE IF NOT EXISTS inpatients (
	inpatient_id	VARCHAR(9) NOT NULL,
    inpatient_required_ward_id	INT NOT NULL,
    inpatient_waitlisted_date	DATE NOT NULL,
    inpatient_checkin_date	DATE,
	inpatient_exp_stay_duration	INT NOT NULL,
    inpatient_bed_id INT UNIQUE,
    inpatient_exp_checkout_date	DATE NOT NULL,
    inpatient_checkout_date	DATE,
    PRIMARY KEY(inpatient_id),
    FOREIGN KEY(inpatient_id) REFERENCES patients(patient_id),
    FOREIGN KEY(inpatient_required_ward_id) REFERENCES wards(ward_id),
    CONSTRAINT BedExists_Ck CHECK (inpatient_bed_id <= 240)		#makes sure bed id doesn't exceed the 240 max
);

CREATE TABLE IF NOT EXISTS patient_medication (
	medicated_patient_id	VARCHAR(9) NOT NULL,
    prescribed_drug_id	VARCHAR(9) NOT NULL,
    total_drug_distributed_tally	INT NOT NULL,
    medication_start_date	DATE NOT NULL,
    medication_end_date	DATE,
    PRIMARY KEY(medicated_patient_id),
    FOREIGN KEY(medicated_patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY(prescribed_drug_id) REFERENCES pharmeceutical_supplies(drug_id)
);

CREATE TABLE IF NOT EXISTS surgical_and_nonsurgical_supplies (
	item_id	VARCHAR(9) NOT NULL UNIQUE,
    item_name	VARCHAR(30) NOT NULL,
    item_description	VARCHAR(255) NOT NULL,
    item_quantity_in_stock	INT NOT NULL,
    item_reorder_level	INT NOT NULL,
    item_cost_per_unit	DECIMAL(15,2) NOT NULL,
    PRIMARY KEY(item_id)
);

CREATE TABLE IF NOT EXISTS pharmaceutical_supplies (
	drug_id VARCHAR(9) NOT NULL UNIQUE,
    drug_name VARCHAR(30) NOT NULL,
    drug_description VARCHAR(255) NOT NULL,
    drug_dosage	VARCHAR(30) NOT NULL,
    drug_administration_method	VARCHAR(30) NOT NULL,
    drug_quantity_in_stock	INT NOT NULL,
    drug_reorder_level	INT NOT NULL,
    drug_cost_per_unit	DECIMAL(15,2) NOT NULL,
    PRIMARY KEY(drug_id)
);

CREATE TABLE IF NOT EXISTS ward_requisitions (
	requisition_id VARCHAR(9) NOT NULL UNIQUE,
    requisitioned_ward_id VARCHAR(9) NOT NULL,
    requisitioned_by_staff_id VARCHAR(9) NOT NULL,
    requisition_date DATE NOT NULL,
    item_or_drug_id VARCHAR(9) NOT NULL,
    item_or_drug_quanitity INT NOT NULL,
    received_by_staff_id VARCHAR(9),
    received_on_date DATE,
    PRIMARY KEY (requisition_id),
    FOREIGN KEY (requisitioned_ward_id) REFERENCES wards(ward_id),
    FOREIGN KEY (requisitioned_by_staff_id) REFERENCES staff(staff_id),
    FOREIGN KEY (item_or_drug_id) REFERENCES pharmaceutical_supplies(drug_id),
    FOREIGN KEY (item_or_drug_id) REFERENCES surgicaland_nonsurgical_supplies(item_id),
    FOREIGN KEY (received_by_staff_id) REFERENCES staff(staff_id),
    CONSTRAINT RecievedOrNot_Ck CHECK ((recieved_by_staff_id=null AND recieved_on_date=null) OR (ecieved_by_staff_id!=null AND recieved_on_date!=null))
);
    #The above constraint means either both the recieved_by_staff_id AND recieved_on_date
    #	have to both be NULL or both be NOT NULL so that the requisition is either 
    #	recieved or not and has all information necessary when it is

CREATE TABLE IF NOT EXISTS suppliers (
	supplier_id	VARCHAR(9) NOT NULL UNIQUE,
    supplier_name	VARCHAR(30) NOT NULL,
    supplier_addr	VARCHAR(255) NOT NULL,
    supplier_phone_number	VARCHAR(15) NOT NULL,
    supplier_fax_line_1	VARCHAR(15) NOT NULL,
    supplier_fax_line_2	VARCHAR(15) NOT NULL,
    PRIMARY KEY (supplier_id)
);
