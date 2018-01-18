using System;
using System.Drawing;

namespace Raytracer
{
	class RenderImage
	{
		public static Color RenderPixel(Scene scene, Camera cam, float x_, float y_, int samples)
		{
			if (1 == samples)
			{
				return RayTracer.TraceRay(cam.Pos, cam.PerspectiveRayDir(x_, y_), scene, 0);
			}
			Color color = Color.Black();
			float delta = 1.0f / ((float)Math.Sqrt(samples));
			int count = 0;
			for (float x = x_ - 0.5f; x < x_ + 0.5f; x += delta)
			{
				for (float y = y_ - 0.5f; y < y_ + 0.5f; y += delta)
				{
					color += RayTracer.TraceRay(cam.Pos, cam.PerspectiveRayDir(x, y), scene, 0);
					++count;
				}
			}
			return color * (1.0f / samples);
		}

		public static void Run(Scene scene, Camera cam, int samples, Action<int, int, Color> setPixel)
		{
			PointF[] pixels = CreatePoints(cam.ViewportWidth, cam.ViewportHeight);
			pixels.Shuffle();
			foreach (PointF pixel in pixels)
			{
				Color color = RenderPixel(scene, cam, pixel.X, pixel.Y, samples);
				setPixel(Convert.ToInt32(pixel.X), Convert.ToInt32(pixel.Y), color);
			}
		}

		private static Random sRnd = new Random();

		private static PointF[] CreateJitteredPoints(int width, int height)
		{
			Random rnd = new Random();
			PointF[] pixels = new PointF[width * height];
			int i = 0;
			for (int y = 0; y < height; ++y)
			{
				for (int x = 0; x < width; ++x)
				{
					double deltaX = (rnd.NextDouble() - 0.5) * 0.7;
					double deltaY = (rnd.NextDouble() - 0.5) * 0.7;
					pixels[i] = new PointF(x + (float)deltaX, y + (float)deltaY);
					++i;
				}
			}
			return pixels;
		}

		private static PointF[] CreatePoints(int width, int height)
		{
			PointF[] pixels = new PointF[width * height];
			int i = 0;
			for (int y = 0; y < height; ++y)
			{
				for (int x = 0; x < width; ++x)
				{
					pixels[i] = new PointF(x, y);
					++i;
				}
			}
			return pixels;
		}
	}
}
