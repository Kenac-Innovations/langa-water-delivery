import 'package:equatable/equatable.dart';
import 'package:langas_user/models/promotion_model.dart';
import 'package:langas_user/util/api_failure_models.dart';

abstract class PromotionsState extends Equatable {
  const PromotionsState();
  @override
  List<Object> get props => [];
}

class PromotionsInitial extends PromotionsState {}

class PromotionsLoading extends PromotionsState {}

class PromotionsLoadSuccess extends PromotionsState {
  final List<Promotion> promotions;
  const PromotionsLoadSuccess(this.promotions);
  @override
  List<Object> get props => [promotions];
}

class PromotionDetailLoadSuccess extends PromotionsState {
  final Promotion promotion;
  const PromotionDetailLoadSuccess(this.promotion);
  @override
  List<Object> get props => [promotion];
}

class PromotionsFailure extends PromotionsState {
  final Failure failure;
  const PromotionsFailure(this.failure);
  @override
  List<Object> get props => [failure];
}
