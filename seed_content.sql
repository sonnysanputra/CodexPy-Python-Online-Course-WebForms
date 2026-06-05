-- ===================================================================
-- CodexPy — Content seed
-- Adds lessons, quizzes, and MCQ questions to the 6 starter modules.
-- Run this in the Supabase SQL Editor.
--
-- Idempotency: this script does NOT clean up before inserting.
-- If you want to start fresh, uncomment the DELETE block below.
-- ===================================================================

-- Optional cleanup (uncomment if you want to wipe existing content):
-- DELETE FROM questions;
-- DELETE FROM quizzes;
-- DELETE FROM lessons;

-- ===================================================================
-- LESSONS — 3 per module
-- ===================================================================

-- Module 1: Variables and Data Types ---------------------------------
INSERT INTO lessons (module_id, title, content, sort_order) VALUES
((SELECT id FROM modules WHERE title = 'Variables and Data Types'),
 'What is a variable?',
 $$A variable is a name that refers to a value stored in memory. In Python, you create a variable by assigning a value to a name using the equals sign (=).

For example:
  age = 20
  name = "Alice"
  pi = 3.14

Here, age, name, and pi are variables that store the values 20, "Alice", and 3.14 respectively.

Variable names should be descriptive. Use lowercase letters and underscores for multi-word names (this is called snake_case in Python):
  student_count = 30
  is_logged_in = True

Variables can be reassigned. The new value replaces the old one:
  age = 20
  age = 21    # age is now 21$$, 1),

((SELECT id FROM modules WHERE title = 'Variables and Data Types'),
 'Numbers in Python',
 $$Python has two main number types:

1. Integers (int) — whole numbers, no decimal point
   examples: 5, -3, 1000, 0

2. Floats (float) — numbers with a decimal point
   examples: 3.14, -0.5, 2.0

You can do arithmetic with both:
  total = 10 + 5       # 15 (int)
  average = 10 / 3     # 3.333... (float)
  power = 2 ** 8       # 256 (int)
  remainder = 17 % 5   # 2 (int)

Division with / always returns a float. Use // for integer division (drops the decimal):
  10 / 3    # 3.333...
  10 // 3   # 3$$, 2),

((SELECT id FROM modules WHERE title = 'Variables and Data Types'),
 'Strings and Booleans',
 $$Strings represent text. Create them with single or double quotes:
  name = "Alice"
  greeting = 'Hello, world!'

Combine strings with +:
  first = "Hello"
  last = "World"
  message = first + " " + last     # "Hello World"

Use len() to count characters:
  len("python")    # 6

Booleans represent True or False — the foundation of decision-making:
  is_logged_in = True
  is_admin = False

Comparisons produce booleans:
  5 > 3       # True
  10 == 5     # False
  "a" != "b"  # True$$, 3);

-- Module 2: Control Flow ---------------------------------------------
INSERT INTO lessons (module_id, title, content, sort_order) VALUES
((SELECT id FROM modules WHERE title = 'Control Flow'),
 'If statements',
 $$The if statement runs code only when a condition is True:

  age = 18
  if age >= 18:
      print("You can vote!")

The colon (:) and indentation matter — Python uses indentation (4 spaces by convention) to group code into blocks. Other languages use braces { } but Python uses whitespace.

Add an else branch for the "otherwise" case:
  age = 15
  if age >= 18:
      print("You can vote.")
  else:
      print("Too young to vote.")$$, 1),

((SELECT id FROM modules WHERE title = 'Control Flow'),
 'Elif and chained conditions',
 $$When there are more than two paths, use elif (short for "else if"):

  score = 85

  if score >= 90:
      grade = "A"
  elif score >= 80:
      grade = "B"
  elif score >= 70:
      grade = "C"
  else:
      grade = "F"

  print(grade)     # "B"

Python checks conditions top-down. The first True one wins — the rest are skipped, even if they'd also be True.$$, 2),

((SELECT id FROM modules WHERE title = 'Control Flow'),
 'Comparison and logical operators',
 $$Comparison operators (return True or False):
  ==   equal to
  !=   not equal to
  <    less than
  >    greater than
  <=   less than or equal
  >=   greater than or equal

Logical operators combine conditions:
  and   both must be True
  or    at least one must be True
  not   reverses True/False

Combined example:
  age = 25
  has_license = True
  if age >= 18 and has_license:
      print("You can drive.")$$, 3);

-- Module 3: Loops & Iteration ----------------------------------------
INSERT INTO lessons (module_id, title, content, sort_order) VALUES
((SELECT id FROM modules WHERE title = 'Loops & Iteration'),
 'For loops',
 $$A for loop repeats code for each item in a sequence:

  fruits = ["apple", "banana", "cherry"]
  for fruit in fruits:
      print(fruit)

This prints each fruit on its own line.

To loop a specific number of times, use range():
  for i in range(5):
      print(i)     # 0, 1, 2, 3, 4

range(start, stop, step) gives more control:
  for i in range(2, 10, 2):
      print(i)     # 2, 4, 6, 8$$, 1),

((SELECT id FROM modules WHERE title = 'Loops & Iteration'),
 'While loops',
 $$A while loop repeats as long as a condition is True:

  count = 0
  while count < 5:
      print(count)
      count = count + 1

This prints 0 through 4. Be careful — if the condition never becomes False, the loop runs forever (an "infinite loop").

Use while when you do not know in advance how many iterations you need:
  password = ""
  while password != "secret":
      password = input("Enter password: ")
  print("Welcome!")$$, 2),

((SELECT id FROM modules WHERE title = 'Loops & Iteration'),
 'Break and continue',
 $$break exits a loop early:
  for n in range(100):
      if n == 5:
          break
      print(n)     # prints 0-4, then stops

continue skips the rest of the current iteration and jumps to the next one:
  for n in range(10):
      if n % 2 == 0:
          continue       # skip even numbers
      print(n)           # prints 1, 3, 5, 7, 9$$, 3);

-- Module 4: Functions ------------------------------------------------
INSERT INTO lessons (module_id, title, content, sort_order) VALUES
((SELECT id FROM modules WHERE title = 'Functions'),
 'Defining functions',
 $$A function is a reusable block of code. Define one with the def keyword:

  def greet():
      print("Hello!")

To "call" (run) the function, write its name with parentheses:
  greet()     # prints "Hello!"
  greet()     # prints "Hello!" again

Functions help you:
- Avoid repeating code
- Organize a program into manageable chunks
- Give meaningful names to operations$$, 1),

((SELECT id FROM modules WHERE title = 'Functions'),
 'Parameters and arguments',
 $$Functions can accept inputs called parameters:

  def greet(name):
      print("Hello, " + name + "!")

  greet("Alice")     # "Hello, Alice!"
  greet("Bob")       # "Hello, Bob!"

Parameters: the names inside the def parentheses.
Arguments: the actual values you pass when calling.

Multiple parameters:
  def add(a, b):
      print(a + b)
  add(3, 5)     # prints 8$$, 2),

((SELECT id FROM modules WHERE title = 'Functions'),
 'Return values and scope',
 $$The return keyword sends a value back to the caller:

  def square(n):
      return n * n

  result = square(5)
  print(result)     # 25

  total = square(3) + square(4)    # 9 + 16 = 25

Without an explicit return, a function returns None.

Variables defined inside a function only exist inside that function (this is called scope):
  def f():
      x = 10
      print(x)

  f()
  print(x)     # NameError - x does not exist out here$$, 3);

-- Module 5: Lists & Dictionaries -------------------------------------
INSERT INTO lessons (module_id, title, content, sort_order) VALUES
((SELECT id FROM modules WHERE title = 'Lists & Dictionaries'),
 'Lists basics',
 $$A list is an ordered collection. Create one with square brackets:

  fruits = ["apple", "banana", "cherry"]
  numbers = [1, 2, 3, 4, 5]
  mixed = [1, "two", 3.0, True]    # different types are OK

Access items by index (counting from 0):
  fruits[0]     # "apple"
  fruits[1]     # "banana"
  fruits[-1]    # "cherry" (negative indices count from the end)

Get the length:
  len(fruits)   # 3$$, 1),

((SELECT id FROM modules WHERE title = 'Lists & Dictionaries'),
 'List operations',
 $$Lists are mutable - you can change them after creation.

Add items:
  fruits = ["apple", "banana"]
  fruits.append("cherry")        # adds to end
  fruits.insert(0, "mango")      # inserts at index 0

Remove items:
  fruits.remove("banana")        # removes first match
  fruits.pop()                   # removes & returns last item

Modify by index:
  fruits[0] = "kiwi"             # replaces first item

Slice to get a portion:
  numbers = [1, 2, 3, 4, 5]
  numbers[1:4]    # [2, 3, 4]
  numbers[:3]     # [1, 2, 3]
  numbers[2:]     # [3, 4, 5]$$, 2),

((SELECT id FROM modules WHERE title = 'Lists & Dictionaries'),
 'Dictionaries',
 $$A dictionary stores key-value pairs. Create with curly braces:

  student = {
      "name": "Alice",
      "age": 20,
      "grade": "A"
  }

Access values by key:
  student["name"]      # "Alice"

Add or update:
  student["email"] = "alice@example.com"   # new key
  student["age"] = 21                       # update existing

Check if a key exists:
  "name" in student     # True
  "phone" in student    # False

Iterate over key-value pairs:
  for key, value in student.items():
      print(key, "=", value)$$, 3);

-- Module 6: OOP Basics -----------------------------------------------
INSERT INTO lessons (module_id, title, content, sort_order) VALUES
((SELECT id FROM modules WHERE title = 'OOP Basics'),
 'Classes and objects',
 $$A class is a blueprint for creating objects. Objects are instances of a class.

  class Dog:
      def __init__(self, name, breed):
          self.name = name
          self.breed = breed

  my_dog = Dog("Buddy", "Golden Retriever")
  print(my_dog.name)    # "Buddy"
  print(my_dog.breed)   # "Golden Retriever"

__init__ is the special "constructor" method that runs when a new object is created.

self refers to the instance being created or used.

Each object has its own attributes (data).$$, 1),

((SELECT id FROM modules WHERE title = 'OOP Basics'),
 'Methods',
 $$Methods are functions defined inside a class. They define what objects can do.

  class Dog:
      def __init__(self, name):
          self.name = name

      def bark(self):
          print(self.name + " says: Woof!")

      def fetch(self, item):
          print(self.name + " fetches the " + item)

  buddy = Dog("Buddy")
  buddy.bark()           # "Buddy says: Woof!"
  buddy.fetch("ball")    # "Buddy fetches the ball"

self is always the first parameter of a method.$$, 2),

((SELECT id FROM modules WHERE title = 'OOP Basics'),
 'Inheritance',
 $$Inheritance lets a class derive attributes and methods from another class:

  class Animal:
      def __init__(self, name):
          self.name = name
      def speak(self):
          print(self.name + " makes a sound")

  class Dog(Animal):       # Dog inherits from Animal
      def speak(self):
          print(self.name + " barks")   # overrides parent

  class Cat(Animal):
      def speak(self):
          print(self.name + " meows")

  Dog("Rex").speak()       # "Rex barks"
  Cat("Whiskers").speak()  # "Whiskers meows"

Inheritance avoids duplication and creates organized hierarchies.$$, 3);


-- ===================================================================
-- QUIZZES — one checkpoint quiz per module
-- ===================================================================

INSERT INTO quizzes (module_id, title, description, time_limit_seconds) VALUES
((SELECT id FROM modules WHERE title = 'Variables and Data Types'),
 'Variables Checkpoint', 'Quick check on Python variables, numbers, strings, and booleans.', 300),
((SELECT id FROM modules WHERE title = 'Control Flow'),
 'Control Flow Checkpoint', 'Test your understanding of if / elif / else.', 300),
((SELECT id FROM modules WHERE title = 'Loops & Iteration'),
 'Loops Checkpoint', 'Practice with for, while, range, break, continue.', 300),
((SELECT id FROM modules WHERE title = 'Functions'),
 'Functions Checkpoint', 'Functions, parameters, arguments, and return values.', 300),
((SELECT id FROM modules WHERE title = 'Lists & Dictionaries'),
 'Lists & Dicts Checkpoint', 'Indexing, slicing, mutation, and key/value access.', 300),
((SELECT id FROM modules WHERE title = 'OOP Basics'),
 'OOP Checkpoint', 'Classes, objects, methods, and inheritance.', 300);


-- ===================================================================
-- QUESTIONS — 4 MCQ per quiz
-- ===================================================================

-- Quiz 1: Variables ---------------------------------------------------
INSERT INTO questions (quiz_id, prompt, kind, options_json, correct_answer, explanation, points, sort_order) VALUES
((SELECT id FROM quizzes WHERE title = 'Variables Checkpoint' LIMIT 1),
 'What is the output of print(type(3.14))?', 'mcq',
 $$["<class 'int'>", "<class 'float'>", "<class 'str'>", "<class 'decimal'>"]$$,
 1, '3.14 is a floating-point literal, so its type is float.', 10, 1),

((SELECT id FROM quizzes WHERE title = 'Variables Checkpoint' LIMIT 1),
 'Which is a valid Python variable name?', 'mcq',
 $$["2nd_place", "student name", "student_name", "student-name"]$$,
 2, 'Variable names can contain letters, digits, and underscores, but cannot start with a digit or contain spaces or hyphens.', 10, 2),

((SELECT id FROM quizzes WHERE title = 'Variables Checkpoint' LIMIT 1),
 'What does len("hello") return?', 'mcq',
 $$["4", "5", "6", "hello"]$$,
 1, 'len() returns the number of characters. "hello" has 5 characters.', 10, 3),

((SELECT id FROM quizzes WHERE title = 'Variables Checkpoint' LIMIT 1),
 'What is the result of 10 // 3 ?', 'mcq',
 $$["3.33", "3.0", "3", "4"]$$,
 2, '// is integer division - it drops the decimal part and returns a whole number.', 10, 4);

-- Quiz 2: Control Flow ------------------------------------------------
INSERT INTO questions (quiz_id, prompt, kind, options_json, correct_answer, explanation, points, sort_order) VALUES
((SELECT id FROM quizzes WHERE title = 'Control Flow Checkpoint' LIMIT 1),
 'What does the == operator do in Python?', 'mcq',
 $$["Assigns a value", "Checks if two values are equal", "Declares a new variable", "Same as ="]$$,
 1, '= is assignment. == is comparison (checks equality and returns True/False).', 10, 1),

((SELECT id FROM quizzes WHERE title = 'Control Flow Checkpoint' LIMIT 1),
 'Why does this code raise an error?  if x > 5: print("big")', 'mcq',
 $$["It does not raise an error", "Missing parentheses around x > 5", "The print statement should be indented under the if", "Missing semicolon"]$$,
 2, 'Python uses indentation to define code blocks. The print line must be indented (usually 4 spaces) under the if.', 10, 2),

((SELECT id FROM quizzes WHERE title = 'Control Flow Checkpoint' LIMIT 1),
 'Given score = 75, which grade is assigned by:  if >=90 A; elif >=80 B; elif >=70 C; else F ?', 'mcq',
 $$["A", "B", "C", "F"]$$,
 2, '75 is not >= 90 or 80, but it IS >= 70, so the third branch matches.', 10, 3),

((SELECT id FROM quizzes WHERE title = 'Control Flow Checkpoint' LIMIT 1),
 'Which expression evaluates to True?', 'mcq',
 $$["5 > 10", "\"a\" == \"A\"", "not False", "True and False"]$$,
 2, 'not False inverts False to True.', 10, 4);

-- Quiz 3: Loops -------------------------------------------------------
INSERT INTO questions (quiz_id, prompt, kind, options_json, correct_answer, explanation, points, sort_order) VALUES
((SELECT id FROM quizzes WHERE title = 'Loops Checkpoint' LIMIT 1),
 'How many times does this loop run?  for i in range(5): print(i)', 'mcq',
 $$["4", "5", "6", "Infinite"]$$,
 1, 'range(5) yields 0, 1, 2, 3, 4 - five values, so the loop runs 5 times.', 10, 1),

((SELECT id FROM quizzes WHERE title = 'Loops Checkpoint' LIMIT 1),
 'What does list(range(2, 10, 3)) produce?', 'mcq',
 $$["[2, 5, 8]", "[2, 3, 4, 5, 6, 7, 8, 9]", "[2, 5, 8, 11]", "[3, 6, 9]"]$$,
 0, 'range(start, stop, step) starts at 2, jumps by 3, stops BEFORE 10. So: 2, 5, 8.', 10, 2),

((SELECT id FROM quizzes WHERE title = 'Loops Checkpoint' LIMIT 1),
 'What does the continue statement do inside a loop?', 'mcq',
 $$["Stops the loop entirely", "Skips to the next iteration", "Restarts the loop from the beginning", "Does nothing"]$$,
 1, 'continue skips the rest of the current iteration and jumps straight to the next one. (break is what exits the loop.)', 10, 3),

((SELECT id FROM quizzes WHERE title = 'Loops Checkpoint' LIMIT 1),
 'Which describes an infinite loop?', 'mcq',
 $$["A loop that runs exactly 100 times", "A loop whose condition is never False", "Any for loop with break", "A loop with no body"]$$,
 1, 'If a while loop condition never becomes False, the loop never exits - that is an infinite loop.', 10, 4);

-- Quiz 4: Functions ---------------------------------------------------
INSERT INTO questions (quiz_id, prompt, kind, options_json, correct_answer, explanation, points, sort_order) VALUES
((SELECT id FROM quizzes WHERE title = 'Functions Checkpoint' LIMIT 1),
 'Which keyword defines a function in Python?', 'mcq',
 $$["function", "define", "def", "func"]$$,
 2, 'Python uses the def keyword to define functions.', 10, 1),

((SELECT id FROM quizzes WHERE title = 'Functions Checkpoint' LIMIT 1),
 'What does this function return?  def f(x): x + 1', 'mcq',
 $$["x + 1", "0", "None", "An error"]$$,
 2, 'Without an explicit return statement, a Python function returns None.', 10, 2),

((SELECT id FROM quizzes WHERE title = 'Functions Checkpoint' LIMIT 1),
 'How many arguments does add(3, 5) pass to  def add(a, b)?', 'mcq',
 $$["1", "2", "3", "0"]$$,
 1, '3 and 5 are two arguments matching the parameters a and b.', 10, 3),

((SELECT id FROM quizzes WHERE title = 'Functions Checkpoint' LIMIT 1),
 'What is the difference between a parameter and an argument?', 'mcq',
 $$["They mean the same thing", "Parameter is the name in the def; argument is the value passed when calling", "Argument is the name in the def; parameter is the value passed", "Parameters can only be numbers"]$$,
 1, 'In def greet(name), name is the parameter. In greet("Alice"), "Alice" is the argument.', 10, 4);

-- Quiz 5: Lists & Dictionaries ----------------------------------------
INSERT INTO questions (quiz_id, prompt, kind, options_json, correct_answer, explanation, points, sort_order) VALUES
((SELECT id FROM quizzes WHERE title = 'Lists & Dicts Checkpoint' LIMIT 1),
 'Which of the following is a MUTABLE sequence in Python?', 'mcq',
 $$["tuple", "str", "list", "frozenset"]$$,
 2, 'Lists are mutable - you can change their contents after creation. Tuples, strings, and frozensets are immutable.', 10, 1),

((SELECT id FROM quizzes WHERE title = 'Lists & Dicts Checkpoint' LIMIT 1),
 'Given  nums = [1, 2, 3, 4],  what does  nums[-1]  return?', 'mcq',
 $$["1", "4", "-1", "An IndexError"]$$,
 1, 'Negative indices count from the end. -1 is the last element.', 10, 2),

((SELECT id FROM quizzes WHERE title = 'Lists & Dicts Checkpoint' LIMIT 1),
 'How do you add a key-value pair to a dictionary d?', 'mcq',
 $$["d.append(\"key\", \"value\")", "d[\"key\"] = \"value\"", "d + \"key\" = \"value\"", "d.add(\"key\", \"value\")"]$$,
 1, 'You assign a value to a key using square brackets, just like accessing one.', 10, 3),

((SELECT id FROM quizzes WHERE title = 'Lists & Dicts Checkpoint' LIMIT 1),
 'What does  len({"a": 1, "b": 2})  return?', 'mcq',
 $$["1", "2", "3", "4"]$$,
 1, 'len() of a dict returns the number of key-value pairs. {"a":1, "b":2} has 2.', 10, 4);

-- Quiz 6: OOP Basics --------------------------------------------------
INSERT INTO questions (quiz_id, prompt, kind, options_json, correct_answer, explanation, points, sort_order) VALUES
((SELECT id FROM quizzes WHERE title = 'OOP Checkpoint' LIMIT 1),
 'What is the role of __init__ in a Python class?', 'mcq',
 $$["A function that destroys the object", "The constructor - runs when a new object is created", "An optional helper method", "A built-in function unrelated to classes"]$$,
 1, '__init__ is the special method Python calls automatically when you create a new instance of a class.', 10, 1),

((SELECT id FROM quizzes WHERE title = 'OOP Checkpoint' LIMIT 1),
 'What does self refer to inside a method?', 'mcq',
 $$["The class itself", "A built-in function", "The instance the method is called on", "The parent class"]$$,
 2, 'self always refers to the specific object (instance) the method is being called on.', 10, 2),

((SELECT id FROM quizzes WHERE title = 'OOP Checkpoint' LIMIT 1),
 'What does inheritance allow in OOP?', 'mcq',
 $$["Copying code from one file to another", "A class to derive attributes and methods from another class", "Deleting a class", "Defining a variable"]$$,
 1, 'A child class inherits its parent class attributes and methods, and can override or extend them.', 10, 3),

((SELECT id FROM quizzes WHERE title = 'OOP Checkpoint' LIMIT 1),
 'In  class Dog(Animal):,  what is Animal?', 'mcq',
 $$["An attribute of Dog", "The parent (base) class that Dog inherits from", "A method", "A variable"]$$,
 1, 'Animal is the parent class. Dog inherits all of Animal attributes and methods.', 10, 4);

-- ===================================================================
-- SAMPLE STUDENT USERS — for testing the forum and announcement feed
-- All four share password "test123" (BCrypt-hashed below).
-- ON CONFLICT (email) DO NOTHING means re-running the script is safe.
-- ===================================================================
INSERT INTO users (name, email, password_hash, role, segment, status, last_active_at) VALUES
    ('Maria Lopez',  'maria@testing.com',  '$2a$11$pPyGg4tkt5wsiCAOpZy8Du.MH46yWY43tCiIFY4unfVyYEfvTlFRi', 'Student', 'University',   'active', NOW()),
    ('Aaron Chen',   'aaron@testing.com',  '$2a$11$pPyGg4tkt5wsiCAOpZy8Du.MH46yWY43tCiIFY4unfVyYEfvTlFRi', 'Student', 'School',       'active', NOW()),
    ('Priya Singh',  'priya@testing.com',  '$2a$11$pPyGg4tkt5wsiCAOpZy8Du.MH46yWY43tCiIFY4unfVyYEfvTlFRi', 'Student', 'Self-learner', 'active', NOW()),
    ('Daniel Wong',  'daniel@testing.com', '$2a$11$pPyGg4tkt5wsiCAOpZy8Du.MH46yWY43tCiIFY4unfVyYEfvTlFRi', 'Student', 'University',   'active', NOW())
ON CONFLICT (email) DO NOTHING;


-- ===================================================================
-- ANNOUNCEMENTS — 10 sample platform-activity entries
-- Populates the "Recent announcements" card on the User Dashboard.
-- ===================================================================
INSERT INTO announcements (action, target_type, target_name, parent_name, created_at) VALUES
    ('added',   'module',   'Decorators & Generators',           NULL,                       NOW() - INTERVAL '30 seconds'),
    ('added',   'lesson',   'List slicing tricks',               'Lists & Dictionaries',     NOW() - INTERVAL '5 minutes'),
    ('updated', 'quiz',     'Loops Checkpoint',                  NULL,                       NOW() - INTERVAL '25 minutes'),
    ('added',   'question', 'What does range(5) produce?',       'Loops Checkpoint',         NOW() - INTERVAL '1 hour'),
    ('updated', 'lesson',   'For loops in Python',               'Loops & Iteration',        NOW() - INTERVAL '3 hours'),
    ('updated', 'module',   'Functions',                         NULL,                       NOW() - INTERVAL '6 hours'),
    ('added',   'quiz',     'Variables Checkpoint',              NULL,                       NOW() - INTERVAL '1 day'),
    ('removed', 'lesson',   'Outdated syntax notes',             'Control Flow',             NOW() - INTERVAL '2 days'),
    ('removed', 'question', 'Deprecated Python 2 question',      'Variables Checkpoint',     NOW() - INTERVAL '3 days'),
    ('added',   'module',   'OOP Basics',                        NULL,                       NOW() - INTERVAL '5 days');


-- ===================================================================
-- FORUM COMMENTS — 8 top-level student comments + 3 admin replies
-- Uses email/title subqueries so the script works regardless of which
-- numeric IDs landed in users / modules / comments.
-- ===================================================================

-- Top-level student comments (parent_comment_id IS NULL)
INSERT INTO comments (user_id, module_id, body, is_read, created_at)
SELECT u.id, m.id, c.body, c.is_read, c.created_at
FROM (VALUES
    ('kenneth@testing.com', 'Lists & Dictionaries',     'Very nice module! The list slicing examples were super clear.',                              FALSE, NOW() - INTERVAL '5 minutes'),
    ('maria@testing.com',   'Lists & Dictionaries',     'Could you add more examples on dictionary comprehensions? Found those a bit tricky.',         FALSE, NOW() - INTERVAL '40 minutes'),
    ('aaron@testing.com',   'Variables and Data Types', 'Perfect for absolute beginners. I''m a school student and I understood everything!',          TRUE,  NOW() - INTERVAL '2 hours'),
    ('priya@testing.com',   'Loops & Iteration',        'The for-loop section was tough at first but it clicked after the third example. Thanks!',    TRUE,  NOW() - INTERVAL '4 hours'),
    ('daniel@testing.com',  'Functions',                'Found a typo: ''fucntion'' instead of ''function'' in lesson 2.',                             TRUE,  NOW() - INTERVAL '8 hours'),
    ('maria@testing.com',   'OOP Basics',               'The OOP module is amazing but feels a bit fast. Could use more practice exercises.',          FALSE, NOW() - INTERVAL '1 day'),
    ('kenneth@testing.com', 'Control Flow',             'Loved how if/elif/else was explained with real-world examples.',                              TRUE,  NOW() - INTERVAL '2 days'),
    ('aaron@testing.com',   'Functions',                'Default arguments and *args confused me. Could you add a flow diagram?',                      FALSE, NOW() - INTERVAL '3 days')
) AS c(email, module_title, body, is_read, created_at)
JOIN users u   ON LOWER(u.email) = LOWER(c.email)
JOIN modules m ON m.title = c.module_title;

-- Admin replies — link to their parent by matching the comment body.
-- Replace 'sonny@testing.com' with whatever your admin email is if different.
INSERT INTO comments (user_id, module_id, parent_comment_id, body, is_read, created_at)
SELECT
    (SELECT id FROM users WHERE LOWER(email) = LOWER('sonny@testing.com')),
    parent.module_id,
    parent.id,
    'Great suggestion! Added a new section on dictionary comprehensions — refresh the module to see the updates.',
    TRUE,
    NOW() - INTERVAL '30 minutes'
FROM comments parent
WHERE parent.body LIKE 'Could you add more examples on dictionary comprehensions%'
  AND parent.parent_comment_id IS NULL;

INSERT INTO comments (user_id, module_id, parent_comment_id, body, is_read, created_at)
SELECT
    (SELECT id FROM users WHERE LOWER(email) = LOWER('sonny@testing.com')),
    parent.module_id,
    parent.id,
    'Fixed! Thanks for catching that :)',
    TRUE,
    NOW() - INTERVAL '7 hours'
FROM comments parent
WHERE parent.body LIKE 'Found a typo%'
  AND parent.parent_comment_id IS NULL;

INSERT INTO comments (user_id, module_id, parent_comment_id, body, is_read, created_at)
SELECT
    (SELECT id FROM users WHERE LOWER(email) = LOWER('sonny@testing.com')),
    parent.module_id,
    parent.id,
    'Thanks for the feedback. We''re adding more exercises next week — stay tuned!',
    TRUE,
    NOW() - INTERVAL '20 hours'
FROM comments parent
WHERE parent.body LIKE 'The OOP module is amazing%'
  AND parent.parent_comment_id IS NULL;

-- Mark the parent comments that received a reply as read
-- (matches the runtime behavior in Admin/Forum.aspx.cs)
UPDATE comments
SET is_read = TRUE
WHERE id IN (SELECT parent_comment_id FROM comments WHERE parent_comment_id IS NOT NULL);


-- ===================================================================
-- Done! You should now have:
--   18 lessons (3 per module x 6 modules)
--   6 quizzes (1 per module)
--   24 questions (4 per quiz x 6 quizzes)
--   4 sample student users (Maria, Aaron, Priya, Daniel — password "test123")
--   10 announcements (covers all action / target_type combinations)
--   8 top-level forum comments + 3 admin replies
-- ===================================================================
