#include <arpa/inet.h>
#include <netdb.h>
#include <stdio.h>
int main () {
  struct addrinfo *res;
  // gethostname is obsolete - it returns hostent structs and is not quite compatible with connect
  struct hostent *x = gethostbyname("alias.kolodziejski.me");
  int i;
  for (i = 0; x->h_aliases[i] != NULL; i++) {
    printf ("alias: %s\n", x->h_aliases[i]);
  }
  printf ("total aliases: %d\n", i);
  printf ("name: %s\n", x->h_name);

  struct in_addr **addr_list;
  addr_list = (struct in_addr **)x->h_addr_list; // types in C are terrible
  for(i = 0; addr_list[i] != NULL; i++) {
    printf("in_addr: %s\n", inet_ntoa(*addr_list[i]));
  }
  printf ("total in_addrs: %d\n", i);
}

