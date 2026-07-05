import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/services/paginated_list.dart';

mixin PaginatedLoaderUi on GetxController {
  LoadingState get paginationContentState;
  PaginatedList<dynamic> get paginatedList;

  bool get showPaginationLoader =>
      paginationContentState == LoadingState.loaded &&
      paginatedList.showLoadMoreLoader;
}
