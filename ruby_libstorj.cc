#include <string.h>
#include "./storj.h"
//#include "uv.h"

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


extern "C"
storj_env * init_storj_ruby(storj_bridge_options_t *bridge,
                              storj_encrypt_options_t *encrypt,
                              storj_http_options_t *http,
                              storj_log_options_t *log) {
//  printf("storj_init_env...");
  storj_env *env = storj_init_env(bridge,
                             encrypt,
                             http,
                             log);
//  printf("done!!! - returning to ruby\n");
  return env;
}
