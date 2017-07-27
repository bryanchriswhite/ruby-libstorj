#include "rice/Class.hpp"
#include <string.h>
#include "./storj.h"

using namespace Rice;
using namespace std;

typedef struct storj_options {
    storj_bridge_options_t *bridge_options,
    storj_encrypt_options_t *encrypt_options,
    storj_http_options_t *http_options,
    storj_log_options_t *log_options,
} storj_options_t;

storj_options_t build_options() {
// Bridge URL handling
    const char *url = "http://api.storj.io";
    char proto[6];
    char host[100];
    int port = 0;
    sscanf(url, "%5[^://]://%99[^:/]:%99d", proto, host, &port);
    if (port == 0) {
        if (strcmp(proto, "http") == 0) {
            port = 80;
        } else {
            port = 443;
        }
    }

    const char *user = "bryan@liminal.ly";
    const char *pass = "reallybadpassword";
    const char *mnemonic = "";

// Setup option structs
    storj_bridge_options_t bridge_options = {};
    bridge_options.proto = proto;
    bridge_options.host = host;
    bridge_options.port = port;
    bridge_options.user = user;
    bridge_options.pass = pass;

    storj_encrypt_options_t encrypt_options = {};
    encrypt_options.mnemonic = mnemonic;

    storj_http_options_t http_options = {};
    http_options.user_agent = "storj-test";
    http_options.low_speed_limit = STORJ_LOW_SPEED_LIMIT;
    http_options.low_speed_time = STORJ_LOW_SPEED_TIME;
    http_options.timeout = STORJ_HTTP_TIMEOUT;

    storj_log_options_t log_options = {};
    log_options.logger = NULL;
    log_options.level = 0;


}

extern "C"

void Init_ruby_libstorj() {
  Class rb_cLibStorj = define_class("LibStorj")
    .define_method("init_env", &storj_init_env)
    .define_method("util_timestamp", &storj_util_timestamp)
    .define_method("mnemonic_check", &storj_mnemonic_check);
//    .define_method("initialize", &init);
}

//void init() {
//// Bridge URL handling
//    const char *url = "http://api.storj.io";
//    char proto[6];
//    char host[100];
//    int port = 0;
//    sscanf(url, "%5[^://]://%99[^:/]:%99d", proto, host, &port);
//    if (port == 0) {
//        if (strcmp(proto, "http") == 0) {
//            port = 80;
//        } else {
//            port = 443;
//        }
//    }
//
//    const char *user = "bryan@liminal.ly";
//    const char *pass = "reallybadpassword";
//    const char *mnemonic = "";
//
//// Setup option structs
//    storj_bridge_options_t bridge_options = {};
//    bridge_options.proto = proto;
//    bridge_options.host = host;
//    bridge_options.port = port;
//    bridge_options.user = user;
//    bridge_options.pass = pass;
//
//    storj_encrypt_options_t encrypt_options = {};
//    encrypt_options.mnemonic = mnemonic;
//
//    storj_http_options_t http_options = {};
//    http_options.user_agent = "storj-test";
//    http_options.low_speed_limit = STORJ_LOW_SPEED_LIMIT;
//    http_options.low_speed_time = STORJ_LOW_SPEED_TIME;
//    http_options.timeout = STORJ_HTTP_TIMEOUT;
//
//    storj_log_options_t log_options = {};
//    log_options.logger = NULL;
//    log_options.level = 0;
//
//// Initialize environment
//    storj_env_t *env = storj_init_env(&bridge_options,
//                                      &encrypt_options,
//                                      &http_options,
//                                      &log_options);
//}

