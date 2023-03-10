#  CSV to Sqlite

* Download a CSV file from remote URL and save in the file system under cachesDirectory. Report progress while downloading.

* The local file is streamed into memory, read and parsed line by line, then inserted into a Sqlite database in bulk.

* Report progress while database population.

* A search screen is provided to browse and search the database.


The project contains following modules:

*  Views: This module contains views/view controllers, etc. and corresponding view models for UI display.

* Data model: This module contains "Product" model structure.

* Generics: This module contains a "Observable" generic class used for binding views and view models for MVVM architecture. This is a closure based method for binding, which can be replaced with the Apple "Combine" framework if desired.

*  Utils: Utility helper to parse CSV files.

*  Services: This module contains network services including download service and file service.

*  Database: This module contains database operations.

*  Operation on Sqlite database is done using a swift wrapper of Sqlite: https://github.com/stephencelis/SQLite.swift


// TODO:
* Update deprecated APIs.

* Add more unit tests to increase code coverage.

* Current UI is minimal, design a more feature rich UI to inprove user experience. For example, current search screen is all-in-one, in the future this could be expanded for a better search experience. 

