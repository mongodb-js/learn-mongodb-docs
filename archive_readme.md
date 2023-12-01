## Requirements

To build you need the following tools installed

* Hugo static web generator `v0.30.2`
  * You can download the right version [here](https://github.com/gohugoio/hugo/releases/tag/v0.30.2)
* jsdoc v3
* node (v6.x or v8.x) and npm (>= 3.x). Note: worked for me with 8.17.0, but not 8.0.0.
* python sphinx

## How to preview the documentation locally

* Install dependencies; ensure you are using the correct npm version in your current shell
* Run `make setup generate_main_docs` to pull each version branch of the docs
  and run `hugo` on them to generate the publishable files.
* At this point, you should be able to run hugo server to preview the
  landing page
* To view one of the reference docs branches, copy the `<root>/public/<version>`
  directory to `<root>/site/content`. Note: for referenced styles, you'll need
  to manually update all the paths to remove `/node-mongodb-native` from the
  path.
* If you need to make local changes to preview the reference docs before
  publishing, build them with hugo and copy them over. For example:

```sh
cd <root>/checkout/<version>
hugo -s docs/reference --destination ../../public -b /<version> -t mongodb --verbose --debug
cp -r public/ <root>/site/content/<version>
```

* Start hugo server, specifying `--contentDir=content`, and at this point
  you should be able to follow the links. Your command might look like
  this:

```sh
hugo server --baseUrl=http://localhost/ --buildDrafts --watch --contentDir=content
```

* If you are working on updating a branch, make sure the PR is against
  the appropriate branch of the `node-mongodb-native` repo.

## How to publish the documentation

* Install all dependencies
* run `make`
* run `make publish`
  * Uncomment the commands in the publish target, I left it this way to make sure we check our work before pushing (i.e. default is --dry-run like)

## How to add a new version

> **NOTE:** Documentation generation changed with version 4.0 and later.
> The repo contains the command to generate the docs with `npm run build:docs`.
>
> Take a look at the `generate_4_0_docs` task in the Makefile
> There is no longer an `api` subdirectory in the 4.0 version the API docs are just in the top level.
> The reference docs are now maintained by the docs team and we link to their site instead.

This assumes that you are adding a new minor version `3.4`

### Update `Makefile`

Add the following variables to the top of the file:

```sh
3_4 = checkout/3.4
baseurl_3_4 = /node-mongodb-native/3.4
branch_3_4=3.4
```

Add the following lines to the `setup` task:

```sh
git clone --depth 1 --no-single-branch https://github.com/mongodb/node-mongodb-native.git $(3_4)
git --git-dir $(3_4)/.git --work-tree $(3_4) checkout $(branch_3_4)
cd checkout/3.4; npm install;
```

Add the following lines to the `refresh` task

```sh
cd $(3_3);git pull
```

Create a new task `generate_3_4_docs`

```makefile
generate_3_3_docs:
    echo "== Generating 3.4 docs"
    cd $(3_4); git reset --hard
    cd $(3_4); hugo -s docs/reference -d ../../public -b $(baseurl_3_4) -t mongodb
    cd $(3_4); $(JSDOC) -c conf.json -t docs/jsdoc-template/ -d ./public/api
    cd $(3_4); cp -R ./public/api/scripts ./public/.
    cd $(3_4); cp -R ./public/api/styles ./public/.
```

Add `generate_3_4_docs` as a requirement for running `generate_main_docs`

```makefile
generate_main_docs: generate_3_4_docs <other requirements>
```

Add the following lines to `generate_main_docs`:

```sh
# Copy the 3.4 docs
cp -R $(3_4)/public ./public/3.4
# Reset branches
git --git-dir $(3_4)/.git --work-tree $(3_4) reset --hard
```

### Update `site/data/releases.toml`

Add a new entry at the top of the fole:

```toml
[[versions]]
  version = "3.4 Driver"
  status = ""
  docs = "./3.4"
  api = "./3.4/api"
```

Change `current` to equal your new version:

```toml
current = "3.4 Driver"
```

### Update `site/static/versions.json`

Add a new entry to the front of the list:

```json
[{"version": "3.4"},
```

You now should be good to go.

### Changes

#### (2021-05-18)

* The makefile now only updates docs for versions 3.6 and 4.0 since these are the only supported driver versions currently. If you need to update older docs, just uncomment the relevant commands in the makefile.
