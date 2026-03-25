# Changelog

All notable changes to this project will be documented in this file.

## [unreleased] - since 3.2.0

## [3.2.0] - 2024-12-07

### Added

- Add optional dependencies handling

### Changed

- Bump default restic version to 0.17.3
- Move defaults var to the default directory

## [3.1.0] - 2023-10-25

### Added

- Print restic version in all cri_* functions
- Add an option to automatically delete old restic binaries

### Changed

- Bump default restic version to 0.16.1

## [3.0.0] - 2023-05-09

### Changed

- Scheduling reworked, added support for systemd-timers
- Project moved to a new git repository

## [2.10.0] - 2023-05-01

### Changed

- Bump default restic version to 0.15.2 which is a fix for a golang CVE

## Added

- Add support for scheduling using systemd-timers

## Changed

- Modified how to enable backup and prune schedules to accommodate for the new systemd-timers support

## [2.9.0] - 2023-01-25

### Added

- Allow to create the metrics file with a specific user

## [2.8.1] - 2023-01-06

### Fixed

- Fix condition for disabling sending logs

## [2.8.0] - 2023-01-04

### Added

- Add support for disabling sending logs in alerting.

### Fixed

- Fix condition on max retry attempts
- Fix message saying failed on success

## [2.7.0] - 2022-11-24

### Added

- Add a `host` label in node-exporter alerting identifying the host from which
  the backup originated.

### Fixed

- Node-exporter alerting now writes its metrics atomically.
- Fix restic SHA256SUMS download link when using the version type handled by renovatebot (prefixed by a `v`)

## [2.6.1] - 2022-11-24

### Fixed

- Fix restic download link when using the version type handled by renovatebot (prefixed by a `v`)
- Add missing `bc` package to the list of installed packages

## [2.6.0] - 2022-11-23

### Added

- Add support for restic compression (added in restic 0.14.0)
- Add an option to send alerting after a failure even if CRI_DISABLE_ALERTING_ON_SUCCESS is true

### Changed

- Update restic default version to v0.14.0

## [2.5.0] - 2022-08-21

### Added

- Add automatic alerting body reduction when body is too long for API based alerting, only enabled for Slack for the moment

## [2.4.0] - 2022-08-06

### Added

- Allow CPU load check to be configured for backuped host and prune host separatly

### Changed

- Improved the log messages when using the "cpu load check" feature

## [2.3.0] - 2022-08-04

### Changed

- Improved the log messages when using the "disable alerting on success mode" (for canary too)

### Fixed

- Fix "disable alerting on success" feature
- Fix shellcheck lint issue on the CPU load feature

## [2.2.1] - 2022-08-04

### Fixed

- Fix small typos on retry_handler.sh template

## [2.2.0] - 2022-08-04

### Added

- Add "canary" alerting when alerting is disabled on success

## [2.1.0] - 2022-08-04

### Added

- Add opt-in check on cpu load before any operation

## [2.0.1] - 2022-08-04

### Fixed

- Fix hooks template/copy when only one type of hook is used

## [2.0.0] - 2022-08-02

### Added

- Add support for non files/templates hooks
- Add hook checking during deployment

## [1.7.0] - 2022-07-19

### Added

- Allow partial deployment of the backups

## [1.6.0] - 2022-07-19

### Changed

- Bump default restic version to 0.13.1

## [1.5.0] - 2022-01-14

### Added

- Install `bzip2` package as it's not installed by default on all distro

## [1.4.1] - 2021-06-16

### Changed

- Allow hostname change per backup

### Fixed

- Fix typo in restore post hooks

## [1.4.0] - 2021-06-05

### Added

- Add compatibility for other CPU arch (arm, etc)

## [1.3.0] - 2021-05-17

### Changed

- Change `KO` tag for `FAIL` in mail alerting

## [1.2.0] - 2021-05-13

### Added

- Add option to disable logrotate if needed
- Add libnotify alerting for systemd desktops

### Changed

- Enhance default vars handling

### Fixed

- Add missing backup name in node exported metrics

## [1.1.0] - 2021-04-05

### Added

- Add compatibility for other distros

### Fixed

- Output was not sanitized for JSON based alerting

## [1.0.0] - 2021-04-01

### Added

- Checks for backend config
- Ability to disable pruning
- Ability to disable cron jobs

### Changed

- Update doc

## [0.2.0] - 2021-04-01

### Added

