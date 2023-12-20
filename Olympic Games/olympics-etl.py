from datetime import timedelta
from datetime import date

import pandas as pd
import numpy as np
import random


#---------------------------------------------------------------------------
#   SELECT ONLY:
#       - Mexico City Olympics Games (1968)
#       - Athletics disciplines (individual sports only)
#---------------------------------------------------------------------------

AthleteEvents_df = pd.read_csv('AthleteEvents.csv')

df = AthleteEvents_df.query("City == 'Mexico City' & Year==1968")
df = df[  df["Sport"].isin(["Athletics"])  ]
df = df[ ~df["Event"].str.contains("Relay") ]

#---------------------------------------------------------------------------
#   QUERY 1: Countries (teams) participating in the selected Olympic Games 
#            and sport(s)
#---------------------------------------------------------------------------

teams_df = df.groupby(["Team", "NOC"]).size().reset_index(name='Num_Athletes')
teams_df = teams_df.sort_values("Num_Athletes", ascending=False)

#---------------------------------------------------------------------------
#   QUERY 2: Disciplines in the selected Olympic Games
#---------------------------------------------------------------------------

disciplines_df = df[["Sport", "Event"]].drop_duplicates()
disciplines_df.insert(0, "DisciplineID", range(1, 1 + len(disciplines_df)))

#---------------------------------------------------------------------------
#   QUERY 3: Athletes competing in the selected disciplines & Olympic Games
#---------------------------------------------------------------------------

athletes_df = df[["AID", "Name", "Gender", "Team", "NOC", "Sport", "Event", "Medal"]]

# add athletes first and last name
names = athletes_df["Name"].tolist()
f_name = []
s_name = []

for i in range(0, len(names)):
    words = names[i].split(" ")
    f_name.append(words[0])
    s_name.append(  " ".join(words[1:])   )
    
athletes_df["Firstname"] = f_name
athletes_df["Surname"]   = s_name

#---------------------------------------------------------------------------
#   QUERY 4: Total number of medals per country
#---------------------------------------------------------------------------

country_medals_df = df.groupby(["Team", "Medal"]).size().reset_index(name='Num_Medals')
country_medals_df = country_medals_df.groupby(["Team"], as_index=False)["Num_Medals"].sum()
country_medals_df = country_medals_df.sort_values("Num_Medals", ascending=False)

#---------------------------------------------------------------------------
#   QUERY 5: Events and number of athletes per event
#---------------------------------------------------------------------------

# num athletes per event
events_df = df.groupby(["Sport", "Event", "Year"]).size().reset_index(name='Num_Athletes')

# add random locations per event
locations =  [ "Stadium {}".format(x) for x in ["A", "B", "C"] ]
events_df['Location'] = np.random.randint(0, len(locations), events_df.shape[0])
events_df['Location'] = events_df['Location'].apply(lambda i: locations[i])

# add random "heat" events 
tmp = []
for event in events_df.to_dict('records'):    
    for i in range(0, random.randint(1, 3)): 
        e = event.copy()
        e["Nature"] = "Heat"
        tmp.append(e)
events_df = pd.DataFrame(tmp)

# add eventID's
events_df.insert(0, "EventID", range(1, 1 + len(events_df)))

# add random dates using the official start and end dates as reference
year  = events_df["Year"].unique()[0]
HostCities_df = pd.read_csv('HostCities.csv')
host_city  = HostCities_df[HostCities_df["Year"] == year]

start_date = date.fromisoformat(host_city["StartDate"].values[0])
end_date   = date.fromisoformat(host_city["EndDate"].values[0])
duration   = (end_date - start_date).days

events_df['Date'] = np.random.randint(0, duration, events_df.shape[0])
events_df['Date'] = events_df['Date'].apply(lambda d: start_date + timedelta(days=d))

# SET final event
final_events_df = events_df.sort_values(["Event", "Date"], ascending=True).groupby(["Event"]).tail(1)
events_df.loc[ events_df["EventID"].isin(final_events_df["EventID"]), "Nature" ] = "Final"
events_df = events_df.sort_values(["Event", "Date"], ascending=True)

#---------------------------------------------------------------------------
#   QUERY 6: Medals per discipline
#---------------------------------------------------------------------------

discipline_medals_df = athletes_df[~athletes_df["Medal"].isna()]

#---------------------------------------------------------------------------
#   QUERY 7: Event Participants ranks
#---------------------------------------------------------------------------

