NODE = node
NPM = npm
JSDOC = jsdoc
HUGO = hugo
name = all
4_0 = checkout/4.0
3_6 = checkout/3.6
3_5 = checkout/3.5
3_4 = checkout/3.4
3_3 = checkout/3.3
3_2 = checkout/3.2
3_1 = checkout/3.1
3_0 = checkout/3.0
2_2 = checkout/2.2
CORE = checkout/core
baseurl_4_0 = /node-mongodb-native/4.0
baseurl_3_6 = /node-mongodb-native/3.6
baseurl_3_5 = /node-mongodb-native/3.5
baseurl_3_4 = /node-mongodb-native/3.4
baseurl_3_3 = /node-mongodb-native/3.3
baseurl_3_2 = /node-mongodb-native/3.2
baseurl_3_1 = /node-mongodb-native/3.1
baseurl_3_0 = /node-mongodb-native/3.0
baseurl_2_2 = /node-mongodb-native/2.2
baseurl_core = /node-mongodb-native/core
baseurl = /node-mongodb-native

branch_4_0=4.0
branch_3_6=3.6
branch_3_5=3.5
branch_3_4=3.4
branch_3_3=3.3
branch_3_2=3.2
branch_3_1=3.1
branch_3_0=3.0
branch_2_2=2.2

# Git repo
repo=dist

.PHONY: all generate_2_2_docs generate_3_0_docs generate_3_1_docs generate_3_2_docs generate_3_3_docs generate_3_4_docs generate_3_5_docs generate_3_6_docs generate_4_0_docs generate_core_docs generate_main_docs publish refresh refresh_publish setup

#
# Generate all
#
all: setup generate_main_docs publish
	@echo "done."

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
	git clone --depth 1 --no-single-branch https://github.com/mongodb/node-mongodb-native.git $(4_0)
	git --git-dir $(4_0)/.git --work-tree $(4_0) checkout $(branch_4_0)

	git clone --depth 1 --no-single-branch https://github.com/mongodb/node-mongodb-native.git $(3_6)
	git --git-dir $(3_6)/.git --work-tree $(3_6) checkout $(branch_3_6)

	git clone --depth 1 --no-single-branch https://github.com/mongodb/node-mongodb-native.git $(3_5)
	git --git-dir $(3_5)/.git --work-tree $(3_5) checkout $(branch_3_5)

	git clone --depth 1 --no-single-branch https://github.com/mongodb/node-mongodb-native.git $(3_4)
	git --git-dir $(3_4)/.git --work-tree $(3_4) checkout $(branch_3_4)

	git clone --depth 1 --no-single-branch https://github.com/mongodb/node-mongodb-native.git $(3_3)
	git --git-dir $(3_3)/.git --work-tree $(3_3) checkout $(branch_3_3)

	git clone --depth 1 --no-single-branch https://github.com/mongodb/node-mongodb-native.git $(3_2)
	git --git-dir $(3_2)/.git --work-tree $(3_2) checkout $(branch_3_2)

	git clone --depth 1 --no-single-branch https://github.com/mongodb/node-mongodb-native.git $(3_1)
	git --git-dir $(3_1)/.git --work-tree $(3_1) checkout $(branch_3_1)

	git clone --depth 1 --no-single-branch https://github.com/mongodb/node-mongodb-native.git $(3_0)
	git --git-dir $(3_0)/.git --work-tree $(3_0) checkout $(branch_3_0)

	git clone --depth 1 --no-single-branch https://github.com/mongodb/node-mongodb-native.git $(2_2)
	git --git-dir $(2_2)/.git --work-tree $(2_2) checkout $(branch_2_2)

	# Checkout the core module
	git clone --depth 1 --no-single-branch https://github.com/mongodb-js/mongodb-core.git $(CORE)

	# Install all dependencies
	cd checkout/core; npm install; npm link;
	cd checkout/4.0; npm install
	cd checkout/3.6; npm install; npm install mongodb-client-encryption;
	cd checkout/3.5; npm install; npm install mongodb-client-encryption;
	cd checkout/3.4; npm install; npm install mongodb-client-encryption;
	cd checkout/3.3; npm install;
	cd checkout/3.2; npm install; npm link mongodb-core;
	cd checkout/3.1; npm install
	cd checkout/3.0; npm install
	cd checkout/2.2; npm install
	cd ../..

