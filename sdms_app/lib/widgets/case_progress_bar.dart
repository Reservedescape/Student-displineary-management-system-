import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/constants.dart';
import '../models/disciplinary_case.dart';

class CaseProgressBar extends StatelessWidget {
  final DisciplinaryCase caseItem;

  const CaseProgressBar({super.key, required this.caseItem});

  int get _currentStep {
    switch (caseItem.status) {
      case CaseStatus.open:
      case CaseStatus.investigating:
        return 1;
      case CaseStatus.hearingScheduled:
        return 2;
      case CaseStatus.sanctionIssued:
        return 3;
      case CaseStatus.appealed:
        return 3; // Step 3 with active appeal review
      case CaseStatus.closed:
        return 4;
    }
  }

  double get _progressPercentage {
    switch (caseItem.status) {
      case CaseStatus.open:
        return 0.15;
      case CaseStatus.investigating:
        return 0.25;
      case CaseStatus.hearingScheduled:
        return 0.50;
      case CaseStatus.sanctionIssued:
        return 0.75;
      case CaseStatus.appealed:
        return 0.85;
      case CaseStatus.closed:
        return 1.00;
    }
  }

  String get _stageTitle {
    switch (caseItem.status) {
      case CaseStatus.open:
        return 'Stage 1: Incident Logged';
      case CaseStatus.investigating:
        return 'Stage 1: Preliminary Investigation';
      case CaseStatus.hearingScheduled:
        return 'Stage 2: Hearing Date Dispatched';
      case CaseStatus.sanctionIssued:
        return 'Stage 3: Ruling & Sanction Issued';
      case CaseStatus.appealed:
        return 'Stage 3: Board Appeal Under Review';
      case CaseStatus.closed:
        return 'Stage 4: Case Resolved & Closed';
    }
  }

  String get _stageSubtitle {
    switch (caseItem.status) {
      case CaseStatus.open:
        return 'Report submitted. Awaiting staff officer assignment.';
      case CaseStatus.investigating:
        return 'Disciplinary officer is reviewing evidence and witness statements.';
      case CaseStatus.hearingScheduled:
        return caseItem.hearing != null
            ? 'Hearing set for ${caseItem.hearing!.venue}. Sanction module locked until hearing date.'
            : 'Hearing scheduled by committee.';
      case CaseStatus.sanctionIssued:
        return caseItem.sanction != null
            ? 'Committee recorded ruling (${caseItem.sanction!.sanctionType}). 1-click appeal available.'
            : 'Committee ruling completed.';
      case CaseStatus.appealed:
        return 'Student appeal submitted to the VC Review Board. Decision pending.';
      case CaseStatus.closed:
        return 'Final decision ratified. Case record archived.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = _currentStep;
    final progress = _progressPercentage;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Percentage Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.analytics_outlined, size: 16, color: AppColors.primary),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Case Progression Status',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: caseItem.status == CaseStatus.closed
                      ? AppColors.successBg
                      : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: caseItem.status == CaseStatus.closed
                        ? AppColors.success
                        : AppColors.primary.withOpacity(0.4),
                  ),
                ),
                child: Text(
                  '${(progress * 100).toInt()}% Complete',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: caseItem.status == CaseStatus.closed
                        ? AppColors.success
                        : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Linear Progress Indicator Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.cardBorder,
              valueColor: AlwaysStoppedAnimation<Color>(
                caseItem.status == CaseStatus.closed
                    ? AppColors.success
                    : (caseItem.status == CaseStatus.appealed
                        ? AppColors.warning
                        : AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 4-Step Nodes Row
          Row(
            children: [
              _buildStepNode(
                stepNum: 1,
                title: 'Intake',
                icon: Icons.assignment_turned_in_outlined,
                activeStep: currentStep,
              ),
              _buildStepLine(isCompleted: currentStep > 1),
              _buildStepNode(
                stepNum: 2,
                title: 'Hearing',
                icon: Icons.event_available_outlined,
                activeStep: currentStep,
              ),
              _buildStepLine(isCompleted: currentStep > 2),
              _buildStepNode(
                stepNum: 3,
                title: 'Ruling',
                icon: Icons.gavel_outlined,
                activeStep: currentStep,
              ),
              _buildStepLine(isCompleted: currentStep > 3),
              _buildStepNode(
                stepNum: 4,
                title: 'Resolved',
                icon: Icons.verified_user_outlined,
                activeStep: currentStep,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Contextual Stage Status Subtitle Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _stageTitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _stageSubtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepNode({
    required int stepNum,
    required String title,
    required IconData icon,
    required int activeStep,
  }) {
    final bool isDone = activeStep > stepNum || (activeStep == 4 && stepNum == 4);
    final bool isCurrent = activeStep == stepNum && !(activeStep == 4 && stepNum != 4);

    Color circleColor;
    Color iconColor;

    if (isDone) {
      circleColor = AppColors.success;
      iconColor = AppColors.white;
    } else if (isCurrent) {
      circleColor = AppColors.primary;
      iconColor = AppColors.white;
    } else {
      circleColor = AppColors.cardBorder;
      iconColor = AppColors.textMuted;
    }

    return Expanded(
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: isDone
                  ? const Icon(Icons.check, size: 16, color: AppColors.white)
                  : Icon(icon, size: 14, color: iconColor),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isCurrent || isDone ? FontWeight.bold : FontWeight.normal,
              color: isCurrent || isDone ? AppColors.textPrimary : AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine({required bool isCompleted}) {
    return Container(
      width: 16,
      height: 2,
      margin: const EdgeInsets.only(bottom: 14),
      color: isCompleted ? AppColors.success : AppColors.cardBorder,
    );
  }
}
