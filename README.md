#  PredictSpring POS App Exercise

Mobile Product Catalog
Your objective is to make a Mobile Product Catalog app to demonstrate downloading a large data file.. The app downloads a large file, CSV, containing more than 2 million rows, processes them by columns and finally inserts into a local SQLite database.
A simple UI with a search bar that allows the app users to search the product catalog with product ID and display the results in a table view cell.
Send an email to sandilya@predictspring.com if you have any questions
Requirements
1. Use an iPad/iPhone and Swift language
2. The iOS app takes the file name as input.
3. The app streams the file into memory or a local file
4. Process the file for records by parsing the rows and columns
5. Insert records into SQLite database
6. Provide stats on progress while processing the file.
7. Provide a single screen to search products from the db
8. Display the products in a table view. (You can display 10 or 20 at a time and support
scroll)
Deliverables
1. The application project folder archive
2. A simple design doc for the application logic
3. Test cases


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

