import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(TodoApp());
}

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-do List',
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLogin = true;

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  void _authenticate() async {
    final prefs = await SharedPreferences.getInstance();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (_isLogin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(email: email)),
      );
    } else {
      if (prefs.getString(email) == null) {
        prefs.setString(email, password);
        _showMessage("Cadastro finalizado! Faça o login.");
        _toggleMode();
      } else {
        _showMessage("E-mail já foi cadastrado.");
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_isLogin ? "Login" : "Cadastro", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              TextField(controller: _emailController, decoration: InputDecoration(labelText: "E-mail")),
              TextField(controller: _passwordController, obscureText: true, decoration: InputDecoration(labelText: "Senha")),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _authenticate, child: Text(_isLogin ? "Entrar" : "Cadastrar")),
              TextButton(onPressed: _toggleMode, child: Text(_isLogin ? "Criar conta" : "Já tenho uma conta")),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String email;
  HomePage({required this.email});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  final TextEditingController _taskController = TextEditingController();
  List<Map<String, dynamic>> _tasks = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Bem Vindo, ${widget.email.split("@")[0]}!',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.orange,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            focusedDay: _selectedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
              });
              _showTaskDialog();
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: Colors.deepOrange, shape: BoxShape.circle),
            ),
          ),
          Expanded(
            child: _taskList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: _showTaskDialog,
      ),
    );
  }

  void _showTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Tarefas do dia"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _taskController,
              decoration: InputDecoration(hintText: "Adicionar uma nova tarefa"),
            ),
            SizedBox(height: 10),
            ElevatedButton(onPressed: _addTask, child: Text("Adicionar")),
          ],
        ),
      ),
    );
  }

  void _addTask() {
    if (_taskController.text.isEmpty) return;
    setState(() {
      _tasks.add({
        "task": _taskController.text,
        "date": _selectedDay.toString().split(" ")[0],
        "completed": false,
      });
    });
    _taskController.clear();
    Navigator.pop(context);
  }

  Widget _taskList() {
    _tasks.sort((a, b) {
      if (a["completed"] == b["completed"]) {
        return a["task"].compareTo(b["task"]);
      }
      return a["completed"] ? 1 : -1;
    });

    return ListView.builder(
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(_tasks[index]["task"],
              style: TextStyle(
                  decoration: _tasks[index]["completed"] ? TextDecoration.lineThrough : TextDecoration.none)),
          subtitle: Text("Data: ${_tasks[index]["date"]}"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: _tasks[index]["completed"],
                onChanged: (value) {
                  setState(() {
                    _tasks[index]["completed"] = value!;
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _tasks.removeAt(index);
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
