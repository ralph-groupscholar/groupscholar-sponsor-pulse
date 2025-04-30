import 'package:postgres/postgres.dart';

import 'config.dart';
import 'models.dart';

class SponsorPulseDb {
  SponsorPulseDb(this._connection);

  final Connection _connection;

  static Future<SponsorPulseDb> connect() async {
    final config = DbConfig.fromEnv();
    final connection = await Connection.openFromUrl(config.toConnectionString());
    return SponsorPulseDb(connection);
  }

  Future<void> close() => _connection.close();

  Future<List<Sponsor>> listSponsors({int limit = 20}) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT id, name, segment, owner, notes
        FROM groupscholar_sponsor_pulse.sponsors
        ORDER BY created_at DESC
        LIMIT @limit
      '''),
      parameters: {'limit': limit},
    );

    return result
        .map(
          (row) => Sponsor(
            id: row[0] as int,
            name: row[1] as String,
            segment: row[2] as String,
            owner: row[3] as String,
            notes: row[4] as String? ?? '',
          ),
        )
        .toList();
  }

  Future<int> addSponsor({
    required String name,
    required String segment,
    required String owner,
    required String notes,
  }) async {
    final result = await _connection.execute(
      Sql.named('''
        INSERT INTO groupscholar_sponsor_pulse.sponsors
          (name, segment, owner, notes)
        VALUES (@name, @segment, @owner, @notes)
        RETURNING id
      '''),
      parameters: {
        'name': name,
        'segment': segment,
        'owner': owner,
        'notes': notes,
      },
    );
    return result.first[0] as int;
  }

  Future<int> _resolveSponsorId(String sponsor) async {
    final parsed = int.tryParse(sponsor);
    if (parsed != null) {
      return parsed;
    }

    final result = await _connection.execute(
      Sql.named('''
        SELECT id
        FROM groupscholar_sponsor_pulse.sponsors
        WHERE LOWER(name) = LOWER(@name)
        LIMIT 1
      '''),
      parameters: {'name': sponsor},
    );

    if (result.isEmpty) {
      throw StateError('Sponsor not found: $sponsor');
    }

    return result.first[0] as int;
  }

  Future<int> addInteraction({
    required String sponsor,
    required DateTime contactDate,
    required String channel,
    required String summary,
    required String nextStep,
    required int sentiment,
  }) async {
    final sponsorId = await _resolveSponsorId(sponsor);

    final result = await _connection.execute(
      Sql.named('''
        INSERT INTO groupscholar_sponsor_pulse.interactions
          (sponsor_id, contact_date, channel, summary, next_step, sentiment)
        VALUES (@sponsorId, @contactDate, @channel, @summary, @nextStep, @sentiment)
        RETURNING id
      '''),
      parameters: {
        'sponsorId': sponsorId,
        'contactDate': contactDate,
        'channel': channel,
        'summary': summary,
        'nextStep': nextStep,
        'sentiment': sentiment,
      },
    );

    return result.first[0] as int;
  }

  Future<List<Interaction>> recentInteractions({int days = 14}) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT i.id,
               s.name,
               i.contact_date,
               i.channel,
               i.summary,
               i.next_step,
               i.sentiment
        FROM groupscholar_sponsor_pulse.interactions i
        JOIN groupscholar_sponsor_pulse.sponsors s ON s.id = i.sponsor_id
        WHERE i.contact_date >= CURRENT_DATE - (@days::int)
        ORDER BY i.contact_date DESC, i.created_at DESC
      '''),
      parameters: {'days': days},
    );

    return result
        .map(
          (row) => Interaction(
            id: row[0] as int,
            sponsorName: row[1] as String,
            contactDate: row[2] as DateTime,
            channel: row[3] as String,
            summary: row[4] as String,
            nextStep: row[5] as String? ?? '',
            sentiment: row[6] as int,
          ),
        )
        .toList();
  }

  Future<List<Interaction>> summaryWindow({
    required DateTime start,
    required DateTime end,
  }) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT i.id,
               s.name,
               i.contact_date,
               i.channel,
               i.summary,
               i.next_step,
               i.sentiment
        FROM groupscholar_sponsor_pulse.interactions i
        JOIN groupscholar_sponsor_pulse.sponsors s ON s.id = i.sponsor_id
        WHERE i.contact_date >= @start
          AND i.contact_date <= @end
        ORDER BY i.contact_date DESC, i.created_at DESC
      '''),
      parameters: {
        'start': start,
        'end': end,
      },
    );

    return result
        .map(
          (row) => Interaction(
            id: row[0] as int,
            sponsorName: row[1] as String,
            contactDate: row[2] as DateTime,
            channel: row[3] as String,
            summary: row[4] as String,
            nextStep: row[5] as String? ?? '',
            sentiment: row[6] as int,
          ),
        )
        .toList();
  }
}
