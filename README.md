
# Olympics Database 

This repository illustrates the ETL process using the [Summer Olympics](https://github.com/tugraz-isds/datasets/tree/master/summer_olympics) dataset for producing the Olympics DB. 

The repository is part of the [Database Systems](http://vargas-solar.com/db-fundaments/) course material.

## Content

* `olympics-db/` contains the SQL scripts (DDL, DML) resulting from the ETL process (see [olympics-db/olympics_etl.ipynb](olympics-db/olympics_etl.ipynb)). 

* `app/` contains a [streamlit](https://streamlit.io) application (`app.py`) illustrating how to query the Olympics Database using python and MariaDB.

* Extra files to run the application and the database using Docker and Docker Compose.

## Relational Algebra 

The Olympics DB can be load and query using the Relational Algebra (Relax) Calculator:

* [Olympics DB relax calculator](https://dbis-uibk.github.io/relax/calc/gist/e1e2263984fa0305c8a836159369bad0)

The Olympic DB relax schema is in [olympics-db/olympics-relax.txt](olympics-db/olympics-relax.txt).

## Run

Start the python and MariaDB containers as follows: 

```
docker-compose up
```

Then visit http://localhost:8501.

## MariaDB client

To query the database using the MariaDB client:

```
docker-compose exec -it db mariadb  
```



