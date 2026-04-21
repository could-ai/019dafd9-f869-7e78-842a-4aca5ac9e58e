import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'results_screen.dart';

class AnalyzerScreen extends StatefulWidget {
  final String niche;

  const AnalyzerScreen({super.key, required this.niche});

  @override
  State<AnalyzerScreen> createState() => _AnalyzerScreenState();
}

class _AnalyzerScreenState extends State<AnalyzerScreen> with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  
  int _currentStepIndex = 0;
  String _currentMetric = '0';
  
  final List<String> _steps = [
    'Conectando à base de dados do YouTube...',
    'Minerando vídeos em alta sobre "{niche}"...',
    'Analisando retenção de público e CTR...',
    'Identificando lacunas de conteúdo...',
    'Calculando potencial de viralização...',
    'Gerando ideias de vídeos otimizadas...',
    'Finalizando análise heurística...',
  ];

  late Timer _stepTimer;
  late Timer _metricTimer;

  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..addListener(() {
        setState(() {});
      })..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _navigateToResults();
        }
      });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _progressController.forward();

    _stepTimer = Timer.periodic(const Duration(milliseconds: 1200), (timer) {
      if (_currentStepIndex < _steps.length - 1) {
        setState(() {
          _currentStepIndex++;
        });
      }
    });

    final random = Random();
    _metricTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        // Simulate reading lots of data
        _currentMetric = (random.nextInt(900000) + 100000).toString().replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]}.',
            );
      });
    });
  }

  void _navigateToResults() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsScreen(niche: widget.niche),
      ),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    _stepTimer.cancel();
    _metricTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentStepText = _steps[_currentStepIndex].replaceAll('{niche}', widget.niche);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1 + (_pulseController.value * 0.1)),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3 + (_pulseController.value * 0.2)),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.2 * _pulseController.value),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      LucideIcons.cpu,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
                },
              ),
              const SizedBox(height: 48),
              Text(
                'Analisando o YouTube',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  currentStepText,
                  key: ValueKey<int>(_currentStepIndex),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _progressController.value,
                  minHeight: 8,
                  backgroundColor: const Color(0xFF1E293B),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(_progressController.value * 100).toInt()}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Pontos de dados: $_currentMetric',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Text(
                'A inteligência artificial está trabalhando.\nPor favor, aguarde.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
