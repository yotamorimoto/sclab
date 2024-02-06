// the code
Impulse xn => dac;
0.1 => float x;
1 => int counter;

MAUI_Slider rslider;
rslider.range(1.5, 2.0);
rslider.name("r");
rslider.display();

fun float logis(float r, float x) {
    return 1.0 - r * x * x;
}

while (true) {
    // Std.randf() => xn.next;
    logis(rslider.value(), x) => x;
    x => xn.next;
    1::samp => now;
    counter++;
}