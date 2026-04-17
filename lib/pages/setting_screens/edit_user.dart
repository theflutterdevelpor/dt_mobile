import 'package:dt_mobile/models/response/user_response.dart';
import 'package:dt_mobile/services/user_service.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:dt_mobile/services/auth_services.dart';
import 'package:image_picker/image_picker.dart';

class EditUser extends StatefulWidget {
  final UserData user;
  const EditUser({super.key,required this.user});

  @override
  State<EditUser> createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lnameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? _selectedPriority;


  List<Map<String, dynamic>> roles = [];
  String? selectedRoleId;
  bool isRoleLoading = false;
  String? _networkImageUrl;
  List<Map<String, dynamic>> buildings = [];
  List<Map<String, dynamic>> floors = [];
  String? selectedBuildingId;
  String selectedBuildingName = 'Select Building';
  String? selectedFloorId;
  String selectedFloorLabel = 'Select Floor';
  bool isLoading = false;
  bool _isUpdating = false;
  bool _isDeleting = false;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchBuildings();

    fetchRoles().then((_) {

      setState(() {
        selectedRoleId = widget.user.role.id;
      });
    });


    final fullName = widget.user.name.trim();
    final spaceIndex = fullName.indexOf(' ');

    if (spaceIndex != -1) {
      _nameController.text = fullName.substring(0, spaceIndex);
      _lnameController.text = fullName.substring(spaceIndex + 1).trim();
    } else {
      _nameController.text = fullName;
      _lnameController.text = "";
    }

    _emailController.text = widget.user.email ?? "";


    bool isActive = widget.user.isActive || widget.user.isVerified;
    _selectedPriority = isActive ? "Active" : "Inactive";


    if (widget.user.image != null) {
      _networkImageUrl = widget.user.image!.url;
    }

