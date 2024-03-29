PRAGMA foreign_keys = OFF;
DROP TABLE IF EXISTS Person;
DROP TABLE IF EXISTS Department;
DROP TABLE IF EXISTS Location;
DROP TABLE IF EXISTS Shift;
DROP TABLE IF EXISTS Specialization;
DROP TABLE IF EXISTS Worker;
DROP TABLE IF EXISTS WorkerShift;
DROP TABLE IF EXISTS Manager;
DROP TABLE IF EXISTS Maintenance;
DROP TABLE IF EXISTS Volunteer;
DROP TABLE IF EXISTS Nurse;
DROP TABLE IF EXISTS Doctor;
DROP TABLE IF EXISTS DoctorSpecialization;
DROP TABLE IF EXISTS Client;
DROP TABLE IF EXISTS Patient;
DROP TABLE IF EXISTS Visitor;
DROP TABLE IF EXISTS VisitTime;
DROP TABLE IF EXISTS Service;
DROP TABLE IF EXISTS DoctorService;
DROP TABLE IF EXISTS NurseService;
DROP TABLE IF EXISTS MedicalRecord;
DROP TABLE IF EXISTS Appointment;
DROP TABLE IF EXISTS Surgery;
DROP TABLE IF EXISTS Ambulance;
DROP TABLE IF EXISTS MaintenanceJob;
DROP TABLE IF EXISTS Extern;
DROP TABLE IF EXISTS SurgeryRoom;
DROP TABLE IF EXISTS IntensiveCareRoom;
DROP TABLE IF EXISTS NormalCareRoom;
DROP TABLE IF EXISTS Office;
PRAGMA foreign_keys = ON;


CREATE TABLE Person(
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    birth_date DATE,
    death_date DATE,
    age INTEGER CHECK(age > 0),
    gender TEXT CHECK(gender == 'M' OR gender == 'F' OR gender == 'O'),
    phone_number INTEGER,
    NIF VARCHAR(9) UNIQUE CHECK(length(NIF)==9),
    email TEXT LIKE "%@%.%",
    address TEXT,
    insurance_id INTEGER UNIQUE
    
);

CREATE TABLE Department(
    id INTEGER PRIMARY KEY,
    floor INTEGER
);

CREATE TABLE Location(
    id INTEGER PRIMARY KEY,
    room_number INTEGER CHECK(room_number > 0),
    bed_number INTEGER CHECK(bed_number > 0) UNIQUE
);

CREATE TABLE Shift(
    id INTEGER PRIMARY KEY,
    day_of_the_week_in INT,
    time_in TIME,
    day_of_the_week_out INT,
    time_out TIME,
    CONSTRAINT dayInIsADay CHECK(day_of_the_week_in >= 0 AND day_of_the_week_in <= 6),
    CONSTRAINT dayOutIsADay CHECK(day_of_the_week_out >= 0 AND day_of_the_week_out <= 6),
    CONSTRAINT shiftLessThan48 CHECK(
        (
            ((day_of_the_week_out - day_of_the_week_in) < 2 AND (day_of_the_week_out - day_of_the_week_in) >= 0)
            OR 
            ((day_of_the_week_out - day_of_the_week_in) + 7 < 2)
        ) 
        OR
        (
            ((day_of_the_week_out - day_of_the_week_in) == 2 OR (day_of_the_week_out - day_of_the_week_in) + 7 == 2)
             AND
            strftime('%s', time_in) >= strftime('%s', time_out)
        )
        
    )
);

CREATE TABLE Specialization(
    speciality TEXT PRIMARY KEY
);

