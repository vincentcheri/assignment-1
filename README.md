# Linux, Bash & Networking Diagnostic Toolkit

A small collection of Bash scripts for inspecting a Linux system, checking
filesystem usage, and testing basic network connectivity. This repository is
the deliverable for **Assignment 1 — Linux, Bash & Networking**.

## Requirements

- Linux
- Bash
- Standard system utilities used by the scripts, such as `hostname`, `uname`,
  `df`, and `ip`

Run the scripts from the repository root. Make them executable if necessary:

```bash
chmod +x system-info.sh disk-check.sh network-check.sh
```

## Scripts

### System information

```bash
./system-info.sh
```

Displays values collected from the running system:

- Hostname and current user
- Current date and time
- Operating system and kernel version
- System uptime
- CPU and memory information
- Current working directory

### Disk usage check

```bash
./disk-check.sh <threshold> [path]
```

Checks the filesystem containing `path`; the path defaults to `/`.
`threshold` must be an integer from `1` to `100`. The script prints the
filesystem's disk usage percentage.

Exit status:

- `0` — usage is below the threshold
- Non-zero — usage reaches or exceeds the threshold
- `2` — invalid threshold or path

Example:

```bash
./disk-check.sh 80 /
```

### Network check

```bash
./network-check.sh <hostname-or-ip> [port]
```

Validates the host, resolves it, performs a basic connectivity check, and
prints network interface information. When a port is supplied, the script also
tests TCP connectivity to that port. Valid ports are integers from `1` to
`65535`.

Example:

```bash
./network-check.sh example.com
./network-check.sh example.com 443
```

Invalid arguments return a non-zero status. Connectivity failures also return
a non-zero status; check the printed results to see which test failed.

## Logs

The `logs/` directory is reserved for useful diagnostic records. Operations
should be logged there with a timestamp and a description, so the time and
result of each check can be reviewed later. The tracked `.gitkeep` file keeps
the directory present when no log files have been created yet.

## Local checks

Run the provided assignment grader from the repository root:

```bash
bash ./grade.sh
```

It checks required files, Bash syntax, executable permissions, basic script
behavior, logs, and selected Git requirements. Some network checks depend on
the host's network configuration and connectivity.

## Git workflow requirement

The assignment requires at least five meaningful commits, at least one
non-main feature branch, and a merge of that feature branch into `main` or
`master`. Use descriptive commit messages that explain each change.