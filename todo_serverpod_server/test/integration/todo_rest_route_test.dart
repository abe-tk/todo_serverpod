import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import 'package:todo_serverpod_server/src/web/middleware/api_error_middleware.dart';
import 'package:todo_serverpod_server/src/web/routes/todo_rest_route.dart';

import 'test_tools/serverpod_test_tools.dart';

class _HttpResult {
  final int statusCode;
  final String body;

  const _HttpResult(this.statusCode, this.body);
}

void main() {
  withServerpod('Given Todo REST routes', (sessionBuilder, endpoints) {
    late Uri baseUri;

    setUpAll(() async {
      baseUri = await _setupRestRoutesAndResolveBaseUri(sessionBuilder);
    });

    setUp(() async {
      final todos = await endpoints.todo.getTodos(
        sessionBuilder,
        sortBy: 'createdAt',
        order: 'asc',
      );
      for (final todo in todos) {
        await endpoints.todo.deleteTodo(sessionBuilder, id: todo.id!);
      }
    });

    test('POST then GET by id returns created todo', () async {
      final created = await _request(
        baseUri,
        'POST',
        '/api/todos',
        jsonBody: {'title': 'Buy milk'},
      );
      expect(created.statusCode, 200);
      final createdJson = jsonDecode(created.body) as Map<String, dynamic>;
      final id = createdJson['id'] as int;

      final fetched = await _request(baseUri, 'GET', '/api/todos/$id');
      expect(fetched.statusCode, 200);
      final fetchedJson = jsonDecode(fetched.body) as Map<String, dynamic>;
      expect(fetchedJson['title'], 'Buy milk');
    });

    test('GET list supports sortBy and order', () async {
      final now = DateTime.now().toUtc();
      await _request(
        baseUri,
        'POST',
        '/api/todos',
        jsonBody: {
          'title': 'First',
          'dueDate': now.add(const Duration(days: 1)).toIso8601String(),
        },
      );
      await _request(
        baseUri,
        'POST',
        '/api/todos',
        jsonBody: {
          'title': 'Second',
          'dueDate': now.add(const Duration(days: 2)).toIso8601String(),
        },
      );

      final listed = await _request(
        baseUri,
        'GET',
        '/api/todos?sortBy=dueDate&order=desc',
      );
      expect(listed.statusCode, 200);
      final listJson = jsonDecode(listed.body) as List<dynamic>;
      final titles = listJson
          .map((e) => (e as Map<String, dynamic>)['title'] as String)
          .toList();
      final secondIndex = titles.indexOf('Second');
      final firstIndex = titles.indexOf('First');
      expect(secondIndex, isNonNegative);
      expect(firstIndex, isNonNegative);
      expect(secondIndex, lessThan(firstIndex));
    });

    test('PATCH does not overwrite createdAt', () async {
      const createdAt = '2026-02-01T00:00:00.000Z';
      final created = await _request(
        baseUri,
        'POST',
        '/api/todos',
        jsonBody: {'title': 'Before', 'createdAt': createdAt},
      );
      final createdJson = jsonDecode(created.body) as Map<String, dynamic>;
      final id = createdJson['id'] as int;

      final patched = await _request(
        baseUri,
        'PATCH',
        '/api/todos/$id',
        jsonBody: {
          'title': 'After',
          'createdAt': '2030-01-01T00:00:00.000Z',
        },
      );
      expect(patched.statusCode, 200);
      final patchedJson = jsonDecode(patched.body) as Map<String, dynamic>;
      expect(patchedJson['createdAt'], createdAt);
      expect(patchedJson['title'], 'After');
    });

    test('GET missing id returns 404 with errorCode', () async {
      final response = await _request(baseUri, 'GET', '/api/todos/999999');
      expect(response.statusCode, 404);
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      expect(body['errorCode'], 'NOT_FOUND');
    });
  });
}

Future<Uri> _setupRestRoutesAndResolveBaseUri(
  TestSessionBuilder sessionBuilder,
) async {
  final dynamic builder = sessionBuilder;
  final dynamic session = builder.internalBuild(
    endpoint: 'todo',
    method: 'restTestBootstrap',
  );
  try {
    final webServer = session.serverpod.webServer;
    webServer.addMiddleware(apiErrorMiddleware(), '/api');
    webServer.addRoute(TodoRestRoute(), '/api/todos');
    if (webServer.port == null) {
      await webServer.start();
    }

    final int port = webServer.port as int;
    return Uri(scheme: 'http', host: '127.0.0.1', port: port);
  } finally {
    await session.close();
  }
}

Future<_HttpResult> _request(
  Uri baseUri,
  String method,
  String path, {
  Map<String, dynamic>? jsonBody,
}) async {
  final client = HttpClient();
  try {
    final request = await client.openUrl(method, baseUri.resolve(path));
    request.headers.contentType = ContentType.json;
    if (jsonBody != null) {
      request.write(jsonEncode(jsonBody));
    }
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    return _HttpResult(response.statusCode, body);
  } finally {
    client.close(force: true);
  }
}
