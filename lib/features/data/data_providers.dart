import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flasholator/features/data/application/data_table_state.dart';
import 'package:flasholator/features/data/application/data_table_view_model.dart';
import 'package:flasholator/features/flashcards/flashcard_providers.dart';

final dataTableViewModelProvider =
    StateNotifierProvider<DataTableViewModel, DataTableState>((ref) =>
        DataTableViewModel(ref.watch(flashcardRepositoryProvider)));
