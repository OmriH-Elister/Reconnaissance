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

The script initializes the Metasploit database, waits 10 seconds, and then uses either:

- every target in `domain_names`, when that file exists; or
- one target entered at the prompt when the file is absent.

For each target it:

1. Requests `http://<target>`, extracts the value following `http://` from a `Location`
   response header, and appends `<target> <extracted-value>` to `/etc/hosts`.
2. Runs a full TCP-port scan with `nmap -p- -T4`, saving normal, grepable, and XML
   output as `basicScan_<target>.*`. Discovered TCP ports are written as a comma-separated
   list to `open_ports.md`, which is overwritten for each target.
3. When at least one port was discovered, runs a second scan against those ports with
   OS/version detection (`-A`) and the `VULN`, `DISCOVERY`, and `EXPLOIT` NSE script
   categories. Results are saved as `advancedScan_<target>.*`.
4. Runs `gobuster dir` against `http://<extracted-value>`, follows redirects, excludes
   status codes 401–405, uses SecLists' `raft-medium-words.txt`, and writes results to
   `<target>_go_bust.txt`. In batch mode this step is chained to a successful advanced
   scan; in prompted single-target mode it is attempted after the scan commands.
5. Starts `msfconsole -r dbimporter.rc`. The resource script imports all matching
   `basicScan_*.xml` and `advancedScan_*.xml` files, runs `analyze`, and exits.

```bash
chmod +x "dumb_automated_nmap+gobuster.sh"
./"dumb_automated_nmap+gobuster.sh"
```

**Requires:** `nmap`, `gobuster`, `curl`, GNU `grep` with PCRE support, Metasploit
(`msfdb` and `msfconsole`), and SecLists at
`/usr/share/wordlists/seclists/` (Kali default path). Run it from the repository root so
`dbimporter.rc` is available. The account must also be able to append to `/etc/hosts`.

Targets are processed sequentially. Full `-p-` scans and the selected NSE script
categories can take a long time, so expect lengthy runs on larger lists.

## Input files

| File             | Used by                            | Format          |
|------------------|------------------------------------|-----------------|
| `hostsfinal.txt` | `Recon-NgBulkAppending`            | one host per line |
| `domain_names`   | `dumb_automated_nmap+gobuster.sh`  | one domain per line |

Both are read from the current working directory and are not tracked in the repo.

## License

This repository's original code and documentation are licensed under the
[MIT License](LICENSE).