    debugPrint("First: ${_nameController.text}, Last: ${_lnameController.text}");
    debugPrint("Status: $_selectedPriority");
    debugPrint("Role ID: ${widget.user.role.id}");
    debugPrint("Image URL: $_networkImageUrl");
  }

  Future<void> fetchRoles() async {
    setState(() => isRoleLoading = true);

    try {
      debugPrint("HIT: /roles API");
      final response = await ApiService.getRequest('/roles');

      if (response['success'] == true && response['data'] != null) {
        setState(() {
          roles = List<Map<String, dynamic>>.from(response['data']);
        });
      }
    } catch (e) {
      debugPrint('Role API Error: $e');
    } finally {
      setState(() => isRoleLoading = false);
    }
  }

  Future<void> fetchBuildings() async {
    setState(() => isLoading = true);

    try {
      debugPrint("HIT: /org/buildings API");
      final response = await ApiService.getRequest('/org/buildings');
      debugPrint("SUCCESS: /org/buildings API hit");

      if (response['success'] == true && response['data'] != null) {
        final List data = response['data'];

        buildings = List<Map<String, dynamic>>.from(data);


        selectedBuildingId = null;
        selectedFloorId = null;
      }
    } catch (e) {
      debugPrint(' Building API Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }



  Future<void> _updateUser() async {
    setState(() => _isUpdating = true);

    try {
      final String fullName =
          '${_nameController.text.trim()} ${_lnameController.text.trim()}';

      debugPrint(' Updating user: ${widget.user.id}');
      debugPrint(' Name: $fullName');
      debugPrint(' Email: ${_emailController.text.trim()}');
      debugPrint(' Role: $selectedRoleId');
      debugPrint(' Building: $selectedBuildingId');
      debugPrint(' Floor: $selectedFloorId');
      debugPrint(' Status: $_selectedPriority');
      debugPrint(' Image: ${_selectedImage?.path}');

      final updatedUser = await UserApiService.updateUser(
        userId: widget.user.id,
        name: fullName,
        email: _emailController.text.trim(),
        roleId: selectedRoleId,
        imageFile: _selectedImage,
        buildingsAllow:
        selectedBuildingId != null ? [selectedBuildingId!] : null,
        isActive: _selectedPriority == 'Active',
      );

      debugPrint(' User updated: ${updatedUser.name}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'User updated successfully',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint(' Update error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Update failed: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  Future<void> _deleteUser() async {
    setState(() => _isDeleting = true);

    try {
      debugPrint("🗑 Deleting user: ${widget.user.id}");
      await UserApiService.deleteUser(userId: widget.user.id);


      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User deleted successfully"),
          backgroundColor: Colors.red,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      debugPrint(" Delete error: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Delete failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }


  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 1800,
                    maxHeight: 1800,
                  );
                  if (image != null) {
                    setState(() {
                      _selectedImage = File(image.path);
                      _networkImageUrl = null;
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1800,
                    maxHeight: 1800,
                  );
                  if (image != null) {
                    setState(() {
                      _selectedImage = File(image.path);
                      _networkImageUrl = null; // Clear network image
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileImage() {
    if (_selectedImage != null) {

      return ClipOval(
        child: Image.file(
          _selectedImage!,
          width: 90,
          height: 90,
          fit: BoxFit.cover,
        ),
      );
    } else if (_networkImageUrl != null && _networkImageUrl!.isNotEmpty) {

      return ClipOval(
        child: Image.network(
          _networkImageUrl!,
          width: 90,
          height: 90,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.person_outline,
              size: 56,
              color: Colors.green,
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const CircularProgressIndicator();
          },
        ),
      );
    } else {

      return const Icon(
        Icons.person_outline,
        size: 56,
        color: Colors.green,
      );
    }
  }


  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete User"),
        content: const Text("Are you sure you want to delete this user?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: _isDeleting
                ? null
                : () {
              Navigator.pop(context);
              _deleteUser();
            },
            child: _isDeleting
                ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Text("Delete"),
          ),
        ],
      ),
    );
  }


  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _emailController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Edit User",
          style: TextStyle(
            color: Colors.green,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
              onPressed: _confirmDelete,
              icon: Image.asset('assets/icons/delete.png'))
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 2,
          color: Colors.grey[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedPriority, // Yeh "Active" ya "Inactive" hona chahiye
                  hint: Text(
                    'Select Status',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.green, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  items: ['Active', 'Inactive'] // Exact same values
                      .map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPriority = value;
                    });
                  },
                ),

                const Text(
                  'First Name',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  cursorColor: Colors.green,
                  enableInteractiveSelection: false,
                  decoration: InputDecoration(
                    hintText: 'Enter your First Name',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.green, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Last Name',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _lnameController,
                  enableInteractiveSelection: false,
                  cursorColor: Colors.green,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: 'Enter your Last Name',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.green, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 20),


                const Text(
                  'Email:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  enableInteractiveSelection: false,
                  cursorColor: Colors.green,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter your Email Address',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.green, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'User role',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: roles.any((r) => r['_id'] == selectedRoleId)
                      ? selectedRoleId
                      : null,
                  hint: Text(
                    isRoleLoading ? 'Loading roles...' : 'Select Role',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.green, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),

                  items: roles.map((role) {
                    return DropdownMenuItem<String>(
                      value: role['_id'],
                      child: Text(role['name']),
                    );
                  }).toList(),

                  onChanged: (value) {
                    setState(() {
                      selectedRoleId = value;
                    });
                  },
                ),
                const SizedBox(height: 20),


                const Text(
                  'Assigned Building',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: buildings.any((b) => b['_id'] == selectedBuildingId)
                      ? selectedBuildingId
                      : null,
                  hint: Text(
                    'Select Building',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.green, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),


                  items: buildings.map((building) {
                    return DropdownMenuItem<String>(
                      value: building['_id'],
                      child: Text(building['name']),
                    );
                  }).toList(),

                  onChanged: (value) {
                    final selectedBuilding =
                    buildings.firstWhere((b) => b['_id'] == value);

                    setState(() {
                      selectedBuildingId = value;
                      selectedBuildingName = selectedBuilding['name'];


                      floors = List<Map<String, dynamic>>.from(
                          selectedBuilding['floors'] ?? []);

                      selectedFloorId = null;
                      selectedFloorLabel = 'Select Floor';
                    });
                  },
                ),
                const SizedBox(height: 20),


                const Text(
                  'Assigned Floor',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: floors.any((f) => f['_id'] == selectedFloorId)
                      ? selectedFloorId
                      : null,
                  hint: Text(
                    'Select Floor',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.green, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),

                  ///  API SE FLOORS (selected building ke)
                  items: floors.map((floor) {
                    return DropdownMenuItem<String>(
                      value: floor['_id'],
                      child: Text(floor['label']),
                    );
                  }).toList(),

                  onChanged: (value) {
                    final selectedFloor =
                    floors.firstWhere((f) => f['_id'] == value);

                    setState(() {
                      selectedFloorId = value;
                      selectedFloorLabel = selectedFloor['label'];
                    });
                  },
                ),
                const SizedBox(height: 20),


                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Profile Photo',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),

                    Column(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.shade400,
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              backgroundColor: Colors.grey[100],
                              child: _buildProfileImage(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),


                        TextButton(
                          onPressed: _pickImage,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            side: const BorderSide(
                              color: Colors.black,
                              width: 0.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: const Text(
                            "Click to replace",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),


                      ],
                    ),
                  ],
                ),






                const SizedBox(height: 30),


                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(width: 15),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(

                          minimumSize: const Size.fromHeight(44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                    ),
                    SizedBox(width: 10,),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isUpdating ? null : _updateUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.green.withOpacity(0.5),
                          minimumSize: const Size.fromHeight(44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: _isUpdating
                              ? const SizedBox(

                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                              : const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),

                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}


