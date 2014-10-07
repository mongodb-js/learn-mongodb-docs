NODE = node
NPM = npm
JSDOC = jsdoc
name = all
2_0 = checkout/2.0
1_4 = checkout/1.4
CORE = checkout/core
# Base url used to generate 2.0 API docs
# baseurl_2_0 = /learn-mongodb-docs/2.0
# baseurl_2_0_regexp = \/learn-mongodb-docs
# baseurl_core = /learn-mongodb-docs/core
# baseurl_core_regexp = \/learn-mongodb-docs
# baseurl = /learn-mongodb-docs
baseurl_2_0 = /node-mongodb-native/2.0
baseurl_2_0_regexp = \/node-mongodb-native
baseurl_core = /node-mongodb-native/core
baseurl_core_regexp = \/node-mongodb-native
baseurl = /node-mongodb-native

# Git repo
repo = ../dist

#
# Generate all
#
all: setup generate_main_docs publish

#
# Setup all the sub repositories used for the documentation
#
setup:
	# Create generation directory
	rm -rf checkout
	mkdir checkout
	
	# Checkout all the modules for sub docs
	git clone https://github.com/mongodb/node-mongodb-native.git $(2_0)
	git --git-dir $(2_0)/.git --work-tree $(2_0) checkout 2.0
	
	# Copy the repo over
	cp -R $(2_0)/ $(1_4)/
	git --git-dir $(1_4)/.git --work-tree $(1_4) checkout master
	
	# Checkout the core module
	git clone https://github.com/christkv/mongodb-core.git $(CORE)

	# Install all dependencies
	cd checkout/2.0; npm install
	cd checkout/1.4; npm install
	cd checkout/core; npm install
	cd ../..

#
# Publishes to the local git repository
# git subtree add --prefix public git@github.com:christkv/learn-mongodb-docs.git gh-pages --squash
#
publish:
	cp -R ./public/. ./$(repo)/.
	cd ./$(repo); git add -A
	cd ./$(repo); git commit -m "Updated documentation"
	cd ./$(repo); git push origin gh-pages

#
# Generates main docs frame
#
generate_main_docs: generate_2_0_docs generate_1_4_docs generate_core_docs
	echo "== Generating Main docs"
	rm -rf ./public
	hugo -s site/ -d ../public -b $(baseurl)
	# Copy the 2.0 docs
	cp -R $(2_0)/public ./public/2.0
	# Copy the 1.4 docs
	cp -R $(1_4)/docs/sphinx-docs/build/html ./public/1.4
	# Copy the core docs
	cp -R $(CORE)/public ./public/core
	# Reset branches
	git --git-dir $(2_0)/.git --work-tree $(2_0) reset --hard
	git --git-dir $(1_4)/.git --work-tree $(1_4) reset --hard
	git --git-dir $(CORE)/.git --work-tree $(CORE) reset --hard

#
# Generates the driver 1.4 docs
#
generate_1_4_docs:
	echo "== Generating 1.4 docs"
	cd $(1_4); git reset --hard
	cd $(1_4); $(NODE) dev/tools/build-docs.js
	cd $(1_4); make --directory=./docs/sphinx-docs --file=Makefile html

#
# Generates the core docs
#
generate_core_docs:		
	echo "== Generating core docs"
	cd $(CORE); git reset --hard
	cd $(CORE); cp -R ./docs/history-header.md ./docs/content/meta/release-notes.md
	cd $(CORE); more ./HISTORY.md >> ./docs/content/meta/release-notes.md
	cd $(CORE); sed -i "" 's/#REPLACE/$(baseurl_core_regexp)/g' ./docs/config.toml
	cd $(CORE); hugo -s docs/ -d ../public -b $(baseurl_core)
	cd $(CORE); $(JSDOC) -c conf.json -t docs/jsdoc-template/ -d ./public/api
	cd $(CORE); cp -R ./public/api/scripts ./public/.
	cd $(CORE); cp -R ./public/api/styles ./public/.

#
# Generates the driver 2.0 docs
#
generate_2_0_docs:		
	echo "== Generating 2.0 docs"
	cd $(2_0); git reset --hard
	cd $(2_0); cp -R ./docs/history-header.md ./docs/content/meta/release-notes.md
	cd $(2_0); more ./HISTORY.md >> ./docs/content/meta/release-notes.md
	cd $(2_0); sed -i "" 's/#REPLACE/$(baseurl_2_0_regexp)/g' ./docs/config.toml
	cd $(2_0); hugo -s docs/ -d ../public -b $(baseurl_2_0)
	cd $(2_0); $(JSDOC) -c conf.json -t docs/jsdoc-template/ -d ./public/api
	cd $(2_0); cp -R ./public/api/scripts ./public/.
	cd $(2_0); cp -R ./public/api/styles ./public/.

.PHONY: total
