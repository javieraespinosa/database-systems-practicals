
CREATE TABLE Country (
    NOC         CHAR(3) PRIMARY KEY,
    name        VARCHAR(255) UNIQUE,
    athletesNr  INT,
    medalsNr    INT,
    CHECK (athletesNr >= 0),
    CHECK (medalsNr >= 0),
    CHECK (NOC  IN ('ARG', 'AUS', 'AUT', 'BAH', 'BAR', 'BEL', 'BER', 'BIZ', 'BRA', 'BUL', 'CAF', 'CAN', 'CHA', 'CHI', 'CIV', 'CMR', 'COL', 'CRC', 'CUB', 'DEN', 'DOM', 'ECU', 'ESA', 'ESP', 'ETH', 'FIJ', 'FIN', 'FRA', 'FRG', 'GBR', 'GDR', 'GHA', 'GRE', 'GUA', 'GUY', 'HON', 'HUN', 'IND', 'IRI', 'IRL', 'ISL', 'ISR', 'ISV', 'ITA', 'JAM', 'JPN', 'KEN', 'KOR', 'KUW', 'LBA', 'LIE', 'LUX', 'MAD', 'MAR', 'MAS', 'MEX', 'MGL', 'MLI', 'MYA', 'NCA', 'NED', 'NGR', 'NOR', 'NZL', 'PER', 'PHI', 'POL', 'POR', 'PUR', 'ROU', 'SEN', 'SGP', 'SLE', 'SRI', 'SUD', 'SUI', 'SUR', 'SWE', 'TAN', 'TCH', 'TPE', 'TTO', 'TUN', 'TUR', 'UGA', 'URS', 'URU', 'USA', 'VEN', 'VIE', 'YUG', 'ZAM'))
);


CREATE TABLE Discipline (
    idDiscipline    INT PRIMARY KEY,
    category        VARCHAR(255) NOT NULL,
    name            VARCHAR(255) NOT NULL,
    UNIQUE (category, name)
);


CREATE TABLE Event (
    idEvent         INT PRIMARY KEY,
    idDiscipline    INT,
    date            DATE,
    place           VARCHAR(255),
    athletesNr      INT,
    nature          ENUM('Heat', 'Final'),
    FOREIGN KEY (idDiscipline) REFERENCES Discipline(idDiscipline),
    CHECK (athletesNr >= 0)
);


CREATE TABLE Athlete (
    idAthlete       INT PRIMARY KEY,
    name            VARCHAR(255) NOT NULL,
    surname         VARCHAR(255) NOT NULL,
    gender          ENUM('F', 'M', 'NB'),
    team            CHAR(3),
    FOREIGN KEY (team) REFERENCES Country(NOC)
);


CREATE TABLE EventParticipant (
    idAthlete   INT,
    idEvent     INT,
    ranking     INT,
    FOREIGN KEY (idAthlete) REFERENCES Athlete(idAthlete),
    FOREIGN KEY (idEvent)   REFERENCES Event(idEvent),
    PRIMARY KEY (idAthlete, idEvent),
    CHECK (ranking >= 0)
);


CREATE TABLE EventMedals (
    idAthlete   INT,
    idEvent     INT,
    medal       ENUM('Gold', 'Silver', 'Bronze'),
    FOREIGN KEY (idAthlete) REFERENCES Athlete(idAthlete),
    FOREIGN KEY (idEvent)   REFERENCES Event(idEvent),
    PRIMARY KEY (idAthlete, idEvent)
);

