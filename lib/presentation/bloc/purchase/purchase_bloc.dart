import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/purchase_repository.dart';
import 'purchase_event.dart';
import 'purchase_state.dart';

class PurchaseBloc extends Bloc<PurchaseEvent, PurchaseState> {
  final PurchaseRepository _purchaseRepository;

  PurchaseBloc(this._purchaseRepository) : super(PurchaseInitial()) {
    on<AddPurchase>(_onAddPurchase);
    on<LoadPurchases>(_onLoadPurchases);
    on<LoadPurchaseDetails>(_onLoadPurchaseDetails);
  }

  void _onAddPurchase(AddPurchase event, Emitter<PurchaseState> emit) async {
    emit(PurchaseLoading());
    try {
      await _purchaseRepository.createPurchase(event.purchase);
      emit(const PurchaseOperationSuccess('Purchase created successfully!'));
      // Reload purchases after adding a new one
      add(LoadPurchases());
    } catch (e) {
      emit(PurchaseError(e.toString()));
    }
  }

  void _onLoadPurchases(LoadPurchases event, Emitter<PurchaseState> emit) async {
    emit(PurchaseLoading());
    try {
      final purchases = await _purchaseRepository.getAllPurchases();
      emit(PurchasesLoaded(purchases));
    } catch (e) {
      emit(PurchaseError(e.toString()));
    }
  }

  void _onLoadPurchaseDetails(LoadPurchaseDetails event, Emitter<PurchaseState> emit) async {
     emit(PurchaseLoading());
    try {
      final purchase = await _purchaseRepository.getPurchaseById(event.purchaseId);
       if (purchase != null) {
        emit(PurchaseDetailsLoaded(purchase));
      } else {
        emit(const PurchaseError('Purchase not found.'));
      }
    } catch (e) {
      emit(PurchaseError(e.toString()));
    }
  }
}
