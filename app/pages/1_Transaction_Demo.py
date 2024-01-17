import streamlit as st
import pandas as pd
import mariadb
import sys


# ------------------------------------------------------------------------------------------
# Database Transaction Example using MariaDB and Python
# 
# More info: 
#   https://mariadb.com/docs/server/connect/programming-languages/python/transactions/
#   https://www.geeksforgeeks.org/commit-rollback-operation-in-python/
# 
# ------------------------------------------------------------------------------------------

# connection parameters
conn_params= {
    "user"     : "root",
    "password" : "",
    "database" : "olympics",
    "host"     : "db",
    "port"     : 3306,
}

conn = None
try:
    # Establish a connection
    connection = mariadb.connect( **conn_params )

    # Disable auto-commit (False by default)
    connection.autocommit = False

    # Get a cursor for interacting with the MariaDB
    cursor = connection.cursor()

    # Read operation
    cursor.execute("SELECT SUM(medalsNr) FROM Country")
    row = cursor.fetchone()
    st.write( row )

    # Write operation
    cursor.execute("UPDATE Country SET medalsNr = 0")

    # Read operation
    cursor.execute("SELECT SUM(medalsNr) FROM Country")
    row = cursor.fetchone()
    st.write( row )

    # Abort transaction 
    connection.rollback()         # or connection.commit() to persist changes

    # Read operation
    cursor.execute("SELECT SUM(medalsNr) FROM Country")
    row = cursor.fetchone()
    st.write( row )
    
    cursor.close()
    connection.close()

except mariadb.Error as e:
    st.write(f"Error connecting to the database: {e}")
    sys.exit(1)
