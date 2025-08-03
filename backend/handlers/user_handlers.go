package handlers

import (
	"database/sql"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
	"goapi/database"
	"goapi/models"
)

// @Summary Create a new user
// @Description Creates a new user with the provided information
// @Tags Users
// @Accept json
// @Produce json
// @Param user body models.CreateUserRequest true "User data"
// @Success 201 {object} models.APIResponse
// @Failure 400 {object} models.APIResponse
// @Failure 409 {object} models.APIResponse
// @Router /users [post]
func CreateUserHandler(c *gin.Context) {
	var req models.CreateUserRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.APIResponse{
			Success: false,
			Message: "Invalid request data: " + err.Error(),
		})
		return
	}

	// Check if user already exists
	var existingID int
	err := database.GetDB().QueryRow("SELECT id FROM users WHERE email = $1", req.Email).Scan(&existingID)
	if err == nil {
		c.JSON(http.StatusConflict, models.APIResponse{
			Success: false,
			Message: "User with email " + req.Email + " already exists",
		})
		return
	} else if err != sql.ErrNoRows {
		c.JSON(http.StatusInternalServerError, models.APIResponse{
			Success: false,
			Message: "Database error",
		})
		return
	}

	// Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.APIResponse{
			Success: false,
			Message: "Error processing password",
		})
		return
	}

	// Set default values
	isActive := true
	if req.IsActive != nil {
		isActive = *req.IsActive
	}

	// Insert user
	var user models.User
	now := time.Now()
	err = database.GetDB().QueryRow(`
		INSERT INTO users (name, email, password, age, is_active, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
		RETURNING id, name, email, age, is_active, created_at, updated_at
	`, req.Name, req.Email, string(hashedPassword), req.Age, isActive, now, now).
		Scan(&user.ID, &user.Name, &user.Email, &user.Age, &user.IsActive, &user.CreatedAt, &user.UpdatedAt)

	if err != nil {
		c.JSON(http.StatusInternalServerError, models.APIResponse{
			Success: false,
			Message: "Error creating user",
		})
		return
	}

	c.JSON(http.StatusCreated, models.APIResponse{
		Success: true,
		Data:    user.ToUserResponse(),
	})
}

// @Summary Get all users
// @Description Retrieves a list of all users
// @Tags Users
// @Produce json
// @Success 200 {object} models.APIResponse
// @Router /users [get]
func GetAllUsersHandler(c *gin.Context) {
	rows, err := database.GetDB().Query(`
		SELECT id, name, email, age, is_active, created_at, updated_at
		FROM users
		ORDER BY created_at DESC
	`)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.APIResponse{
			Success: false,
			Message: "Error retrieving users",
		})
		return
	}
	defer rows.Close()

	var users []models.UserResponse
	for rows.Next() {
		var user models.User
		err := rows.Scan(&user.ID, &user.Name, &user.Email, &user.Age, &user.IsActive, &user.CreatedAt, &user.UpdatedAt)
		if err != nil {
			c.JSON(http.StatusInternalServerError, models.APIResponse{
				Success: false,
				Message: "Error scanning user data",
			})
			return
		}
		users = append(users, user.ToUserResponse())
	}

	c.JSON(http.StatusOK, models.APIResponse{
		Success: true,
		Data:    users,
	})
}

// @Summary Get user by ID
// @Description Retrieves a specific user by their ID
// @Tags Users
// @Produce json
// @Param id path int true "User ID"
// @Success 200 {object} models.APIResponse
// @Failure 404 {object} models.APIResponse
// @Router /users/{id} [get]
func GetUserByIDHandler(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, models.APIResponse{
			Success: false,
			Message: "Invalid user ID",
		})
		return
	}

	var user models.User
	err = database.GetDB().QueryRow(`
		SELECT id, name, email, age, is_active, created_at, updated_at
		FROM users WHERE id = $1
	`, id).Scan(&user.ID, &user.Name, &user.Email, &user.Age, &user.IsActive, &user.CreatedAt, &user.UpdatedAt)

	if err == sql.ErrNoRows {
		c.JSON(http.StatusNotFound, models.APIResponse{
			Success: false,
			Message: "User with ID " + strconv.Itoa(id) + " not found",
		})
		return
	} else if err != nil {
		c.JSON(http.StatusInternalServerError, models.APIResponse{
			Success: false,
			Message: "Error retrieving user",
		})
		return
	}

	c.JSON(http.StatusOK, models.APIResponse{
		Success: true,
		Data:    user.ToUserResponse(),
	})
}

