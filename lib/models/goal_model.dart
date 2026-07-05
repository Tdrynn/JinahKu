class Goal {
  int? id;
  String name;
  double target;
  double collected;
  String targetDate;
  String? note;
  bool reminder;
  String? image;

  Goal({
    this.id,
    required this.name,
    required this.target,
    this.collected = 0,
    required this.targetDate,
    this.note,
    this.reminder = false,
    this.image,
  });
}