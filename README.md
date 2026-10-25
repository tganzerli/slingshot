# slingshot

The contract shared by every driver package of the slingshot family (`slingshot_postgres` and the others). It carries no driver and links no client
library; it holds only what every driver must agree on:

- `UnitOfWork<E>`: the transaction lifecycle, generic in the driver's own executor type. The shape of a query is
  deliberately not part of the contract.
- `Repository<T, K>`: CRUD by primary key.
- `TransactionStateError`, `QueryFailedException`, `QueryTimeoutException`, `ConnectionLostException`: how
  failure reaches the caller.
- `openDriverLibrary` and `assertNativeAbiCompatible`: how a driver finds its native library and validates its
  ABI.

Applications normally do not depend on this package directly; they get it through a driver such as
[`slingshot_postgres`](https://github.com/tganzerli/slingshot_postgres).

Experimental (pre-1.0 drivers). A driver depends on it from pub.dev:

```yaml
dependencies:
  slingshot: ^1.0.3
```

## Versioning

Adding a member to `UnitOfWork` or `Repository` breaks every implementor, so it is a MAJOR release of this
package and must extend the conformance battery in the same change. A new error class, or a new optional field
on an existing one, is a MINOR release.

## Conformance battery

The [repository](https://github.com/tganzerli/slingshot) also holds `slingshot_conformance` in `conformance/`,
the executable half of the contract: each driver imports it as a `dev_dependency` from the tag that matches its
`slingshot` version and runs `runUnitOfWorkConformance` against its own database. It is not published on
pub.dev, so it is not part of this package's archive.

## License

MIT, see `LICENSE`.
