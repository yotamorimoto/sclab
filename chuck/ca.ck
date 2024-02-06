// the code
Impulse xn => dac;
300 => int WIDTH;
float prevCell[WIDTH];
float nextCell[WIDTH];
1 => int counter;

MAUI_Slider slider;
slider.range(0, 0.9);
slider.name("const");
slider.display();

//for(0=>int i; i<WIDTH; i++)
// Std.randf() => cell[i];
1. => prevCell[WIDTH/2];

fun float takeFraction(float f)
{
    
    float result;
    
    f - Math.trunc(f) => result;
    
    return result;
}
fun float updateNext(int i)
{
    
    takeFraction((prevCell[(i-1)%WIDTH] + prevCell[i%WIDTH] + prevCell[(i+1)%WIDTH])/3.) 
    
    + slider.value() => nextCell[i%WIDTH];
    
    return prevCell[i%WIDTH];
}
fun float updatePrev(int i){
    
    takeFraction((nextCell[(i-1)%WIDTH] + nextCell[i%WIDTH] + nextCell[(i+1)%WIDTH])/3.)
    
    + slider.value() => prevCell[i%WIDTH];
    
    return nextCell[i%WIDTH];
};

while( true )
{
    // Std.randf() => xn.next;
    if(Math.trunc(counter/WIDTH)%2 == 1){
        updateNext(counter) => xn.next;
    } else {
        updatePrev(counter) => xn.next;
    }
    1::samp => now;
    counter++;
}