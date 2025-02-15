import 'package:honey_and_thyme/src/models/parsable.dart';

class PaginationResult<T extends Parsable> {
  List<T>? results;
  int? pageIndex;
  int? pageSize;
  int? pageCount;
  int? totalCount;

  PaginationResult({
    this.results,
    this.pageIndex,
    this.pageSize,
    this.pageCount,
    this.totalCount,
  });
}
