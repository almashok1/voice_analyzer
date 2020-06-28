import 'dart:io';
import 'package:dio/dio.dart';
import 'package:voice_analyzer/model/emojis_model.dart';
import 'package:voice_analyzer/repository/user_repository.dart';

class ApiConnection {
  static final ApiConnection _apiConnection = ApiConnection._internal();
  static final Dio _dio = Dio();
  static String _url = "http://95.56.249.38:8011";

  factory ApiConnection() {
    _dio.options.headers['Content-Type'] = 'application/json';
    return _apiConnection;
  }

  ApiConnection._internal();

  void createUser({String username, String password, String email}) async {
    final data = {
      "user_name": username,
      "password": password,
      "email": email,
    };
    String pref = "/user";
    Response response = await _dio.put(
      _url + pref,
      data: data,
    );
  }

  Future getUser({String username, String password}) async {
    String pref = "/user";
    final data = {
      "user_name": username,
      "password": password,
    };
    Response response = await _dio.post(
      _url + pref,
      data: data,
    );
    return response.data;
  }

  Future<bool> sendToBackEnd(String path) async {
    String pref = "/mobile_upload";
    String fileName = path.split('/').last;
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(path, filename: fileName),
      "user": await UserRepository.getId(),
    });
    try {
      final Response response = await _dio.post(
        _url + pref,
        data: formData,
        options: Options(
          contentType: "application/x-www-form-_urlencoded",
        ),
      );
      if (response.data['sucsess'].toString() == '200') {
        await putRecord(fileName, path).catchError((e) {
          throw e;
        });
        return true;
      } else {
        File file = File(path);
        file.deleteSync();
        throw Exception('Не удалось загрузить запись');
      }
    } on DioError {
      File file = File(path);
      await file.delete().catchError((_) {});
      throw Exception("Ошибка сети");
    } on Exception catch (e) {
      File file = File(path);
      await file.delete().catchError((_) {});
      throw e;
    } catch (e) {
      File file = File(path);
      await file.delete().catchError((_) {});
      throw Exception("Ошибка загрузки");
    }
  }

  Future<void> putRecord(String filename, String path) async {
    String pref = "/record";

    final data = {"name": filename, "user": await UserRepository.getId()};
    try {
      Response response = await _dio.put(_url + pref, data: data);
      if (response.statusCode != 200) {
        File file = File(path);
        file.deleteSync();
        throw Exception('Не удалось загрузить запись');
      }
      if (response.data.toString().contains('error'))
        throw Exception('Ошибка прогнозирования');
    } on Exception catch (e) {
      File file = File(path);
      await file.delete().catchError((_) {});
      throw e;
    } catch (e) {
      File file = File(path);
      await file.delete().catchError((_) {});
      throw Exception("Ошибка загрузки");
    }
  }

  Future<List<EmojisModel>> getAllRecords() async {
    String pref = "/record";
    int id = await UserRepository.getId();
    final data = {"user": id};
    Response response = await _dio.post(_url + pref, data: data);
    List<EmojisModel> list = [];
    for (var i in response.data) {
      if ((i['emotion_data'] != null ||
              i['emotion_data'].toString().trim() != 'null') &&
          !i['emotion_data'].toString().contains('error')) {
        list.add(EmojisModel.fromJson(i));
      }
    }
    return list;
  }
}
