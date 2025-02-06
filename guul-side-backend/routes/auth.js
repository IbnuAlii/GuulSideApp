const express = require("express")
const router = express.Router()
const bcrypt = require("bcryptjs")
const jwt = require("jsonwebtoken")
const auth = require("../middleware/auth")
const User = require("../models/user")
const rateLimit = require("express-rate-limit")

// Rate limiting setup
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // Limit each IP to 5 requests per windowMs
  message: "Too many attempts from this IP, please try again after 15 minutes"
})

// Apply rate limiting to auth routes
router.use("/signup", authLimiter)
router.use("/signin", authLimiter)

// @route   POST api/auth/signup
// @desc    Register a user
// @access  Public
router.post("/signup", async (req, res) => {
  console.log("Signup request received:", req.body.email)
  try {
    const { name, email, password } = req.body

    // Validate input
    if (!name || !email || !password) {
      return res.status(400).json({ message: "Please provide all required fields" })
    }

    // Check if user exists
    let user = await User.findOne({ email })
    if (user) {
      return res.status(400).json({ message: "User already exists" })
    }

    // Create new user
    user = new User({
      name,
      email,
      password,
    })

    // Hash password
    const salt = await bcrypt.genSalt(10)
    user.password = await bcrypt.hash(password, salt)

    // Save user
    await user.save()
    console.log("User saved successfully:", user.email)

    // Create token payload
    const payload = {
      user: {
        id: user.id,
      },
    }

    // Generate token
    jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: "24h" }, (err, token) => {
      if (err) {
        console.error("Token generation error:", err)
        throw err
      }
      res.status(201).json({ token })
    })
  } catch (err) {
    console.error("Signup error:", err.message, err.stack)
    res.status(500).json({ message: "Server error during signup", error: err.message })
  }
})

// @route   POST api/auth/signin
// @desc    Authenticate user & get token
// @access  Public
router.post("/signin", async (req, res) => {
  console.log("Signin request received:", req.body.email)
  try {
    const { email, password } = req.body

    // Validate input
    if (!email || !password) {
      return res.status(400).json({ message: "Please provide email and password" })
    }

    // Check if user exists
    const user = await User.findOne({ email })
    if (!user) {
      return res.status(400).json({ message: "Invalid credentials" })
    }

    // Verify password
    const isMatch = await bcrypt.compare(password, user.password)
    if (!isMatch) {
      return res.status(400).json({ message: "Invalid credentials" })
    }

    console.log("User authenticated successfully:", user.email)

    // Create token payload
    const payload = {
      user: {
        id: user.id,
      },
    }

    // Generate token
    jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: "24h" }, (err, token) => {
      if (err) {
        console.error("Token generation error:", err)
        throw err
      }
      res.json({ token })
    })
  } catch (err) {
    console.error("Signin error:", err.message, err.stack)
    res.status(500).json({ message: "Server error during signin", error: err.message })
  }
})

// @route   POST api/auth/signout
// @desc    Sign out user (optional server-side logout)
// @access  Private
router.post("/signout", auth, async (req, res) => {
  try {
    // Here you could implement additional logout logic if needed
    // For example, invalidating the token on the server side
    res.json({ message: "Signout successful" })
  } catch (err) {
    console.error("Signout error:", err.message)
    res.status(500).json({ message: "Server error during signout" })
  }
})

// @route   GET api/auth/me
// @desc    Get logged in user
// @access  Private
router.get("/me", auth, async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select("-password")
    res.json(user)
  } catch (err) {
    console.error("Get user error:", err.message)
    res.status(500).json({ message: "Server error getting user data" })
  }
})

// @route   GET api/auth/verify
// @desc    Verify token
// @access  Public
router.get("/verify", async (req, res) => {
  try {
    const token = req.header("Authorization")?.replace("Bearer ", "")
    if (!token) {
      return res.status(401).json({ message: "No token, authorization denied" })
    }

    jwt.verify(token, process.env.JWT_SECRET)
    res.status(200).json({ valid: true })
  } catch (err) {
    res.status(401).json({ message: "Token is not valid" })
  }
})

// @route   GET api/auth/profile
// @desc    Get user profile
// @access  Private
router.get("/profile", auth, async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select("-password")
    if (!user) {
      return res.status(404).json({ message: "User not found" })
    }
    res.json(user)
  } catch (err) {
    console.error("Error fetching user profile:", err)
    res.status(500).json({ message: "Server error fetching profile" })
  }
})

// @route   PUT api/auth/profile
// @desc    Update user profile
// @access  Private
router.put("/profile", auth, async (req, res) => {
  try {
    const { name, email, phone, location } = req.body

    // Build profile object
    const profileFields = {}
    if (name) profileFields.name = name
    if (email) profileFields.email = email
    if (phone) profileFields.phone = phone
    if (location) profileFields.location = location

    let user = await User.findById(req.user.id)
    if (!user) {
      return res.status(404).json({ message: "User not found" })
    }

    // Update user
    user = await User.findByIdAndUpdate(req.user.id, { $set: profileFields }, { new: true }).select("-password")

    res.json(user)
  } catch (err) {
    console.error("Error updating user profile:", err)
    res.status(500).json({ message: "Server error updating profile" })
  }
})

// @route   POST api/auth/profile/image
// @desc    Upload profile image
// @access  Private
router.post("/profile/image", auth, async (req, res) => {
  try {
    // Handle image upload logic here
    // For now, we'll just update the imageUrl field
    const imageUrl = req.body.imageUrl // You'll need to implement actual image upload

    const user = await User.findByIdAndUpdate(req.user.id, { $set: { imageUrl } }, { new: true }).select("-password")

    if (!user) {
      return res.status(404).json({ message: "User not found" })
    }

    res.json({ imageUrl: user.imageUrl })
  } catch (err) {
    console.error("Error uploading profile image:", err)
    res.status(500).json({ message: "Server error uploading image" })
  }
})

module.exports = router