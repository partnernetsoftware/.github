/* nano-cc slice 2: two-arg add + main call (canonical lower: nano-jit-slice-add.lisp). */
int add(int a,int b){return a+b;}
int main(void){return add(40,2);}