- Full alerting rework
- New alerting backends:
    - discord
    - healthchecks.io
    - mail
    - mattermost
    - node
    - rocketchat
    - slack
    - telegram
- This CHANGELOG file

## [0.1.0] - 2021-03-08

### Added

- All project:
    - multiple backup per host
    - multiple backends supported

[unreleased]: https://gitlab.com/byh0ki-org/infra/ansible/roles/restic/-/compare/3.2.0...main
[3.2.0]: https://gitlab.com/byh0ki-org/infra/ansible/roles/restic/-/compare/3.1.0...3.2.0
[3.1.0]: https://gitlab.com/byh0ki-org/infra/ansible/roles/restic/-/compare/3.0.0...3.1.0
[3.0.0]: https://gitlab.com/byh0ki-org/infra/ansible/roles/restic/-/compare/2.10.0...3.0.0
[2.10.0]: https://gitlab.com/byh0ki-org/infra/ansible/roles/restic/-/compare/2.9.0...2.10.0
[2.9.0]: https://gitlab.com/byh0ki-org/infra/ansible/roles/restic/-/compare/2.8.1...2.9.0
[2.8.1]: https://gitlab.com/byh0ki-org/infra/ansible/roles/restic/-/compare/2.8.0...2.8.1
[2.8.0]: https://gitlab.com/byh0ki-org/infra/ansible/roles/restic/-/compare/2.7.0...2.8.0
[2.7.0]: https://gitlab.com/byh0ki-org/infra/ansible/roles/restic/-/compare/2.6.1...2.7.0
[2.6.1]: https://gitlab.com/byh0ki-org/infra/ansible/roles/restic/-/compare/2.6.0...2.6.1
[2.6.0]: https://gitlab.com/byh0ki-org/infra/ansible/roles/restic/-/compare/2.5.0...2.6.0
[2.5.0]: https://gitlab.com/byh0ki-org/infra/ansible/roles/restic/-/compare/2.4.0...2.5.0
[2.4.0]: https://gitlab.com/byh0ki-org/infra/ansible/roles/restic/-/compare/2.3.0...2.4.0
[2.3.0]: https://gitlab.com/byh0ki-org/infra/ansible/roles/restic/-/compare/2.2.1...2.3.0
[2.2.1]: https://gitlab.com/byh0ki-org/infra/ansible/roles/restic/-/compare/2.2.0...2.2.1
[2.2.0]: https://gitlab.com/byh0ki-org/infra/ansible/roles/restic/-/compare/2.1.0...2.2.0
[2.1.0]: https://gitlab.com/byh0ki-org/infra/ansible/roles/restic/-/compare/2.0.1...2.1.0
[2.0.1]: https://gitlab.com/byh0ki-org/infra/ansible/roles/restic/-/compare/2.0.0...2.0.1
[2.0.0]: https://gitlab.com/byh0ki-org/infra/ansible/roles/restic/-/compare/1.7.0...2.0.0
[1.7.0]: https://gitlab.com/byh0ki-org/infra/ansible/roles/restic/-/compare/1.6.0...1.7.0
[1.6.0]: https://gitlab.com/byh0ki-org/infra/ansible/roles/restic/-/compare/1.5.0...1.6.0
[1.5.0]: https://gitlab.com/byh0ki-org/infra/ansible/roles/restic/-/compare/1.4.1...1.5.0
[1.4.1]: https://gitlab.com/byh0ki-org/infra/ansible/roles/restic/-/compare/1.4.0...1.4.1
[1.4.0]: https://gitlab.com/byh0ki-org/infra/ansible/roles/restic/-/compare/1.3.0...1.4.0
[1.3.0]: https://gitlab.com/byh0ki-org/infra/ansible/roles/restic/-/compare/1.2.0...1.3.0
[1.2.0]: https://gitlab.com/byh0ki-org/infra/ansible/roles/restic/-/compare/1.1.0...1.2.0
[1.1.0]: https://gitlab.com/byh0ki-org/infra/ansible/roles/restic/-/compare/1.0.0...1.1.0
[1.0.0]: https://gitlab.com/byh0ki-org/infra/ansible/roles/restic/-/compare/0.2.0...1.0.0
[0.2.0]: https://gitlab.com/byh0ki-org/infra/ansible/roles/restic/-/compare/0.1.0...0.2.0
[0.1.0]: https://gitlab.com/byh0ki-org/infra/ansible/roles/restic/-/releases/0.1.0
