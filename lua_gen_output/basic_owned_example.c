void simple_integer (int s)
/*@
requires
  s == 0i32;
@*/
{
}

struct s {
  int x;
  int y;
};

void simple_owned (struct s *origin)
/*@
requires
  take Or = RW<struct s>(origin);
  Or.y == 0i32;
ensures
  take Or_ = RW<struct s>(origin);
  Or_.y == 7i32;
@*/
{
  origin->y = 7;
}

void addtl_indirection_owned (struct s **origin)
/*@
requires
  take Or = RW<struct s*>(origin);
  take Or_ = RW<struct s>(Or);
  Or_.y == 7i32;
ensures
  take Or = RW<struct s*>(origin);
  take Or_ = RW<struct s>(Or);
  Or_.y == 0i32;
@*/
{
  (*origin)->y = 0;
}


int main(void)
{
  int x = 0;
  simple_integer(x);

  struct s sample = { .x = 7, .y = 0 };
  simple_owned(&sample);

  struct s *s_addr = &sample;
  addtl_indirection_owned(&s_addr);
}