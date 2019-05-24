1. Creating randomness [ShapingFunctions.glsl](ShapingFunctions.glsl)
	1. Look at function y = fract(sin(x) * 1.0);
	1. Add zeros to factor
	1. One way of creating pseudo random numbers
1. [Random.glsl](Random.glsl)
	1. Play around with the magic numbers
	1. Try out random(float) for both axis; note symmetry
	1. Try out random(vec2)
	1. Hook it to mouse movement
	1. Hook it to iGlobalTime
	1. Apply it to Truchet patterns
	1. Create your own effect [some examples](http://thebookofshaders.com/10/)
1. [Noise.glsl](Noise.glsl), [Noise2D.glsl](Noise2D.glsl)
	1. Analyse differences of rand() and noise() in [ShapingFunctions.glsl](ShapingFunctions.glsl)
	1. Look at code together
	1. When do rand() and noise() look the same?
	1. Try out different interpolations
1. (Wood.glsl)
	1. Uncomment and analyze
1. (Lava.glsl)
	1. Uncomment and analyze
1. [ShapingFunctions.glsl](ShapingFunctions.glsl)
	1. Look at amplitude * sin(x * frequency + phase)
	1. Hook phase to iMouse.x * 0.1
	1. Add second sin() with much higher frequency and small amplitude
	1. Do the same with noise()
1. [fBm.glsl](fBm.glsl)
	1. Look at code together
	1. Increase the number of octaves
	1. Change the other parameters
1. [fBm2D.glsl](fBm2D.glsl)
	1. Look at code together
	1. Uncomment different types
