// A toy in-memory driver for the slingshot contract.
//
// Real drivers (slingshot_postgres) implement the same two interfaces over a
// database; application code written against `UnitOfWork` and `Repository`
// does not change when the driver does. Run with `dart run example/main.dart`.
import 'package:slingshot/slingshot.dart';

class User {
  final int id;
  final String name;
  const User(this.id, this.name);

  @override
  String toString() => 'User($id, $name)';
}

/// The "database": committed rows only.
final Map<int, User> _table = {};

/// The executor this driver hands out: a staging copy of the table.
class MemoryTx {
  final Map<int, User> rows;
  MemoryTx(this.rows);
}

class MemoryUnitOfWork implements UnitOfWork<MemoryTx> {
  MemoryTx? _tx;

  @override
  bool get isActive => _tx != null;

  @override
  MemoryTx get executor =>
      _tx ?? (throw TransactionStateError('executor read before begin()'));

  @override
  Future<void> begin() async {
    if (isActive) throw TransactionStateError('transaction already active');
    _tx = MemoryTx(Map.of(_table));
  }

  @override
  Future<void> commit() async {
    final tx = executor;
    _table
      ..clear()
      ..addAll(tx.rows);
    _tx = null;
  }

  @override
  Future<void> rollback() async {
    executor;
    _tx = null;
  }

  @override
  Future<void> close() async {
    if (isActive) await rollback();
  }
}

class UserRepository implements Repository<User, int> {
  final MemoryTx tx;
  UserRepository(this.tx);

  @override
  Future<User?> findById(int id) async => tx.rows[id];

  @override
  Future<List<User>> findAll() async => tx.rows.values.toList();

  @override
  Future<void> insert(User entity) async {
    if (tx.rows.containsKey(entity.id)) {
      throw QueryFailedException('INSERT users', 'duplicate key ${entity.id}');
    }
    tx.rows[entity.id] = entity;
  }

  @override
  Future<void> update(User entity) async => tx.rows[entity.id] = entity;

  @override
  Future<void> delete(int id) async => tx.rows.remove(id);
}

/// Application code: depends only on the contract.
Future<void> register(UnitOfWork<MemoryTx> uow, List<User> users) async {
  await uow.begin();
  try {
    final repo = UserRepository(uow.executor);
    for (final u in users) {
      await repo.insert(u);
    }
    await uow.commit();
  } finally {
    await uow.close();
  }
}

Future<void> main() async {
  await register(MemoryUnitOfWork(), [User(1, 'Ada'), User(2, 'Grace')]);
  print('committed: ${_table.values.toList()}');

  try {
    await register(
        MemoryUnitOfWork(), [User(3, 'Linus'), User(1, 'Ada again')]);
  } on QueryFailedException catch (e) {
    print('rolled back: $e');
  }
  print('still committed: ${_table.values.toList()}');
}
