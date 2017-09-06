#include <string.h>
#include <storj.h>
//#include <ffi/MemoryPointer.h>
#include "rice/Class.hpp"

using namespace std;

extern "C"
void mnemonic_generate_proxy(int strength, char* buffer) {

    char* mnemonic = storj_mnemonic_generate(strength, )
}

extern "C"
void Init_ruby_libstorj(void) {
/*
 *  Experiment here...
 *
 *      the goal of this implementation is to use ruby FFI
 *      as much as possible for better compatibility/support
 *      as well as more accessibility from the ruby side
 */

//    printf("C: hello from `Init_ruby_libstorj`!");
}
