// Based on http://stackoverflow.com/a/23533623/1566221
// compile with `gcc -std=c11 -Wall -o ../scripts/unicode_test unicode_test.c`
//
// This code tests if the first unicode character number should be displayed correctly
// It is used to guess if we will have issues with unicode characters, testing the 2713 character

#define _XOPEN_SOURCE 600
#include <locale.h>
#include <stdio.h>
#include <stdlib.h>
#include <wctype.h>
#include <wchar.h>

int main(int argc, char** argv) {
  setlocale(LC_CTYPE,"");
  wint_t c = strtoul(argv[1], NULL, 16);
  return (wcwidth(c) != 1);
}

