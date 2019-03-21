NODE = node
NPM = npm
JSDOC = jsdoc
name = all
3_2 = checkout/3.2
3_1 = checkout/3.1
3_0 = checkout/3.0
2_2 = checkout/2.2
CORE = checkout/core
baseurl_3_2 = /node-mongodb-native/3.2
baseurl_3_1 = /node-mongodb-native/3.1
baseurl_3_0 = /node-mongodb-native/3.0
baseurl_2_2 = /node-mongodb-native/2.2
baseurl_core = /node-mongodb-native/core
baseurl = /node-mongodb-native

# Git repo
repo=dist

#
# Generate all
#
all: setup generate_main_docs publish

#
# Refresh and publish
#
refresh_publish: refresh generate_main_docs publish

#
# Setup all the sub repositories used for the documentation
#
setup:
	# Create generation directory
	rm -rf checkout
	mkdir checkout

	# Checkout all the modules for sub docs
	git clone --depth 1 --no-single-branch https://github.com/mongodb/node-mongodb-native.git $(3_2)
	git --git-dir $(3_2)/.git --work-tree $(3_2) checkout master

	git clone --depth 1 --no-single-branch https://github.com/mongodb/node-mongodb-native.git $(3_1)
	git --git-dir $(3_1)/.git --work-tree $(3_1) checkout 3.1

	git clone --depth 1 --no-single-branch https://github.com/mongodb/node-mongodb-native.git $(3_0)
	git --git-dir $(3_0)/.git --work-tree $(3_0) checkout 3.0

	git clone --depth 1 --no-single-branch https://github.com/mongodb/node-mongodb-native.git $(2_2)
	git --git-dir $(2_2)/.git --work-tree $(2_2) checkout 2.2

	# Checkout the core module
	git clone --depth 1 --no-single-branch https://github.com/mongodb-js/mongodb-core.git $(CORE)

	# Install all dependencies
	cd checkout/core; npm install; npm link;
	cd checkout/3.2; npm install; npm link mongodb-core;
	cd checkout/3.1; npm install
	cd checkout/3.0; npm install
	cd checkout/2.2; npm install
	cd ../..

#
# Pull any new content for the repos
#
refresh:
	cd $(3_2);git pull
	cd $(3_1);git pull
	cd $(3_0);git pull
	cd $(2_2);git pull
	cd $(CORE);git pull

#
# Publishes to the local git repository
# git subtree add --prefix dist git@github.com:mongodb-js/learn-mongodb-docs.git gh-pages --squash
#
publish:
	rm -rf ./$(repo)
	git clone git@github.com:mongodb/node-mongodb-native.git $(repo)
	cd ./$(repo);git checkout gh-pages
	cd ..
	cp -R ./public/. ./$(repo)/.
	cd ./$(repo); git add -A
	cd ./$(repo); git commit -m "Updated documentation"
	cd ./$(repo); git push origin gh-pages

#
# Generates main docs frame
#
generate_main_docs: generate_3_2_docs generate_3_1_docs generate_3_0_docs generate_core_docs
	echo "== Generating Main docs"
	rm -rf ./public
	hugo -s site/ -d ../public -b $(baseurl)
	# Copy the 3.2 docs
	cp -R $(3_2)/public ./public/3.2
	# Copy the 3.1 docs
	cp -R $(3_1)/public ./public/3.1
	# Copy the 3.0 docs
	cp -R $(3_0)/public ./public/3.0
	# Copy the 2.2 docs
	# cp -R $(2_2)/public ./public/2.2
	# Copy the core docs
	cp -R $(CORE)/public ./public/core
	# Reset branches
	git --git-dir $(3_2)/.git --work-tree $(3_2) reset --hard
	git --git-dir $(3_1)/.git --work-tree $(3_1) reset --hard
	git --git-dir $(3_0)/.git --work-tree $(3_0) reset --hard
	git --git-dir $(2_2)/.git --work-tree $(2_2) reset --hard
	git --git-dir $(CORE)/.git --work-tree $(CORE) reset --hard

#
# Generates the core docs
#
generate_core_docs:
	echo "== Generating core docs"
	cd $(CORE); git reset --hard
	cd $(CORE); hugo -s docs/reference -d ../../public -b $(baseurl_core) -t mongodb
	cd $(CORE); $(JSDOC) -c conf.json -t docs/jsdoc-template/ -d ./public/api
	cd $(CORE); cp -R ./public/api/scripts ./public/.
	cd $(CORE); cp -R ./public/api/styles ./public/.

#
# Generates the driver 2.0 docs
#
generate_2_2_docs:
	echo "== Generating 2.2 docs"
	cd $(2_2); git reset --hard
	cd $(2_2); hugo -s docs/reference -d ../../public -b $(baseurl_2_2) -t mongodb
	cd $(2_2); $(JSDOC) -c conf.json -t docs/jsdoc-template/ -d ./public/api
	cd $(2_2); cp -R ./public/api/scripts ./public/.
	cd $(2_2); cp -R ./public/api/styles ./public/.

#
# Generates the driver 3.0 docs
#
generate_3_0_docs:
	echo "== Generating 3.0 docs"
	cd $(3_0); git reset --hard
	cd $(3_0); hugo -s docs/reference -d ../../public -b $(baseurl_3_0) -t mongodb
	cd $(3_0); $(JSDOC) -c conf.json -t docs/jsdoc-template/ -d ./public/api
	cd $(3_0); cp -R ./public/api/scripts ./public/.
	cd $(3_0); cp -R ./public/api/styles ./public/.

.PHONY: total

#
# Generates the driver 3.1 docs
#
generate_3_1_docs:
	echo "== Generating 3.1 docs"
	cd $(3_1); git reset --hard
	cd $(3_1); hugo -s docs/reference -d ../../public -b $(baseurl_3_1) -t mongodb
	cd $(3_1); $(JSDOC) -c conf.json -t docs/jsdoc-template/ -d ./public/api
	cd $(3_1); cp -R ./public/api/scripts ./public/.
	cd $(3_1); cp -R ./public/api/styles ./public/.

.PHONY: total

#
# Generates the driver 3.2 docs
#
generate_3_2_docs:
	echo "== Generating 3.2 docs"
	cd $(3_2); git reset --hard
	cd $(3_2); hugo -s docs/reference -d ../../public -b $(baseurl_3_2) -t mongodb
	cd $(3_2); $(JSDOC) -c conf.json -t docs/jsdoc-template/ -d ./public/api
	cd $(3_2); cp -R ./public/api/scripts ./public/.
	cd $(3_2); cp -R ./public/api/styles ./public/.

.PHONY: total
