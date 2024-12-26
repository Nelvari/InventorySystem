
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:inventory_system/components/styles.dart';
import 'package:inventory_system/model/supplier.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddSupplierPage extends StatefulWidget {
  
  final Supplier? supplier;
  const AddSupplierPage({Key? key, this.supplier}) : super(key: key);

  @override
  State<AddSupplierPage> createState() => _AddSupplierPageState();
}

class _AddSupplierPageState extends State<AddSupplierPage> {

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    if (widget.supplier != null) {
      _nameController.text = widget.supplier!.nama;
      _addressController.text = widget.supplier!.alamat;
      _contactController.text = widget.supplier!.kontak;
      _latitude = double.tryParse(widget.supplier!.latitude);
      _longitude = double.tryParse(widget.supplier!.longitude);
    }
  }

  Future<void> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Location permissions are permanently denied.')),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
    });
  }

  Future<void> _saveSupplier() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_latitude == null || _longitude == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Koordinat lokasi harus diambil terlebih dahulu!')),
        );
        return;
      }
      try {
        widget.supplier == null
            ? await Supabase.instance.client.from('supplier').insert({
          'nama': _nameController.text,
          'alamat': _addressController.text,
          'kontak': _contactController.text,
          'latitude': _latitude,
          'longitude': _longitude,
        })
            : await Supabase.instance.client.from('supplier').update({
          'nama': _nameController.text,
          'alamat': _addressController.text,
          'kontak': _contactController.text,
          'latitude': _latitude,
          'longitude': _longitude,
        }).eq('id', widget.supplier!.id); // Update existing supplier

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Supplier berhasil disimpan!')),
        );
        Navigator.pushNamedAndRemoveUntil(
            context, '/dashboard', (Route<dynamic> route) => false);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan supplier: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.supplier == null ? 'Add Supplier' : 'Update Supplier'),
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
                decoration: const InputDecoration(labelText: 'Nama'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Nama wajib diisi' : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Alamat'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Alamat wajib diisi'
                    : null,
              ),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(labelText: 'Kontak'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty
                    ? 'Kontak wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _getLocation,
                icon: const Icon(Icons.my_location),
                label: const Text('Ambil Lokasi'),
              ),
              if (_latitude != null && _longitude != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('Koordinat: $_latitude, $_longitude'),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveSupplier,
                style: buttonStyle,
                child:
                    const Text('Simpan', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}