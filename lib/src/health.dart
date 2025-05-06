import 'models.dart';

class SponsorHealthStatus {
  SponsorHealthStatus({
    required this.metric,
    required this.daysSinceContact,
    required this.riskScore,
    required this.riskLabel,
    required this.flags,
    required this.recommendedAction,
  });

  final SponsorHealthMetric metric;
  final int? daysSinceContact;
  final int riskScore;
  final String riskLabel;
  final List<String> flags;
  final String recommendedAction;
}

List<SponsorHealthStatus> assessSponsorHealth(
  List<SponsorHealthMetric> metrics, {
  DateTime? now,
  int staleDays = 45,
  int warmDays = 30,
}) {
  final reference = now ?? DateTime.now();

  final statuses = metrics
      .map(
        (metric) => _assessSingle(
          metric,
          reference: reference,
          staleDays: staleDays,
          warmDays: warmDays,
        ),
      )
      .toList();

  statuses.sort((a, b) {
    final score = b.riskScore.compareTo(a.riskScore);
    if (score != 0) {
      return score;
    }
    final daysA = a.daysSinceContact ?? 9999;
    final daysB = b.daysSinceContact ?? 9999;
    final daysCompare = daysB.compareTo(daysA);
    if (daysCompare != 0) {
      return daysCompare;
    }
    return a.metric.name.compareTo(b.metric.name);
  });

  return statuses;
}

String renderHealthReport(
  List<SponsorHealthStatus> statuses, {
  required DateTime asOf,
}) {
  final buffer = StringBuffer();
  buffer.writeln('Sponsor Health Snapshot');
  buffer.writeln('As of: ${_formatDate(asOf)}');
  buffer.writeln('');

  if (statuses.isEmpty) {
    buffer.writeln('No sponsors available.');
    return buffer.toString().trimRight();
  }

  for (final status in statuses) {
    final metric = status.metric;
    final lastContact = metric.lastContactDate == null
        ? 'none'
        : _formatDate(metric.lastContactDate!);
    final daysSince = status.daysSinceContact == null
        ? 'n/a'
        : '${status.daysSinceContact}d';
    final avgSentiment = metric.avgSentiment == null
        ? 'n/a'
        : metric.avgSentiment!.toStringAsFixed(2);
    final flags = status.flags.isEmpty ? 'None' : status.flags.join('; ');

    buffer.writeln(
      '${status.riskLabel} | ${metric.name} | Owner: ${metric.owner}',
    );
    buffer.writeln(
      '  Segment: ${metric.segment} | Last: $lastContact ($daysSince) | Recent: ${metric.recentInteractions} | Avg sentiment: $avgSentiment',
    );
    buffer.writeln('  Flags: $flags');
    buffer.writeln('  Next action: ${status.recommendedAction}');
  }

  return buffer.toString().trimRight();
}

SponsorHealthStatus _assessSingle(
  SponsorHealthMetric metric, {
  required DateTime reference,
  required int staleDays,
  required int warmDays,
}) {
  final daysSince = metric.lastContactDate == null
      ? null
      : reference.difference(metric.lastContactDate!).inDays;

  if (metric.lastContactDate == null) {
    return SponsorHealthStatus(
      metric: metric,
      daysSinceContact: null,
      riskScore: 5,
      riskLabel: 'Unengaged',
      flags: const ['No interactions logged'],
      recommendedAction: 'Start intro outreach',
    );
  }

  var score = 0;
  final flags = <String>[];

  if (daysSince != null) {
    if (daysSince > staleDays) {
      score += 2;
      flags.add('Stale touchpoint');
    } else if (daysSince > warmDays) {
      score += 1;
      flags.add('Cadence slipping');
    }
  }

  if (metric.recentInteractions == 0) {
    score += 1;
    flags.add('No recent interactions');
  }

  final avgSentiment = metric.avgSentiment;
  if (avgSentiment != null) {
    if (avgSentiment <= -1) {
      score += 2;
      flags.add('Negative sentiment');
    } else if (avgSentiment < 0) {
      score += 1;
      flags.add('Soft sentiment');
    }
  }

  final riskLabel = _labelForScore(score);
  final recommendedAction = _recommendedAction(
    score: score,
    daysSince: daysSince,
    staleDays: staleDays,
    warmDays: warmDays,
    avgSentiment: avgSentiment,
    recentInteractions: metric.recentInteractions,
  );

  return SponsorHealthStatus(
    metric: metric,
    daysSinceContact: daysSince,
    riskScore: score,
    riskLabel: riskLabel,
    flags: flags,
    recommendedAction: recommendedAction,
  );
}

String _labelForScore(int score) {
  if (score >= 4) {
    return 'At-Risk';
  }
  if (score >= 2) {
    return 'Watch';
  }
  return 'Healthy';
}

String _recommendedAction({
  required int score,
  required int? daysSince,
  required int staleDays,
  required int warmDays,
  required double? avgSentiment,
  required int recentInteractions,
}) {
  if (daysSince == null) {
    return 'Start intro outreach';
  }
  if (daysSince > staleDays) {
    return 'Schedule check-in';
  }
  if (avgSentiment != null && avgSentiment < 0) {
    return 'Repair sentiment';
  }
  if (recentInteractions == 0 || daysSince > warmDays) {
    return 'Log touchpoint';
  }
  if (score >= 2) {
    return 'Review account plan';
  }
  return 'Maintain cadence';
}

String _formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
