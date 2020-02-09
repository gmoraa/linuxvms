# LinuxVMs

## Usage

```
Usage: This repository be default will create 3 Linux VMs locally, you will be able to query every server with it's IP.

Requirements for execution:

1. Bash terminal(Linux or Mac, WSL won't work).
2. Docker installed.
```

# ssi.sh create
```
Be default this will create 3 Linux virtual machines locally but can be increase if you modify the array size called 'boxes'.
```

# ssi.sh list
```
Return all your running servers with IP and hostname.
```

# ssi.sh query <IP>
```
This will connect to IP provided as a parameter and return the server stats as a file in the current working directory. Example:

./ssi.sh query 172.17.0.2

*Note you will only be able to execute one query at the time.
```

# ssi.sh clean
```
Remove all VMs created with the 'create' function.
```
