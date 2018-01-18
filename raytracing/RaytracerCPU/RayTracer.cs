using System;

namespace Raytracer
{
	static class RayTracer
	{
		public static Color TraceRay(Vector3 start, Vector3 dir, Scene scene, int depth_)
		{
			if (depth_ >= scene.MaxRayDepth)
			{
				return scene.Ambient;
			}

			Ray ray = new Ray() { Start = start, Dir = dir };
			Intersection isect = scene.FirstIntersect(ray);
			if (null == isect)
			{
				return scene.Background;
			}
			//light hit

			Surface surf = isect.Thing.Surface;
			Vector3 pos = isect.Ray.Start + isect.Dist * isect.Ray.Dir;
			Vector3 invRayDir = -isect.Ray.Dir;
			Vector3 normal = isect.Thing.Normal(pos, isect.Inside);
			Vector3 reflect = Vector3.Reflect(normal, invRayDir);

			Color ambient = scene.Ambient;
			Color local = LocalLighting(surf, pos, normal, reflect, scene);

			float refl = surf.Reflect(pos);
			float alpha = surf.Alpha(pos);
			Color reflected = Color.Black();
			if (0 < refl && 0 < alpha)
			{
				reflected = TraceRay(pos + .001 * reflect, reflect, scene, depth_ + 1) * refl;
			}

			Color transmitted = Color.Black();
			if (1 > alpha)
			{
				double eta = isect.Inside ? 1 / surf.Eta : surf.Eta;
				Vector3 transmit = Vector3.Refract(normal, invRayDir, eta);
				transmitted = TraceRay(pos + .001 * transmit, transmit, scene, depth_ + 1);
			}

			return ambient + (local + reflected) * alpha + transmitted * (1 - alpha);
		}

		private static Color LocalLighting(Surface surf_, Vector3 pos, Vector3 normal, Vector3 reflect, Scene scene)
		{
			Color colorSum = Color.Black();
			foreach (Light light in scene.Lights)
			{
				Vector3 lightVec = light.Pos - pos;
				double distance = Vector3.Length(lightVec);
				lightVec = lightVec * (1 / distance);
				//shadow ray: test if there is something between pos and light source
				Intersection isect = scene.FirstIntersect(new Ray() { Start = pos + 0.001 * lightVec, Dir = lightVec });
				if (null != isect)
				{
					//test if intersection is between lightsource and pos
					if (isect.Dist < distance)
					{
						continue;
					}
				}
				//diffuse with Lambert
				float illum = (float)Vector3.Dot(lightVec, normal);
				Color colorDiffuse = illum > 0 ? light.Color * illum : Color.Black();
				colorSum += surf_.Diffuse(pos) * colorDiffuse;
				//phong specular
				double specular = Vector3.Dot(lightVec, reflect);
				Color scolor = specular > 0 ? light.Color * (float)Math.Pow(specular, surf_.Roughness) : Color.Black();
				colorSum += surf_.Specular(pos) * scolor;
			}
			return colorSum;
		}
	}
}
