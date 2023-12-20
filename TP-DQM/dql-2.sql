
/***** Organisers *****/

-- 1. The general schedule of the contests of all disciplines including the number of athletes participating in each contest, the day and location
SELECT Discipline.name AS discipline, Contest.idContest, Contest.date, Contest.place, COUNT(ContestParticipant.idAthlete) AS numParticipants
FROM Discipline
JOIN Contest ON Discipline.idDiscipline = Contest.idDiscipline
LEFT JOIN ContestParticipant ON Contest.idContest = ContestParticipant.idContest
GROUP BY Discipline.name, Contest.idContest, Contest.date, Contest.place;

-- 2. The general results of all disciplines (gold, silver, bronce) organised by country
SELECT Country.NOC, Country.name AS team,
       COUNT(CASE WHEN ContestMedals.medal = 'Gold' THEN 1 END) AS gold,
       COUNT(CASE WHEN ContestMedals.medal = 'Silver' THEN 1 END) AS silver,
       COUNT(CASE WHEN ContestMedals.medal = 'Bronze' THEN 1 END) AS bronze
FROM Country
LEFT JOIN Athlete ON Country.NOC = Athlete.team
LEFT JOIN ContestParticipant ON Athlete.idAthlete = ContestParticipant.idAthlete
LEFT JOIN ContestMedals ON ContestParticipant.idAthlete = ContestMedals.idAthlete
                       AND ContestParticipant.idContest = ContestMedals.idContest
GROUP BY Country.NOC, Country.name;

-- 3. The general classification of all athletes participating in each contest organised by discipline and country
SELECT Discipline.name AS discipline, Country.NOC, Country.name AS team,
       Athlete.idAthlete, Athlete.name, Athlete.surname,
       ContestParticipant.partRank
FROM Discipline
JOIN Contest ON Discipline.idDiscipline = Contest.idDiscipline
JOIN ContestParticipant ON Contest.idContest = ContestParticipant.idContest
JOIN Athlete ON ContestParticipant.idAthlete = Athlete.idAthlete
JOIN Country ON Athlete.team = Country.NOC;

-- 4. The participants of the delegations organised by discipline and country
SELECT Discipline.name AS discipline, Country.NOC, Country.name AS team,
       Athlete.idAthlete, Athlete.name, Athlete.surname
FROM Discipline
JOIN Contest ON Discipline.idDiscipline = Contest.idDiscipline
JOIN ContestParticipant ON Contest.idContest = ContestParticipant.idContest
JOIN Athlete ON ContestParticipant.idAthlete = Athlete.idAthlete
JOIN Country ON Athlete.team = Country.NOC;


/***** Press/Public *****/

-- 1. The composition of the delegations organised by country and discipline
SELECT Country.NOC, Country.name AS team, Discipline.name AS discipline,
       COUNT(Athlete.idAthlete) AS numAthletes
FROM Country
JOIN Athlete ON Country.NOC = Athlete.team
JOIN Discipline ON TRUE  -- Agregando una condición siempre verdadera para obtener todas las combinaciones posibles
GROUP BY Country.NOC, Country.name, Discipline.name;

-- 2. The disciplines of the delegation of a country
-- Para un país específico (por ejemplo, el país con NOC = 'USA')
SELECT Country.NOC, Country.name AS team, Discipline.name AS discipline
FROM Country
JOIN Athlete ON Country.NOC = Athlete.team
JOIN Discipline ON TRUE
WHERE Country.NOC = 'USA';

-- 3. The profile of top-k athletes organised by discipline and country
-- Para los primeros 5 atletas, por ejemplo
SELECT Discipline.name AS discipline, Country.NOC, Country.name AS team,
       Athlete.idAthlete, Athlete.name, Athlete.surname
FROM Athlete
JOIN Country ON Athlete.team = Country.NOC
JOIN Discipline ON TRUE  -- Agregando una condición siempre verdadera para obtener todas las disciplinas
ORDER BY Athlete.idAthlete
LIMIT 5;

-- 4. The profile of an athlete
-- Para un atleta específico (por ejemplo, el atleta con idAthlete = 1)
SELECT Athlete.idAthlete, Athlete.name, Athlete.surname, Athlete.gender, Country.name AS team
FROM Athlete
JOIN Country ON Athlete.team = Country.NOC
WHERE Athlete.idAthlete = 1;

-- 5. The schedule of the contests organised by discipline
-- Para una disciplina específica (por ejemplo, la disciplina con idDiscipline = 1)
SELECT Contest.idContest, Contest.date, Contest.place
FROM Contest
WHERE Contest.idDiscipline = 1;

-- 6. The participants of a contest of a discipline organised by country
-- Para una competencia específica (por ejemplo, la competencia con idContest = 1 y disciplina con idDiscipline = 1)
SELECT Athlete.idAthlete, Athlete.name, Athlete.surname, Country.name AS team
FROM Athlete
JOIN ContestParticipant ON Athlete.idAthlete = ContestParticipant.idAthlete
JOIN Contest ON ContestParticipant.idContest = Contest.idContest
JOIN Country ON Athlete.team = Country.NOC
WHERE Contest.idContest = 1 AND Contest.idDiscipline = 1;

-- 7. The general medal results organised by country and discipline
SELECT Country.NOC, Country.name AS team, Discipline.name AS discipline,
       COUNT(CASE WHEN ContestMedals.medal = 'Gold' THEN 1 END) AS gold,
       COUNT(CASE WHEN ContestMedals.medal = 'Silver' THEN 1 END) AS silver,
       COUNT(CASE WHEN ContestMedals.medal = 'Bronze' THEN 1 END) AS bronze
FROM Country
JOIN Athlete ON Country.NOC = Athlete.team
JOIN Discipline ON TRUE
LEFT JOIN ContestParticipant ON Athlete.idAthlete = ContestParticipant.idAthlete
LEFT JOIN ContestMedals ON ContestParticipant.idAthlete = ContestMedals.idAthlete
                       AND ContestParticipant.idContest = ContestMedals.idContest
GROUP BY Country.NOC, Country.name, Discipline.name;
