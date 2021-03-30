# Backup Strategy

## About

We take daily backups of our sidechain and production servers using [Tarsnap][1].

Tarsnap allows for:

* Encrypted offsite backups with write- and read-only keys
* Reduced bandwidth & storage via deduplication
* Daily snapshots and history
* Linear, prepaid pricing

## Configuring a new system

##### Local Environment

1. Create `/root/tarsnap` on the target machine.

`$ ssh <user@host> 'sudo mkdir -p /root/tarsnap'`

2. Drop `tarsnap-install.sh` and `tarsnap-register.sh` into `/root/tarsnap` on the target machine.

```
$ scp tarsnap-{install,register}.sh <user@host>:/tmp`
$ ssh <user@host> 'sudo mv /tmp/tarsnap-{install,register}.sh /root/tarsnap'`
```

3. Log into the box as root or an administrator account and change to the root directory.

`$ ssh <user@host>`

##### Target Environment

1. Open a root shell.

`$ sudo bash`

2. Change to the root directory:

`# cd /`

3. Run `tarsnap-install.sh`. If it exits with an error, confirm the package key signatures match and request assistance if needed.

`# /root/tarsnap/tarsnap-install.sh`

4. After successfully installing Tarsnap, run `tarsnap-register.sh`. Backups are namespaced by keyfile, but make sure you provide a unique machine name for logging purposes.

`# /root/tarsnap/tarsnap-register.sh <machine name>`

## Environment-specific backup strategies

##### Local Environment

###### ethereum-backend

Drop `geth/tarsnap-backup.sh` into `/root/tarsnap` on the target machine.

`$ scp geth/tarsnap-backup.sh <user@host>:/tmp`

###### ipfs-backend

Drop `ipfs/tarsnap-backup.sh` into `/root/tarsnap` on the target machine.

`$ scp ipfs/tarsnap-backup.sh <user@host>:/tmp`

###### General (Full system backups)

Drop `tarsnap-backup.sh` into `/root/tarsnap` on the target machine.

`$ scp tarsnap-backup.sh <user@host>:/tmp`

## Further configuration

##### Target Environment

1. Open a root shell.

`$ sudo bash`

2. Move the backup script to `/root/tarsnap`.

`# mv /tmp/tarsnap-backup.sh /root/tarsnap`

3. Configure permissions.

```
$ # chown -R root:root /root/tarsnap
$ # chmod 744 /root/tarsnap/tarsnap-{install,register}.sh
$ # chmod 755 /root/tarsnap/tarsnap-backup.sh
```

## Configure cron job

##### Local Environment

Add a cron job for tarsnap-backup.
This creates a backup every night between 12-3AM.

`$ scp cron/tarsnap-backup <user@host>:/tmp`


##### Target Environment

1. Open a root shell.

`$ sudo bash`

2. Move the cron job to cron.d

`# mv /tmp/tarsnap-backup /etc/cron.d`

3. Configure permissions

`# chown root:root /etc/cron.d/tarsnap-backup` 

## Test the backup procedure

#### Quick Test

##### Target Environment

1. Create a canary file.

`$ echo hello | sudo tee /backed/up/path/tarsnap-hello.txt`

3. Run `tarsnap-backup.sh`

`$ /root/tarsnap/tarsnap-backup.sh`

4. Delete the canary file.

`$ sudo rm /backed/up/path/tarsnap-hello.txt`

5. Print the available snapshots sorted by most recent.

`$ sudo tarsnap --list-archives | sort`

6. Restore the most recent snapshot.

`$ sudo tarsnap -x -f $(tarsnap --list-archives | sort | head -n 1)`

7. Test the canary file. Is the output correct?

```
$ cat /backed/up/path/tarsnap-hello.txt
hello
```

8. Delete the canary file.

`$ sudo rm /backed/up/path/tarsnap-hello.txt`

#### Full Test

##### Target Environment

1. Run `tarsnap-backup.sh`

`# /root/tarsnap-backup.sh`

##### Local Environment

1. Copy the appropriate key to `/root`.

`$ scp tarsnap.key <user@test-host>:/root`

2. Log into the box as root or an administrator account and change to the root directory.

`$ ssh <user@test-host>`

##### Test Environment

1. Change to the root directory:

`# cd /`

2. Restore the most recent snapshot.

`# tarsnap -x -f $(tarsnap --list-archives | sort | head -n 1)`

3. Ensure the resulting files and directories are what you expect.

## Notes

* To cleanly stop a Tarsnap upload, use `^Q` (Cmd/Ctrl+Q) and not `^C` (Cmd/Ctrl+C). This will create a truncated archive appended with `.part`.

* Tarsnap should not be used to back up live databases or ipfs/geth nodes in production. If backups are being implemented for a new environment that requires special handling, use the appropriate software to create a static dump, and test backups and restores. Do not compress the dump. Document the process.

## Further reading

* [Simple Usage][2]
* [Tips][3]

[1]: https://www.tarsnap.com/ "Tarsnap"
[2]: https://www.tarsnap.com/simple-usage.html "Simple Usage"
[3]: https://www.tarsnap.com/tips.html "Tips"

