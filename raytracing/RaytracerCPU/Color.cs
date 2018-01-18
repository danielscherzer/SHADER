using System;

namespace Raytracer
{
	public class Color
	{
		public float R;
		public float G;
		public float B;

		//public Color() 
		//{
		//    R = 0.0;
		//    G = 0.0;
		//    B = 0.0;
		//}

		public Color(float r, float g, float b) 
		{ 
			R = r; 
			G = g; 
			B = b; 
		}

		public Color(string str)
		{
			string[] nums = str.Split(',');
			if (nums.Length != 3) throw new ArgumentException();
			R = float.Parse(nums[0]);
			G = float.Parse(nums[1]);
			B = float.Parse(nums[2]);
		}

		public static Color Black()
		{
			return new Color(0, 0, 0);
		}

		public static Color White()
		{
			return new Color(1, 1, 1);
		}

		public static Color operator *(Color v, float n)
		{
			return new Color(n * v.R, n * v.G, n * v.B);
		}

		public static Color operator*(Color v1, Color v2)
		{
			return new Color(v1.R * v2.R, v1.G * v2.G, v1.B * v2.B);
		}

		public static Color operator+(Color v1, Color v2)
		{
			return new Color(v1.R + v2.R, v1.G + v2.G, v1.B + v2.B);
		}

		public static Color operator-(Color v1, Color v2)
		{
			return new Color(v1.R - v2.R, v1.G - v2.G, v1.B - v2.B);
		}
	}
}
