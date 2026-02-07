#include <assert.h>

enum flags {
  flag_1 = 1,
  flag_4 = 4,
};

int flag_to_int(enum flags flag)
{
  switch (flag) {
    case flag_1:
      return 1;
    case flag_4:
      return 4;
    default:
      ; // @note saljuk: Weird that the CN parser requires this, otherwise it thinks there's nothing here.
      /*@ assert(false); @*/     // <-- should be unreachable
      break;
  }
}

int main(void)
/*@ trusted; @*/
{
  flag_to_int(flag_1);
}
