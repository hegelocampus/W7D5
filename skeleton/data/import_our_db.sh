#!/usr/bin/env sh

dropdb meowtime
createdb meowtime
psql meowtime < data/import_db.sql
