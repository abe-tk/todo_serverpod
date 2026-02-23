# todo_serverpod

Flutter + Serverpod で構築した ToDo アプリです。  

## 前提条件

以下が実行できることを確認してください。

- Flutter: `flutter doctor`（`No issues found` が目安）
- Serverpod CLI: `serverpod`
- Docker: `docker info`

## clone 後のセットアップ（DB + API）

```bash
# 1) clone
git clone <YOUR_REPOSITORY_URL>
cd todo_serverpod

# 2) 依存関係取得（workspace ルート）
dart pub get

# 3) DB コンテナ起動
cd todo_serverpod_server
docker compose up -d

# 4) マイグレーション適用 + API起動
dart run bin/main.dart --apply-migrations
```

API は通常 `http://localhost:8080`、Web API は `http://localhost:8082` で待ち受けます。

## App の起動

別ターミナルで実行:

```bash
cd todo_serverpod_flutter
flutter run -d chrome
```


## API の利用方法

このプロジェクトには `Todo` の API が 2 系統あります。

- RPC: Serverpod endpoint（Flutter クライアントから利用）
- REST: `/api/todos`（curl / 外部クライアントから利用）

### REST API

Base URL: `http://localhost:8082/api/todos`

```bash
# 一覧取得（sortBy: createdAt|updatedAt|dueDate, order: asc|desc）
curl "http://localhost:8082/api/todos?sortBy=createdAt&order=asc"

# 1件取得
curl "http://localhost:8082/api/todos/1"

# 作成
curl -X POST "http://localhost:8082/api/todos" \
  -H "Content-Type: application/json" \
  -d '{"title":"牛乳を買う","description":"スーパーに寄る","isDone":false}'

# 更新（部分更新）
curl -X PATCH "http://localhost:8082/api/todos/1" \
  -H "Content-Type: application/json" \
  -d '{"title":"牛乳と卵を買う","isDone":true}'

# 削除
curl -X DELETE "http://localhost:8082/api/todos/1"
```

### RPC API（Flutter から）

`todo_serverpod_flutter` では `todo_serverpod_client` を利用します。

```dart
final todos = await client.todo.getTodos(sortBy: 'createdAt', order: 'asc');
await client.todo.addTodo(todo: Todo(title: '買い物'));
await client.todo.updateTodo(todo: todo.copyWith(isDone: true));
await client.todo.deleteTodo(id: todo.id!);
```

## 開発メモ（DB マイグレーション）

1. `.spy.yaml` を更新
2. `serverpod generate`
3. `serverpod create-migration`（必要に応じて `--force`）
4. `dart run bin/main.dart --apply-migrations`
