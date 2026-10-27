# Patrol Dispatch actions

GitHub Actions for Patrol Dispatch.

## create-build

`create-build` builds the app in develop mode and keeps the build with Patrol Dispatch, unless a
kept build already fits the checkout. Patrol Dispatch refuses a session or test run on a commit
that no kept build fits.

Put the action in `.github/workflows/patrol-dispatch-build.yml` on your default branch, after your
toolchain steps. The job authenticates with the workflow's identity token, so the workflow needs
`id-token: write` and no secret. If the workflow is missing, your project's settings page in the
Patrol Dispatch dashboard links to GitHub with the whole workflow already written.

```yaml
permissions:
  contents: read
  id-token: write

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
        with:
          persist-credentials: false
      # Your toolchain steps: Java, Flutter and `flutter pub get`.
      - uses: leancodepl/patrol-dispatch-actions/create-build@v0
```

[`action.yml`](create-build/action.yml) describes the inputs.

## Versions

`v0` points at the newest `0.y.z` release. No input is removed or renamed behind `v0`, and no
behavior changes in a way that breaks a workflow. Such a change ships as `v1`.

To pin a commit instead, write the version beside it. Dependabot then updates both:

```yaml
- uses: leancodepl/patrol-dispatch-actions/create-build@<commit sha> # v0.1.0
```

The action installs the newest Patrol Dispatch CLI from the control plane in every job. A fix to
the CLI reaches you without a new version of the action.

[`CHANGELOG.md`](CHANGELOG.md) lists every release.

## Releasing

1. Open a pull request that moves the `Unreleased` entries in `CHANGELOG.md` under
   `## [0.y.z] - <date>`, and merge it.
2. Publish the release from the merge commit:

   ```bash
   gh release create v0.y.z -R leancodepl/patrol-dispatch-actions --target <commit sha> --title v0.y.z --notes "<the version's section>"
   ```

3. Move `v0` to the same commit:

   ```bash
   gh api -X PATCH repos/leancodepl/patrol-dispatch-actions/git/refs/tags/v0 -f sha=<commit sha> -F force=true
   ```

A published release is immutable, so a mistake ships as the next version.
