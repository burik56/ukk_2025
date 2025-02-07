import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UsersPage extends StatefulWidget {
  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _allUsers = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    try {
      final List<dynamic> response =
          await _supabase.from('user').select('username, role');

      if (response.isNotEmpty) {
        setState(() {
          _allUsers =
              response.map((e) => Map<String, dynamic>.from(e)).toList();
          _users = List.from(_allUsers);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak ada data pengguna')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: ${error.toString()}')),
      );
    }
  }

  void _filterUsers() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _users = _users
          .where((user) =>
              user['username']!.toLowerCase().contains(query) ||
              user['role']!.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _deleteUser(String username) async {
    bool confirmDelete = await _showDeleteConfirmationDialog();
    if (confirmDelete) {
      final response = await _supabase
          .from('user')
          .delete()
          .eq('username', username)
          .maybeSingle();

      if (response != null) {
        _fetchUsers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus pengguna')),
        );
      }
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Konfirmasi'),
            content: Text('Apakah Anda yakin ingin menghapus pengguna ini?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.red, 
                  foregroundColor:
                      Colors.white,
                ),
                child: Text('Hapus'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _editUserDialog(String oldUsername, String oldRole) async {
    TextEditingController usernameController =
        TextEditingController(text: oldUsername);
    String selectedRole = oldRole;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Edit Pengguna'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(labelText: 'Username'),
                ),
                SizedBox(height: 10),
                DropdownButton<String>(
                  value: selectedRole,
                  onChanged: (newValue) {
                    setState(() {
                      selectedRole = newValue!;
                    });
                  },
                  items: ['petugas', 'administrator']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (usernameController.text.isNotEmpty) {
                    _updateUser(
                        oldUsername, usernameController.text, selectedRole);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
                child: Text('Simpan'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _updateUser(
      String oldUsername, String newUsername, String newRole) async {
    final response = await _supabase
        .from('user')
        .update({'username': newUsername, 'role': newRole})
        .eq('username', oldUsername)
        .maybeSingle();

    if (response == null) {
      _fetchUsers();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui pengguna')),
      );
    }
  }

  Future<void> _addUserDialog() async {
    TextEditingController usernameController = TextEditingController();
    String selectedRole = 'user';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Tambah Pengguna'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(labelText: 'Username'),
                ),
                SizedBox(height: 10),
                DropdownButton<String>(
                  value: selectedRole,
                  onChanged: (newValue) {
                    setState(() {
                      selectedRole = newValue!;
                    });
                  },
                  items: ['user', 'petugas', 'administrator']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (usernameController.text.isNotEmpty) {
                    _addUser(usernameController.text, selectedRole);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
                child: Text('Tambah'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _addUser(String username, String role) async {
    final response = await _supabase
        .from('user')
        .insert({'username': username, 'role': role}).maybeSingle();

    if (response == null) {
      _fetchUsers();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambah pengguna')),
      );
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Cari Pengguna',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            _addUserDialog();
          },
          child: Text('Tambah Pengguna'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _users.length,
            itemBuilder: (context, index) {
              final user = _users[index];
              return ListTile(
                leading: CircleAvatar(child: Text(user['username'][0])),
                title: Text(user['username']),
                subtitle: Text('Role: ${user['role']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editUserDialog(user['username'], user['role']),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteUser(user['username']),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

}
