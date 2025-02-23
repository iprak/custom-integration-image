## Adjustments
* Copy content from upstream/**master**.

* Edit `pyproject.toml`
    * `"tests/*/*/*" = ["TID252"]`
    * `#"tests".msg = "You should not import tests"`

## Test
* Run `docker build -t custom-integration-image:local . --force-rm` to build the image locally.
* Test is locally by changing Dopckerfile in the test project to `FROM custom-integration-image:local`

## Prepare release
* On `main`, first `pull`, then create a new tag `git tag homeassistant_version`, push it `git push origin tag <tag_name>`.
* Run the action `Docker` on the new tag.

## Tag maintenance
* List tags `git tag -l`
* Local deletion `git tag -d tagname`
* Push deleted tag `git push --delete origin tagname`
