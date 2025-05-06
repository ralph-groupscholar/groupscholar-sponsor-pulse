import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:groupscholar_sponsor_pulse/groupscholar_sponsor_pulse.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false)
    ..addCommand('add-sponsor', _addSponsorParser())
    ..addCommand('log-interaction', _logInteractionParser())
    ..addCommand('list-sponsors', _listSponsorsParser())
    ..addCommand('recent-interactions', _recentInteractionsParser())
    ..addCommand('weekly-summary', _weeklySummaryParser())
    ..addCommand('sponsor-health', _sponsorHealthParser());

  ArgResults results;
  try {
    results = parser.parse(arguments);
  } catch (error) {
    stderr.writeln('Error: $error');
    _printUsage(parser);
    exitCode = 64;
    return;
  }

  if (results['help'] == true || results.command == null) {
    _printUsage(parser);
    return;
  }

  final command = results.command!;

  try {
    switch (command.name) {
      case 'add-sponsor':
        await _handleAddSponsor(command);
        break;
      case 'log-interaction':
        await _handleLogInteraction(command);
        break;
      case 'list-sponsors':
        await _handleListSponsors(command);
        break;
      case 'recent-interactions':
        await _handleRecentInteractions(command);
        break;
      case 'weekly-summary':
        await _handleWeeklySummary(command);
        break;
      case 'sponsor-health':
        await _handleSponsorHealth(command);
        break;
      default:
        _printUsage(parser);
    }
  } catch (error) {
    stderr.writeln('Error: $error');
    exitCode = 1;
  }
}

ArgParser _addSponsorParser() {
  return ArgParser()
    ..addOption('name', abbr: 'n', help: 'Sponsor name', mandatory: true)
    ..addOption('segment', abbr: 's', help: 'Sponsor segment', mandatory: true)
    ..addOption('owner', abbr: 'o', help: 'Relationship owner', mandatory: true)
    ..addOption('notes', abbr: 'x', help: 'Notes', defaultsTo: '');
}

ArgParser _logInteractionParser() {
  return ArgParser()
    ..addOption(
      'sponsor',
      abbr: 's',
      help: 'Sponsor name or ID',
      mandatory: true,
    )
    ..addOption(
      'date',
      abbr: 'd',
      help: 'Contact date (YYYY-MM-DD)',
      mandatory: true,
    )
    ..addOption(
      'channel',
      abbr: 'c',
      help: 'Channel (email, call, etc.)',
      mandatory: true,
    )
    ..addOption(
      'summary',
      abbr: 'm',
      help: 'Summary of interaction',
      mandatory: true,
    )
    ..addOption('next-step', abbr: 'n', help: 'Next step', defaultsTo: '')
    ..addOption(
      'sentiment',
      abbr: 't',
      help: 'Sentiment (-2 to 2)',
      defaultsTo: '0',
    );
}

ArgParser _listSponsorsParser() {
  return ArgParser()..addOption('limit', abbr: 'l', defaultsTo: '20');
}

ArgParser _recentInteractionsParser() {
  return ArgParser()..addOption('days', abbr: 'd', defaultsTo: '14');
}

ArgParser _weeklySummaryParser() {
  return ArgParser()..addOption(
    'weeks',
    abbr: 'w',
    defaultsTo: '1',
    help: 'Number of weeks back',
  );
}

ArgParser _sponsorHealthParser() {
  return ArgParser()
    ..addOption(
      'recency-days',
      abbr: 'r',
      defaultsTo: '30',
      help: 'Days to count recent interactions',
    )
    ..addOption(
      'sentiment-days',
      abbr: 's',
      defaultsTo: '90',
      help: 'Days to average sentiment over',
    )
    ..addOption(
      'stale-days',
      abbr: 't',
      defaultsTo: '45',
      help: 'Days without touchpoint to flag stale',
    )
    ..addOption(
      'warm-days',
      abbr: 'w',
      defaultsTo: '30',
      help: 'Days without touchpoint to flag slipping',
    );
}

Future<void> _handleAddSponsor(ArgResults command) async {
  final db = await SponsorPulseDb.connect();
  try {
    final id = await db.addSponsor(
      name: command['name'] as String,
      segment: command['segment'] as String,
      owner: command['owner'] as String,
      notes: command['notes'] as String,
    );
    stdout.writeln('Added sponsor #$id');
  } finally {
    await db.close();
  }
}

