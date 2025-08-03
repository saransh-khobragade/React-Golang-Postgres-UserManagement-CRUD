package database

import "database/sql"

var db *sql.DB

// SetDB sets the database connection
func SetDB(database *sql.DB) {
	db = database
}

// GetDB returns the database connection
func GetDB() *sql.DB {
	return db
} 