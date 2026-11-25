# Tutorial 10 backend changes

`tutorial10.patch` contains the Django changes for the supplied `myportofolio.zip`.
The prepared, migrated local copy is in `../backend_work/myportofolio/` (ignored
by the Flutter repository). The original ZIP is unchanged. Environment files,
the original database, and Git history were not copied into that working copy.

To apply the changes to your actual Django repository, run from that repository
(replace the patch path with its absolute path in this Flutter repository):

```powershell
git apply --check --ignore-whitespace "PATH/TO/backend_changes/tutorial10.patch"
git apply --ignore-whitespace "PATH/TO/backend_changes/tutorial10.patch"
python -m pip install -r requirements.txt
python manage.py migrate
python manage.py test main
python manage.py runserver
```

The patch enables token authentication before session authentication, adds token
login and logout endpoints, allows the Android emulator host, and configures
development CORS. Existing session authentication and owner permissions remain.

The supplied backend differed from the tutorial's assumed schema. Migration
`0008_tutorial10_project_fields` adds `tech_stack` and `project_image_url` with
empty defaults for existing records, and defaults `category` to `project-small`.
The serializer still supports category for the existing website. The Flutter
client sends the tutorial fields without requiring category.

Anonymous protected requests now return 401; authenticated users without the
required permissions still receive 403. The old API tests are updated accordingly.

For the isolated working copy, create your own login with
`python manage.py createsuperuser`; no original accounts or passwords were copied.
Only a superuser can create projects, matching the existing permission class.
Before using the deployed backend from Flutter, apply the patch and migrations
there through your usual Django deployment workflow. For hosted Flutter Web,
set production `CORS_ALLOWED_ORIGINS` to its exact HTTPS origin.

Verified locally: migrations, 36 Django tests, patch applicability against the ZIP,
and a real Dart-to-Django HTTP login/create/read/logout/revoked-token check. The
temporary integration account and project were removed afterward.
