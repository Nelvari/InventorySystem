import 'package:flutter/material.dart';
import 'package:inventory_system/components/styles.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../model/barang.dart';

class RiwayatPage extends StatefulWidget {
  final Product product;
  const RiwayatPage({super.key, required this.product});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  
  late Product _product;
  final stockController = TextEditingController();
  String jenisTransaksi = "Masuk";
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _product = widget.product;
  }

  Future<void> _updateAndAddHistory() async {
    final stokLama = _product.stock;
    final perubahanStok = int.tryParse(stockController.text);
    if (perubahanStok == null || perubahanStok <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan jumlah stok yang valid!')),
      );
      return;
    } else if (jenisTransaksi == 'Keluar' && perubahanStok > _product.stock) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Stok keluar tidak bisa lebih dari stok yang ada')));
      return;
    }

    if (_product.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID produk tidak valid!')),
      );
      return;
    }
    late int stokBaru;
    if (jenisTransaksi == "Masuk") {
      stokBaru = stokLama + perubahanStok;
    } else {
      stokBaru = stokLama - perubahanStok;
    }
    try {
      await Supabase.instance.client.from('transaksi').insert({
        'idProduct': _product.id,
        'tanggal': selectedDate.toIso8601String(),
        'jumlah': perubahanStok,
        'jenisTransaksi': jenisTransaksi,
      });
      await Supabase.instance.client.from('product').update({
        'stock': stokBaru,
      }).eq('id', _product.id);

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stok berhasil diperbarui.')),
      );
      Navigator.pushNamedAndRemoveUntil(
          // ignore: use_build_context_synchronously
          context, '/dashboard', (Route<dynamic> route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Stok Barang'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nama: ${_product.name}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Harga: Rp${_product.price}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Stok Sekarang: ${_product.stock}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Row(
              children: [
                Text('Jenis Transaksi: '),
                DropdownButton<String>(
                  value: jenisTransaksi,
                  items: ['Masuk', 'Keluar'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      jenisTransaksi = newValue!;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Jumlah Stok Baru',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text('Pilih Tanggal: '),
                TextButton.icon(
                  onPressed: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null && pickedDate != selectedDate) {
                      setState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  },
                  icon: Icon(Icons.calendar_today),
                  label: Text(
                    DateFormat('dd-MM-yyyy').format(selectedDate),
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateAndAddHistory,
              style: buttonStyle,
              child: Text(
                'Update Stok',
                style: textStyle(level: 4, dark: false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
