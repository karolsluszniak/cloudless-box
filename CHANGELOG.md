## Changelog

### v2.1.3

##### New features

- added the `asset_cmd` per-app attribute support
- added the `migration_cmd` per-app attribute support

### v2.1.2

##### Bug fixes

- fixed nginx configuration for proxying websockets (`phoenix` layout)

### v2.1.1

##### Improvements

- nodejs is now installed from 4.x LTS repo

### v2.1

##### New features

- added support for the `phoenix` application layout
- added the `gems` global attribute support
- added the `packages` global attribute support

### v2.0

##### New features

- added worker support via `Procfile` and the `workers` per-app attribute
- added the `shared_dirs` per-app attribute support
- added the `symlinks` per-app attribute support
- added the `whenever` per-app attribute support
- added complete Test Kitchen spec suite

##### Bug fixes

- fixed redis & environment recipe timing that resulted in failures for new apps
- fixed linking to non-existing database.yml for `rails` layout
- fixed blank path argument handling
- fixed `repository_path` for Rails applications
- fixed nodejs version in order to meet `meteor` layout's requirements
- fixed redis version to one that actually exists in yum

### v1.6

##### New features

- added the `nginx` per-app attribute support

##### Bug fixes

- added cronie package in case it's not installed
- fixed backup sudo execution issue

### v1.5

##### New features

- added support for the `middleman` application layout
- added support for the `repository_path` per-app attribute

