# Pretator

A compass to point you to your nearest open Prêt à Manger. *Get to the Choc Bar!*

Data is derived from Jonty Wareing's [Pretadata][pretadata].

## Installation

Pretator is a fairly standard Rails application. It requires PostgresSQL as a datastore, with [PostGIS][postgis] installed in the database. Once you've configured your database, a quick `bundle` should be enough to install all dependencies.

[postgis]: http://postgis.net/
[pretadata]: https://github.com/Jonty/pretadata

## Data Ingest

Data is currently included in `/pretadata`. TODO: Tom, explain how to update this. (_I am really stupid with git subtrees_)

Once the `pretadata` repository is in `/pretdata`, running `rake full_ingest` from the application root will delete any existing Prets and store all the latest Prets in PostgresSQL.