/* slice 1 negative: add body not return a+b (parse should fail). */
int add(int a,int b){return a-b;}
int main(void){return add(40,2);}
