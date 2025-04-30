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
}
