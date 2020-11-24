int add8(int *z) {
    return add2(add4(z[0], z[1], z[2], z[3]),
                add4(z[4], z[5], z[6], z[7]));
}

int add4(int a, int b, int c, int d) {
    return add2(add2(a, b), add2(c, d));
}

int add2(int x, int y) {
    return x + y;
}
