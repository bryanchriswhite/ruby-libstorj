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
gem build
```

install gem:
```bash
gem install --local ./ruby_libstorj-0.0.0.gem  --no-ri --no-rdoc  
```
