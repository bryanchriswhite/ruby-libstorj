ruby_libstorj: Ruby bindings for libstorj
===

install ruby dependencies:
```bash
# assumes bundler is installed (see http://bundler.io/)
bundle install
```

build native extensions:
```bash
rake compile
```
(see https://github.com/rake-compiler/rake-compiler)

build gem:
```bash
rake
# OR
#rake build
```

install gem:
```bash
rake install
# OR (in case `rake install` doesn't work)
# gem install --local ./ruby_libstorj-*.gem  --no-ri --no-rdoc  
```
