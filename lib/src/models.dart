class Sponsor {
  Sponsor({
    required this.id,
    required this.name,
    required this.segment,
    required this.owner,
    required this.notes,
  });

  final int id;
  final String name;
  final String segment;
  final String owner;
  final String notes;
}

class Interaction {
  Interaction({
    required this.id,
    required this.sponsorName,
    required this.contactDate,
    required this.channel,
    required this.summary,
    required this.nextStep,
    required this.sentiment,
  });

  final int id;
  final String sponsorName;
  final DateTime contactDate;
  final String channel;
  final String summary;
  final String nextStep;
  final int sentiment;
}
