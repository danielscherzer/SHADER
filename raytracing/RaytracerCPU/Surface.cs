using System;

namespace Raytracer
{
	class Surface
	{
		public Func<Vector3, Color> Diffuse;
		public Func<Vector3, Color> Specular;
		public Func<Vector3, float> Reflect;
		public Func<Vector3, float> Alpha; //== 1 for solid; 0 == for air; blend foreground with background
        public float Roughness;
		public double Eta = 1.0; // := n1/n2; medium 1 index of refraction divided by medium 2 index of refraction  
	}

	static class Surfaces
	{
		// Pattern only works nicely with X-Z plane.
		public static readonly Surface CheckerBoard =
			new Surface()
			{
				Diffuse = pos => ((Math.Floor(pos.Z) + Math.Floor(pos.X)) % 2 != 0)
									? Color.White()
									: Color.Black(),
				Specular = pos => Color.White(),
				Reflect = pos => ((Math.Floor(pos.Z) + Math.Floor(pos.X)) % 2 != 0)
									? .2f
									: .0f,
                Alpha = pos => 1,
                Roughness = 150
			};

		public static readonly Surface Shiny =
			new Surface()
			{
				Diffuse = pos => Color.White(),
				Specular = pos => new Color(.5f, .5f, .5f),
				Reflect = pos => 0.9f,
                Alpha = pos => 1,
                Roughness = 50
			};

		public static readonly Surface Glass =
			new Surface()
			{
				Diffuse = pos => Color.White(),
				Specular = pos => Color.White(),
				Reflect = pos => 1,
				Alpha = pos => 0.1f,
				Roughness = 50,
				Eta = 1.002/1.5 //air:1.002; glass:1.5; water:1.33; diamond:2.4;
			};
	}
}