// @Summary Update user
// @Description Updates an existing user's information
// @Tags Users
// @Accept json
// @Produce json
// @Param id path int true "User ID"
// @Param user body models.UpdateUserRequest true "User update data"
// @Success 200 {object} models.APIResponse
// @Failure 400 {object} models.APIResponse
// @Failure 404 {object} models.APIResponse
// @Failure 409 {object} models.APIResponse
// @Router /users/{id} [put]
func UpdateUserHandler(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, models.APIResponse{
			Success: false,
			Message: "Invalid user ID",
		})
		return
	}

	var req models.UpdateUserRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.APIResponse{
			Success: false,
			Message: "Invalid request data: " + err.Error(),
		})
		return
	}

	// Check if user exists
	var existingUser models.User
	err = database.GetDB().QueryRow(`
		SELECT id, name, email, age, is_active, created_at, updated_at
		FROM users WHERE id = $1
	`, id).Scan(&existingUser.ID, &existingUser.Name, &existingUser.Email, &existingUser.Age, &existingUser.IsActive, &existingUser.CreatedAt, &existingUser.UpdatedAt)

	if err == sql.ErrNoRows {
		c.JSON(http.StatusNotFound, models.APIResponse{
			Success: false,
			Message: "User with ID " + strconv.Itoa(id) + " not found",
		})
		return
	} else if err != nil {
		c.JSON(http.StatusInternalServerError, models.APIResponse{
			Success: false,
			Message: "Error retrieving user",
		})
		return
	}

	// Check email uniqueness if email is being updated
	if req.Email != nil && *req.Email != existingUser.Email {
		var existingID int
		err := database.GetDB().QueryRow("SELECT id FROM users WHERE email = $1", *req.Email).Scan(&existingID)
		if err == nil {
			c.JSON(http.StatusConflict, models.APIResponse{
				Success: false,
				Message: "Email " + *req.Email + " is already taken",
			})
			return
		} else if err != sql.ErrNoRows {
			c.JSON(http.StatusInternalServerError, models.APIResponse{
				Success: false,
				Message: "Database error",
			})
			return
		}
	}

	// Update fields
	if req.Name != nil {
		existingUser.Name = *req.Name
	}
	if req.Email != nil {
		existingUser.Email = *req.Email
	}
	if req.Age != nil {
		existingUser.Age = req.Age
	}
	if req.IsActive != nil {
		existingUser.IsActive = *req.IsActive
	}
	existingUser.UpdatedAt = time.Now()

	// Update in database
	_, err = database.GetDB().Exec(`
		UPDATE users 
		SET name = $1, email = $2, age = $3, is_active = $4, updated_at = $5
		WHERE id = $6
	`, existingUser.Name, existingUser.Email, existingUser.Age, existingUser.IsActive, existingUser.UpdatedAt, id)

	if err != nil {
		c.JSON(http.StatusInternalServerError, models.APIResponse{
			Success: false,
			Message: "Error updating user",
		})
		return
	}

	c.JSON(http.StatusOK, models.APIResponse{
		Success: true,
		Data:    existingUser.ToUserResponse(),
	})
}

// @Summary Delete user
// @Description Deletes a user by their ID
// @Tags Users
// @Produce json
// @Param id path int true "User ID"
// @Success 200 {object} models.APIResponse
// @Failure 404 {object} models.APIResponse
// @Router /users/{id} [delete]
func DeleteUserHandler(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, models.APIResponse{
			Success: false,
			Message: "Invalid user ID",
		})
		return
	}

	// Check if user exists
	var userID int
	err = database.GetDB().QueryRow("SELECT id FROM users WHERE id = $1", id).Scan(&userID)
	if err == sql.ErrNoRows {
		c.JSON(http.StatusNotFound, models.APIResponse{
			Success: false,
			Message: "User with ID " + strconv.Itoa(id) + " not found",
		})
		return
	} else if err != nil {
		c.JSON(http.StatusInternalServerError, models.APIResponse{
			Success: false,
			Message: "Error checking user existence",
		})
		return
	}

	// Delete user
	_, err = database.GetDB().Exec("DELETE FROM users WHERE id = $1", id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.APIResponse{
			Success: false,
			Message: "Error deleting user",
		})
		return
	}

	c.JSON(http.StatusOK, models.APIResponse{
		Success: true,
		Message: "User deleted successfully",
	})
} 