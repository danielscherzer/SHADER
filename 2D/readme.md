1. [HelloWorld.glsl](HelloWorld.glsl)
	1. Colors (line i)
		1. Invert the colors
		1. Make them brighter, darker
	1. Uniforms
		vec3 iMouse contains the mouse pixel position in xy and the state of the left mouse button in z.
	1. Functions (line ii and iii) [detailed description](https://thebookofshaders.com/07/)
		1. Compare the result of lines ii and iii
		1. How can you rotate the result by 90°?
		1. Combine results from multiple step functions like in line iv
		1. Use the step function to draw a rectangle
		1. Use smoothstep to draw soft edged rectangle
		1. Color the quad
		1. Can you do something that resembles a Piet Mondrian painting? ![Mondrian painting](mondrian.jpg "Mondrian painting")
	1. Draw a circle
1. [Pattern.glsl](Pattern.glsl)
	1. Do not look at the code
	1. Start the example without animation
	1. Code this brick pattern yourself
	1. Start the animation
	1. Code this animation yourself
	1. Look at the solution in the code
1. [ShapingFunctions.glsl](ShapingFunctions.glsl)
	1. Uncomment the different functions
	1. How to draw the green line? Create such a function plotter!
	1. How can we map coordinates to a bigger range than [0..1]²?
	1. How are vertical/horizontal lines that keep their thickness realized?
	1. Choose a function with very steep parts. What happens?
	1. How can we control the thickness of general functions?
	1. Create your own function using sin, smoothstep, mod, ...
	1. Look at [Creation by Silexars@shadertoy](https://www.shadertoy.com/view/XsXXDn)
1. [PatternTruchet.glsl](PatternTruchet.glsl)
	1. Look at code together
	1. Other tiling systems
		1. [Girih tiles](https://en.wikipedia.org/wiki/Girih_tiles)
		1. [Penrose tiling](https://en.wikipedia.org/wiki/Penrose_tiling)
		1. [Aperiodic tiling](https://en.wikipedia.org/wiki/Aperiodic_tiling)
1. [PatternCircle.glsl](PatternCircle.glsl)
	1. Do not look at the code
	1. Start the animation
	1. Code this animation yourself
1. [CircleDistanceField.glsl](CircleDistanceField.glsl)
	1. We look at code together
	1. Uncomment from top to bottom
	1. Create your own moving distance fields
1. [Polar.glsl](Polar.glsl)
	1. We look at code together
	1. Uncomment from top to bottom
	1. Try to do this <https://www.shadertoy.com/view/4sSGDR>
	1. Make your own flowers, snowflakes, gears
1. Combine [Pattern.glsl](Pattern.glsl) with [Polar.glsl](Polar.glsl)
	1. Snowflakes grid with multiple layers (<https://www.shadertoy.com/view/XlSBz1>) (<https://www.shadertoy.com/view/XdsSDn>)
	1. Code a hexagrid (<https://www.shadertoy.com/view/Xljczw)>
		+ (<https://www.shadertoy.com/view/llSyDh)>
	1. Code your own pattern