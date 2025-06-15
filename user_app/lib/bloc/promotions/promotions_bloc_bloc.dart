import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:langas_user/bloc/promotions/promotions_bloc_event.dart';
import 'package:langas_user/bloc/promotions/promotions_bloc_state.dart';
import 'package:langas_user/repository/promotions_repository.dart';

class PromotionsBloc extends Bloc<PromotionsEvent, PromotionsState> {
  final PromotionsRepository _promotionsRepository;

  PromotionsBloc({required PromotionsRepository promotionsRepository})
      : _promotionsRepository = promotionsRepository,
        super(PromotionsInitial()) {
    on<FetchAllPromotions>(_onFetchAllPromotions);
    on<FetchPromotionById>(_onFetchPromotionById);
  }

  Future<void> _onFetchAllPromotions(
      FetchAllPromotions event, Emitter<PromotionsState> emit) async {
    emit(PromotionsLoading());
    final result = await _promotionsRepository.getAllPromotions();
    result.fold(
      (failure) => emit(PromotionsFailure(failure)),
      (promotions) => emit(PromotionsLoadSuccess(promotions)),
    );
  }

  Future<void> _onFetchPromotionById(
      FetchPromotionById event, Emitter<PromotionsState> emit) async {
    emit(PromotionsLoading());
    final result = await _promotionsRepository.getPromotionById(event.id);
    result.fold(
      (failure) => emit(PromotionsFailure(failure)),
      (promotion) => emit(PromotionDetailLoadSuccess(promotion)),
    );
  }
}