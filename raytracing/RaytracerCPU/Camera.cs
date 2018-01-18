
namespace Raytracer
{
	class Camera
	{
		public Vector3 Pos;
		public Vector3 Forward;
		public Vector3 Up;
		public Vector3 Right;

		public int ViewportWidth { get { return m_iViewportWidth; } }
		public int ViewportHeight { get { return m_iViewportHeight; } }

		public Camera(Vector3 pos, Vector3 lookAt, int viewportWidth_, int viewportHeight_)
		{
			m_iViewportWidth = viewportWidth_;
			m_iViewportHeight = viewportHeight_;
			Pos = pos;
			Forward = Vector3.Norm(lookAt - pos);
			Vector3 down = new Vector3(0, -1, 0);
			Right = Vector3.Norm(Vector3.Cross(Forward, down));
			Up = Vector3.Norm(Vector3.Cross(Forward, Right));
		}

		public Vector3 PerspectiveRayDir(double x, double y)
		{
			return Vector3.Norm(Forward + RecenterX(x) * Right + RecenterY(y) * Up);
		}

		private int m_iViewportWidth;
		private int m_iViewportHeight;

		private double RecenterX(double x)
		{
			return (x - (m_iViewportWidth / 2.0)) / (2.0 * m_iViewportWidth);
		}

		private double RecenterY(double y)
		{
			return -(y - (m_iViewportHeight / 2.0)) / (2.0 * m_iViewportHeight);
		}
	}

}
