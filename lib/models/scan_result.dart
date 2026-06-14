import 'package:flutter/material.dart';

class DetectedRoadObject {
  final String label;
  final String category;
  final String detail;
  final String risk;
  final IconData icon;
  final Color color;
  final Rect? boundingBox;
  final double? confidence;

  const DetectedRoadObject({
    required this.label,
    required this.category,
    required this.detail,
    required this.risk,
    required this.icon,
    required this.color,
    this.boundingBox,
    this.confidence,
  });
}

class PriorityQuestion {
  final String question;
  final List<String> answers;
  final int correctIndex;
  final String correction;
  final String ruleExplanation;

  const PriorityQuestion({
    required this.question,
    required this.answers,
    required this.correctIndex,
    required this.correction,
    this.ruleExplanation = '',
  });
}

class ScanResult {
  final String title;
  final String description;
  final String dangerLevel;
  final String advice;
  final IconData icon;
  final Color iconColor;
  final List<DetectedRoadObject> detectedObjects;
  final List<DetectedRoadObject> hazards;
  final PriorityQuestion priorityQuestion;
  final List<PriorityQuestion> followUpQuestions;
  final List<String> scanChecklist;
  final bool generatedScene;

  List<PriorityQuestion> get allQuestions => [
        priorityQuestion,
        ...followUpQuestions,
      ];

  const ScanResult({
    required this.title,
    required this.description,
    required this.dangerLevel,
    required this.advice,
    required this.icon,
    required this.detectedObjects,
    required this.hazards,
    required this.priorityQuestion,
    required this.scanChecklist,
    this.followUpQuestions = const [],
    this.generatedScene = false,
    this.iconColor = Colors.amber,
  });
}