event_participants_df = pd.merge(events_df, athletes_df[["AID", "Sport", "Event"]], on=["Sport", "Event"])
event_participants_df = event_participants_df[["AID", "EventID", "Sport", "Event", "Nature", "Date"]]

# add athletes ranks per event
event_participants_df["Rank"] = 0
for key, group in event_participants_df.groupby(["EventID"]):
    i=1
    for row_number, row in group.iterrows():
        event_participants_df.loc[row_number, "Rank"] = i
        i+=1

event_participants_df = event_participants_df.sort_values(["EventID", "Rank"], ascending=True)




#---------------------------------------------------------------------------
#   QUERY 8: UPDATE final events ranks with medals
#---------------------------------------------------------------------------

# SELECT final events only
final_events_participants_df = event_participants_df[ (event_participants_df["Nature"] == "Final") ]

# JOIN events and medals based on athleteID, Sport and Event
final_events_participants_df = pd.merge(final_events_participants_df, discipline_medals_df, on=["AID", "Sport", "Event"], how="right")

# PROJECT the required columns and ORDER BY EventID and Rank
final_events_participants_df = final_events_participants_df[["AID", "EventID", "Rank", "Medal"]].sort_values(["EventID", "Rank"], ascending=True)

# SET medalists rank to 1, 2 or 3 (Gold, Silver, Bronze) and update the others ranks accordingly
for index, row in final_events_participants_df.iterrows():
    
    targetRank = row["Rank"]
    medalRank = 0
    match row["Medal"]:
        case "Gold":
            medalRank = 1
        case "Silver":
            medalRank = 2
        case "Bronze":
            medalRank = 3

    # SELECT the athlete with the old rank and update his rank to the new rank
    sel_i = event_participants_df[ (event_participants_df["Nature"]  == "Final") 
                                 & (event_participants_df["EventID"] == row["EventID"]) 
                                 & (event_participants_df["Rank"]    == targetRank) ]
    
    sel_j = event_participants_df[ (event_participants_df["Nature"]  == "Final") 
                                 & (event_participants_df["EventID"] == row["EventID"]) 
                                 & (event_participants_df["Rank"]    == medalRank) ]
    
    i = sel_i.index.tolist()[0]
    j = sel_j.index.tolist()[0]

    event_participants_df.loc[i, "Rank"] = medalRank
    event_participants_df.loc[j, "Rank"] = targetRank






###########################################################################
#
#   SQL: DDL & DML
#
###########################################################################

dml_file = open("olympics-dml.sql", "w")
ddl_file = open("olympics-ddl.sql", "w")

#---------------------------------------------------------------------------
#   Helper function
#---------------------------------------------------------------------------

def toDML(df, df_columns, table_name, table_columns, string_columns):
    """
    Generate DML statements from a dataframe using the given column names
    """
    values = []
    for index, row in df.iterrows():
        tmp = []
        for i in range(0, len(df_columns)):
            v = str(row[df_columns[i]])
            if string_columns[i]:
                v = v.replace("'", "''")
                v = "'{}'".format( v )
            tmp.append(v)
        values.append(     "({})".format( ", ".join(tmp) )    )
    s = "INSERT INTO {0} ({1}) VALUES \n {2};".format( table_name, ", ".join(table_columns), ",\n ".join(values) )
    return s


#---------------------------------------------------------------------------
#   QUERY X: Countries with number of medals and athletes
#---------------------------------------------------------------------------

src_df = pd.merge(teams_df, country_medals_df, on="Team", how="left")
src_df["Num_Medals"] = src_df["Num_Medals"].fillna(0)

exp1 = """
CREATE TABLE Country (
    NOC         CHAR(3) PRIMARY KEY,
    name        VARCHAR(255) UNIQUE,
    athletesNr  INT,
    medalsNr    INT,
    CHECK (athletesNr >= 0),
    CHECK (medalsNr >= 0),
    CHECK (NOC  IN ({}))
);
"""

countries = src_df.sort_values("NOC", ascending=True)["NOC"].unique().tolist()
exp1 = exp1.format( ", ".join( [ "'{}'".format(c) for c in countries ] ) )

df_columns     = ["NOC", "Team", "Num_Athletes", "Num_Medals"]
table_name     = "Country" 
table_columns  = ["NOC", "name", "athletesNr", "medalsNr"]
string_columns = [True, True, False, False]

exp2 = toDML(src_df, df_columns, table_name, table_columns, string_columns)

ddl_file.write(exp1 + "\n")
dml_file.write(exp2 + "\n\n")



