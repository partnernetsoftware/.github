/* slice 1 negative: non-int add signature (parse should fail). */
float add(float a,float b){return a+b;}
int main(void){return (int)add(40,2);}
