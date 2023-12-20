
/***** Athletes *****/

-- 1. Their own competition(s) schedules:
-- Para un atleta específico (por ejemplo, el atleta con idAthlete = 1)
SELECT *
FROM Contest
WHERE idContest IN (
    SELECT idContest
    FROM ContestParticipant
    WHERE idAthlete = 1
);

-- 2. The number of medals and ranking of the participants of their discipline organised by country
-- Para un atleta específico en una disciplina específica (por ejemplo, el atleta con idAthlete = 1 y idDiscipline = 1)
SELECT Athlete.idAthlete, Athlete.name, Athlete.surname, Country.name AS team,
       COUNT(ContestMedals.medal) AS numMedals,
       RANK() OVER (PARTITION BY Athlete.team ORDER BY COUNT(ContestMedals.medal) DESC) AS ranking
FROM Athlete
JOIN Country ON Athlete.team = Country.NOC
LEFT JOIN ContestParticipant ON Athlete.idAthlete = ContestParticipant.idAthlete
LEFT JOIN ContestMedals ON ContestParticipant.idAthlete = ContestMedals.idAthlete
                       AND ContestParticipant.idContest = ContestMedals.idContest
WHERE Athlete.idAthlete = 1
GROUP BY Athlete.idAthlete, Country.name;

-- 3. Their own scores during the competition
-- Para un atleta específico en una competencia específica (por ejemplo, el atleta con idAthlete = 1 y idContest = 1)
SELECT ContestParticipant.idAthlete, Athlete.name, Athlete.surname, ContestParticipant.idContest,
       ContestParticipant.partRank
FROM ContestParticipant
JOIN Athlete ON ContestParticipant.idAthlete = Athlete.idAthlete
WHERE ContestParticipant.idAthlete = 1 AND ContestParticipant.idContest = 1;

-- 4. The scores of the participants during the games
-- Para una competencia específica (por ejemplo, la competencia con idContest = 1)
SELECT Athlete.idAthlete, Athlete.name, Athlete.surname, ContestParticipant.partRank
FROM ContestParticipant
JOIN Athlete ON ContestParticipant.idAthlete = Athlete.idAthlete
WHERE ContestParticipant.idContest = 1;

/***** Trainers *****/

-- 1. Performance per athlete of their team
-- Para un equipo específico (por ejemplo, el equipo con NOC = 'USA')
SELECT Athlete.idAthlete, Athlete.name, Athlete.surname, Athlete.team,
       COUNT(ContestMedals.medal) AS numMedals
FROM Athlete
LEFT JOIN ContestMedals ON Athlete.idAthlete = ContestMedals.idAthlete
WHERE Athlete.team = 'USA'
GROUP BY Athlete.idAthlete, Athlete.name, Athlete.surname, Athlete.team;

-- 2. Number of medals and ranking of the participants of their discipline
-- Para un atleta específico en una disciplina específica (por ejemplo, el atleta con idAthlete = 1 y idDiscipline = 1)
SELECT Athlete.idAthlete, Athlete.name, Athlete.surname, Country.name AS team,
       COUNT(ContestMedals.medal) AS numMedals,
       RANK() OVER (PARTITION BY Athlete.team ORDER BY COUNT(ContestMedals.medal) DESC) AS ranking
FROM Athlete
JOIN Country ON Athlete.team = Country.NOC
LEFT JOIN ContestParticipant ON Athlete.idAthlete = ContestParticipant.idAthlete
LEFT JOIN ContestMedals ON ContestParticipant.idAthlete = ContestMedals.idAthlete
                       AND ContestParticipant.idContest = ContestMedals.idContest
WHERE Athlete.idAthlete = 1 /*AND ContestParticipant.idDiscipline = 1*/
GROUP BY Athlete.idAthlete, Country.name;

-- 3. The global score of the team they couch
-- Para un equipo específico (por ejemplo, el equipo con NOC = 'USA')
SELECT Country.NOC, Country.name AS team,
       SUM(ContestMedals.medal = 'Gold') * 3 +
       SUM(ContestMedals.medal = 'Silver') * 2 +
       SUM(ContestMedals.medal = 'Bronze') AS totalScore
FROM Country
LEFT JOIN Athlete ON Country.NOC = Athlete.team
LEFT JOIN ContestParticipant ON Athlete.idAthlete = ContestParticipant.idAthlete
LEFT JOIN ContestMedals ON ContestParticipant.idAthlete = ContestMedals.idAthlete
                       AND ContestParticipant.idContest = ContestMedals.idContest
WHERE Country.NOC = 'USA'
GROUP BY Country.NOC, Country.name;

-- 4. The contest(s) schedules.
-- Para un atleta específico (por ejemplo, el atleta con idAthlete = 1)
SELECT Contest.*
FROM Contest
JOIN ContestParticipant ON Contest.idContest = ContestParticipant.idContest
WHERE ContestParticipant.idAthlete = 1;
