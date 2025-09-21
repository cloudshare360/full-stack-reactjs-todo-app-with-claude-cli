const express = require('express');
const {
  getAllTodos,
  getTodo,
  createTodo,
  updateTodo,
  deleteTodo,
  getTodosStats
} = require('../controllers/todoController');
const { validateCreateTodo, validateUpdateTodo } = require('../middleware/validation');

const router = express.Router();

// Routes
router.route('/')
  .get(getAllTodos)
  .post(validateCreateTodo, createTodo);

router.route('/stats')
  .get(getTodosStats);

router.route('/:id')
  .get(getTodo)
  .put(validateUpdateTodo, updateTodo)
  .delete(deleteTodo);

module.exports = router;