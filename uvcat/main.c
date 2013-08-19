#include <stdio.h>
#include <uv.h>

uv_fs_t open_req;
uv_fs_t read_req;
uv_fs_t write_req;
char buffer[1000];

void do_read();
void on_read();
void on_open();

void error(char *name, int errorno) {
	fprintf(stderr, "%s error, %d: %s\n", name, errorno, uv_strerror(errorno));
}

void do_read(){
	uv_fs_read(uv_default_loop(), &read_req, open_req.result, buffer, sizeof(buffer), -1, on_read);
}

void on_write(uv_fs_t *req){
	uv_fs_req_cleanup(req);
	if (req->result < 0) {
		error("write", req->result);
		return;
	} else {
		do_read();
	}
}

void on_read(uv_fs_t *req){
	uv_fs_req_cleanup(req);
	if (req->result < 0) {
		error("read", req->result);
		return;
	} else if(req->result == 0) {
		uv_fs_t close_req;
		uv_fs_close(uv_default_loop(), &close_req, open_req.result, NULL);
	} else {
		uv_fs_write(uv_default_loop(), &write_req, 1, buffer, req->result, -1, on_write);
	}
}

void on_open(uv_fs_t *req){
	uv_fs_req_cleanup(req);
	if (req->result < 0) {
		error("open", req->result);
		return;
	}
	do_read();
}

int main(int argc, char **argv){
	if (argc < 2) return 1;
	uv_fs_open(uv_default_loop(), &open_req, argv[1], O_RDONLY, 0, on_open);
	uv_run(uv_default_loop(), UV_RUN_DEFAULT);

	return 0;
}
