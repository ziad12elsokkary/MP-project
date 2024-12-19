import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty3/models/gift.dart';

class GiftEditPage extends StatefulWidget {
  final String giftId;

  const GiftEditPage({Key? key, required this.giftId}) : super(key: key);

  @override
  State<GiftEditPage> createState() => _GiftEditPageState();
}

class _GiftEditPageState extends State<GiftEditPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String _status = 'available';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGiftDetails();
  }

  Future<void> _fetchGiftDetails() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('gifts')
          .doc(widget.giftId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = data['name'] ?? '';
          _descriptionController.text = data['description'] ?? '';
          _categoryController.text = data['category'] ?? '';
          _priceController.text = data['price']?.toString() ?? '';
          _status = data['status'] ?? 'available';
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching gift details: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch gift details.')),
      );
    }
  }

  Future<void> _updateGift() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('gifts').doc(widget.giftId).update({
          'name': _nameController.text,
          'description': _descriptionController.text,
          'category': _categoryController.text,
          'price': double.parse(_priceController.text),
          'status': _status,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gift updated successfully!')),
        );

        Navigator.pop(context, true); // Return success
      } catch (e) {
        print("Error updating gift: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update gift. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Gift"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: [
                  DropdownMenuItem(value: 'available', child: Text('Available')),
                  DropdownMenuItem(value: 'pledged', child: Text('Pledged')),
                ],
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateGift,
                child: const Text('Update Gift'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
