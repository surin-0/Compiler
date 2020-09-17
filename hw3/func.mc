def f(a, b){
    local max;
    if(a>b)
        max = a;
    else
        max = b;
    return max;
}

def i(a, b, c){
    count = a+b+c;
    print count;
}

r = f(18, 20);
i(1,2,3);
print r;
