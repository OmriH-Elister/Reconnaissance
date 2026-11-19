# Reconnaissance

Small shell helpers for the recon phase of an engagement: bulk-loading targets into
recon-ng, and running a full-port nmap sweep plus gobuster directory brute-force across
a list of domains.

> Use only against systems you own or are explicitly authorized to test.

## Scripts

### `Recon-NgBulkAppending`

Reads hostnames from `hostsfinal.txt` (one per line) and inserts each one into the
`hosts` table of the recon-ng workspace `intel`, via `recon-cli`.

```bash
chmod +x Recon-NgBulkAppending
./Recon-NgBulkAppending
```

**Requires:** [recon-ng](https://github.com/lanmaster53/recon-ng) (`recon-cli` on `PATH`).
The workspace name `intel` is hardcoded; edit the script to target another one.

### `dumb_automated_nmap+gobuster.sh`

For each target in `domain_names` (one per line) it:

1. Runs `nmap -p- -T4 -vvv` and saves all output formats as `scan_<target>.*`
2. Runs `gobuster dir` with redirects followed, status codes 401–405 excluded, and the
   SecLists `raft-medium-words.txt` wordlist, writing results to `<target>_go_bust.txt`

```bash
chmod +x "dumb_automated_nmap+gobuster.sh"
./"dumb_automated_nmap+gobuster.sh"
```

**Requires:** `nmap`, `gobuster`, and SecLists at
`/usr/share/wordlists/seclists/` (Kali default path).

Targets are processed sequentially, and gobuster only runs if nmap exits cleanly. A
full `-p-` scan is slow, so expect long runtimes on larger lists.

## Input files

| File             | Used by                            | Format          |
|------------------|------------------------------------|-----------------|
| `hostsfinal.txt` | `Recon-NgBulkAppending`            | one host per line |
| `domain_names`   | `dumb_automated_nmap+gobuster.sh`  | one domain per line |

Both are read from the current working directory and are not tracked in the repo.

## License

No license file yet. See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) for contribution conduct.
