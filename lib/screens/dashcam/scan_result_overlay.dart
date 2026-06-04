import 'dart:ui';

import 'package:code_route_flutter/core/constants/app_colors.dart';
import 'package:code_route_flutter/models/scan_result.dart';
import 'package:flutter/material.dart';

class ScanResultOverlay extends StatefulWidget {
  final ScanResult result;

  const ScanResultOverlay({Key? key, required this.result}) : super(key: key);

  @override
  State<ScanResultOverlay> createState() => _ScanResultOverlayState();
}

class _ScanResultOverlayState extends State<ScanResultOverlay> {
  int? _selectedAnswer;

  bool get _hasAnswered => _selectedAnswer != null;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(18),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          decoration: BoxDecoration(
            color: AppColors.backgroundDark.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSoft),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSituationSummary(),
                      const SizedBox(height: 16),
                      _buildPriorityQuestion(),
                      if (_hasAnswered) ...[
                        const SizedBox(height: 16),
                        _buildCorrection(),
                        const SizedBox(height: 16),
                        _buildHazards(),
                        const SizedBox(height: 16),
                        _buildChecklist(),
                      ],
                    ],
                  ),
                ),
              ),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: widget.result.iconColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(widget.result.icon, color: widget.result.iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.result.generatedScene
                      ? 'Scene generee'
                      : 'Situation reelle analysee',
                  style: const TextStyle(
                    color: AppColors.accentCyan,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.result.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSituationSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.result.description,
          style: const TextStyle(
            color: AppColors.textSecondary,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final object in widget.result.detectedObjects)
              _DetectedObjectCard(object: object),
          ],
        ),
      ],
    );
  }

  Widget _buildPriorityQuestion() {
    final question = widget.result.priorityQuestion;

    return _SectionCard(
      icon: Icons.help_outline_rounded,
      title: question.question,
      child: Column(
        children: [
          for (var i = 0; i < question.answers.length; i++) ...[
            _AnswerTile(
              text: question.answers[i],
              selected: _selectedAnswer == i,
              correct: _hasAnswered && question.correctIndex == i,
              wrong: _hasAnswered &&
                  _selectedAnswer == i &&
                  _selectedAnswer != question.correctIndex,
              onTap: _hasAnswered
                  ? null
                  : () => setState(() => _selectedAnswer = i),
            ),
            if (i < question.answers.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildCorrection() {
    final isCorrect =
        _selectedAnswer == widget.result.priorityQuestion.correctIndex;

    return _SectionCard(
      icon: isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
      iconColor: isCorrect ? AppColors.success : AppColors.error,
      title: isCorrect ? 'Bonne reponse' : 'Correction immediate',
      child: Text(
        widget.result.priorityQuestion.correction,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 13,
          height: 1.45,
        ),
      ),
    );
  }

  Widget _buildHazards() {
    return _SectionCard(
      icon: Icons.warning_amber_rounded,
      iconColor: AppColors.warning,
      title: 'Dangers a anticiper',
      child: Column(
        children: [
          for (final hazard in widget.result.hazards)
            _HazardRow(hazard: hazard),
          const SizedBox(height: 8),
          Text(
            widget.result.advice,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklist() {
    return _SectionCard(
      icon: Icons.remove_red_eye_outlined,
      title: 'Methode de scan conducteur',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in widget.result.scanChecklist)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_rounded,
                    color: AppColors.accentCyan,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: _hasAnswered ? () => Navigator.pop(context) : null,
          icon: const Icon(Icons.done_rounded),
          label: Text(_hasAnswered ? 'Compris' : 'Reponds pour continuer'),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
    this.iconColor = AppColors.accentCyan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DetectedObjectCard extends StatelessWidget {
  final DetectedRoadObject object;

  const _DetectedObjectCard({required this.object});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: object.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: object.color.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(object.icon, color: object.color, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  object.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: object.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            object.category,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            object.detail,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 11,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerTile extends StatelessWidget {
  final String text;
  final bool selected;
  final bool correct;
  final bool wrong;
  final VoidCallback? onTap;

  const _AnswerTile({
    required this.text,
    required this.selected,
    required this.correct,
    required this.wrong,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = correct
        ? AppColors.success
        : wrong
            ? AppColors.error
            : selected
                ? AppColors.accentCyan
                : AppColors.borderSoft;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: correct || wrong ? 0.13 : 0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color),
          ),
          child: Row(
            children: [
              Icon(
                correct
                    ? Icons.check_circle_rounded
                    : wrong
                        ? Icons.cancel_rounded
                        : Icons.radio_button_unchecked_rounded,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HazardRow extends StatelessWidget {
  final DetectedRoadObject hazard;

  const _HazardRow({required this.hazard});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(hazard.icon, color: hazard.color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hazard.label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${hazard.detail} ${hazard.risk}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
