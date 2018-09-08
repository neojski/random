#include <arpa/inet.h>
#include <errno.h>
#include <netdb.h>
#include <netinet/in.h>
#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>

// first run:
// echo 'hello world' | nc -l 127.0.0.1 -p 1234
int main () {
  int buf[100];
  int fd = socket (AF_INET, SOCK_STREAM, 0);
  if (fd < 0) {
    printf ("ERROR socket\n");
    return 1;
  }

  struct addrinfo *res;

  if (getaddrinfo("127.0.0.1", "1234", NULL, &res) < 0) { 
    printf ("ERROR getaddrinfo, %d, %s\n", errno, strerror(errno));
    return 2;
  }

  if (connect (fd, res->ai_addr, res->ai_addrlen) < 0) {
    printf ("ERROR connect, %d, %s\n", errno, strerror(errno));
    return 3;
  }

  ssize_t len = read (fd, buf, 100);
  if (len < -1) {
    printf ("ERROR read, %d, %s\n", errno, strerror(errno));
    return 4;
  }
  printf ("%s", buf);
}

