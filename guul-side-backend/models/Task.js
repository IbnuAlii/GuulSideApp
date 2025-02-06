const mongoose = require("mongoose")

const taskSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    name: { type: String, required: true },
    category: {
      name: { type: String, required: true },
      icon: { type: String, required: true },
      color: { type: String, required: true },
    },
    startDate: { type: Date, required: true },
    endDate: { type: Date, required: true },
    priority: {
      value: { type: Number, required: true },
      isDefault: { type: Boolean, required: true },
    },
    note: { type: String },
    completed: { type: Boolean, default: false },
    completedAt: { type: Date },
  },
  { timestamps: true },
)

// Add index to improve query performance
taskSchema.index({ userId: 1 });

module.exports = mongoose.model("Task", taskSchema)