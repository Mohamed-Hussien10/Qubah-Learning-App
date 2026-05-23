import '../entities/section_entity.dart';

abstract class SectionsRepository {
  Future<List<SectionEntity>> getSections(String parentId);
}
