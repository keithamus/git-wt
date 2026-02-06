# git-wt

Share untracked files across [git worktrees] via symlinks.

If you use multiple worktrees, you've probably run into this: config files,
local overrides, `node_modules`, compilation target directories (e.g. Rust's
`target/`), or caches; files that aren't committed but need to exist in every
worktree, taking up space or being awkwardly synced by hand across all your
worktrees.

`git-wt` solves this by storing shared files centrally
(inside `.git/wt-shared/`) and symlinking them into each worktree. `git-wt`
manages all of this so that `git worktree add` will symlink all of these files
into the new worktree, and adding new files across all worktrees is just one
command away.

Typical workflow:

```bash
# Be in a worktree
$ pwd
~/Code/csskit-4

# Make a file you want to share in all worktrees
$ nvim .mise.local.toml

# Ugh... now I need to track it across my 10 different git worktrees
$ git wt add .mise.local.toml

csskit:
  ok  .mise.local.toml
csskit-2:
  ok  .mise.local.toml
csskit-3:
  ok  .mise.local.toml
csskit-4:
  ok  .mise.local.toml
csskit-5:
  ok  .mise.local.toml
csskit-6:
  ok  .mise.local.toml
csskit-7:
  ok  .mise.local.toml
csskit-8:
  ok  .mise.local.toml
csskit-9:
  ok  .mise.local.toml
csskit-10:
  ok  .mise.local.toml

# Ahhh. Life is much better now
```

## Install

`git-wt` is just a bash script, save it anywhere, or you can clone and run
`make`:

```bash
# Clone and install
git clone https://github.com/keithamus/git-wt.git
cd git-wt
# installs to /usr/local/bin
make install
# or installs to a custom dir (~/.local/bin in this case)
make install PREFIX=~/.local
```

Once `git-wt` is on your `PATH`, git automatically picks it up as `git wt`.

## Usage

### Add a file

From any worktree, start sharing a file:

```bash
git wt add .mise.local.toml
```

This moves `.mise.local.toml` into shared storage and symlinks it back into **every**
worktree.

### Sync all worktrees

Re-sync symlinks (idempotent, safe to run anytime):

```bash
git wt sync
```

### Check health

See which worktrees have correct symlinks:

```bash
git wt status
```

```
main:
  ok  .mise.local.toml
  ok  .env.local
feature-branch:
  ok  .mise.local.toml
  !!  .env.local (real file, not symlinked)
```

### Remove a file

Restore the real file to the current worktree and remove symlinks from all others:

```bash
git wt rm .mise.local.toml
```

### List tracked files

```bash
git wt list
```

### Auto-sync new worktrees

Install a `post-checkout` hook so that `git worktree add` automatically syncs shared files:

```bash
git wt hook install    # adds hook to .git/hooks/post-checkout
git wt hook uninstall  # removes it
```

## How it works

```bash
.git/
  wt-shared/          # central storage for shared files
    .manifest         # list of tracked filenames
    .mise.local.toml  # the actual file
    .env.local
  hooks/
    post-checkout     # optional auto-sync hook

worktree-1/
  .mise.local.toml    # ../.git/wt-shared/.mise.local.toml
  .env.local          # ../.git/wt-shared/.env.local

worktree-2/
  .mise.local.toml    # ../.git/wt-shared/.mise.local.toml
  .env.local          # ../.git/wt-shared/.env.local
```

- Files are stored once in `.git/wt-shared/` and symlinked everywhere.
- A plain-text `.manifest` file tracks which files are shared.
- If a real (non-symlinked) file exists in a worktree during sync, it's backed
  up as `<file>.wt-backup` before being replaced.
- `git rev-parse --git-common-dir` ensures the shared directory is always the
  same regardless of which worktree you run from.

### P(otentially) FAQ

Q: What do you use this for?

A: I use this for:

- `.mise.local.toml` across various worktrees.
- my various `mozconfig` and `mozconfig-*` configs across my Firefox worktrees
- syncing `target/` to avoid having hundreds of GB of Rust artefacts
- syncing `node_modules/`, arguably the only folder which can get larger than `target/`.
- Planning world domination one shell script at a time.

Q: What happens if a file already exists in a worktree during sync?

A: It gets backed up as `<file>.wt-backup` before the symlink is created.
Nothing is silently overwritten.

Q: Can I share directories?

A: Yes. Symlinks to directories work just fine, so `git wt add node_modules`
or `git wt add target` does what you'd expect.

Q: What if I delete a worktree?

A: Shared files live in `.git/wt-shared/`, not in any worktree. Deleting a
worktree just removes its symlinks — the real files are safe. Just don't
delete the `.git` directory itself, as that's where everything is stored.

Q: Does this work with `.gitignore`?

A: `git-wt` is for files that aren't committed, but the symlinks themselves
still show up as untracked. You'll want the shared paths in `.gitignore`
(which you probably already have if they were untracked to begin with).

Q: This already exists!

A: That's a statement not a question! But if it did, I didn't know. Let me know
please, I'll happily use that instead.

## License

MIT

[git worktrees]: https://git-scm.com/docs/git-worktree
