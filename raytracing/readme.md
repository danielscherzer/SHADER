1. [raycast.glsl](raycast.glsl)
	1. Create multiple spheres inside a for loop(s)
	1. Give each sphere a different color
	1. Make further spheres dimmer
	1. Implement diffuse lighting
	1. Create a ground plane
	1. Implement shadow rays
	1. Move the camera (wasd+mouse-drag)
	1. Look at [camera.glsl](../libs/camera.glsl)
	1. Implement reflected rays
	1. Implement soft shadows
	1. Add Multiple light sources
	1. Implement refracted rays
1. [RaytracerCPU](RaytracerCPU) 
	1. Implement same scene on both
	2. Compare speeds
1. [DiffusePathTracer.glsl](DiffusePathTracer.glsl)
1. [NaivePathTracer.glsl](NaivePathTracer.glsl)
	1. Change sample count
	1. Change the recursion depth (path length); start with 1;
	1. How is the intersection point biased?
	1. Where do the shadows come from?
	1. Constant seed
	1. Change light size and brightness. What happens and why? Convergence?
	1. All pixel samples are now equal. What happens if you weight them according to distance to pixel center?
	1. What happens if you do not choose refraction vs. reflection with a random threshold?
	1. Add a second light source (e.x.: the top plane).
	1. Add a glossy box. What do you have to change in the BRDF?
	
