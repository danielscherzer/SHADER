using System;

namespace Raytracer
{
	class Vector3
	{
		public double X;
		public double Y;
		public double Z;

		public Vector3(double x, double y, double z) { X = x; Y = y; Z = z; }

		public Vector3(string str)
		{
			string[] nums = str.Split(',');
			if (nums.Length != 3) throw new ArgumentException();
			X = double.Parse(nums[0]);
			Y = double.Parse(nums[1]);
			Z = double.Parse(nums[2]);
		}

		public static Vector3 operator -(Vector3 v)
		{
			return new Vector3(-v.X, -v.Y, -v.Z);
		}

		public static Vector3 operator *(Vector3 v, double n)
		{
			return new Vector3(v.X * n, v.Y * n, v.Z * n);
		}

		public static Vector3 operator*(double n, Vector3 v)
		{
			return new Vector3(v.X * n, v.Y * n, v.Z * n);
		}

		public static Vector3 operator-(Vector3 v1, Vector3 v2)
		{
			return new Vector3(v1.X - v2.X, v1.Y - v2.Y, v1.Z - v2.Z);
		}

		public static Vector3 operator+(Vector3 v1, Vector3 v2)
		{
			return new Vector3(v1.X + v2.X, v1.Y + v2.Y, v1.Z + v2.Z);
		}

		public static double Dot(Vector3 v1, Vector3 v2)
		{
			return (v1.X * v2.X) + (v1.Y * v2.Y) + (v1.Z * v2.Z);
		}

		public static double Length(Vector3 v) { return Math.Sqrt(Dot(v, v)); }

		public static Vector3 Norm(Vector3 v)
		{
			double mag = Length(v);
			double div = mag == 0 ? double.PositiveInfinity : 1 / mag;
			return v * div;
		}

		public static Vector3 Cross(Vector3 v1, Vector3 v2)
		{
			return new Vector3(((v1.Y * v2.Z) - (v1.Z * v2.Y)),
							  ((v1.Z * v2.X) - (v1.X * v2.Z)),
							  ((v1.X * v2.Y) - (v1.Y * v2.X)));
		}

        public static Vector3 Reflect(Vector3 normal, Vector3 vec)
        {
            return 2 * Vector3.Dot(normal, vec) * normal - vec;
        }

		public static Vector3 Refract(Vector3 normal, Vector3 invRayDir, double eta)
		{
			double cosI = Dot(normal, invRayDir);
			double sinI2 = 1-cosI*cosI; //Pythagoras for incoming
			double sinT2 = sinI2 * (eta * eta); //Snell's law
			double cosT2 = 1 - sinT2; //Pythagoras for outgoing
			if (0 >= cosT2) return new Vector3(0, 0, 0);
			double cosT = Math.Sqrt(cosT2);
			return eta * -invRayDir - (cosT - Math.Sign(cosI) * eta * cosI) * normal;
		}

		public static bool operator ==(Vector3 v1, Vector3 v2)
		{
			return (v1.X == v2.X) && (v1.Y == v2.Y) && (v1.Z == v2.Z);
		}

		public static bool operator !=(Vector3 v1, Vector3 v2)
		{
			return !(v1 == v2);
		}

		public override bool Equals(object obj)
		{
			if (obj is Vector3)
			{
				Vector3 c = (Vector3)obj;
				return this == c;
			}
			else
			{
				return false;
			}

		}

		public override int GetHashCode()
		{
			return X.GetHashCode() ^ Y.GetHashCode() ^ Z.GetHashCode();
		}
	}
}
