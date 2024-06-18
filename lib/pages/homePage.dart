import 'package:flutter/material.dart';
import 'package:sqlite_project/models/emp_model.dart';
import 'package:sqlite_project/services/database_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomepState();
}

class _HomepState extends State<HomePage> {
  final DatabaseService _dbService = DatabaseService.instance;
  String? name;
  String? dept;
  int? empId;
  String isHighlighted = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _addEmployeeButton(),
      appBar: AppBar(
        title: const Text("SQFLite App"),
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                          title: const Text("Search Employee"),
                          content: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                  "Enter the GN ID you want to search : "),
                              const SizedBox(
                                height: 10,
                              ),
                              TextField(
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {
                                    empId = int.parse(value);
                                  });
                                },
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: "Emp ID"),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              MaterialButton(
                                color: Theme.of(context).colorScheme.primary,
                                onPressed: () async {
                                  if (empId == null) return;
                                  List<Map<String, dynamic>> ll =
                                      await _dbService.searchEmployee(empId!);
                                  for (var employee in ll) {
                                    isHighlighted =
                                        employee['employee_id'].toString();
                                  }
                                  setState(() {
                                    name = null;
                                    dept = null;
                                  });
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  "Search",
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            ],
                          ),
                        ));
              },
              icon: const Icon(Icons.search)),
          IconButton(
              onPressed: () {
                isHighlighted = "";
                setState(() {
                });
              },
              icon: const Icon(Icons.cancel)),
        ],
      ),
      body: _employeesList(),
    );
  }

  Widget _addEmployeeButton() {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  title: const Text("Add Employee"),
                  content: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            name = value;
                          });
                        },
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(), hintText: "Name"),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            dept = value;
                          });
                        },
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Department"),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextField(
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            empId = int.parse(value);
                          });
                        },
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(), hintText: "Emp ID"),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      MaterialButton(
                        color: Theme.of(context).colorScheme.primary,
                        onPressed: () {
                          if (name == null ||
                              name == "" ||
                              dept == null ||
                              dept == "" ||
                              empId == null) return;
                          _dbService.addEmployee(name!, dept!, empId!);
                          setState(() {
                            name = null;
                            dept = null;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Done",
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ));
      },
      child: const Icon(Icons.add),
    );
  }

  Widget _employeesList()  {
    return FutureBuilder(
        future: _dbService.getEmployees(),
        builder: (context, snapshot) {
          return ListView.builder(
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) {
                EmployeeModel empModel = snapshot.data![index];
                return ListTile(
                  tileColor: (isHighlighted == empModel.empId.toString())
                      ? Colors.yellow
                      : null,
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                              title: const Text("Update Employee"),
                              content: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    onChanged: (value) {
                                      setState(() {
                                        name = value;
                                      });
                                    },
                                    decoration: InputDecoration(
                                        border: const OutlineInputBorder(),
                                        hintText: empModel.name),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  TextField(
                                    onChanged: (value) {
                                      setState(() {
                                        dept = value;
                                      });
                                    },
                                    decoration: InputDecoration(
                                        border: const OutlineInputBorder(),
                                        hintText: empModel.dept),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  TextField(
                                    readOnly: true,
                                  enableInteractiveSelection: false, //to disable the paste, copy and select feature...
                                    textInputAction: TextInputAction.done,
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      setState(() {
                                        empId = int.parse(value);
                                      });
                                    },
                                    decoration: InputDecoration(
                                        border: const OutlineInputBorder(),
                                        hintText: empModel.empId.toString() ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  MaterialButton(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    onPressed: () {
                                      if (name == null ||
                                          name == "" ||
                                          dept == null ||
                                          dept == "") return;
                                      _dbService.updateEmployee(
                                          name!, dept!, empModel.empId);
                                      setState(() {
                                        name = null;
                                        dept = null;
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      "Update",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )
                                ],
                              ),
                            ));
                  },
                  onLongPress: () {
                    {
                      showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                                title: const Text("Delete Employee"),
                                content: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                        "Are you sure that you want to delete Employee Id : ${empModel.empId} ?"),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    MaterialButton(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      onPressed: () {
                                        _dbService
                                            .deleteEmployee(empModel.empId);
                                        setState(() {
                                          name = null;
                                          dept = null;
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        "Delete",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    )
                                  ],
                                ),
                              ));
                    }
                    setState(() {});
                  },
                  focusColor: Colors.green,
                  // trailing: Checkbox(
                  //   value: false,
                  //   onChanged: (v) {
                  //     setState(() {
                  //       t = !t;
                  //     });
                  //   },
                  // ),
                  title: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // (isHighlighted == empModel.empId.toString())
                        //     ? const SizedBox(
                        //     child: Icon(
                        //       Icons.airplane_ticket,
                        //       color: Colors.green,
                        //     )): const SizedBox.shrink(),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(empModel.empId.toString(), maxLines: 1,),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(empModel.dept, maxLines: 1,),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(empModel.name, maxLines: 1,),
                      ],
                    ),
                  ),
                );
              });
        });
  }
}
