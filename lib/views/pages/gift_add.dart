import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty3/models/gift.dart';

class GiftAddPage extends StatefulWidget {
  final String eventId;

  const GiftAddPage({Key? key, required this.eventId}) : super(key: key);

  @override
  State<GiftAddPage> createState() => _GiftAddPageState();
}

class _GiftAddPageState extends State<GiftAddPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String _status = 'available';

  Future<void> _addGift() async {
    if (_formKey.currentState!.validate()) {
      try {
        final gift = Gift(
          id: '', // Firestore will generate the ID
          name: _nameController.text,
          description: _descriptionController.text,
          category: _categoryController.text,
          price: double.parse(_priceController.text),
          status: _status,
          eventId: widget.eventId,
        );

        await FirebaseFirestore.instance.collection('gifts').add(gift.toFirestore());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gift added successfully!')),
        );

        Navigator.pop(context, true); // Return success
      } catch (e) {
        print("Error adding gift: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add gift. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Gift"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Gift Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a gift name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addGift,
                child: const Text('Add Gift'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
