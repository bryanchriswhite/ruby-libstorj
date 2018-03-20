ruby-libstorj
===
[![Storj.io](https://storj.io/img/storj-badge.svg)](https://storj.io)
[![Gem Version](https://badge.fury.io/rb/ruby-libstorj.svg)](https://badge.fury.io/rb/ruby-libstorj)

Ruby library for encrypted file transfer on the Storj network via bindings to [libstorj](https://github.com/Storj/libstorj).

## Using ruby-libstorj

### First, install [`libstorj`](https://github.com/storj/libstorj)

### Install gem:
+ using bundler:
    ```
    # in your Gemfile
    gem 'ruby-libstorj'
    ```
    ```bash
    bundle install
    ```
+ using rubygems (`gem`):
    ```bash
    gem install ruby-libstorj
    ```
+ from source:
    ```bash
    git clone https://github.com/storj/ruby-libstorj && \
    cd ruby-libstorj && \
    rake install
    ```
    (see [installing for development](#wip) if you have issues with `rake install`)

### Usage:
Until more thorough documentation is available, please see the tests:
+ [`LibStorj`](./spec/ruby-libstorj/libstorj_spec.rb) _[(source)](./lib/ruby-libstorj/libstorj.rb)_
    - `LibStorj::Ext::Storj::Mixins`  _[(source)](./lib/ruby-libstorj/mixins/storj.rb)_
        - `.util_timestamp`
        - `.util_datetime`
        - `.mnemonic_check`
        - `.mnemonic_generate`
+ [`LibStorj::Env`](./spec/ruby-libstorj/env_spec.rb) _[(source)](./lib/ruby-libstorj/env.rb)_
    - `#get_info`
    - `#get_buckets`
    - `#create_bucket`
    - `#delete_bucket`
    - `#store_file`
    - `#resolve_file`
    - `#list_files`
    - `#delete_file`

## Developing ruby-libstorj

This project primarily uses the ruby [`ffi`](https://rubygems.org/gems/ffi) (foreign function interface) gem api to bind to C/C++ libraries and plain old ruby for logic.

If the ffi api becomes insufficient the ruby gem [`rice`](https://rubygems.org/gems/rice) has proven extremely useful for doing ruby things in C/C++.
Otherwise, you're going to want to read up on [ruby's C API](https://silverhammermba.github.io/emberb/c/)

This project strives to conform to the ruby  and rubygems standards and conventions. See [rubygems.org guide on "Make Your Own Gem"](http://guides.rubygems.org/make-your-own-gem/) for more.

#### Tooling:
+ `bundler` (see http://bundler.io/)
  - dependency management
+ `rake` (see https://github.com/ruby/rake)
  - task runner
+ `rspec` (see http://rspec.info/documentation/)
  - test framework
+ `guard` (see https://github.com/guard/guard)
  - task automation
    - rspec - file watching

### Install ruby dependencies:
```bash
bundle install
```

### Build native extensions:
```bash
rake compile
```
(see [`rake-compiler`](https://github.com/rake-compiler/rake-compiler))

### Build gem:
```bash
rake

# OR
# rake build
# rake build[no-test]   # build without requiring tests to pass
```

### Install gem:
+ with `rake`:
    ```bash
    rake install
    
    # OR
    # rake install[no-test]   # install without requiring tests to pass
    ```

+ with `gem`:

    Maybe you need/want to pass args to `gem`, or maybe `rake install` doesn't work on your system:
    
    ```bash
    gem install --local ./ruby-libstorj-*.gem  --no-ri --no-rdoc  
    ```

### Testing:
#### First create spec/helpers/options.yml !
For the moment, the test suite doesn't start it's own mock backend but it does parse whatever's in the `spec/helpsers/options.yml` file to initialize `LibStorj::Ext::Storj::Env` to connect via http/https.

You can copy [`spec/helpers/options.yml.example`](spec/helpers/options.example.yml) and modify it for your use:
```bash
cp spec/helpers/options.yml.example spec/helpers/options.yml && \
vim spec/helpers/options.yml   # or whatever
```
`spec/helpers/options.yml` should be in the [`.gitignore`](./.gitignore) so you shouldn't have to worry about accidentally committing it.

#### A quick note on rspec formatters:
The "progress" formatter is the default.
This repo makes it easy to change formatters when invoking rspec via `rspec` or `rake` binaries.

With that said, here are your options:
```bash
$ rspec --help | less
    #=>
-f, --format FORMATTER   Choose a formatter.
                         [p]rogress (default - dots)
                         [d]ocumentation (group and example names)
                         [h]tml
                         [j]son
                         custom formatter class name
```

#### Test coverage reporting:
This repo uses [`simplecov`](https://github.com/colszowka/simplecov) to generage test coverage reports on **each** test run.

When executing tests via rake, a `file://` url to the coverage report is printed for easy copy/pasting into a browser;
further, if you want to automatically open it (via [`launchy`](https://github.com/copiousfreetime/launchy)) you may pass `y` or `yes` as the second rake argument to either `:spec` or `:test` tasks.

For example usages see "with `rake`" below.

#### Running the tests:
+ with `rake`:
    ```bash
    rake test
    
    # rake test[<formatter>,<open coverage>]
    #
    # pass <formatter> to rspec as `--format <formatter>` 
    #
    # e.g. (the following are all equivalent):
    # rake test[doc]
    # rake test[d]
    # rake spec[d]
    #
    # open coverage report automatically
    #
    # e.g. (also equivalent; using default formatter):
    # rake test[,yes]
    # rake test[,y]
    #
    # do both
    #
    # rake test[d,y]
    ```
    
    Keep in mind that rake will also run any dependencies of the `:test` (or `:spec`) task
    
    _(e.g. start a web server, open coverage report, etc.)_
+ with `rspec`:
    ```bash
    rspec   # cli args can be passed directly to rspec
    
    # Change the rspec formatter:
    #
    # rspec --format doc  # use the 'document' rspec formatter
    # rspec -f d          # short version
    #
    # Test specific files:
    #
    # rspec spec/ruby-libstorj/env_spec.rb      # single file
    # rspec spec/ruby-libstorj/{env,libstorj}*  # glob of files
    #
    # Test specific examples:
    #
    # rspec spec/ruby-libstorj/env_spec.rb:15   # run test(s) containing line 15
    ```
    (see `rspec --help | less`)
    
### Gotchas:
+ `libuv` (see http://docs.libuv.org/en/v1.x/)
   
   #### The problem
   The C library [`libuv`](http://docs.libuv.org/en/v1.x/) is used by [`libstorj`](https://github.com/storj/libstorj) for concurrency;
   however, ruby's C API is not thread-safe so this is currently resolved by using the ruby gem [`libuv`](https://rubygems.org/gems/libuv) in tandem with the C-`libuv` calls in `libstorj`
   
   Specifically, `libstorj` makes calls to the C-`libuv` function [`uv_queue_work`](http://docs.libuv.org/en/v1.x/threadpool.html), which queues work to be run in another thread.
   In standard C-`libuv` usage, you would call [`uv_run(...)`](http://docs.libuv.org/en/v1.x/loop.html#c.uv_run):
   
   ```c
   #include <uv.h>
   ...
   // Queue work to be run in another thread
   uv_queue_work(...);
   ...
   // Run the event loop
   uv_run(...);
   ```
   
   After calling a function which queues work using the C `uv_queue_work` function, simply calling `uv_run` from ruby does **not work**:
   ```c
   /* example.c */
   #include <uv.h>
   ...
   // implemented elsewhere
   uv_work_t* my_work_factory(void* handle);
   ...
   handle_wrapper
   ...
   extern "C"
   int example_queue_work(void* handle, uv_after_work_cb cb)
   {
       uv_loop_t* loop = uv_default_loop();
       uv_work_t *work = my_work_factory(handle);
   
       return uv_queue_work(loop, work, my_worker, cb);
   }
   ```
    
   ```ruby
   # example.rb
   # NOTE: THIS IS AN EXAMPLE OF WHAT DOES NOT WORK
   ####################################### === ####
   require 'ffi'

   module Example
     extend FFI::Library
     # load built shared object from C/C++ using ruby ffi
     ffi_lib '/path/to/libexample.so'
   
     # NB: if `libexample` is installed in the usual system location*
     # ffi_lib 'example'
   
     # expose C functions as members of the `Example` module
     attach_function('queue_work', 'example_queue_work', [:pointer, :int], :int)
     attach_function('run', 'uv_run', [:pointer, :int], :int)
   end
 
   handle = FFI::Function.new(...) {...}
   cb     = FFI::Function.new(...) {...}
 
   Example.queue_work handle, cb
   Example.run  #=> segmentation fault
   ```
   _*`ffi_lib` automatically adds the conventional "lib" prefix to args which are not absolute paths_
   
   
   It seems to be the case that calls to `uv_default_loop()` made from within C-libstorj point to a different location than the default loop from ruby-livub.
   It may be the case that C-libuv is being loaded twice, one linked through C-libstorj and the other through ruby-libuv bindings or something; more digging required.
   
   #### The solution
   Instead of calling `uv_run` directly, if we let the ruby `libuv` gem do it for us, we can call `uv_queue_work` in C as much as we want.
   
   Using ruby-`libuv`'s `reactor` block to wrap calls to C functions that call `uv_queue_work`, we let ruby-`libuv` do the heavy concurrency lifting and C-`libuv` integration:
   
   ```ruby
   # example.rb
   require 'libuv'
   require 'ffi'
 
   module Example
     extend FFI::Library
     # load built shared object from C/C++ using ruby ffi
     ffi_lib '/path/to/libexample.so'
  
     # NB: if `libexample` is installed in the usual system location*
     # ffi_lib 'example'
  
     # expose C functions as members of the `Example` module
    attach_function('queue_work', 'example_queue_work', [:pointer, :int], :int)
   end
 
   handle = FFI::Function.new(...) {...}
   cb     = FFI::Function.new(...) {...}
 
   reactor do |reactor|
     reactor.work do
       Example.queue_work handle, cb
     end
   end
   ```
   (see https://github.com/cotag/libuv)
   
_NB: the understanding presented here comes from reading the docs and source of the various C and ruby libraries involved_