#---------------------------------------------------------------------------
#   QUERY XI: Disciplines
#---------------------------------------------------------------------------

exp1 = """
CREATE TABLE Discipline (
    idDiscipline    INT PRIMARY KEY,
    category        VARCHAR(255) NOT NULL,
    name            VARCHAR(255) NOT NULL,
    UNIQUE (category, name)
);
"""

src_df         = disciplines_df
df_columns     = ["DisciplineID", "Sport", "Event"]
table_name     = "Discipline" 
table_columns  = ["idDiscipline", "category", "name"]
string_columns = [False, True, True]

exp2 = toDML(src_df, df_columns, table_name, table_columns, string_columns)

ddl_file.write(exp1 + "\n")
dml_file.write(exp2 + "\n\n")



#---------------------------------------------------------------------------
#   QUERY XII Events
#---------------------------------------------------------------------------

exp1 = """
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
"""

src_df         = pd.merge(events_df, disciplines_df, on=["Sport", "Event"])
df_columns     = ["EventID", "DisciplineID", "Date", "Location", "Num_Athletes", "Nature"]
table_name     = "Event" 
table_columns  = ["idEvent", "idDiscipline", "date", "place", "athletesNr", "nature"]
string_columns = [False, False, True, True, False, True]

exp2 = toDML(src_df, df_columns, table_name, table_columns, string_columns)

ddl_file.write(exp1 + "\n")
dml_file.write(exp2 + "\n\n")



#---------------------------------------------------------------------------
#   QUERY XIII: Atheltes 
#---------------------------------------------------------------------------

exp1 = """
CREATE TABLE Athlete (
    idAthlete       INT PRIMARY KEY,
    name            VARCHAR(255) NOT NULL,
    surname         VARCHAR(255) NOT NULL,
    gender          ENUM('F', 'M', 'NB'),
    team            CHAR(3),
    FOREIGN KEY (team) REFERENCES Country(NOC)
);
"""

src_df         = athletes_df[["AID", "Firstname", "Surname", "Gender", "NOC"]].drop_duplicates()
df_columns     = ["AID", "Firstname", "Surname", "Gender", "NOC"]
table_name     = "Athlete" 
table_columns  = ["idAthlete", "name", "surname", "gender", "team"]
string_columns = [False, True, True, True, True]

exp2 = toDML(src_df, df_columns, table_name, table_columns, string_columns)

ddl_file.write(exp1 + "\n")
dml_file.write(exp2 + "\n\n")



#---------------------------------------------------------------------------
#   QUERY XIV: Athletes participating in events
#---------------------------------------------------------------------------

exp1 = """
CREATE TABLE EventParticipant (
    idAthlete   INT,
    idEvent     INT,
    ranking     INT,
    FOREIGN KEY (idAthlete) REFERENCES Athlete(idAthlete),
    FOREIGN KEY (idEvent)   REFERENCES Event(idEvent),
    PRIMARY KEY (idAthlete, idEvent),
    CHECK (ranking >= 0)
);
"""

src_df         = event_participants_df
df_columns     = ["AID", "EventID", "Rank"]
table_name     = "EventParticipant" 
table_columns  = ["idAthlete", "idEvent", "ranking"]
string_columns = [False, False, False]

exp2 = toDML(src_df, df_columns, table_name, table_columns, string_columns)

ddl_file.write(exp1 + "\n")
dml_file.write(exp2 + "\n\n")


#---------------------------------------------------------------------------
#   QUERY XV: Event Medals
#---------------------------------------------------------------------------

exp1 = """
CREATE TABLE EventMedals (
    idAthlete   INT,
    idEvent     INT,
    medal       ENUM('Gold', 'Silver', 'Bronze'),
    FOREIGN KEY (idAthlete) REFERENCES Athlete(idAthlete),
    FOREIGN KEY (idEvent)   REFERENCES Event(idEvent),
    PRIMARY KEY (idAthlete, idEvent)
);
"""

src_df         = pd.merge(discipline_medals_df[['AID', 'Name', 'Team', 'NOC', 'Sport', 'Event', 'Medal']], events_df[events_df["Nature"] == "Final"], on=["Sport", "Event"])
df_columns     = ["AID", "EventID", "Medal"]
table_name     = "EventMedals" 
table_columns  = ["idAthlete", "idEvent", "medal"]
string_columns = [False, False, True]

exp2 = toDML(src_df, df_columns, table_name, table_columns, string_columns)

ddl_file.write(exp1 + "\n")
dml_file.write(exp2 + "\n\n")

