# slingshot_conformance

The conformance battery for the `slingshot` contract. The contract (`UnitOfWork`) declares the states; this
battery checks that a driver honours the transitions between them.

A driver imports it as a `dev_dependency`, from the same tag of the core repository it implements:

```yaml
dev_dependencies:
  slingshot_conformance:
    git:
      url: https://github.com/tganzerli/slingshot_core
      ref: v1.0.2
      path: conformance
```

and calls `runUnitOfWorkConformance` with an `open` callback that yields a fresh unit of work on its own
database. Not meant to be published.

## License

MIT, see `LICENSE`.
