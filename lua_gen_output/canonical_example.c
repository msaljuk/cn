struct s { int a; int b; struct s *s; };

void callme(int a, int *b, int ***c, struct s s0, struct s *s1, struct s *s2)
/*@
requires
    take bb   = Owned<int>(b);
    take s1_b = Owned<int>(member_shift<struct s>(s1, b));
    take ss2  = Owned(s2);
    take cc   = Owned(c);
    take ccc  = Owned(cc);
    take cccc = Owned(ccc);
    a == 42i32;
    bb == 43i32;
    cccc == 44i32;
    s0.a == s0.b;
    s1_b == 45i32;
    ss2.a == ss2.b;
@*/
{
    int xxx = 1;
}


int main(void)
/*@ trusted; @*/
{
    int a = 42;

    int bb = 43;
    int *b = &bb;

    int cccc = 44;
    int *c1 = &cccc;
    int **c2 = &c1;
    int ***c = &c2;

    struct s s0 = { .a = 0, .b = 0 };

    struct s s1val = { .b = 45 };
    struct s* s1 = &s1val;

    struct s ss2 = { .a = 0, .b = 0 };
    struct s* s2 = &ss2;

    callme(a, b, c, s0, s1, s2);

    return 0;
}