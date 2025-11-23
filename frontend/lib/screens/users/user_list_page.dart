import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/api.dart';
import 'user_edit_page.dart';
import 'user_detail_page.dart';
import 'user_add_page.dart';

class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List users = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    final uri = Uri.parse("${ApiConfig.baseUrl}/users");

    final response = await http.get(
      uri,
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      setState(() {
        users = jsonDecode(response.body);
        loading = false;
      });
    } else {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal memuat data")));
    }
  }

  Future<void> deleteUser(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    final uri = Uri.parse("${ApiConfig.baseUrl}/users/$id");

    final response = await http.delete(
      uri,
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      fetchUsers();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("User berhasil dihapus")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal menghapus user")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Data Karyawan"),
        backgroundColor: Colors.blueAccent,
      ),

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UserAddPage()),
          );
          if (created == true) fetchUsers();
        },
      ),

      body: loading
          ? Center(child: CircularProgressIndicator())
          : users.isEmpty
          ? Center(child: Text("Tidak ada data karyawan"))
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];

                return Card(
                  elevation: 2,
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  child: ListTile(
                    leading: Icon(Icons.person),
                    title: Text(user["name"]),
                    subtitle: Text(user["email"]),

                    // 🔹 Tombol Edit & Delete
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            final updated = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UserEditPage(user: user),
                              ),
                            );
                            if (updated == true) fetchUsers();
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            deleteUser(user["id"]);
                          },
                        ),
                      ],
                    ),

                    // 🔹 Tap membuka detail user
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserDetailPage(user: user),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
