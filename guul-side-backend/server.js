const express = require("express")
const mongoose = require("mongoose")
const cors = require("cors")
const path = require("path")
require("dotenv").config({ path: path.resolve(__dirname, ".env") })

const app = express()

// Middleware
app.use(
  cors({
    origin: process.env.NODE_ENV === "production" ? process.env.ALLOWED_ORIGIN : "*",
    methods: ["GET", "POST", "PUT", "DELETE", "PATCH"],
    allowedHeaders: ["Content-Type", "Authorization"],
  }),
)
app.use(express.json({ limit: '1mb' })) // Limit request body size to 1MB

// Set strictQuery to false
mongoose.set("strictQuery", false)

// MongoDB Connection with increased timeout
const connectDB = async () => {
  try {
    console.log("Attempting to connect to MongoDB...")

    if (!process.env.MONGODB_URI) {
      throw new Error("MONGODB_URI is not defined in environment variables")
    }

    await mongoose.connect(process.env.MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
      serverSelectionTimeoutMS: 10000, // Increase timeout to 10 seconds
      socketTimeoutMS: 45000, // Increase socket timeout to 45 seconds
      connectTimeoutMS: 10000, // Add connection timeout
    })

    console.log("MongoDB Connected Successfully")
  } catch (err) {
    console.error("MongoDB Connection Error:", err.message)
    // Instead of exiting, we'll throw the error to be caught by the error handling middleware
    throw err
  }
}

// Connect to MongoDB
connectDB().catch(err => {
  console.error("Failed to connect to MongoDB", err)
  process.exit(1)
})

// Routes
const authRoutes = require("./routes/auth")
const taskRoutes = require("./routes/tasks")

// API Routes with timeout handling
const timeoutMiddleware = (req, res, next) => {
  res.setTimeout(30000, () => {
    res.status(408).send("Request Timeout")
  })
  next()
}

app.use(timeoutMiddleware)
app.use("/api/auth", authRoutes)
app.use("/api/tasks", taskRoutes)

// Welcome route
app.get("/", (req, res) => {
  res.send("Welcome to Guul Side API")
})

// Error handling middleware
app.use((err, req, res, next) => {
  console.error("Error details:", err.message, err.stack)
  res.status(err.status || 500).json({
    message: err.message || "An unexpected error occurred",
    status: err.status || 500,
    error: process.env.NODE_ENV === "development" ? err.stack : undefined,
  })
})

// Handle 404 routes
app.use((req, res) => {
  res.status(404).json({ message: `Route ${req.originalUrl} not found` })
})

// Start server
const PORT = process.env.PORT || 3000
let server = app.listen(PORT, "0.0.0.0", () => {
  // Listen on all network interfaces
  console.log(`Server is running on port ${PORT}`)
})

// Increase timeout for the server
server.timeout = 30000 // 30 seconds

// Handle server errors
server.on("error", (e) => {
  if (e.code === "EADDRINUSE") {
    console.log("Address in use, retrying...")
    setTimeout(() => {
      server.close()
      server = app.listen(PORT, "0.0.0.0")
    }, 1000)
  }
})

// Graceful shutdown
process.on("SIGTERM", () => {
  console.log("SIGTERM received. Shutting down gracefully...")
  server.close(() => {
    mongoose.connection.close(false, () => {
      console.log("Process terminated")
      process.exit(0)
    })
  })
})