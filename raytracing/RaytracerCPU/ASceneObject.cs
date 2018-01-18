
namespace Raytracer
{
	abstract class ASceneObject
	{
		public Surface Surface;
		public abstract Intersection Intersect(Ray ray);
		public abstract Vector3 Normal(Vector3 pos, bool inside);
	}

}
