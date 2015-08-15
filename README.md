# github-backup

Backups *all* the Github repositories in a single archive.

The name of the archive is `github-archive-%s.tar.gz`, where `%s` is
the current time in an rfc3339 format.

2 environments variables:

- `PERSONAL_ACCESS_TOKEN`: a Personal Access Token to authenticate on Github API.
- `ORGS`: a comma-separated list of organizations to backup.

Dependencies:

- cl-launch
- cl-quicklisp
- git
- tar

How to run:

    $ USER=foo PERSONAL_ACCESS_TOKEN=bar ORGS=baz,qux ./github-backup

License: MIT.