#
# Pull any new content for the repos
#
refresh:
	cd $(4_0);git pull
	cd $(3_6);git pull
	cd $(3_5);git pull
	cd $(3_4);git pull
	cd $(3_3);git pull
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
	@echo "publishing..."
	rm -rf ./$(repo)
	git clone git@github.com:mongodb/node-mongodb-native.git $(repo)
	cd ./$(repo); git checkout gh-pages
	cd ..
	cp -R ./public/. ./$(repo)/.
	cd ./$(repo); git add -A
	cd ./$(repo); git commit -m "Updated documentation"
	cd ./$(repo); git push origin gh-pages

#
# Generates main docs frame
#
generate_main_docs: generate_4_0_docs generate_3_6_docs generate_3_5_docs generate_3_4_docs generate_3_3_docs generate_3_2_docs generate_3_1_docs generate_3_0_docs generate_2_2_docs generate_core_docs
	@echo "== Generating Main docs"
	rm -rf ./public
	$(HUGO) -s site/ -d ../public -b $(baseurl)
	# Copy the 4.0 docs
	cp -R $(4_0)/docs/public ./public/4.0
	# Copy the 3.6 docs
	cp -R $(3_6)/public ./public/3.6
	# Copy the 3.5 docs
	cp -R $(3_5)/public ./public/3.5
	# Copy the 3.4 docs
	cp -R $(3_4)/public ./public/3.4
	# Copy the 3.3 docs
	cp -R $(3_3)/public ./public/3.3
	# Copy the 3.2 docs
	cp -R $(3_2)/public ./public/3.2
	# Copy the 3.1 docs
	cp -R $(3_1)/public ./public/3.1
	# Copy the 3.0 docs
	cp -R $(3_0)/public ./public/3.0
	# Copy the 2.2 docs
	cp -R $(2_2)/public ./public/2.2
	# Copy the core docs
	cp -R $(CORE)/public ./public/core
	# Reset branches
	git --git-dir $(4_0)/.git --work-tree $(4_0) reset --hard
	git --git-dir $(3_6)/.git --work-tree $(3_6) reset --hard
	git --git-dir $(3_5)/.git --work-tree $(3_5) reset --hard
	git --git-dir $(3_4)/.git --work-tree $(3_4) reset --hard
	git --git-dir $(3_3)/.git --work-tree $(3_3) reset --hard
	git --git-dir $(3_2)/.git --work-tree $(3_2) reset --hard
	git --git-dir $(3_1)/.git --work-tree $(3_1) reset --hard
	git --git-dir $(3_0)/.git --work-tree $(3_0) reset --hard
	git --git-dir $(2_2)/.git --work-tree $(2_2) reset --hard
	git --git-dir $(CORE)/.git --work-tree $(CORE) reset --hard

#
# Generates the core docs
#
generate_core_docs:
	@echo "== Generating core docs"
	cd $(CORE); git reset --hard
	cd $(CORE); $(HUGO) -s docs/reference -d ../../public -b $(baseurl_core) -t mongodb
	cd $(CORE); $(JSDOC) -c conf.json -t docs/jsdoc-template/ -d ./public/api
	cd $(CORE); cp -R ./public/api/scripts ./public/.
	cd $(CORE); cp -R ./public/api/styles ./public/.

#
# Generates the driver 2.0 docs
#
generate_2_2_docs:
	@echo "== Generating 2.2 docs"
	cd $(2_2); git reset --hard
	cd $(2_2); $(HUGO) -s docs/reference -d ../../public -b $(baseurl_2_2) -t mongodb
	# cd $(2_2); $(JSDOC) -c conf.json -t docs/jsdoc-template/ -d ./public/api
	# cd $(2_2); cp -R ./public/api/scripts ./public/.
	# cd $(2_2); cp -R ./public/api/styles ./public/.

