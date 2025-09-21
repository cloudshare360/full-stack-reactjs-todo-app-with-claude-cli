const Todo = require('../models/Todo');
const { validationResult } = require('express-validator');

// Get all todos
exports.getAllTodos = async (req, res) => {
  try {
    const { completed, priority, sort = '-createdAt' } = req.query;

    let filter = {};

    if (completed !== undefined) {
      filter.completed = completed === 'true';
    }

    if (priority) {
      filter.priority = priority;
    }

    const todos = await Todo.find(filter).sort(sort);

    res.json({
      success: true,
      count: todos.length,
      data: todos
    });
  } catch (error) {
    console.error('Error in getAllTodos:', error);
    res.status(500).json({
      success: false,
      error: 'Server Error'
    });
  }
};

// Get single todo
exports.getTodo = async (req, res) => {
  try {
    const todo = await Todo.findById(req.params.id);

    if (!todo) {
      return res.status(404).json({
        success: false,
        error: 'Todo not found'
      });
    }

    res.json({
      success: true,
      data: todo
    });
  } catch (error) {
    console.error('Error in getTodo:', error);

    if (error.name === 'CastError') {
      return res.status(404).json({
        success: false,
        error: 'Todo not found'
      });
    }

    res.status(500).json({
      success: false,
      error: 'Server Error'
    });
  }
};

// Create todo
exports.createTodo = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        error: 'Validation Error',
        details: errors.array()
      });
    }

    const todo = await Todo.create(req.body);

    res.status(201).json({
      success: true,
      data: todo
    });
  } catch (error) {
    console.error('Error in createTodo:', error);

    if (error.name === 'ValidationError') {
      const messages = Object.values(error.errors).map(err => err.message);
      return res.status(400).json({
        success: false,
        error: 'Validation Error',
        details: messages
      });
    }

    res.status(500).json({
      success: false,
      error: 'Server Error'
    });
  }
};

// Update todo
exports.updateTodo = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        error: 'Validation Error',
        details: errors.array()
      });
    }

    const todo = await Todo.findByIdAndUpdate(
      req.params.id,
      req.body,
      {
        new: true,
        runValidators: true
      }
    );

    if (!todo) {
      return res.status(404).json({
        success: false,
        error: 'Todo not found'
      });
    }

    res.json({
      success: true,
      data: todo
    });
  } catch (error) {
    console.error('Error in updateTodo:', error);

    if (error.name === 'CastError') {
      return res.status(404).json({
        success: false,
        error: 'Todo not found'
      });
    }

    if (error.name === 'ValidationError') {
      const messages = Object.values(error.errors).map(err => err.message);
      return res.status(400).json({
        success: false,
        error: 'Validation Error',
        details: messages
      });
    }

    res.status(500).json({
      success: false,
      error: 'Server Error'
    });
  }
};

// Delete todo
exports.deleteTodo = async (req, res) => {
  try {
    const todo = await Todo.findByIdAndDelete(req.params.id);

    if (!todo) {
      return res.status(404).json({
        success: false,
        error: 'Todo not found'
      });
    }

    res.json({
      success: true,
      message: 'Todo deleted successfully'
    });
  } catch (error) {
    console.error('Error in deleteTodo:', error);

    if (error.name === 'CastError') {
      return res.status(404).json({
        success: false,
        error: 'Todo not found'
      });
    }

    res.status(500).json({
      success: false,
      error: 'Server Error'
    });
  }
};

// Get todos statistics
exports.getTodosStats = async (req, res) => {
  try {
    const stats = await Todo.aggregate([
      {
        $group: {
          _id: '$completed',
          count: { $sum: 1 }
        }
      }
    ]);

    const priorityStats = await Todo.aggregate([
      {
        $group: {
          _id: '$priority',
          count: { $sum: 1 }
        }
      }
    ]);

    const totalTodos = await Todo.countDocuments();

    res.json({
      success: true,
      data: {
        total: totalTodos,
        completed: stats.find(stat => stat._id === true)?.count || 0,
        pending: stats.find(stat => stat._id === false)?.count || 0,
        byPriority: priorityStats.reduce((acc, stat) => {
          acc[stat._id] = stat.count;
          return acc;
        }, {})
      }
    });
  } catch (error) {
    console.error('Error in getTodosStats:', error);
    res.status(500).json({
      success: false,
      error: 'Server Error'
    });
  }
};