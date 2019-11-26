# learn-mongodb-docs

## Requirements

To build you need the following tools installed

* Hugo static web generator `v0.30.2`
    * You can download the right version [here](https://github.com/gohugoio/hugo/releases/tag/v0.30.2)
* jsdoc v3
* node (v6.x or v8.x) and npm (>= 3.x)
* python sphinx

## How to build the documentations

* Install all dependencies
* run `make`

## How to add a new version

This will assume that you are adding a new minor version `3.4`

### Update `Makefile`

Add the following variables to the top of the file:

```
3_4 = checkout/3.4
baseurl_3_4 = /node-mongodb-native/3.4
branch_3_4=3.4
```

Add the following lines to the `setup` task:

```
git clone --depth 1 --no-single-branch https://github.com/mongodb/node-mongodb-native.git $(3_4)
git --git-dir $(3_4)/.git --work-tree $(3_4) checkout $(branch_3_4)
cd checkout/3.3; npm install;
```

Add the following lines to the `refresh` task

```
cd $(3_3);git pull
```

Create a new task `generate_3_4_docs`

```
generate_3_3_docs:
	echo "== Generating 3.4 docs"
	cd $(3_4); git reset --hard
	cd $(3_4); hugo -s docs/reference -d ../../public -b $(baseurl_3_4) -t mongodb
	cd $(3_4); $(JSDOC) -c conf.json -t docs/jsdoc-template/ -d ./public/api
	cd $(3_4); cp -R ./public/api/scripts ./public/.
	cd $(3_4); cp -R ./public/api/styles ./public/.
```

Add `generate_3_4_docs` as a requirement for running `generate_main_docs`

```
generate_main_docs: generate_3_4_docs <other requirements>
```

Add the following lines to `generate_main_docs`:

```
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

```
current = "3.4 Driver"
```

### Update `site/static/versions.json`

Add a new entry to the front of the list:

```json
[{"version": "3.4"}, 
```

You now should be good to go.