#
# Generates the driver 3.0 docs
#
generate_3_0_docs:
	@echo "== Generating 3.0 docs"
	cd $(3_0); git reset --hard
	cd $(3_0); $(HUGO) -s docs/reference -d ../../public -b $(baseurl_3_0) -t mongodb
	cd $(3_0); $(JSDOC) -c conf.json -t docs/jsdoc-template/ -d ./public/api
	cd $(3_0); cp -R ./public/api/scripts ./public/.
	cd $(3_0); cp -R ./public/api/styles ./public/.

#
# Generates the driver 3.1 docs
#
generate_3_1_docs:
	@echo "== Generating 3.1 docs"
	cd $(3_1); git reset --hard
	cd $(3_1); $(HUGO) -s docs/reference -d ../../public -b $(baseurl_3_1) -t mongodb
	cd $(3_1); $(JSDOC) -c conf.json -t docs/jsdoc-template/ -d ./public/api
	cd $(3_1); cp -R ./public/api/scripts ./public/.
	cd $(3_1); cp -R ./public/api/styles ./public/.

#
# Generates the driver 3.2 docs
#
generate_3_2_docs:
	@echo "== Generating 3.2 docs"
	cd $(3_2); git reset --hard
	cd $(3_2); $(HUGO) -s docs/reference -d ../../public -b $(baseurl_3_2) -t mongodb
	cd $(3_2); $(JSDOC) -c conf.json -t docs/jsdoc-template/ -d ./public/api
	cd $(3_2); cp -R ./public/api/scripts ./public/.
	cd $(3_2); cp -R ./public/api/styles ./public/.

#
# Generates the driver 3.3 docs
#
generate_3_3_docs:
	@echo "== Generating 3.3 docs"
	cd $(3_3); git reset --hard
	cd $(3_3); $(HUGO) -s docs/reference -d ../../public -b $(baseurl_3_3) -t mongodb
	cd $(3_3); $(JSDOC) -c conf.json -t docs/jsdoc-template/ -d ./public/api
	cd $(3_3); cp -R ./public/api/scripts ./public/.
	cd $(3_3); cp -R ./public/api/styles ./public/.

#
# Generates the driver 3.4 docs
#
generate_3_4_docs:
	@echo "== Generating 3.4 docs"
	cd $(3_4); git reset --hard
	cd $(3_4); $(HUGO) -s docs/reference -d ../../public -b $(baseurl_3_4) -t mongodb
	cd $(3_4); $(JSDOC) -c conf.json -t docs/jsdoc-template/ -d ./public/api
	cd $(3_4); cp -R ./public/api/scripts ./public/.
	cd $(3_4); cp -R ./public/api/styles ./public/.

#
# Generates the driver 3.5 docs
#
generate_3_5_docs:
	@echo "== Generating 3.5 docs"
	# cd $(3_5); git reset --hard
	cd $(3_5); $(HUGO) -s docs/reference -d ../../public -b $(baseurl_3_5) -t mongodb
	cd $(3_5); $(JSDOC) -c conf.json -t docs/jsdoc-template/ -d ./public/api
	cd $(3_5); cp -R ./public/api/scripts ./public/.
	cd $(3_5); cp -R ./public/api/styles ./public/.

#
# Generates the driver 3.6 docs
#
generate_3_6_docs:
	@echo "== Generating 3.6 docs"
	cd $(3_6); git reset --hard
	cd $(3_6); $(HUGO) -s docs/reference -d ../../public -b $(baseurl_3_6) -t mongodb
	cd $(3_6); $(JSDOC) -c conf.json -t docs/jsdoc-template/ -d ./public/api
	cd $(3_6); cp -R ./public/api/scripts ./public/.
	cd $(3_6); cp -R ./public/api/styles ./public/.

#
# Generates the driver 4.0 docs
#
generate_4_0_docs:
	@echo "== Generating 4.0 docs"
	cd $(4_0); npm run build:docs
