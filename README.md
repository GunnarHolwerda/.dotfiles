## My Computer Setup & Configuration Repo

This repo exists to be a single configurable place where I store the configuration for all of the apps that I use. For things that earn a staple in my fleet, I will commit their installation and configuration (if I have any) to this repository.

This repo was modeled after [ThePrimeagen's dev repo](https://github.com/ThePrimeagen/dev). I have changed some things though for my own use case. I mainly program on a Mac, but also wanted to have my setup available on Linux for a new laptop I was setting up.

I decided that the way I would structure this is actually keep the program installation between the two separate since they require slightly different commands/tweaks, but this also made it much easier for me to not have to have a bunch of configuration on what to install on what platform.

## Options

`--dry-run` - print out all of the commands that would be run by the program instead of executing them

`--config-only` - only copy configuration files and skip the program installation.


### Mac setup

1. Clone repository
2. Run the `mac` command

```bash
./mac
```

### Ubuntu setup

1. Cloine the repository
2. Run the `ubuntu` command

```bash
./ubuntu
```
