require 'mkmf'
REQUIRED_LIBS = %w[curl uv storj]

REQUIRED_LIBS.each do |lib_name|
  abort "missing C library: #{lib_name}" unless have_library(lib_name)
end

create_makefile('ruby-libstorj/ruby-libstorj')
