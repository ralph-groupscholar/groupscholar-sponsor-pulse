import 'package:groupscholar_sponsor_pulse/groupscholar_sponsor_pulse.dart';
import 'package:test/test.dart';

void main() {
  test('buildSummary aggregates interactions', () {
    final interactions = [
      Interaction(
        id: 1,
        sponsorName: 'North Star Fund',
        contactDate: DateTime(2026, 2, 2),
        channel: 'email',
        summary: 'Shared mid-year progress.',
        nextStep: 'Schedule Q2 briefing.',
        sentiment: 1,
      ),
      Interaction(
        id: 2,
        sponsorName: 'North Star Fund',
        contactDate: DateTime(2026, 2, 3),
        channel: 'call',
        summary: 'Reviewed renewal timeline.',
        nextStep: 'Send updated budget slide.',
        sentiment: 2,
      ),
      Interaction(
        id: 3,
        sponsorName: 'Aspire Foundation',
        contactDate: DateTime(2026, 2, 4),
        channel: 'email',
        summary: 'Followed up on impact report.',
        nextStep: '',
        sentiment: 0,
      ),
    ];

    final result = buildSummary(interactions);

    expect(result.totalInteractions, 3);
    expect(result.bySponsor['North Star Fund'], 2);
    expect(result.bySponsor['Aspire Foundation'], 1);
    expect(result.byChannel['email'], 2);
    expect(result.byChannel['call'], 1);
    expect(result.avgSentiment, closeTo(1.0, 0.0001));
    expect(result.nextSteps.length, 2);
  });

  test('assessSponsorHealth labels risk and actions', () {
    final now = DateTime(2026, 2, 8);
    final metrics = [
      SponsorHealthMetric(
        id: 1,
        name: 'North Star Fund',
        segment: 'National Foundation',
        owner: 'Avery Kim',
        lastContactDate: DateTime(2026, 1, 1),
        recentInteractions: 0,
        avgSentiment: -1.5,
      ),
      SponsorHealthMetric(
        id: 2,
        name: 'Aspire Foundation',
        segment: 'Regional Partner',
        owner: 'Samir Patel',
        lastContactDate: DateTime(2026, 2, 5),
        recentInteractions: 2,
        avgSentiment: 1.0,
      ),
      SponsorHealthMetric(
        id: 3,
        name: 'Harbor Giving Circle',
        segment: 'Community Partner',
        owner: 'Lena Torres',
        lastContactDate: null,
        recentInteractions: 0,
        avgSentiment: null,
      ),
    ];

    final statuses = assessSponsorHealth(metrics, now: now);

    expect(statuses.first.metric.name, 'Harbor Giving Circle');
    expect(statuses.first.riskLabel, 'Unengaged');
    expect(statuses.first.recommendedAction, 'Start intro outreach');

    final northStar = statuses.firstWhere(
      (status) => status.metric.name == 'North Star Fund',
    );
    expect(northStar.riskLabel, 'At-Risk');
    expect(northStar.flags.contains('Negative sentiment'), true);

    final aspire = statuses.firstWhere(
      (status) => status.metric.name == 'Aspire Foundation',
    );
    expect(aspire.riskLabel, 'Healthy');
  });
}
