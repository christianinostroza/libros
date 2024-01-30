// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class Book {
  final String title;
  final String author;
  final String publisher;
  final String description;

  Book({
    required this.title,
    required this.author,
    required this.publisher,
    required this.description
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['volumeInfo']['title'],
      author: json['volumeInfo']['authors']?.join(", ") ?? 'Unknown Author',
      publisher: json['volumeInfo']['publisher'] ?? 'Unknown Publisher',
      description: json['volumeInfo']['description'] ?? 'Unknown Description'
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CatalogScreen(),
    );
  }
}

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  _CatalogScreenState createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Book> _books = [];

  Future<void> _searchBooks(String query) async {
    final response = await http.get(
      Uri.parse(
          'https://www.googleapis.com/books/v1/volumes?q=$query&maxResults=10'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['items'];
      final List<Book> books = data.map((item) => Book.fromJson(item)).toList();
      setState(() {
        _books = books;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogo de Libros'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: '¿Qué desea leer?',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _searchBooks(_searchController.text);
              },
              child: const Text('Buscar'),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _books.length,
                itemBuilder: (context, index) {
                  return BookItem(book: _books[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookItem extends StatelessWidget {
  final Book book;

  const BookItem({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(book.title),
      subtitle: Text('Autor: ${book.author}'),
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return BookDetailsPopup(book: book);
          },
        );
      },
    );
  }
}

class BookDetailsPopup extends StatelessWidget {
  final Book book;

  const BookDetailsPopup({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(book.title),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Autor: ${book.author}'),
          Text('Publicado: ${book.publisher}'),
          Text('Descripcion: ${book.description}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}
