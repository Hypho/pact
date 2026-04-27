# Release Process

PACT separates framework version checks from repository publishing.

---

## Levels

### Level 0: File-only

Default for every PACT project.

Requires:
- shell
- local files

Does not require:
- git
- GitHub
- network access

Checks:
- `VERSION` exists and uses `MAJOR.MINOR.PATCH`
- README / README.zh / CLAUDE versions match `VERSION`
- README version histories contain `v$VERSION`
- `CHANGELOG.md` contains `v$VERSION`
- public docs do not reference internal roadmap drafts
- `state.md` structure is valid
- state fixtures pass expected checks

Command:

```bash
bash .pact/bin/pact-check.sh
```

### Level 1: Git-aware

Optional for teams using local git, private repositories, GitLab, Gitea, Bitbucket, or similar systems.

Requires:
- git

Does not require:
- GitHub
- `gh`
- network access

Checks:
- current directory is inside a git repository
- working tree is clean
- current `VERSION` tag status
- if `v$VERSION` exists, it must point to the current commit

Command:

```bash
bash .pact/bin/pact-release-check.sh
```

This script reports readiness only. It does not create commits, tags, pushes, or releases.

### Level 2: GitHub-aware

Optional for maintainers publishing through GitHub Releases.

Requires:
- git
- GitHub access
- `gh`
- network access

This layer is intentionally documented, not built into the default PACT checks.

---

## Version Source

`VERSION` is the single editable version source.

Flow:

```text
VERSION -> README / README.zh / CLAUDE / CHANGELOG -> git tag -> GitHub Release
```

Do not derive the source version from git tags or GitHub Releases.

---

## Version Type

Use semantic versioning.

| Type | Use for |
|------|---------|
| PATCH | Documentation fixes, wording changes, release note corrections, non-contract script fixes |
| MINOR | Backward-compatible framework capabilities, optional checks, new templates, new lint rules |
| MAJOR | Incompatible protocol, state machine, command, or directory changes |

---

## File-only Release Preparation

1. Decide the next version.
2. Update `VERSION`.
3. Update version text in:
   - `README.md`
   - `README.zh.md`
   - `CLAUDE.md`
4. Add a new entry to:
   - `CHANGELOG.md`
   - README version history
   - README.zh version history
5. Run:

```bash
bash .pact/bin/pact-check.sh
```

This is enough for projects that do not use git.

---

## Git-aware Release Preparation

After file-only checks pass:

1. Run:

```bash
bash .pact/bin/pact-release-check.sh
```

2. Commit the release changes.
3. Run the git-aware check again.
4. Create a tag only after the commit is final:

```bash
git tag -a vX.Y.Z -m "PACT vX.Y.Z"
```

5. Push according to your team's repository workflow.

---

## GitHub Publishing

For the PACT public repository:

1. Push `main`.
2. Confirm GitHub Actions passed.
3. Push the release tag.
4. Create GitHub Release using the `CHANGELOG.md` entry as the source.
5. Confirm the GitHub Release exists and is not a draft.

---

## Freeze Rules

- A published git tag is immutable.
- Do not retag a released version.
- If source files are wrong after release, publish a PATCH version.
- GitHub Release notes may be clarified after release, but they must not imply source changes that did not happen.
- Internal roadmap notes remain local unless intentionally converted into public issues or milestones.
