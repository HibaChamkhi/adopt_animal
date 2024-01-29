
import '../../domain/repository/profile_repository_impl.dart';
import '../dataSources/profile_remote_data_sources.dart';

class ProfileRepositoryImpl implements ProfileRepository {

  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});


}