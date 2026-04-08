struct s { int a; int b; struct s *s; };
struct q { int a; struct s b; };

void callme(int a, int *b, int ***c, struct s s0, struct s *s1, struct s *s2, int *x, struct q* qp, struct q qs)
/*@
requires
    take bb   = Owned<int>(b);
    take s1_b = Owned<int>(member_shift<struct s>(s1, b));
    take ss2  = Owned(s2);
    take cc   = Owned(c);
    take ccc  = Owned(cc);
    take cccc = Owned(ccc);
    take y = Owned(x);
    take q = Owned(qp);
    a == 42i32;
    bb == 43i32;
    cccc == 44i32;
    s0.a == s0.b;
    s1_b == 45i32;
    ss2.a == ss2.b;
    y == 5i32;
    q.a == 0i32;
ensures
    take bb_   = Owned<int>(b);
    take s1_b_ = Owned<int>(member_shift<struct s>(s1, b));
    take ss2_  = Owned(s2);
    take cc_   = Owned(c);
    take ccc_  = Owned(cc_);
    take cccc_ = Owned(ccc);
    take y_ = Owned(x);
    take q_ = Owned(qp);
    a == 42i32;
    bb_ == 43i32;
    cccc_ == 44i32;
    s0.a == s0.b;
    s1_b_ == 45i32;
    ss2_.a == ss2.b;
    y_ == 5i32;
    q_.a == 0i32;
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

    int x = 5;

    struct q q = { .a = 0 };

    struct q s = { .a = 5 };

    callme(a, b, c, s0, s1, s2, &x, &q, s);

    return 0;
}