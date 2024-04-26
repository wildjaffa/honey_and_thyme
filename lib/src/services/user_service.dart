import '../models/bool_result.dart';
import 'api_service.dart';

class UserService {
  static Future<BoolResult> userSignedIn() {
    return ApiService.postRequest<BoolResult>(
        'api/users/signedIn', BoolResult.fromJson, '');
  }
}
