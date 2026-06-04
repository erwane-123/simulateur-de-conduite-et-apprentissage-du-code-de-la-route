import 'dart:io';
import 'package:code_route_flutter/data/test_questions.dart';

void main() {
  final file = File('../lib/data/models/question_series.dart');
  var out = StringBuffer();

  out.writeln("import 'package:code_route_flutter/data/models/base_question.dart';");
  out.writeln("");
  out.writeln("List<TestQuestion> getAllSeriesQuestions() {");
  out.writeln("  return [");

  final questions = getTestQuestions();
  for (var q in questions) {
    out.writeln("    TestQuestion(");
    out.writeln("      id: ${q.id},");
    out.writeln("      themeId: '${q.themeId}',");
    
    // Escape quotes in question and explanation
    final qStr = q.question.replaceAll("'", "\\'").replaceAll("\n", "\\n");
    out.writeln("      question: '$qStr',");
    
    out.writeln("      imagePath: 'assets/images/questions/series_q${q.id}.png',");
    
    if (q.explanation != null) {
      final explStr = q.explanation!.replaceAll("'", "\\'").replaceAll("\n", "\\n");
      out.writeln("      explanation: '$explStr',");
    }
    if (q.officialLink != null) {
      out.writeln("      officialLink: '${q.officialLink}',");
    }
    
    if (q.tags.isNotEmpty) {
      out.writeln("      tags: [${q.tags.map((t) => "'$t'").join(',')}],");
    }

    out.writeln("      answers: [");
    for (var a in q.answers) {
      final aStr = a.text.replaceAll("'", "\\'").replaceAll("\n", "\\n");
      out.writeln("        Answer(text: '$aStr', isCorrect: ${a.isCorrect}),");
    }
    out.writeln("      ],");
    out.writeln("    ),");
  }

  out.writeln("  ];");
  out.writeln("}");

  file.writeAsStringSync(out.toString());
  stdout.writeln("Done formatting series questions.");
}
