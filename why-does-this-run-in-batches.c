#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/ioctl.h>

const int MAXLINE = 1000;

int main (void) {
  int n;
  int fd[2];
  pid_t pid;
  char line[MAXLINE];
  int nbytes;

  if (pipe(fd) < 0) {
    exit(1);
  }

  if ((pid = fork()) < 0) {
    exit(2);
  } else if (pid > 0) { // parent
    close(fd[0]);
    while (1) {
      write(fd[1], "x", 1); // why does this run in batches and a single run after every single read?!
    }
  } else { // child
    int i = 0;
    close(fd[1]);
    while (1) {
      usleep(1000);
      read(fd[0], line, 1);

      ioctl(fd[0], FIONREAD, &nbytes); // how much data is in the pipe
      printf("%d\n", nbytes);
    }
  }
}
