import 'package:dartz/dartz.dart';
import 'package:sonara/core/domain/usecase/failure.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}
