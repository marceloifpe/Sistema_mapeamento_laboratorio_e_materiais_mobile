import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart'; // Assuming you have this import

class VerRelatorioPage extends StatefulWidget {
  // Added const constructor with super.key
  const VerRelatorioPage({super.key});

  @override
  _VerRelatorioPageState createState() => _VerRelatorioPageState();
}

class _VerRelatorioPageState extends State<VerRelatorioPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _showCharts = true; // Default to showing charts

  // --- Color Scheme ---
  static const Color kPrimaryColor = Color(0xFF091057);
  static const Color kAccentColor = Color(0xff1F509A);
  static const Color kLightTextColor = Colors.white;
  static const Color kDarkTextColor = Colors.black87;
  static const Color kScaffoldBackgroundColor = Color(0xFFF4F6F8);
  static const Color kCardBackgroundColor = Colors.white;
  static const Color kErrorColor = Colors.redAccent;
  static const Color kChartMaterialColor =
      kPrimaryColor; // Color for material charts/chips
  static const Color kChartSalaColor =
      kAccentColor; // Color for sala charts/chips

  // --- Data Fetching Functions (Original - Unchanged) ---
  Future<Map<String, int>> _getMaterialRanking() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('reserva')
          .get(); // Assuming 'reserva' is for materials
      Map<String, int> materialCount = {};

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        String material = data['material_nome']?.toString() ?? 'Sem nome';
        materialCount[material] = (materialCount[material] ?? 0) + 1;
      }
      return materialCount;
    } catch (e) {
      print('Erro em ranking de materiais: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Erro ao carregar ranking de materiais: $e'),
            backgroundColor: kErrorColor));
      }
      return {};
    }
  }

  Future<Map<String, Map<String, int>>> _getSalaRanking() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('reservas')
          .get(); // Assuming 'reservas' is for salas
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
      print('Erro em ranking de salas: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Erro ao carregar ranking de salas: $e'),
            backgroundColor: kErrorColor));
      }
      return {};
    }
  }

  // --- UI Building Helper Functions ---
  Widget _buildRankingCard(String title, Widget content) {
    return Card(
      elevation: 3.0, // Subtle elevation
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: kCardBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Make column stretch
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor, // Using theme color
              ),
            ),
            const SizedBox(height: 15),
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
      return _buildEmptyState("Nenhum material foi reservado ainda.");
    }

    return ListView.separated(
      // Using separated for a nice divider
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedList.length,
      itemBuilder: (context, index) {
        return ListTile(
          dense: true,
          leading: CircleAvatar(
            backgroundColor: kChartMaterialColor.withOpacity(0.15),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: kChartMaterialColor),
            ),
          ),
          title: Text(sortedList[index].key,
              style: const TextStyle(
                  fontWeight: FontWeight.w500, color: kDarkTextColor)),
          trailing: Chip(
            label: Text('${sortedList[index].value}x',
                style: const TextStyle(
                    color: kLightTextColor, fontWeight: FontWeight.bold)),
            backgroundColor: kChartMaterialColor,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
          ),
        );
      },
      separatorBuilder: (context, index) =>
          const Divider(height: 1, indent: 16, endIndent: 16),
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
      return _buildEmptyState("Nenhuma sala foi reservada ainda.");
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: allSalas.length,
      itemBuilder: (context, index) {
        return ListTile(
          dense: true,
          leading: CircleAvatar(
            backgroundColor: kChartSalaColor.withOpacity(0.15),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: kChartSalaColor),
            ),
          ),
          title: Text(allSalas[index].value.key,
              style: const TextStyle(
                  fontWeight: FontWeight.w500, color: kDarkTextColor)), // Sala
          subtitle: Text(allSalas[index].key,
              style:
                  TextStyle(color: kDarkTextColor.withOpacity(0.7))), // Local
          trailing: Chip(
            label: Text('${allSalas[index].value.value}x',
                style: const TextStyle(
                    color: kLightTextColor, fontWeight: FontWeight.bold)),
            backgroundColor: kChartSalaColor,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
          ),
        );
      },
      separatorBuilder: (context, index) =>
          const Divider(height: 1, indent: 16, endIndent: 16),
    );
  }

  Widget _buildMaterialBarChart(Map<String, int> data) {
    if (data.isEmpty)
      return _buildEmptyState("Sem dados para exibir no gráfico de materiais.");

    final sortedEntries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Limitar o número de itens no gráfico para melhor visualização
    final topEntries = sortedEntries.take(7).toList();

    return AspectRatio(
      aspectRatio: 1.6, // Ajustado para melhor visualização
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY:
              (topEntries.isNotEmpty ? topEntries.first.value.toDouble() : 1) +
                  2, // Adiciona um pouco de margem no topo
          barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: kAccentColor.withOpacity(0.8),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    String materialName = topEntries[groupIndex].key;
                    return BarTooltipItem(
                      '$materialName\n',
                      const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                      children: <TextSpan>[
                        TextSpan(
                          text: (rod.toY - 0)
                              .toString(), // Remove .0 se for inteiro
                          style: const TextStyle(
                            color: Colors.yellow, // Cor do valor no tooltip
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  })),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: (topEntries.isNotEmpty
                          ? (topEntries.first.value / 5).ceilToDouble()
                          : 1)
                      .toDouble()
                      .clamp(1, double.infinity),
                  getTitlesWidget: leftTitleWidgets),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35, // Espaço para os labels
                getTitlesWidget: (double value, TitleMeta meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < topEntries.length) {
                    final label = topEntries[index].key;
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 4.0, // Espaço entre o título e o eixo
                      child: Text(
                        label.length > 8
                            ? '${label.substring(0, 8)}...'
                            : label,
                        style: TextStyle(
                            fontSize: 10,
                            color: kDarkTextColor.withOpacity(0.8),
                            fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }
                  return SideTitleWidget(
                      axisSide: meta.axisSide, child: const SizedBox.shrink());
                },
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false), // Remove borda externa
          gridData: FlGridData(
            // Linhas de grade horizontais sutis
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 0.8),
          ),
          barGroups: List.generate(topEntries.length, (index) {
            final entry = topEntries[index];
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: entry.value.toDouble(),
                  color: kChartMaterialColor,
                  width: 20, // Largura das barras
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSalaBarChart(Map<String, Map<String, int>> data) {
    if (data.isEmpty)
      return _buildEmptyState("Sem dados para exibir no gráfico de salas.");

    List<MapEntry<String, int>> flatList = [];
    data.forEach((local, salas) {
      salas.forEach((sala, count) {
        flatList.add(MapEntry('$sala\n($local)', count));
      });
    });
    flatList.sort((a, b) => b.value.compareTo(a.value));

    // Limitar o número de itens no gráfico
    final topEntries = flatList.take(7).toList();

    return AspectRatio(
      aspectRatio: 1.6,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY:
              (topEntries.isNotEmpty ? topEntries.first.value.toDouble() : 1) +
                  2,
          barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: kPrimaryColor.withOpacity(0.8),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    String salaName = topEntries[groupIndex].key;
                    return BarTooltipItem(
                      '$salaName\n',
                      const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                      children: <TextSpan>[
                        TextSpan(
                          text: (rod.toY - 0).toString(),
                          style: const TextStyle(
                            color: Colors.yellow,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  })),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: (topEntries.isNotEmpty
                          ? (topEntries.first.value / 5).ceilToDouble()
                          : 1)
                      .toDouble()
                      .clamp(1, double.infinity),
                  getTitlesWidget: leftTitleWidgets),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40, // Aumentar espaço para labels de duas linhas
                getTitlesWidget: (double value, TitleMeta meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < topEntries.length) {
                    final labelParts = topEntries[index].key.split('\n');
                    final salaLabel = labelParts[0];
                    final localLabel =
                        labelParts.length > 1 ? labelParts[1] : "";

                    return SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 4.0,
                        child: Column(
                          // Para exibir sala e local em duas linhas
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              salaLabel.length > 8
                                  ? '${salaLabel.substring(0, 8)}...'
                                  : salaLabel,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: kDarkTextColor.withOpacity(0.8),
                                  fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (localLabel.isNotEmpty)
                              Text(
                                localLabel,
                                style: TextStyle(
                                    fontSize: 8,
                                    color: kDarkTextColor.withOpacity(0.6)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ));
                  }
                  return SideTitleWidget(
                      axisSide: meta.axisSide, child: const SizedBox.shrink());
                },
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 0.8),
          ),
          barGroups: List.generate(topEntries.length, (index) {
            final entry = topEntries[index];
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: entry.value.toDouble(),
                  color: kChartSalaColor,
                  width: 20,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // Helper para títulos do eixo Y (esquerdo)
  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: kDarkTextColor,
      fontWeight: FontWeight.w500,
      fontSize: 12,
    );
    String text;
    if (value.toInt() % meta.appliedInterval.toInt() == 0 ||
        value == meta.max) {
      // Mostra se for múltiplo do intervalo ou o máximo
      text = value.toInt().toString();
    } else {
      return Container();
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(text, style: style, textAlign: TextAlign.center),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 16.0),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sentiment_dissatisfied_outlined,
              size: 50, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.0, color: Colors.grey.shade600),
          ),
        ],
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
      backgroundColor: kScaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Relatórios de Reservas',
            style:
                TextStyle(color: kLightTextColor, fontWeight: FontWeight.bold)),
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(
            color: kLightTextColor), // Cor do botão de voltar, se houver
        elevation: 1.0,
        actions: [
          Tooltip(
            // Adicionado Tooltip para clareza
            message: _showCharts ? 'Ver em Lista' : 'Ver em Gráficos',
            child: IconButton(
              icon: Icon(
                  _showCharts
                      ? Icons.list_alt_outlined
                      : Icons.bar_chart_outlined,
                  color: kLightTextColor),
              onPressed: _toggleView,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            vertical: 10.0, horizontal: 8.0), // Padding geral
        child: Column(
          children: [
            FutureBuilder<Map<String, int>>(
              future: _getMaterialRanking(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildRankingCard(
                      "Materiais Mais Reservados",
                      const Center(
                          child:
                              CircularProgressIndicator(color: kPrimaryColor)));
                }
                if (snapshot.hasError) {
                  return _buildRankingCard("Materiais Mais Reservados",
                      _buildErrorState('Erro ao carregar dados de materiais.'));
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
            const SizedBox(height: 10), // Espaço entre os cards
            FutureBuilder<Map<String, Map<String, int>>>(
              future: _getSalaRanking(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildRankingCard(
                      "Salas Mais Reservadas",
                      const Center(
                          child:
                              CircularProgressIndicator(color: kPrimaryColor)));
                }
                if (snapshot.hasError) {
                  return _buildRankingCard("Salas Mais Reservadas",
                      _buildErrorState('Erro ao carregar dados de salas.'));
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

  Widget _buildErrorState(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 16.0),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline,
              size: 50, color: kErrorColor.withOpacity(0.7)),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.0, color: kErrorColor),
          ),
        ],
      ),
    );
  }
}
