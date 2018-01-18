using System;

namespace Raytracer
{
	class Sphere : ASceneObject
	{
		public Vector3 Center;
		public double Radius;

		public override Intersection Intersect(Ray ray)
		{
			Vector3 l = Center-ray.Start;
			double s = Vector3.Dot(l, ray.Dir);
			double l2 = Vector3.Dot(l, l);
			double r2 = Radius*Radius;
			bool outside = l2 > r2;
			if (0 > s && outside) return null;

			double m2 = l2 - s * s;
			if (m2 > r2) return null;

			double q = Math.Sqrt(r2 - m2);
			double t = outside ? s-q : s+q;
			return new Intersection()
			{
				Thing = this,
				Ray = ray,
				Dist = t,
				Inside = !outside
			};
		}

		public override Vector3 Normal(Vector3 pos, bool inside)
		{
			return inside ? Vector3.Norm(Center - pos) : Vector3.Norm(pos - Center);
		}
	}
}
