# PyCharm Setup

- Download and install [PyCharm Community Edition](https://www.jetbrains.com/pycharm/download/)
  
- Open PyCharm and [install the following plugins](https://www.jetbrains.com/help/pycharm/managing-plugins.html)
> Preferences > Plugins > Marketplace > enter plugin names > install
- [Database Navigator](https://plugins.jetbrains.com/plugin/1800-database-navigator)
- [Makefile](https://plugins.jetbrains.com/plugin/9333-makefile-language)
- [Docker](https://plugins.jetbrains.com/plugin/7724-docker)
- [Terraform](https://plugins.jetbrains.com/plugin/7808-hashicorp-terraform--hcl-language-support) (_Optional_)

### Open DB Browser

> Menu > View > Tool Windows > DB Browser

### Add New Connection

> DB Browser view > click + symbol > select PostgreSQL

At Connection dialog, fill:
```
Name: metadata
Database: metadata
User: metadata
Password: metadata
```

At DB Browser view, click to expand tree menu:

> Schemas > public

### Open SQL Console

> Menu > DB Navigator > Open SQL Console > select metadata

## REF

- https://confluence.jetbrains.com/display/CONTEST/Database+Navigator  (outdated, it seems)
