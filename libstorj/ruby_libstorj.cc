#include "rice/Class.hpp"
#include <string.h>
#include "./storj.h"

using namespace Rice;
using namespace std;

typedef struct {
    storj_bridge_options_t bridge;
    storj_encrypt_options_t encrypt;
    storj_http_options_t http;
    storj_log_options_t log;
} storj_options_t;

storj_options_t build_options(const char *user,
                              const char *pass,
                              const char *url,
                              const char *mnemonic) {
// Bridge URL handling
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

// Setup option structs
//    storj_options_t storj_options = {};
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

    storj_options_t options = {};
    options.bridge = bridge_options;
    options.encrypt = encrypt_options;
    options.http = http_options;
    options.log = log_options;

    return options;
}

storj_env_t* init_storj(String user_string, String pass_string) {
  const char *url = "http://api.storj.io";
  const char *mnemonic = "one two three four five six seven";
  const char *user = user_string.c_str();
  const char *pass = pass_string.c_str();
//  const char user = &_user;
//  const char pass = &_pass;
  storj_options_t options = build_options(user, pass, url, mnemonic);

  return storj_init_env(&options.bridge,
                        &options.encrypt,
                        &options.http,
                        &options.log);
}

extern "C"

void Init_ruby_libstorj() {
  Class rb_cLibStorj = define_class("LibStorj")
    .define_method("init_env", &init_storj)
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