CREATE TABLE Worker(
    person PRIMARY KEY REFERENCES Person ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE WorkerShift(
    worker REFERENCES Worker ON UPDATE CASCADE ON DELETE SET NULL,
    shift REFERENCES Shift ON UPDATE CASCADE ON DELETE SET NULL,
    PRIMARY KEY (worker, shift)
);

CREATE TABLE Manager(
    person PRIMARY KEY REFERENCES Worker ON UPDATE CASCADE ON DELETE SET NULL,
    department INTEGER NOT NULL REFERENCES Department ON UPDATE CASCADE ON DELETE SET NULL,
    salary INTEGER,
    CONSTRAINT needsMoney CHECK(salary > 0)
);

CREATE TABLE Maintenance(
    person PRIMARY KEY REFERENCES Worker ON UPDATE CASCADE ON DELETE SET NULL,
    department INTEGER NOT NULL REFERENCES Department ON UPDATE CASCADE ON DELETE SET NULL,
    salary INTEGER,
    CONSTRAINT needsMoney CHECK(salary > 0)
);

CREATE TABLE Volunteer(
    person PRIMARY KEY REFERENCES Worker ON UPDATE CASCADE ON DELETE SET NULL,
    association_name TEXT,
    department INTEGER NOT NULL REFERENCES Department ON UPDATE CASCADE ON DELETE SET NULL 
);

CREATE TABLE Nurse(
    person PRIMARY KEY REFERENCES Worker ON UPDATE CASCADE ON DELETE SET NULL,
    department INTEGER NOT NULL REFERENCES Department ON UPDATE CASCADE ON DELETE SET NULL,
    salary INTEGER,
    CONSTRAINT needsMoney CHECK(salary > 0) 
);

CREATE TABLE Doctor(
    person PRIMARY KEY REFERENCES Worker ON UPDATE CASCADE ON DELETE SET NULL ,
    department INTEGER NOT NULL REFERENCES Department ON UPDATE CASCADE ON DELETE SET NULL,
    salary INTEGER,
    CONSTRAINT needsMoney CHECK(salary > 0) 
);

CREATE TABLE DoctorSpecialization(
    doctor REFERENCES Person ON UPDATE CASCADE ON DELETE SET NULL, 
    specialization REFERENCES Specialization ON UPDATE CASCADE ON DELETE SET NULL, 
    PRIMARY KEY(doctor, specialization)
);

CREATE TABLE Client(
    person INTEGER PRIMARY KEY REFERENCES Person ON UPDATE CASCADE ON DELETE SET NULL 
);

CREATE TABLE Patient(
    person INTEGER PRIMARY KEY REFERENCES Client ON UPDATE CASCADE ON DELETE SET NULL 
);

CREATE TABLE Visitor(
    person INTEGER PRIMARY KEY REFERENCES Client ON UPDATE CASCADE ON DELETE SET NULL 
);

CREATE TABLE VisitTime(
    patient REFERENCES Patient ON UPDATE CASCADE ON DELETE SET NULL,
    visitor REFERENCES Visitor ON UPDATE CASCADE ON DELETE SET NULL, 
    start_visit_date DATETIME,
    end_visit_date DATETIME,
    PRIMARY KEY (patient, visitor),
    CONSTRAINT notSamePerson CHECK(patient IS NOT visitor),
    CONSTRAINT validVisitTime CHECK(end_visit_date > start_visit_date)
);

CREATE TABLE Service(
    id INTEGER PRIMARY KEY,
    diagnosis TEXT,
    medication TEXT,    
    price INTEGER CHECK (price >= 0),
    date_in DATETIME NOT NULL,
    date_out DATETIME,
    location INTEGER REFERENCES Location ON UPDATE CASCADE ON DELETE SET NULL,
    patient INTEGER REFERENCES Patient ON UPDATE CASCADE ON DELETE SET NULL ,
    CONSTRAINT validServiceTime CHECK(date_out > date_in OR date_out IS NULL)
);

CREATE TABLE NurseService(
    nurse REFERENCES Nurse ON UPDATE CASCADE ON DELETE SET NULL, 
    service REFERENCES Service ON UPDATE CASCADE ON DELETE SET NULL, 
    PRIMARY KEY(nurse, service)
);  

CREATE TABLE DoctorService(
    doctor REFERENCES Doctor ON UPDATE CASCADE ON DELETE SET NULL, 
    service REFERENCES Service ON UPDATE CASCADE ON DELETE SET NULL, 
    PRIMARY KEY(doctor, service)
);

CREATE TABLE Appointment(
    service INTEGER PRIMARY KEY REFERENCES Service ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE Surgery(
    service INTEGER PRIMARY KEY REFERENCES Service ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE Ambulance(
    service INTEGER PRIMARY KEY REFERENCES Service ON UPDATE CASCADE ON DELETE SET NULL, 
    amb_id INTEGER CHECK(amb_id > 0) UNIQUE,
    priority INTEGER CHECK(priority >=1 AND priority <= 5)
);

CREATE TABLE MaintenanceJob(
    ambulance INTEGER REFERENCES Ambulance ON UPDATE CASCADE ON DELETE SET NULL ,
    maintenance INTEGER REFERENCES Maintenance ON UPDATE CASCADE ON DELETE SET NULL ,
    date DATE,
    did_disinfection INTEGER,
    did_restock INTEGER,
    PRIMARY KEY(ambulance, maintenance),
    CONSTRAINT disinfectionBoolean CHECK (did_disinfection == 0 OR did_disinfection == 1),
    CONSTRAINT restockBoolean CHECK (did_restock == 0 OR did_restock == 1)
);

CREATE TABLE Extern(
    location INTEGER PRIMARY KEY REFERENCES Location ON UPDATE CASCADE ON DELETE SET NULL, 
    address TEXT NOT NULL
);

CREATE TABLE SurgeryRoom(
    location INTEGER PRIMARY KEY REFERENCES Location ON UPDATE CASCADE ON DELETE SET NULL,
    specialization TEXT NOT NULL REFERENCES Specialization ON UPDATE CASCADE ON DELETE SET NULL

);

CREATE TABLE IntensiveCareRoom(
    location INTEGER PRIMARY KEY REFERENCES Location ON UPDATE CASCADE ON DELETE SET NULL,
    o2 INTEGER,
    iv INTEGER,
    CONSTRAINT o2Boolean CHECK (o2 == 0 OR o2 == 1),
    CONSTRAINT ivBoolean CHECK (iv == 0 OR iv == 1)

);

CREATE TABLE NormalCareRoom(
    location INTEGER PRIMARY KEY REFERENCES Location ON UPDATE CASCADE ON DELETE SET NULL 
);

CREATE TABLE Office(
    location INTEGER PRIMARY KEY REFERENCES Location ON UPDATE CASCADE ON DELETE SET NULL 
);
