# Spec: `git tree [<commit>] [<commit>]`

Tracking issue: [#6](https://github.com/wteuber/git-status-tree/issues/6)

## 1. Summary

Today `git tree` only visualizes the **working tree status** (`git status
--porcelain`). This spec adds two new modes so the same tree rendering can be
used to inspect history:

| Invocation | Meaning | Source command |
| --- | --- | --- |
| `git tree` | Current working-tree status (unchanged) | `git status --porcelain -z` |
| `git tree <commit>` | Files changed **in** `<commit>` (vs. its first parent) | `git diff-tree … -r <commit>` |
| `git tree <commit> <commit>` | Files that differ **between** the two commits | `git diff-tree … -r <c1> <c2>` |

`<commit>` is any revision git accepts: SHA, `HEAD`, `HEAD~3`, a branch, or a tag.
The two-commit form may also be written as a single `A..B` token (see §8).

### Decisions (locked)

- **Rename detection:** `-M` only (arrows, like status mode). No `-C`. — §5.2, §6
- **Commit-view color:** a distinct third color (cyan) for all commit-mode
  entries, separate from the green=staged / red=dirty working-tree palette. — §6
- **Range syntax:** support `A..B` as a single arg; reject `A...B` with a clear
  error (diff-tree silently returns nothing for `...`). — §7, §8

## 2. Goals / Non-goals

**Goals**
- Reuse the existing `Node` / `NodesCollection` rendering pipeline verbatim.
- Keep `git tree` (no args) byte-for-byte identical to today's output.
- Support rename/copy detection in commit views (arrow display like status mode).
- Honor existing `-i/--indent` and `-c/--collapse` options in all three modes.
- Fail gracefully on invalid revisions.

**Non-goals**
- No diff *content* (hunks/line changes) — only the name-status tree.
- `-u/--untracked-files` is meaningless for commits and is ignored in commit modes.
- No commit-range syntax beyond two positional args (`A..B`, `A...B` are out of
  scope for now; see §8).

## 3. Current architecture (relevant pieces)

- [bin/git-status-tree](../../bin/git-status-tree) parses options with
  `OptionParser`, then calls `GitStatusTree.new(options)`.
- [src/git_status_tree.rb](../../src/git_status_tree.rb) `#initialize` runs
  `git status --porcelain -z`, splits it into **porcelain entry strings**, and
  maps each through `Node.create_from_string`.
- A porcelain entry string has the shape `XY<space>path` (two status columns, a
  space, then the path). Renames are normalized to `XY<orig> -> <dest>`.
- [lib/node.rb](../../lib/node.rb) `Node.status` reads `gs[0]`/`gs[1]` and the
  path from `gs[3..]`. When the second column is a space it marks the entry
  *staged* (`"#{c0}+"`, rendered **green**); otherwise it renders **red**.

The key realization: **everything downstream of `parse_status` only speaks the
porcelain entry-string format.** So the cleanest implementation translates
`git diff-tree` output into that same format and feeds it to the unchanged
node pipeline.

## 4. Output-format differences to bridge

`git diff-tree --name-status` does **not** use the porcelain layout. With `-z`:

```
# status -z (today):      "<XY> path\0"           rename: "<XY> dest\0orig\0"
# diff-tree -z (new):     "<S>\0path\0"            rename: "R100\0old\0new\0"
```

Differences the translator must handle:

1. **Status width.** diff-tree emits a *single* status letter (`A C D M R T U X B`),
   optionally with a similarity score for renames/copies (`R100`, `C075`). The
   status letter is its **own** NUL token, separate from the path.
2. **Rename token order is reversed vs. status mode.** diff-tree yields
   `R<score>\0OLD\0NEW`, i.e. old path first; status mode yields dest first.
   The node parser expects `…<orig> -> <dest>`, so map `OLD -> NEW`.
3. **No staged/unstaged distinction.** A committed change has no second column.
   We must choose how to populate the porcelain `XY` field (see §6).

## 5. Proposed changes

### 5.1 CLI — [bin/git-status-tree](../../bin/git-status-tree)

After `parser.parse!`, the residual `ARGV` holds the positional commit args
(verified: options are consumed, positionals remain). Pass them through:

```ruby
begin
  parser.parse!
rescue OptionParser::InvalidOption => e
  # unchanged
end

if ARGV.length > 2
  warn 'Error: git tree accepts at most two commits'
  warn parser
  exit 1
end
options[:commits] = ARGV.dup

puts GitStatusTree.new(options)
```

### 5.2 Source selection — `GitStatusTree#initialize`

```ruby
def initialize(options = {})
  Node.indent = indent(options)
  Node.collapse_dirs = collapse(options)
  @files = source_files(options)        # NEW: dispatch on commit count
  @nodes = files.map { |file| Node.create_from_string file }
  @tree = nodes.reduce { |a, i| (a + i).nodes[0] }
end

private

def source_files(options)
  commits = Array(options[:commits])
  case commits.length
  when 0 then parse_status(`git status --porcelain -z#{untracked_files(options)}`)
  else        parse_diff_tree(diff_tree_output(commits))
  end
end

def diff_tree_output(commits)
  refs = validate_revs!(commits)                # see §7
  # -M enables rename detection (no -C: copy detection is off by default in git
  # and is slower/noisier), -r recurses into subtrees, --no-commit-id suppresses
  # the leading SHA line, -z gives unambiguous paths.
  `git diff-tree --no-commit-id --name-status -M -r -z #{refs.join(' ')}`
end
```

### 5.3 New parser — `parse_diff_tree`

Translates diff-tree `-z` tokens into porcelain entry strings the existing
`Node.create_from_string` already understands.

```ruby
# diff-tree -z stream: <status>\0<path>\0 …  (rename/copy: <status>\0<old>\0<new>\0)
def parse_diff_tree(raw)
  tokens = raw.force_encoding('UTF-8').split("\0")
  files = []
  i = 0
  while i < tokens.length
    status = tokens[i]; i += 1
    next if status.nil? || status.empty?

    code = status[0]                       # drop similarity score (R100 -> R)
    if code == 'R' || code == 'C'
      old = tokens[i]; i += 1
      new = tokens[i]; i += 1
      files << "#{porcelain_xy(code)}#{old} -> #{new}"
    else
      path = tokens[i]; i += 1
      files << "#{porcelain_xy(code)}#{path}"
    end
  end
  files
end
```

`porcelain_xy` produces the 2-column + space prefix the node parser slices
(`gs[0]`, `gs[1]`, `gs[3..]`). See §6 for what goes in column Y.

## 6. Rendering: committed changes (locked)

The working-tree renderer colors **green** when the porcelain Y column is a
space (*staged*, with a `+` suffix) and **red** otherwise (*dirty*). Committed
history has no staged concept, and reusing either color is misleading (a green
"deleted" entry reads oddly). **Decision: commit-mode entries render in a
distinct third color — cyan — with no `+` suffix.** This signals "history view,
not your working tree" at a glance.

Implementation:

1. Add a `mode` accessor on `Node`, mirroring `indent` / `collapse_dirs`:

   ```ruby
   class << self
     attr_accessor :indent, :collapse_dirs, :mode   # :status (default) | :commit
   end
   ```

   `GitStatusTree#initialize` sets `Node.mode = commits.empty? ? :status : :commit`.

2. Add a cyan constant to [lib/bash_color.rb](../../lib/bash_color.rb) (e.g.
   `C = "\e[0;36m"`; verify the exact escape against the existing style).

3. Branch in `Node#color_name`'s file path:

   ```ruby
   if self.class.mode == :commit
     color_name += BashColor::C                 # cyan, no '+'
   elsif staged?
     color_name += BashColor::G
   else
     color_name += BashColor::R
   end
   color_name += "#{name} (#{status})"
   ```

   In commit mode the porcelain Y column is a space, so `Node.status` would
   normally append `+`. Suppress it for commit mode — either keep the existing
   `status` value but strip a trailing `+` for display when `mode == :commit`,
   or have `porcelain_xy` (see §5.3) encode the letter so no `+` is produced.
   Pick whichever keeps `status`-mode output byte-identical.

Directory nodes keep their existing emphasis color in both modes.

Status-letter → meaning shown to the user (unchanged letters): `A` added,
`M` modified, `D` deleted, `R` renamed, `T` type-changed. (`C`/copied won't
appear since `-C` is off, but the parser tolerates it — see §5.3.)

## 7. Revision validation & errors

`validate_revs!` normalizes the positional args into the list of refs handed to
diff-tree, accepting both `git tree A B` and the single-token `git tree A..B`:

```ruby
def validate_revs!(commits)
  # Expand a single "A..B" token into two endpoints. Reject "A...B": diff-tree
  # does not honor symmetric-difference semantics and silently returns nothing.
  if commits.length == 1 && commits[0].include?('..')
    raise "fatal: '#{commits[0]}': '...' range is not supported; use 'A..B'" \
      if commits[0].include?('...')
    commits = commits[0].split('..', 2)
  end
  commits.map { |rev| validate_rev!(rev) }
end

def validate_rev!(rev)
  sha = `git rev-parse --verify --quiet #{rev}^{commit} 2>/dev/null`.strip
  raise "fatal: bad revision '#{rev}'" if sha.empty?
  sha
end
```

- Invalid ref → print `fatal: bad revision '<rev>'` to stderr, exit non-zero.
- `A...B` → print the symmetric-difference error above, exit non-zero.
- Not in a git repo → existing behavior (git prints its own error) is acceptable;
  optionally detect and message uniformly.
- More than two positional args → handled in CLI (§5.1), exit 1 with usage.

Note: the arg-count guard in §5.1 counts **positional tokens**, so a single
`A..B` token is allowed (it expands to two refs here); `A B C` is rejected.

## 8. Edge cases

- **Range token** (`git tree A..B`): expanded to two endpoints in
  `validate_revs!` (§7); `A...B` is rejected. `A..B C` (token + extra arg) is
  rejected by the §5.1 count guard.
- **Empty diff** (commit with no changes, or two identical trees): `@tree` is
  `nil`. `#to_s` should be mode-aware: keep `(working directory clean)` for
  status mode, return `(no changes)` for commit mode (`Node.mode == :commit`).
- **Root commit** (no parent): `git diff-tree <root>` lists every file as added
  — acceptable and arguably useful. Document it.
- **Merge commits**: `diff-tree` of a merge with `-r` and no `-m`/`-c` prints
  nothing by default. For MVP, document that single-commit view of a merge may
  be empty; users can pass the two parents explicitly. (Adding `-c`/combined
  diff is out of scope.)
- **Paths with spaces / unicode / quotes**: `-z` keeps them literal, same as the
  status path already handled by `parse_status`. Reuse the UTF-8 forcing.
- **Rename across directories**: node already supports `old -> new/path`
  display via `build_rename_display`; commit renames flow through the same code.
- **`-u` with commits**: silently ignored (not applicable). Optionally warn.

## 9. Testing plan

Add integration tests under `test/integration/` mirroring existing ones
(`test_command_line*.rb`), each building a throwaway repo with known commits:

- `test_command_line_commit.rb`
  - single commit shows that commit's changes (A/M/D) in tree form;
  - rename within a commit shows `old -> new (R…)`;
  - root commit lists all files as added;
  - empty/merge commit → "no changes" / empty handling;
  - invalid revision → non-zero exit + stderr message;
  - three+ args → exit 1 + usage.
- `test_command_line_commit_range.rb`
  - `c1 c2` shows the symmetric diff;
  - reversed order flips add/delete;
  - rename across dirs renders arrow with path;
  - `-i`/`-c` options still apply in range mode.

Unit tests:
- `test/git_status_tree/test_parse_diff_tree.rb` (or extend existing) covering
  the `-z` token walk: regular entry, rename triplet, copy triplet, similarity
  score stripping, empty stream, multibyte paths.

Keep coverage green (`rake`), including RuboCop (`.rubocop.yml`) and SimpleCov.

## 10. Documentation updates

- **README.md** – new "Inspecting commits" section with the three invocations
  and example output; note `-u` is ignored for commits and the merge-commit
  caveat.
- **CHANGELOG.md** – add an entry under a new minor version (history inspection
  is a feature → bump minor, e.g. `3.6.0`); update `VERSION`.
- **`git tree --help`** – the existing alias caveat (`git tree -h`) still applies.

## 11. Implementation checklist

1. CLI: capture positionals into `options[:commits]`, guard arg count.
2. `GitStatusTree`: add `source_files`, `diff_tree_output`, `parse_diff_tree`,
   `validate_rev!`.
3. Rendering: add `Node.mode`, cyan `BashColor` constant, adjust `color_name`
   (cyan, no `+` for commit mode); keep status-mode output byte-identical.
4. Mode-aware empty message in `#to_s` (`(no changes)` for commit mode).
5. Tests: integration + unit per §9.
6. README / CHANGELOG / VERSION.
7. `rake` green (tests + RuboCop + coverage).
