using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Drawing;

namespace Raytracer
{
    static class Tools
    {
        public static void Shuffle(this PointF[] array)
        {
            Random rnd = new Random();
            int n = array.GetLength(0);
            while (n > 1)
            {
                --n;
                int k = rnd.Next(n + 1);
                PointF value = array[k];
                array[k] = array[n];
                array[n] = value;
            }
        }
    }
}
