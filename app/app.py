import streamlit as st
import pandas as pd
import mariadb
import sys

@st.cache_resource
def init_db_connection():
    """
    Initialize a database connection and save it to the Streamlit cache.
    """
    conn = None
    try:
        conn = mariadb.connect(
            host="db", 
            port=3306, 
            user="root", 
            password="", 
            database="olympics"
        )
    except mariadb.Error as e:
        st.write(f"Error connecting to the database: {e}")
        sys.exit(1)
    return conn

def execute_query(query, cursor):
    """
    Execute a SQL query and return the results as a Pandas DataFrame.
    """
    cursor.execute(query)
    cols = [field_md[0] for field_md in cursor.description]
    rows = [r for r in cur]
    df = pd.DataFrame(rows, columns=cols)
    df.index += 1
    return df


#---------------------------------------------------------------------#
# Database connection
#---------------------------------------------------------------------#
conn = init_db_connection()     # create a connection or get one from cache
cur = conn.cursor()             # create a cursor


#---------------------------------------------------------------------#
# Interface
#---------------------------------------------------------------------#

st.write("# Olympics DB")
st.sidebar.header("Olympics DB Demo")

query_text_area = st.text_area("SQL query", value="show tables")
button = st.button("Execute", type="primary")

# on button click
if button:
    res = execute_query(query_text_area, cur)
    st.dataframe(data=res, use_container_width=True)

