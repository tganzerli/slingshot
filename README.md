# slingshot

[![pub package](https://img.shields.io/pub/v/slingshot.svg)](https://pub.dev/packages/slingshot)
[![pub points](https://img.shields.io/pub/points/slingshot)](https://pub.dev/packages/slingshot/score)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

**One contract for every database driver of the slingshot family: your domain code depends on the same transaction
lifecycle, repository interface and errors, whichever database sits underneath.**

slingshot is a family of database drivers for Dart backends built on native client libraries through `dart:ffi`,
with the connection pool living in native threads outside the Dart VM. Each database has its own package, so an
application installs only the driver it uses and never loads another database's client library.

This package is what those drivers agree on. It defines how a transaction begins, commits and rolls back, what a
repository looks like, and how failures reach your code. Every driver is checked against it by an executable
conformance battery, so the guarantees below hold for every driver that implements it, not just the first one.

## Features

- **`UnitOfWork<E>`:** one transaction lifecycle (`begin`, `commit`, `rollback`, idempotent `close`) for every
  driver. The executor type is the driver's own, so each database keeps its native query API instead of a lowest
  common denominator.
- **`Repository<T, K>`:** CRUD by primary key, written against your domain types. Swap it for an in-memory fake in
  tests without touching domain code.
- **One error taxonomy:** `QueryFailedException` (the server answered with an error), `QueryTimeoutException` (the
  query ran out of budget, the session survives), `ConnectionLostException` (the link dropped, nothing was
  committed) and `TransactionStateError` (an illegal lifecycle step). The same failure means the same thing in
  every driver.
- **Native library loading:** `openDriverLibrary` finds a driver's library from an environment override, next to
  the executable (AOT and Docker), inside the installed package or in a local build, and fails with the list of
  paths it tried. `assertNativeAbiCompatible` refuses a library built for another ABI.
- **No client library, no driver:** a small Dart package (`dart:ffi` and `dart:io`) that links nothing.

## Install

Applications normally get this package through a driver:

```sh
dart pub add slingshot_postgres
```

Depend on it directly when you write a driver, or code that must work with any of them:

```sh
dart pub add slingshot
```

## Usage

Application code depends only on the contract:

```dart
import 'package:slingshot/slingshot.dart';

Future<void> register<E extends Object>(
  UnitOfWork<E> uow,
  Repository<User, int> Function(E executor) users,
  List<User> newUsers,
) async {
  await uow.begin();
  try {
    final repo = users(uow.executor);
    for (final u in newUsers) {
      await repo.insert(u);
    }
    await uow.commit();
  } on QueryFailedException catch (e) {
    print('nothing was committed: ${e.serverMessage}');
    rethrow;
  } finally {
    await uow.close(); // rolls back if still active
  }
}
```

[`example/main.dart`](example/main.dart) implements the contract with a toy in-memory driver and runs with
`dart run`, no database needed. With PostgreSQL, the same code takes a `PostgresUnitOfWork` from
[`slingshot_postgres`](https://pub.dev/packages/slingshot_postgres).

## The family

| Package | Role |
|---|---|
| [`slingshot`](https://pub.dev/packages/slingshot) | This contract. |
| [`slingshot_postgres`](https://pub.dev/packages/slingshot_postgres) | PostgreSQL driver over `libpq`. |
| [`orbiter`](https://pub.dev/packages/orbiter) | HTTP backend framework, no database dependency. |
| [`orbiter_postgres`](https://pub.dev/packages/orbiter_postgres) | Kit for `orbiter` + `slingshot_postgres`: one row-level-security transaction per request. |

MySQL, MongoDB and SQLite drivers exist in the project and are not published yet.

## Versioning

Adding a member to `UnitOfWork` or `Repository` breaks every implementor, so it is a MAJOR release of this
package and must extend the conformance battery in the same change. A new error class, or a new optional field
on an existing one, is a MINOR release.

## Conformance battery

The [repository](https://github.com/tganzerli/slingshot) also holds `slingshot_conformance` in `conformance/`,
the executable half of the contract: each driver imports it as a `dev_dependency` from the tag that matches its
`slingshot` version and runs `runUnitOfWorkConformance` against its own database. It is not published on
pub.dev, so it is not part of this package's archive.

## Benchmarks and research

The project started as an MBA thesis in Software Engineering at the University of São Paulo (USP). The code
evaluated there, the cross-language benchmark suite (harnesses in six languages, Docker topologies, statistical
aggregation) and the results are public at
[tganzerli/dart_db_connector](https://github.com/tganzerli/dart_db_connector): see
[`benchmarks/RESULTS.md`](https://github.com/tganzerli/dart_db_connector/blob/main/benchmarks/RESULTS.md) and the
tag `tcc-baseline` for the evaluated state.

## License

MIT, see `LICENSE`.
