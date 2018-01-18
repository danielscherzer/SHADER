
namespace Raytracer
{
	class Plane : ASceneObject
	{
		public Vector3 Norm; //normal vector 
		public double Offset; //signed distance to origin

		public override Intersection Intersect(Ray ray)
		{
			double denom = Vector3.Dot(Norm, ray.Dir);
			if (denom > 0) return null;
			return new Intersection()
			{
				Thing = this,
				Ray = ray,
				Dist = (Vector3.Dot(Norm, ray.Start) + Offset) / (-denom)
				//Inside = 0 > Dist
			};
		}

		public override Vector3 Normal(Vector3 pos, bool inside)
		{
			return inside ? -Norm : Norm;
		}
	}
}
