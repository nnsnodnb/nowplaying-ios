.PHONY: setup
setup:
	$(MAKE) bundler
	$(MAKE) cocoapods

.PHONY: bundler
bundler:
	@gem install bundler -v 2.3.12 -N
	@bundle config set path 'vendor/bundle'
	@bundle config set jobs '4'
	@bundle config set retry '3'
	@bundle install

.PHONY: cocoapods
cocoapods:
	@bundle exec pod install
