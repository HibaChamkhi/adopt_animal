import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../auth/domain/useCases/sign_out_use_case.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final SignOutUseCase signOutUseCase;
  ProfileCubit({required this.signOutUseCase}) : super(const ProfileState());

  Future<void> loggedOut() async {
    try {
      await signOutUseCase.call();
      emit(state.copyWith(isLoading: true, error: "",successLogout: false));
    } catch (_) {
      emit(state.copyWith(isLoading: true, error: "",successLogout: true));
    }
  }

}
