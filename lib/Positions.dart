import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PositionsPage extends StatefulWidget {
  final String jwt;
  const PositionsPage({Key? key, required this.jwt}) : super(key: key);

  @override
  _PositionsPageState createState() => _PositionsPageState();
}

class _PositionsPageState extends State<PositionsPage> {
  bool _loading = true;
  String? _error;
  double _balance = 0, _equity = 0, _freeMargin = 0;

  @override
  void initState() {
    super.initState();
    _fetchSummary();
  }

  Future<void> _fetchSummary() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // 1) extract userId from JWT payload
      final parts = widget.jwt.split('.');
      final payloadJson = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final payload = jsonDecode(payloadJson) as Map<String, dynamic>;
      final userId = payload['userId'];

      // 2) call API
      final uri = Uri.parse(
        'https://wefundclient.com/Crm/Crm/positions_app_api.php?user_id=$userId',
      );
      final resp = await http.get(uri, headers: {
        'Authorization': 'Bearer ${widget.jwt}',
        'Accept': 'application/json',
      });

      if (resp.statusCode != 200) {
        throw Exception('Server returned ${resp.statusCode}');
      }

      // 3) parse JSON
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      setState(() {
        _balance    = _parseMoney(data['balance']);
        _equity     = _parseMoney(data['equity']);
        _freeMargin = _parseMoney(data['free_margin']);
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  double _parseMoney(dynamic v) {
    if (v is String) {
      return double.tryParse(
            v.replaceAll(RegExp(r'[^0-9\.\-]'), ''),
          ) ??
          0;
    }
    if (v is num) return v.toDouble();
    return 0;
  }

  Widget _dottedRow(String label, double value) {
    final valStr = value.toStringAsFixed(2);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: LayoutBuilder(builder: (ctx, bc) {
        // measure
        final lp = TextPainter(
          text: TextSpan(text: label, style: TextStyle(fontSize: 16)),
          textDirection: TextDirection.ltr,
        )..layout();
        final vp = TextPainter(
          text: TextSpan(text: valStr, style: TextStyle(fontSize: 16)),
          textDirection: TextDirection.ltr,
        )..layout();
        final dotSpace = bc.maxWidth - lp.width - vp.width - 16;
        final dotCount = (dotSpace / 6).floor().clamp(0, 100);
        final dots = List.filled(dotCount, '·').join();
        return Row(children: [
          Text(label, style: TextStyle(fontSize: 16)),
          SizedBox(width: 8),
          Expanded(
            child: Text(dots,
                style: TextStyle(fontSize: 16, color: Colors.grey[400])),
          ),
          SizedBox(width: 8),
          Text(valStr, style: TextStyle(fontSize: 16)),
        ]);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trade'),
        leading: Builder(builder: (c) {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(c).openDrawer(),
          );
        }),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchSummary),
          IconButton(icon: const Icon(Icons.add), onPressed: () {}),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _dottedRow('Balance:', _balance),
                      _dottedRow('Equity:', _equity),
                      _dottedRow('Free margin:', _freeMargin),
                      const SizedBox(height: 24),
                      Expanded(
                        child: Center(
                          child: Text(
                            'No open positions',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (i) {},
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.swap_vert), label: 'Quotes'),
          BottomNavigationBarItem(
              icon: Icon(Icons.show_chart), label: 'Charts'),
          BottomNavigationBarItem(
              icon: Icon(Icons.trending_up), label: 'Trade'),
          BottomNavigationBarItem(
              icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(
              icon: Icon(Icons.message), label: 'Messages'),
        ],
      ),
    );
  }
}
