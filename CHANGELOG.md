## Changelog

### v2.0.0

##### New features

- added support for starting per-app workers defined in Procfile and the `workers` per-app attribute
- added support for the `shared_dirs` per-app attribute
- added support for the `symlinks` per-app attribute
- added support for the `whenever` per-app attribute
- added complete Test Kitchen spec suite

##### Bug fixes

- fixed redis & environment recipe timing that resulted in failures for new apps
- fixed linking to non-existing database.yml for `rails` layout
- fixed blank path argument handling
- fixed `repository_path` for Rails applications
- fixed nodejs version in order to meet `meteor` layout's requirements
- fixed redis version to one that actually exists in yum

### v1.6.0

##### New features

- added support for the `nginx` per-app attribute

##### Bug fixes

- added cronie package in case it's not installed
- fixed backup sudo execution issue

### v1.5.0

##### New features

- added support for the `middleman` application layout
- added support for the `repository_path` per-app attribute

