#include "rice/Module.hpp"
#include "rice/Class.hpp"
#include "rice/Object.hpp"
#include "rice/Data_Type.hpp"
#include "rice/Constructor.hpp"
#include <string.h>
#include "./storj.h"
//#include "uv.h"

using namespace Rice;
using namespace std;

//typedef void (*callback_t)(void*);

typedef struct {
    storj_bridge_options_t bridge;
    storj_encrypt_options_t encrypt;
    storj_http_options_t http;
    storj_log_options_t log;
} storj_options_t;

//void GetInfoCallback(uv_work_t *work_req, int status) {
////    Nan::HandleScope scope;
////
//    json_request_t *req = (json_request_t *) work_req->data;
////
////    Nan::Callback *callback = (Nan::Callback*)req->handle;
//callback_t (*callback)(String, String) = ((void(*)(String, String))req->handle);
////((void (*)(void *))req->handle) (callback);
////callback = req->handle;
////
////    v8::Local<v8::Value> error = Nan::Null();
////    v8::Local<Value> result = Nan::Null();
//String error = "";
//String result = "";
//
//    if (req->error_code || req->response == NULL) {
//        if (req->error_code) {
//            error = (String)curl_easy_strerror((CURLcode)req->error_code);
//        } else {
//            error = (String)"Failed to get info";
//        }
//    } else {
//        result = (String)json_object_to_json_string(req->response);
//    }
//
//    callback(error, result);
//    free(req);
//    free(work_req);
//}

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

//class rb_cStorjEnv {
//  public:
//     void *address;
//     void printAddress(void) {
//         printf("address: %p", address);
//     };
//         rb_cStorjEnv(storj_env_t *x) {
//         address = x;
//     };
//};

storj_env_t* init_storj_c(String user_string, String pass_string) {
  const char *url = "https://api.storj.io";
  const char *mnemonic = "one two three four five six seven";
  const char *user = user_string.c_str();
  const char *pass = pass_string.c_str();
  storj_options_t options = build_options(user, pass, url, mnemonic);

  storj_env_t *c_env = storj_init_env(&options.bridge,
                        &options.encrypt,
                        &options.http,
                        &options.log);

  printf("res address: %p\n", &c_env);
  printf("res bridge.user: %s\n", c_env->bridge_options->user);

//  rb_cStorjEnv rb_env = rb_cStorjEnv(c_env);
//  return rb_env;
  return c_env;
//  Rice::Data_Type<rb_cStorjEnv>
}

//storj_env_t* proxy_storj_init_env(char *user, char *pass) {
//
//}


extern "C"
storj_env * init_storj_ruby(storj_bridge_options_t *bridge,
                              storj_encrypt_options_t *encrypt,
                              storj_http_options_t *http,
                              storj_log_options_t *log) {
  printf("storj_init_env...");
  storj_env *env = storj_init_env(bridge,
                             encrypt,
                             http,
                             log);
  printf("done!!! - returning to ruby\n");
  return env;
}

extern "C"
void Init_ruby_libstorj() {
  Data_Type<storj_env> rb_cStorjEnv = define_class<storj_env>("storj_env")
    .define_constructor(Constructor<storj_env>())
//    .define_method("get_info", &storj_bridge_get_info)
    .define_singleton_method("util_timestamp", &storj_util_timestamp)
    .define_singleton_method("mnemonic_check", &storj_mnemonic_check);
//    .define_singleton_method("initialize", &initialize)
//    .define_singleton_method("print_address", &print_address);
  Module rb_mLibStorjC = define_module("LibStorjC")
    .define_singleton_method("init_env_c", &init_storj_c)
//    .define_singleton_method("init_env_ruby", &init_storj_ruby)
    .define_singleton_method("util_timestamp", &storj_util_timestamp)
    .define_singleton_method("mnemonic_check", &storj_mnemonic_check);

//  printf("rb_cStorjEnv.name(): %s\n", rb_cStorjEnv.name().c_str());
//  printf("rb_mLibStorj.name(): %s\n", rb_mLibStorj.name().c_str());
}

