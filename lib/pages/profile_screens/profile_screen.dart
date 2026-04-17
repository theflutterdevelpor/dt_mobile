import 'package:dt_mobile/services/role_api_services.dart';
import 'package:flutter/material.dart';
import 'package:dt_mobile/models/response/permission_model.dart';


class CreateUserRoleScreen extends StatefulWidget {
  const CreateUserRoleScreen({super.key});

  @override
  State<CreateUserRoleScreen> createState() => _CreateUserRoleScreenState();
}

class _CreateUserRoleScreenState extends State<CreateUserRoleScreen> {
  final TextEditingController roleNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  static const List<String> _permissionHeaders = ['Create', 'Read', 'Update', 'Delete'];

  final List<Map<String, dynamic>> modules = [
    {"icon": "assets/icons/icon1.png", "name": "Dashboard Management"},
    {"icon": "assets/icons/icon2.png", "name": "Building Management"},
    {"icon": "assets/icons/icon3.png", "name": "Maintenance Management"},
    {"icon": "assets/icons/icon4.png", "name": "Role Management"},
    {"icon": "assets/icons/icon5.png", "name": "User Management"},
    {"icon": "assets/icons/icon6.png", "name": "Analytic Management"},
    {"icon": "assets/icons/icon7.png", "name": "Device Management"},
  ];

  late List<List<bool>> permissions;
  List<Permission> allPermissions = [];
  Set<String> allowedBackendKeys = {};
  List<String> permissionIds = [];
  List<String> permissionKeys = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPermissions();
    
    roleNameController.addListener((){
      setState(() {});
    });
  }

  @override
  void dispose() {
    roleNameController.dispose();
    super.dispose();
  }

  bool get _isSaveEnabled{
    return roleNameController.text.trim().isNotEmpty &&  permissionIds.isNotEmpty;
  }

  void _resetPermissions() {
    permissions = List.generate(
      modules.length,
          (_) => List.generate(_permissionHeaders.length, (_) => false),
    );

    permissionIds.clear();
    permissionKeys.clear();
  }

  Future<void> _fetchPermissions() async {
    try {
      final response = await RoleApiService.getPermissions();
      setState(() {
        allPermissions = response.data;
        allowedBackendKeys = allPermissions.map((e) => e.key).toSet();


        print('========== ALL BACKEND KEYS ==========');
        for (var perm in allPermissions) {
          print('${perm.key} => ${perm.id}');
        }
        print('Total permissions: ${allPermissions.length}');
        print('=====================================');

        _resetPermissions();

        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load permissions: $e')),
      );
    }
  }

  String _generateKey(int moduleIndex, int permIndex) {
    final moduleKey = modules[moduleIndex]["name"]
        .toString()
        .toLowerCase()
        .replaceAll(RegExp(r' management'), '')
        .replaceAll(' ', '');

    String action = _permissionHeaders[permIndex].toLowerCase();

    if (action == 'read') {
      action = 'get';
    }

    return "$action:$moduleKey";
  }






  void _togglePermission(int moduleIndex, int permIndex, bool value) {
    setState(() {
      permissions[moduleIndex][permIndex] = value;

      final key = _generateKey(moduleIndex, permIndex);

      print('Generated Key: $key');

      final permObj = allPermissions.firstWhere(
            (p) => p.key == key,
        orElse: () {
          print(' KEY NOT FOUND: $key');

          return Permission(
            id: '',
            key: '',
            label: '',
            description: '',
            category: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }
      );

      if (permObj.id.isEmpty) {
        print(' Empty permission object for key: $key');
        return;
      }

      if (value) {
        print(' Adding: $key => ${permObj.id}');

        if (!permissionIds.contains(permObj.id)) {
          permissionIds.add(permObj.id);
        }
        if (!permissionKeys.contains(key)) {
          permissionKeys.add(key);
        }
      } else {
        print(' Removing: $key');
        permissionIds.remove(permObj.id);
        permissionKeys.remove(key);
      }
    });
  }


  void _handleReset() {
    setState(() {
      roleNameController.clear();
      _resetPermissions();


    });
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final roleName = roleNameController.text.trim();

    if (permissionIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please assign at least one permission')),
      );
      return;
    }

    print('Total Permissions: ${permissionIds.length}');
    print('Permission IDs: $permissionIds');
    print('Permission Keys: $permissionKeys');


    try {
      final response = await RoleApiService.createRole(
        name: roleNameController.text.trim(),
        permissionIds: permissionIds,
        permissionKeys: permissionKeys,

      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Role "$roleName" created successfully!')),
      );
      _handleReset();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating role: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 20),
                        child: Text(
                          "Create User Role",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Divider(),
                    const Text("Role Name", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: roleNameController,
                      cursorColor: Colors.green,
                      enableInteractiveSelection: false,
                      decoration: InputDecoration(
                        hintText: "Enter role name",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: Colors.green, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: Colors.green, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Role name is required';
                        if (value.length < 3) return 'Role name must be at least 3 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text("Assign Permissions", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Expanded(flex: 3, child: Text("Module", style: TextStyle(fontWeight: FontWeight.bold))),
                        for (final header in _permissionHeaders)
                          Expanded(child: Center(child: Text(header, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
                      ],
                    ),
                    const Divider(),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: modules.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Row(
                                    children: [
                                      Image.asset(modules[index]["icon"], width: 22, height: 22),
                                      const SizedBox(width: 6),
                                      Expanded(child: Text(modules[index]["name"])),
                                    ],
                                  ),
                                ),
                                for (int i = 0; i < 4; i++)
                                  Expanded(
                                    child: Center(
                                      child: Builder(
                                        builder: (context) {
                                          final isAllowed = allowedBackendKeys.contains(
                                            _generateKey(index, i),
                                          );

                                          return Opacity(
                                            opacity: isAllowed ? 1.0 : 0.35,
                                            child: IgnorePointer(
                                              ignoring: !isAllowed,
                                              child: Checkbox(
                                                value: permissions[index][i],
                                                activeColor: Colors.green,
                                                checkColor: Colors.white,
                                                side: const BorderSide(color: Colors.black, width: 1.5),
                                                onChanged: (val) =>
                                                    _togglePermission(index, i, val ?? false),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),

                              ],
                            ),
                            const Divider(height: 1),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(width: double.infinity, height: 45, child: OutlinedButton(onPressed: _handleReset, child: const Text("Reset"))),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _isSaveEnabled ? _handleSave :null,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text("Save Role", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