Future<void> _handleLogInteraction(ArgResults command) async {
  final sentiment = int.tryParse(command['sentiment'] as String) ?? 0;
  if (sentiment < -2 || sentiment > 2) {
    throw ArgumentError('Sentiment must be between -2 and 2');
  }

  final contactDate = DateTime.parse(command['date'] as String);

  final db = await SponsorPulseDb.connect();
  try {
    final id = await db.addInteraction(
      sponsor: command['sponsor'] as String,
      contactDate: contactDate,
      channel: command['channel'] as String,
      summary: command['summary'] as String,
      nextStep: command['next-step'] as String,
      sentiment: sentiment,
    );
    stdout.writeln('Logged interaction #$id');
  } finally {
    await db.close();
  }
}

Future<void> _handleListSponsors(ArgResults command) async {
  final limit = int.tryParse(command['limit'] as String) ?? 20;
  final db = await SponsorPulseDb.connect();
  try {
    final sponsors = await db.listSponsors(limit: limit);
    if (sponsors.isEmpty) {
      stdout.writeln('No sponsors found.');
      return;
    }
    for (final sponsor in sponsors) {
      stdout.writeln(
        '#${sponsor.id} | ${sponsor.name} | ${sponsor.segment} | Owner: ${sponsor.owner}',
      );
    }
  } finally {
    await db.close();
  }
}

Future<void> _handleRecentInteractions(ArgResults command) async {
  final days = int.tryParse(command['days'] as String) ?? 14;
  final db = await SponsorPulseDb.connect();
  try {
    final interactions = await db.recentInteractions(days: days);
    if (interactions.isEmpty) {
      stdout.writeln('No interactions found in the last $days days.');
      return;
    }
    for (final interaction in interactions) {
      stdout.writeln(
        '${_formatDate(interaction.contactDate)} | ${interaction.sponsorName} | ${interaction.channel} | ${interaction.summary}',
      );
    }
  } finally {
    await db.close();
  }
}

Future<void> _handleWeeklySummary(ArgResults command) async {
  final weeks = int.tryParse(command['weeks'] as String) ?? 1;
  final end = DateTime.now();
  final start = end.subtract(Duration(days: weeks * 7));

  final db = await SponsorPulseDb.connect();
  try {
    final interactions = await db.summaryWindow(start: start, end: end);
    final summary = buildSummary(interactions);
    stdout.writeln(renderSummary(summary, start: start, end: end));
  } finally {
    await db.close();
  }
}

Future<void> _handleSponsorHealth(ArgResults command) async {
  final recencyDays = int.tryParse(command['recency-days'] as String) ?? 30;
  final sentimentDays = int.tryParse(command['sentiment-days'] as String) ?? 90;
  final staleDays = int.tryParse(command['stale-days'] as String) ?? 45;
  final warmDays = int.tryParse(command['warm-days'] as String) ?? 30;
  final now = DateTime.now();

  final db = await SponsorPulseDb.connect();
  try {
    final metrics = await db.sponsorHealthMetrics(
      recencyDays: recencyDays,
      sentimentDays: sentimentDays,
    );
    final statuses = assessSponsorHealth(
      metrics,
      now: now,
      staleDays: staleDays,
      warmDays: warmDays,
    );
    stdout.writeln(renderHealthReport(statuses, asOf: now));
  } finally {
    await db.close();
  }
}

void _printUsage(ArgParser parser) {
  stdout.writeln('Sponsor Pulse CLI');
  stdout.writeln(
    'Usage: dart run bin/groupscholar_sponsor_pulse.dart <command> [options]',
  );
  stdout.writeln('');
  stdout.writeln('Commands:');
  stdout.writeln('  add-sponsor        Add a new sponsor');
  stdout.writeln('  log-interaction    Log a sponsor interaction');
  stdout.writeln('  list-sponsors      List sponsors');
  stdout.writeln('  recent-interactions  List recent interactions');
  stdout.writeln('  weekly-summary     Generate a weekly summary');
  stdout.writeln('  sponsor-health     Show sponsor health snapshot');
  stdout.writeln('');
  stdout.writeln(parser.usage);
}

String _formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
