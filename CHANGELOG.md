# Changelog

## 1.0.4

Documentation only: README rewritten, a runnable example (`example/main.dart`, an in-memory driver), dartdoc on
the error types, shorter pubspec description. No API change.

## 1.0.3

First release on pub.dev. Renamed from `slingshot_core` to `slingshot`, the name of the family: there is no
umbrella package, each database has its own driver package that depends on this one. The repository moved with
it. No API change: only the package name, the library import (`package:slingshot/slingshot.dart`) and the
dependency key change. The conformance battery, kept in the repository and not published, takes this package from pub.dev too.

## 1.0.2

Renamed from `dart_db_connector_core` to `slingshot_core`; the repository moved with it. No API change: only the package
name, the library import (`package:slingshot_core/slingshot_core.dart`) and the dependency key change.

## 1.0.1

Packaging only; the contract is unchanged. The conformance battery in `conformance/` now depends on this
package by the same `git` url and tag that drivers use, so a driver can depend on both. With 1.0.0 the battery
referenced the core by relative path, which pub resolves as a different source and refuses.

## 1.0.0

First public release, consumed by `git` reference to the tag `v1.0.0`.

- Contract: `UnitOfWork<E>`, `Repository<T, K>`.
- Errors: `TransactionStateError`, `QueryFailedException`, `QueryTimeoutException`, `ConnectionLostException`.
- Native library resolution (`openDriverLibrary`, `LibNames`, `libraryFileName`, `detectPlatformId`) and the
  shared ABI check (`assertNativeAbiCompatible`).
- Conformance battery in `conformance/` (`runUnitOfWorkConformance`), versioned with this tag.
