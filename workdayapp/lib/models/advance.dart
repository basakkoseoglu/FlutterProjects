class Advance {
  final double amount;
  final DateTime date;
  final String? note;

  Advance({
    required this.amount,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'date': date.toIso8601String(),
        'note': note,
      };

  factory Advance.fromJson(Map<String, dynamic> json) {
    return Advance(
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      note: json['note'],
    );
  }
}
