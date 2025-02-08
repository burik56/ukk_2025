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
      try {
        // Cek apakah user ada sebelum dihapus
        final existingUser = await _supabase
            .from('user')
            .select()
            .eq('username', username)
            .maybeSingle();

        if (existingUser == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Pengguna tidak ditemukan')),
          );
          return; // Hentikan eksekusi jika user tidak ada
        }

        print("Menghapus user: $existingUser");

        // Hapus user
        final response = await _supabase
            .from('user')
            .delete()
            .eq('username', username)
            .select('*'); // Menggunakan select agar mendapat respons

        print("Respon dari Supabase setelah delete: $response");

        if (response.isNotEmpty) {
          _fetchUsers(); // Refresh daftar pengguna setelah menghapus
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Pengguna berhasil dihapus')),
          );
        } else {
          throw Exception(
              'Gagal menghapus pengguna. Tidak ada data yang dihapus.');
        }
      } catch (error) {
        print("Error saat menghapus pengguna: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus pengguna: $error')),
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
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text('Hapus'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _editUserDialog(
      String oldUsername, String oldRole, String oldPassword) async {
    TextEditingController usernameController =
        TextEditingController(text: oldUsername);
    TextEditingController passwordController =
        TextEditingController(text: '******'); // Tampilkan placeholder password
    String selectedRole = oldRole;
    bool isPasswordChanged = false; // Menandai apakah password diubah

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
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Password'),
                  onChanged: (value) {
                    setState(() {
                      isPasswordChanged = true; // Password baru dimasukkan
                    });
                  },
                  onTap: () {
                    if (!isPasswordChanged) {
                      passwordController.clear(); // Kosongkan jika disentuh
                    }
                  },
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
                      oldUsername,
                      usernameController.text,
                      isPasswordChanged
                          ? passwordController.text
                          : null, // Update hanya jika diubah
                      selectedRole,
                    );
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

  Future<void> _updateUser(String oldUsername, String newUsername,
      String? newPassword, String newRole) async {
    try {
      Map<String, dynamic> updateData = {
        'username': newUsername,
        'role': newRole,
      };

      // Update password hanya jika pengguna mengubahnya
      if (newPassword != null && newPassword.isNotEmpty) {
        updateData['password'] = newPassword; // HARUS di-hash sebelum disimpan
      }

      final response = await _supabase
          .from('user')
          .update(updateData)
          .eq('username', oldUsername)
          .select();

      if (response.isNotEmpty) {
        _fetchUsers();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pengguna berhasil diperbarui')),
        );
      } else {
        throw Exception('Gagal memperbarui pengguna');
      }
    } catch (error) {
      print("Error saat memperbarui pengguna: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $error')),
      );
    }
  }

  Future<void> _addUserDialog() async {
    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    String selectedRole = 'petugas';

    return showDialog(
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
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Password'),
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
                onPressed: () async {
                  if (usernameController.text.isNotEmpty &&
                      passwordController.text.isNotEmpty) {
                    await _addUser(usernameController.text,
                        passwordController.text, selectedRole);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Username dan Password tidak boleh kosong')),
                    );
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

  Future<void> _addUser(String username, String password, String role) async {
    try {
      print("Menambahkan pengguna: $username, Role: $role");

      final response = await _supabase.from('user').insert({
        'username': username,
        'password': password, // Pastikan password di-hash sebelum disimpan
        'role': role,
      }).select();

      print("Respon dari Supabase: $response");

      if (response != null && response.isNotEmpty) {
        _fetchUsers(); // Refresh daftar user
        Navigator.pop(context); // Tutup dialog setelah sukses
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pengguna berhasil ditambahkan')),
        );
      } else {
        throw Exception('Gagal menambah pengguna');
      }
    } catch (error) {
      print("Error: $error"); // Debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $error')),
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
            onPressed: () async {
              try {
                await _addUserDialog(); // Pastikan ini benar-benar dideklarasikan
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Terjadi kesalahan: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text('Tambah Pengguna'),
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
                        onPressed: () async {
                          // Ambil data lengkap user termasuk password
                          final userDetails = await _supabase
                              .from('user')
                              .select('password')
                              .eq('username', user['username'])
                              .maybeSingle();

                          String oldPassword = userDetails?['password'] ?? '';

                          _editUserDialog(
                              user['username'], user['role'], oldPassword);
                        },
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
