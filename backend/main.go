package main

import (
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	_ "github.com/lib/pq"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
	"goapi/database"
	"goapi/handlers"
	_ "goapi/docs"
)

// @title Go CRUD API
// @version 1.0
// @description A simple CRUD API built with Go and PostgreSQL
// @contact.name API Support
// @contact.email support@example.com
// @host localhost:8080
// @BasePath /api

var db *sql.DB

// CORS middleware function
func corsMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		origin := c.Request.Header.Get("Origin")
		
		// For development, allow all localhost origins
		if origin == "http://localhost:5173" || origin == "http://127.0.0.1:5173" {
			c.Header("Access-Control-Allow-Origin", origin)
			c.Header("Access-Control-Allow-Credentials", "true")
		} else {
			// For other origins, allow without credentials
			c.Header("Access-Control-Allow-Origin", "*")
			c.Header("Access-Control-Allow-Credentials", "false")
		}
		
		c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS")
		c.Header("Access-Control-Allow-Headers", "Origin, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, Accept")
		c.Header("Access-Control-Expose-Headers", "Content-Length, Access-Control-Allow-Origin, Access-Control-Allow-Headers, Cache-Control, Content-Language, Content-Type")
		
		// Handle preflight requests
		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}
		
		c.Next()
	}
}

func main() {
	// Initialize database connection
	initDB()
	defer db.Close()

	// Set database connection for handlers
	database.SetDB(db)

	// Set Gin mode
	gin.SetMode(gin.ReleaseMode)

	// Create router
	r := gin.Default()

	// Add CORS middleware
	r.Use(corsMiddleware())

	// Health check endpoint
	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status":  "ok",
			"message": "Service is running",
			"time":    time.Now().Format(time.RFC3339),
		})
	})

	// Root endpoint
	r.GET("/", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "Welcome to Go API",
			"version": "1.0.0",
			"docs":    "/api/swagger/index.html",
		})
	})

	// API routes
	api := r.Group("/api")
	{
		// Redirect /api to Swagger documentation
		api.GET("", func(c *gin.Context) {
			c.Redirect(http.StatusMovedPermanently, "/api/swagger/index.html")
		})
		api.HEAD("", func(c *gin.Context) {
			c.Redirect(http.StatusMovedPermanently, "/api/swagger/index.html")
		})
		
		// Swagger documentation
		api.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

		// Auth routes
		auth := api.Group("/auth")
		{
			auth.POST("/login", handlers.LoginHandler)
			auth.POST("/signup", handlers.SignupHandler)
		}

		// User routes
		users := api.Group("/users")
		{
			users.POST("", handlers.CreateUserHandler)
			users.POST("/", handlers.CreateUserHandler)
			users.GET("", handlers.GetAllUsersHandler)
			users.GET("/", handlers.GetAllUsersHandler)
			users.GET("/:id", handlers.GetUserByIDHandler)
			users.PUT("/:id", handlers.UpdateUserHandler)
			users.PATCH("/:id", handlers.UpdateUserHandler)
			users.DELETE("/:id", handlers.DeleteUserHandler)
		}
	}

	// Get port from environment or use default
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Server starting on port %s", port)
	log.Fatal(r.Run(":" + port))
}

func initDB() {
	// Get database connection details from environment variables
	dbHost := getEnv("DATABASE_HOST", "localhost")
	dbPort := getEnv("DATABASE_PORT", "5432")
	dbName := getEnv("DATABASE_NAME", "test_db")
	dbUser := getEnv("DATABASE_USER", "postgres")
	dbPassword := getEnv("DATABASE_PASSWORD", "password")

	// Create connection string
	connStr := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		dbHost, dbPort, dbUser, dbPassword, dbName)

	var err error
	db, err = sql.Open("postgres", connStr)
	if err != nil {
		log.Fatal("Error opening database connection:", err)
	}

	// Test the connection
	err = db.Ping()
	if err != nil {
		log.Fatal("Error connecting to database:", err)
	}

	log.Println("Successfully connected to database")

	// Create users table if it doesn't exist
	createTableSQL := `
	CREATE TABLE IF NOT EXISTS users (
		id SERIAL PRIMARY KEY,
		name VARCHAR(100) NOT NULL,
		email VARCHAR(255) NOT NULL UNIQUE,
		password VARCHAR(255) NOT NULL,
		age INTEGER,
		is_active BOOLEAN DEFAULT TRUE,
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	);`

	_, err = db.Exec(createTableSQL)
	if err != nil {
		log.Fatal("Error creating users table:", err)
	}

	log.Println("Users table ready")
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
} 