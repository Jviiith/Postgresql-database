# Connecting Python to Postgresql
import psycopg2
import psycopg2.extras

hostname = 'ip_address'  # Enter ip_address of EC2 instance
database = 'animedb'
username = 'postgres'
passwd = '123'
port_id = 5432
conn = None

try:
    with psycopg2.connect(host=hostname, dbname=database, user=username,
                          password=passwd, port=port_id) as conn:

        # cursor needed to execute commands in psql, stores values from psql operations
        with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:

            # psql commands/operations

            # drops & create table everytime the command is executed (avoid duplicates when code is re-run)
            cur.execute('DROP TABLE IF EXISTS animes')

            # Create table
            create_script = ''' CREATE TABLE IF NOT EXISTS animes (
                id SERIAL PRIMARY KEY, 
                name VARCHAR(50), 
                genre VARCHAR(50), 
                rating INT) '''
            cur.execute(create_script)

            # INSERT data in table
            insert_script = 'INSERT INTO animes (name, genre, rating) VALUES (%s, %s, %s)'
            insert_values = [('Blue Lock', 'Sports', 5),
                             ('Ninja Kamui', 'Action', 3), ('Horimiya', 'Romance', 5), ('Wind Breaker', 'Delinquent', 4)]
            # Best Method to insert multiple records into table: record holds each tuple of into to be inserted one by one (not all at once)
            for record in insert_values:
                cur.execute(insert_script, record)

            # DELETE data in table
            delete_script = 'DELETE FROM animes WHERE name = %s'
            delete_record = ('Ninja Kamui',)
            cur.execute(delete_script, delete_record)

            # UPDATE data in table
            update_script = 'UPDATE animes SET rating = rating + 1 WHERE name = %s'
            update_record = ('Wind Breaker',)
            cur.execute(update_script, update_record)

            # DISPLAY data in table
            # Best Method  to fetch data from db table: fetch all data from database table into python as a dictionary
            cur.execute('SELECT * FROM ANIMES')
            for record in cur.fetchall():
                print(record['name'], record['genre'])


# Display any connection error
except Exception as error:
    print(error)
# close conn(database connection if open)
finally:
    if conn is not None:
        conn.close()
