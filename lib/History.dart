// lib/History.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  final String jwt;
  const HistoryPage({Key? key, required this.jwt}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool _loading = true;
  String? _error;
  double _profit = 0;
  double _profitSplit = 0;
  double _withdrawal = 0;
  double _swap = 0;
  double _commission = 0;
  double _balance = 0;
  List<_HistItem> _history = [];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory({String? from, String? to}) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      var uri = Uri.parse('https://wefundclient.com/Crm/Crm/history_api.php');
      final params = <String, String>{};
      if (from != null) params['from'] = from;
      if (to != null) params['to'] = to;
      uri = uri.replace(queryParameters: params);

      final resp = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${widget.jwt}',
          'Accept': 'application/json',
        },
      );
      if (resp.statusCode != 200) throw Exception('HTTP ${resp.statusCode}');

      final Map<String, dynamic> data =
          jsonDecode(resp.body) as Map<String, dynamic>;
      final wallet = data['wallet'] as Map<String, dynamic>;

      setState(() {
        _profit      = (wallet['profit']       as num).toDouble();
        _profitSplit = (wallet['profit_split'] as num).toDouble();
        _withdrawal  = (wallet['withdrawal']   as num).toDouble();
        _swap        = (wallet['swap']         as num).toDouble();
        _commission  = (wallet['commission']   as num).toDouble();
        _balance     = (wallet['balance']      as num).toDouble();
        _history = (data['history'] as List<dynamic>)
            .map((m) => _HistItem.fromJson(m as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _dottedRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(
          child: LayoutBuilder(builder: (ctx, bc) {
            final dotCount = (bc.maxWidth / 6).floor();
            return Text(
              List.generate(dotCount, (_) => '.').join(),
              style: TextStyle(color: Colors.grey[400]),
              overflow: TextOverflow.clip,
            );
          }),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: valueColor ?? Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchHistory),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final now = DateTime.now();
              final picked = await showDateRangePicker(
                context: context,
                firstDate: now.subtract(const Duration(days: 365)),
                lastDate: now,
              );
              if (picked != null) {
                final fmt = DateFormat('yyyy-MM-dd');
                _fetchHistory(
                  from: fmt.format(picked.start),
                  to:   fmt.format(picked.end),
                );
              }
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _dottedRow(
                        'Profit:',
                        _profit.toStringAsFixed(2),
                        valueColor: _profit >= 0 ? Colors.blue : Colors.red,
                      ),
                      _dottedRow(
                        'Withdrawal:',
                        _withdrawal.toStringAsFixed(2),
                        valueColor: Colors.red,
                      ),
                      _dottedRow('Swap:', _swap.toStringAsFixed(2)),
                      _dottedRow('Commission:', _commission.toStringAsFixed(2)),
                      _dottedRow('Balance:', _balance.toStringAsFixed(2)),
                      _dottedRow(
                        'Profit Split:',
                        _profitSplit.toStringAsFixed(2),
                        valueColor:
                            _profitSplit >= 0 ? Colors.blue : Colors.red,
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: _history.isEmpty
                            ? Center(
                                child: Text(
                                  'No history in this period',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              )
                            : ListView.separated(
                                itemCount: _history.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1, thickness: 1),    // thinner gap
                                itemBuilder: (ctx, i) {
                                  final h = _history[i];
                                  final col =
                                      h.pl >= 0 ? Colors.blue : Colors.red;
                                  return ListTile(
                                    dense: true,                                 // less vertical padding
                                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                                    
                                    title: RichText(
                                      text: TextSpan(
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                        children: [
                                          TextSpan(
                                            text: h.symbol,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          TextSpan(
                                            text: h.type == 'buy'
                                                ? '  buy ${h.lot.toStringAsFixed(2)}'
                                                : '  sell ${h.lot.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: h.type == 'buy'
                                                  ? Colors.blue
                                                  : Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        DateFormat('yyyy.MM.dd')
                                            .format(
                                          DateTime.parse(h.closeDate),
                                        ),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                    trailing: Text(
                                      h.pl.toStringAsFixed(2),
                                      style: TextStyle(
                                        color: col,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_vert),
            label: 'Quotes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Charts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Trade',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
        ],
      ),
    );
  }
}

class _HistItem {
  final String symbol, type, tradeDate, closeDate;
  final double lot, pl;
  _HistItem({
    required this.symbol,
    required this.type,
    required this.lot,
    required this.pl,
    required this.tradeDate,
    required this.closeDate,
  });

  factory _HistItem.fromJson(Map<String, dynamic> j) {
    return _HistItem(
      symbol:    j['symbol']     as String,
      type:      j['type']       as String,
      lot:       (j['lot']   as num).toDouble(),
      pl:        (j['pl']    as num).toDouble(),
      tradeDate: j['trade_date'] as String,
      closeDate: j['close_date'] as String,
    );
  }
}
