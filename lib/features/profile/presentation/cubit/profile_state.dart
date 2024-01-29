part of 'profile_cubit.dart';

@immutable
 class ProfileState {


  final bool success;
  final bool successLogout;
  final int page;
  final String error;
  final bool isLoading;
  final bool loadingNextPage;
  final String loadNextPageError;

  final int currentPage;


  const ProfileState(
      {this.loadingNextPage = false,
        this.currentPage = 1,
        this.loadNextPageError = "",
        this.error = "",
        this.success = false,
        this.successLogout = false,
        this.isLoading = false,
        this.page = 1,});

  ProfileState copyWith({
    int? currentPage,
    bool? loadingNextPage,
    String? loadNextPageError,
    String? error,
    bool? isLoading,
    bool? success,
    bool? successLogout,
    bool? hasReachedMax,
    int? page,
  }) {
    return ProfileState(
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      success: success ?? this.success,
      successLogout: successLogout ?? this.successLogout,
      page: page ?? this.page,
      loadingNextPage: loadingNextPage ?? this.loadingNextPage,
      loadNextPageError: loadNextPageError ?? this.loadNextPageError,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [
    error,
    isLoading,
    success,
    successLogout,
    page,
    loadingNextPage,
    loadNextPageError,
    currentPage,
  ];
}
