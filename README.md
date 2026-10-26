
# Rich Social

A small desktop social app written in C++ with wxWidgets and PostgreSQL.
I built it to try a new GUI library and to practice C++ on a project with a 
real database behind it.

## Features

- Register and log in, with passwords hashed using Argon2id
- Registration fields validated in the UI, in C++, and by database constraints
- City autocomplete backed by a GeoNames table
- Post short messages (up to 500 characters)
- Search for users, follow and unfollow them
- Home feed showing your posts and the posts of people you follow

## Tech

C++20, wxWidgets, PostgreSQL 16 (Docker), libpqxx, Argon2

## Design notes

- A repository interface separates the GUI code from the database code.
- All SQL uses bound parameters.
- Passwords are never stored or compared in plain text.

## Running it

Tested on macOS only. The code uses cross-platform libraries, but the build script assumes macOS with Homebrew.

You need wxWidgets, libpqxx, libpq and argon2 (installed with Homebrew on macOS).

```
brew install wxwidgets libpqxx libpq argon2 
```

1. Start PostgreSQL:
   ```
   docker run --name login-app-db -e POSTGRES_PASSWORD=<password> -e POSTGRES_DB=login_app -p 5432:5432 -d postgres:16
   ```
	
2. Create the tables:
   ```
   docker cp db/schema.sql login-app-db:/tmp/schema.sql
   docker exec -it login-app-db psql -U postgres -d login_app -f /tmp/schema.sql
   ```

3. Download the GeoNames `cities5000` file and copy it into the container:
   ```
   curl -O https://download.geonames.org/export/dump/cities5000.zip
   unzip cities5000.zip
   docker cp cities5000.txt login-app-db:/tmp/cities5000.txt
   ```
	
   Then open `psql` (`docker exec -it login-app-db psql -U postgres -d login_app`) and run:
   ```sql
   CREATE TABLE geonames_raw (
	geonameid integer, name text, asciiname text, alternatenames text,
	latitude text, longitude text, feature_class text, feature_code text,
	country_code text, cc2 text, admin1_code text, admin2_code text,
	admin3_code text, admin4_code text, population bigint, elevation text,
	dem text, timezone text, modification_date text		
   );
   \copy geonames_raw FROM '/tmp/cities5000.txt'
   INSERT INTO cities (label)
   SELECT concat_ws(', ', asciiname, NULLIF(admin1_code, ''), country_code)
   FROM geonames_raw ON CONFLICT DO NOTHING;
   DROP TABLE geonames_raw;
   ```

4. Set the connection string:
   ```
   export LOGIN_APP_DB="host=localhost port=5432 dbname=login_app user=postgres password=<password>"
   ```

5. Build and run:
   ```
   ./build_login.sh
   ./login
   ```

## Data
This project uses data from GeoNames (https://www.geonames.org), licensed under CC BY 4.0.

## Limitations

Likes, comments and profile pages are not implemented. Post times are shown in UTC.


