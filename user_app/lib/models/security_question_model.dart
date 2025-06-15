import 'package:equatable/equatable.dart';

class SecurityQuestion extends Equatable {
  final int id;
  final String question;

  const SecurityQuestion({required this.id, required this.question});

  @override
  List<Object?> get props => [id, question];

  factory SecurityQuestion.fromJson(Map<String, dynamic> json) {
    return SecurityQuestion(
      id: json['id'] as int,
      question: json['question'] as String,
    );
  }
}
