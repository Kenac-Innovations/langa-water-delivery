import 'package:equatable/equatable.dart';

abstract class PromotionsEvent extends Equatable {
  const PromotionsEvent();
  @override
  List<Object> get props => [];
}

class FetchAllPromotions extends PromotionsEvent {}

class FetchPromotionById extends PromotionsEvent {
  final int id;
  const FetchPromotionById(this.id);
  @override
  List<Object> get props => [id];
}