NODE = node
NPM = npm
JSDOC = jsdoc
name = all
2_0 = checkout/2.0
1_4 = checkout/1.4
# Base url used to generate 2.0 API docs
baseurl_2_0 = /2.0
baseurl = /

#
# Generate all
#
all: setup generate_main_docs

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
	git --git-dir $(1_4)/.git --work-tree $(1_4) checkout 1.4
	
	# Install all dependencies
	cd checkout/2.0; npm install
	cd checkout/1.4; npm install
	cd ../..

#
# Generates main docs frame
#
generate_main_docs: generate_2_0_docs generate_1_4_docs
	echo "== Generating Main docs"
	rm -rf ./public
	hugo -s site/ -d ../public -b $(baseurl)
	# Copy the 2.0 docs
	cp -R $(2_0)/public ./public/2.0
	# Copy the 1.4 docs
	cp -R $(1_4)/docs/sphinx-docs/build/html ./public/1.4
	# Tar up the release information
	tar -zcvf ./docs.tar.gz public/

#
# Generates the driver 1.4 docs
#
generate_1_4_docs:
	echo "== Generating 1.4 docs"
	cd $(1_4); $(NODE) dev/tools/build-docs.js
	cd $(1_4); make --directory=./docs/sphinx-docs --file=Makefile html

#
# Generates the driver 2.0 docs
#
generate_2_0_docs:		
	echo "== Generating 2.0 docs"
	cd $(2_0); cp -R ./docs/history-header.md ./docs/content/meta/release-notes.md
	cd $(2_0); more ./HISTORY.md >> ./docs/content/meta/release-notes.md
	cd $(2_0); hugo -s docs/ -d ../public -b $(baseurl_2_0)
	cd $(2_0); $(JSDOC) -c conf.json -t docs/jsdoc-template/ -d ./public/api
	cd $(2_0); cp -R ./public/api/scripts ./public/.
	cd $(2_0); cp -R ./public/api/styles ./public/.

.PHONY: total
