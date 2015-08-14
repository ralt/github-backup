# github-backup

Backups *all* the Github repositories in a single archive.

The name of the archive is `github-archive-%s.tar.gz`, where `%s` is
the current time in an rfc3339 format.

3 environments variables:

- `USER`: the user to backup.
- `PERSONAL_ACCESS_TOKEN`: a Personal Access Token to authenticate on Github API.
- `ORGS`: a comma-separated list of organizations to backup.

Dependencies:

- sbcl
- quicklisp
- git
- tar

How to run:

    $ USER=foo PERSONAL_ACCESS_TOKEN=bar ORGS=baz,qux ./github-backup

License: MIT.
