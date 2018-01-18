using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Drawing;

namespace Raytracer
{
	class Pixel
	{
		public Pixel(int x, int y, System.Drawing.Color color)
		{
			m_x = x;
			m_y = y;
			m_color = color;
		}

		public void draw(Bitmap bitmap)
		{
			bitmap.SetPixel(m_x,m_y,m_color);
		}

		private int m_x;
		private int m_y;
		private System.Drawing.Color m_color;
	}
}
