import 'models.dart';

class SummaryResult {
  SummaryResult({
    required this.totalInteractions,
    required this.bySponsor,
    required this.byChannel,
    required this.avgSentiment,
    required this.nextSteps,
  });

  final int totalInteractions;
  final Map<String, int> bySponsor;
  final Map<String, int> byChannel;
  final double avgSentiment;
  final List<String> nextSteps;
}

SummaryResult buildSummary(List<Interaction> interactions) {
  final bySponsor = <String, int>{};
  final byChannel = <String, int>{};
  var sentimentTotal = 0;
  final nextSteps = <String>[];

  for (final interaction in interactions) {
    bySponsor.update(interaction.sponsorName, (value) => value + 1,
        ifAbsent: () => 1);
    byChannel.update(interaction.channel, (value) => value + 1,
        ifAbsent: () => 1);
    sentimentTotal += interaction.sentiment;
    if (interaction.nextStep.trim().isNotEmpty) {
      nextSteps.add(interaction.nextStep.trim());
    }
  }

  final avgSentiment = interactions.isEmpty
      ? 0.0
      : sentimentTotal / interactions.length.toDouble();

  return SummaryResult(
    totalInteractions: interactions.length,
    bySponsor: bySponsor,
    byChannel: byChannel,
    avgSentiment: avgSentiment,
    nextSteps: nextSteps,
  );
}

String renderSummary(SummaryResult result, {required DateTime start, required DateTime end}) {
  final buffer = StringBuffer();
  buffer.writeln('Sponsor Pulse Summary');
  buffer.writeln('Window: ${_formatDate(start)} to ${_formatDate(end)}');
  buffer.writeln('Total interactions: ${result.totalInteractions}');
  buffer.writeln('Average sentiment: ${result.avgSentiment.toStringAsFixed(2)}');
  buffer.writeln('');
  buffer.writeln('Interactions by sponsor:');
  if (result.bySponsor.isEmpty) {
    buffer.writeln('  - No interactions logged.');
  } else {
    for (final entry in _sortedEntries(result.bySponsor)) {
      buffer.writeln('  - ${entry.key}: ${entry.value}');
    }
  }
  buffer.writeln('');
  buffer.writeln('Interactions by channel:');
  if (result.byChannel.isEmpty) {
    buffer.writeln('  - No interactions logged.');
  } else {
    for (final entry in _sortedEntries(result.byChannel)) {
      buffer.writeln('  - ${entry.key}: ${entry.value}');
    }
  }
  buffer.writeln('');
  buffer.writeln('Next steps:');
  if (result.nextSteps.isEmpty) {
    buffer.writeln('  - None captured yet.');
  } else {
    for (final step in result.nextSteps) {
      buffer.writeln('  - $step');
    }
  }
  return buffer.toString().trimRight();
}

List<MapEntry<String, int>> _sortedEntries(Map<String, int> map) {
  final entries = map.entries.toList();
  entries.sort((a, b) => b.value.compareTo(a.value));
  return entries;
}

String _formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
