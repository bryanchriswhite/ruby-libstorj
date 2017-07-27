require 'mkmf-rice'
have_library('storj', 'storj_init_env', 'storj.h')
create_makefile('ruby_libstorj', 'libstorj')