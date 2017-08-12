#include "uv.h"
#include "ruby.h"
#include <ruby/thread.h>
//#include <string.h>
#include <string>

typedef struct {
  uv_loop_t *loop;
  uv_run_mode mode;
} uv_run_args_t;

typedef struct {
  uv_run_args_t *run_args;
  uv_work_t *work;
  uv_work_cb callback;
  uv_after_work_cb after_callback;
} uv_queue_work_args_t;

uv_loop_t *loop = uv_default_loop();

uv_run_args_t run_args = {
  loop,
  UV_RUN_DEFAULT,
};
uv_run_args_t *uv_run_args = &run_args;

extern "C"
void callback(uv_work_t *req) {
  printf("callback called\n");
}

extern "C"
void after_callback(uv_work_t *req, int status) {
  printf("after_callback called\n");
}

extern "C"//  rb_thread_call_without_gvl(((void* (*)(void*))uv_run), uv_run_args, RUBY_UBF_IO, NULL);
void uv_run_default() {
  uv_run(uv_default_loop(), UV_RUN_DEFAULT);
}

extern "C"
void uv_run_default_without_gvl() {
//  rb_thread_call_without_gvl(uv_run, uv_run_args, RUBY_UBF_IO, NULL);
  rb_thread_call_without_gvl(((void* (*)(void*))uv_run), uv_run_args, RUBY_UBF_IO, NULL);
}

extern "C"
void queue_work_without_gvl(uv_loop_t *loop, uv_work_t *work, uv_work_cb cb, uv_after_work_cb after_cb) {
  printf("SANITY CHECK\n");
  uv_queue_work_args_t work_args = {
    uv_run_args,
    work,
    callback,
    after_callback
  };
//  uv_run_args_t ra = {uv_default_loop(), UV_RUN_DEFAULT};
//  uv_queue_work_args_t work_args = {
//    &ra,
//    work,
//    callback,
//    after_callback
//  };
  uv_queue_work_args_t *uv_queue_work_args = &work_args;
  printf("calling uv_queue_work...\n");

//  uv_queue_work(uv_run_args->loop, work, callback, after_callback);

//  uv_queue_work(uv_default_loop(), work, (uv_work_cb)cb, (uv_after_work_cb)a_cb);

  rb_thread_call_without_gvl(((void* (*)(void*))uv_queue_work), uv_queue_work_args, RUBY_UBF_IO, NULL);

  printf("done calling uv_work_queue.\n");
//  rb_thread_call_without_gvl(((void* (*)(void*))uv_run), uv_run_args, RUBY_UBF_IO, NULL);
}

//typedef void* void_t();

extern "C"
void queue_work(uv_work_cb cb, uv_after_work_cb a_cb) {
//void queue_work(void *cb, void *a_cb) {
//  uv_work_cb callback = ((void (*)(uv_work_t *)cb);
  printf("SANITY CHECK\n");
  uv_work_t worker;
  printf("beginning to queue work...\n");
  printf("C: default loop: %p\n", uv_default_loop());
  uv_queue_work(uv_default_loop(), &worker, (uv_work_cb)cb, (uv_after_work_cb)a_cb);
//  uv_queue_work_without_gvl(uv_default_loop(), &worker, callback, after_callback);
//  ((void (*)())cb)();
  printf("done queueing.\n");

//  printf("uv_run\n");(void *)
//  uv_run(uv_default_loop(), UV_RUN_DEFAULT);
//  printf("uv_run done\n");
  printf("exiting!\n");
}

//extern "C"
//int main() {
//  printf("SANITY CHECK\n");
//  uv_work_t worker;
//  printf("beginning to queue work...\n");
//  uv_queue_work(uv_default_loop(), &worker, callback, after_callback);
//  printf("done queueing.\n");
//
//  uv_run(uv_default_loop(), UV_RUN_DEFAULT);
//  printf("exiting!\n");
//  return 0;
//}
//int greet(void *handle, void *cb) {
////  int test_res = ((int (*)(int))test_func)(status);
////  printf("test_res: %d\n", test_res);
//  printf("greeting...\n");
//  int test_res = ((int (*)(void *))cb)(handle);
//  printf("done!\n");
//
////  int test_handle = ((int (*)(int))handle)(status);
//
//  return test_res;
//}
