using System.Linq;

namespace Raytracer
{
	class Scene
	{
		public ASceneObject[] Objects;
		public Light[] Lights;
		public Color Background;
		public Color Ambient;
		public int MaxRayDepth = 3;

		public Intersection FirstIntersect(Ray ray)
		{
			//return from thing in Objects
			//       select thing.Intersect(ray);
			return Objects
						.Select(obj => obj.Intersect(ray))
						.Where(inter => inter != null)
						.OrderBy(inter => inter.Dist)
						.FirstOrDefault();
		}
	}
}
