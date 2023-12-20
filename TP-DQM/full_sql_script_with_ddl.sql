
CREATE TABLE Country (
    NOC             CHAR(3) NOT NULL PRIMARY KEY,
    name            VARCHAR(255) NOT NULL,
    athletesNr      INT UNSIGNED NOT NULL,
    medalsNr        INT UNSIGNED NOT NULL
);

CREATE TABLE Discipline (
    idDiscipline    INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    category        VARCHAR(255) NOT NULL,
    name            VARCHAR(255) NOT NULL
);

CREATE TABLE Contest (
    idContest       INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    idDiscipline    INT NOT NULL,
    date            DATE NOT NULL,
    place           VARCHAR(255) NOT NULL,
    athletesNr      INT UNSIGNED NOT NULL,
    nature          ENUM('Heat', 'Final') NOT NULL,
    FOREIGN KEY     (idDiscipline) REFERENCES Discipline(idDiscipline)
);

CREATE TABLE Athlete (
    idAthlete       INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    name            VARCHAR(255) NOT NULL,
    surname         VARCHAR(255) NOT NULL,
    gender          ENUM('F', 'M', 'NB') NOT NULL,
    team            CHAR(3) NOT NULL,
    FOREIGN KEY     (team) REFERENCES Country(NOC)
);

CREATE TABLE ContestParticipant (
    idAthlete       INT NOT NULL,
    idContest       INT NOT NULL,
    partRank        INT UNSIGNED NOT NULL,
    FOREIGN KEY     (idAthlete) REFERENCES Athlete(idAthlete),
    FOREIGN KEY     (idContest) REFERENCES Contest(idContest),
    PRIMARY KEY     (idAthlete, idContest)
);

CREATE TABLE ContestMedals (
    idAthlete       INT NOT NULL,
    idContest       INT NOT NULL,
    medal           ENUM('Gold', 'Silver', 'Bronze') NOT NULL,
    FOREIGN KEY     (idAthlete) REFERENCES Athlete(idAthlete),
    FOREIGN KEY     (idContest) REFERENCES Contest(idContest),
    PRIMARY KEY     (idAthlete, idContest)
);


