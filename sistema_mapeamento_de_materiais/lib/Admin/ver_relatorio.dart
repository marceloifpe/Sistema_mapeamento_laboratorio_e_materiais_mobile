import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class VerRelatorioPage extends StatefulWidget {
  @override
  _VerRelatorioPageState createState() => _VerRelatorioPageState();
}

class _VerRelatorioPageState extends State<VerRelatorioPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _showCharts = true;

  Future<Map<String, int>> _getMaterialRanking() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('reserva').get();
      Map<String, int> materialCount = {};

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        String material = data['material_nome']?.toString() ?? 'Sem nome';
        materialCount[material] = (materialCount[material] ?? 0) + 1;
      }

      return materialCount;
    } catch (e) {
      print('Erro em materiais: $e');
      return {};
    }
  }

  Future<Map<String, Map<String, int>>> _getSalaRanking() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('reservas').get();
      Map<String, Map<String, int>> salaCount = {};

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        String sala = data['sala']?.toString() ?? 'Sem sala';
        String local = data['local']?.toString() ?? 'Sem local';

        if (!salaCount.containsKey(local)) {
          salaCount[local] = {};
        }
        salaCount[local]![sala] = (salaCount[local]![sala] ?? 0) + 1;
      }

      return salaCount;
    } catch (e) {
      print('Erro em salas: $e');
      return {};
    }
  }

  Widget _buildRankingCard(String title, Widget content) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 10),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialList(Map<String, int> materials) {
    List<MapEntry<String, int>> sortedList = materials.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedList.isEmpty) {
      return Center(child: Text('Nenhum material reservado'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: sortedList.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(child: Text('${index + 1}')),
          title: Text(sortedList[index].key),
          trailing: Chip(
            label: Text('${sortedList[index].value}x'),
            backgroundColor: Colors.blue,
          ),
        );
      },
    );
  }

  Widget _buildSalaList(Map<String, Map<String, int>> salas) {
    List<MapEntry<String, MapEntry<String, int>>> allSalas = [];

    salas.forEach((local, salasLocal) {
      salasLocal.forEach((sala, count) {
        allSalas.add(MapEntry(local, MapEntry(sala, count)));
      });
    });

    allSalas.sort((a, b) => b.value.value.compareTo(a.value.value));

    if (allSalas.isEmpty) {
      return Center(child: Text('Nenhuma sala reservada'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: allSalas.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(child: Text('${index + 1}')),
          title: Text(allSalas[index].value.key),
          subtitle: Text(allSalas[index].key),
          trailing: Chip(
            label: Text('${allSalas[index].value.value}x'),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }

  Widget _buildMaterialBarChart(Map<String, int> data) {
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return AspectRatio(
      aspectRatio: 1.5,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (sortedEntries.isNotEmpty
                  ? sortedEntries.first.value.toDouble()
                  : 1) +
              1,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < sortedEntries.length) {
                    final label = sortedEntries[index].key;
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        label.length > 6
                            ? '${label.substring(0, 6)}...'
                            : label,
                        style: TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return SideTitleWidget(
                      axisSide: meta.axisSide, child: SizedBox.shrink());
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: List.generate(sortedEntries.length, (index) {
            final entry = sortedEntries[index];
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: entry.value.toDouble(),
                  color: Colors.blue,
                  width: 20,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSalaBarChart(Map<String, Map<String, int>> data) {
    List<MapEntry<String, int>> flatList = [];

    data.forEach((local, salas) {
      salas.forEach((sala, count) {
        flatList.add(MapEntry('$sala\n($local)', count));
      });
    });

    flatList.sort((a, b) => b.value.compareTo(a.value));

    return AspectRatio(
      aspectRatio: 1.5,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (flatList.isNotEmpty ? flatList.first.value.toDouble() : 1) + 1,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < flatList.length) {
                    final label = flatList[index].key;
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        label.length > 6
                            ? '${label.substring(0, 6)}...'
                            : label,
                        style: TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return SideTitleWidget(
                      axisSide: meta.axisSide, child: SizedBox.shrink());
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: List.generate(flatList.length, (index) {
            final entry = flatList[index];
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: entry.value.toDouble(),
                  color: Colors.green,
                  width: 20,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  void _toggleView() {
    setState(() {
      _showCharts = !_showCharts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Relatórios de Reservas'),
        actions: [
          IconButton(
            icon: Icon(_showCharts ? Icons.list : Icons.bar_chart),
            onPressed: _toggleView,
            tooltip: _showCharts ? 'Mostrar lista' : 'Mostrar gráficos',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<Map<String, int>>(
              future: _getMaterialRanking(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text('Erro: ${snapshot.error}');
                }
                final data = snapshot.data ?? {};
                return _buildRankingCard(
                  'Materiais Mais Reservados',
                  _showCharts
                      ? _buildMaterialBarChart(data)
                      : _buildMaterialList(data),
                );
              },
            ),
            FutureBuilder<Map<String, Map<String, int>>>(
              future: _getSalaRanking(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text('Erro: ${snapshot.error}');
                }
                final data = snapshot.data ?? {};
                return _buildRankingCard(
                  'Salas Mais Reservadas',
                  _showCharts ? _buildSalaBarChart(data) : _buildSalaList(data),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
