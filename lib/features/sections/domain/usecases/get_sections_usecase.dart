import '../../../../core/utils/usecase.dart';
import '../entities/section_entity.dart';
import '../repositories/sections_repository.dart';

class GetSectionsUseCase implements UseCase<List<SectionEntity>, String> {
  final SectionsRepository repository;

  GetSectionsUseCase(this.repository);

  @override
  Future<List<SectionEntity>> call(String params) {
    return repository.getSections(params);
  }
}
