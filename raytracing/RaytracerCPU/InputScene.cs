
namespace Raytracer
{
	static class InputScene
	{
		static public readonly Scene Scene1 =
			new Scene()
			{
				MaxRayDepth = 7
				,Background = new Color(1,1,1)
				,Ambient = new Color(0.0f,0.0f,0.0f)
				,Objects = new ASceneObject[] { 
                                new Plane() {
                                    Norm = new Vector3(0,1,0),
                                    Offset = 0,
                                    Surface = Surfaces.CheckerBoard
                                },
                                new Sphere() {
                                    Center = new Vector3(0,1,0),
                                    Radius = 1,
                                    Surface = Surfaces.Shiny
                                },
                                new Sphere() {
                                    Center = new Vector3(2,0.2,2),
                                    Radius = .2,
                                    Surface = Surfaces.Shiny
                                },
                                new Sphere() {
                                    Center = new Vector3(-1,.5,1.5),
                                    Radius = .5,
                                    Surface = Surfaces.Glass
                                }}
				,
				Lights = new Light[] { 
								new Light() {
								    Pos = new Vector3(-2,2.5,0),
								    Color = new Color(.49f,.07f,.07f)
								},
								new Light() {
								    Pos = new Vector3(1.5,2.5,1.5),
								    Color = new Color(.07f,.07f,.49f)
								},
								new Light() {
								    Pos = new Vector3(1.5,2.5,-1.5),
								    Color = new Color(.07f,.49f,.071f)
								},
								new Light() {
								    Pos = new Vector3(0,3.5,0),
								    Color = new Color(.21f,.21f,.35f)
								}
                 }
			 };
	}
}
