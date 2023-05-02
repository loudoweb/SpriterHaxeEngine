package spriter.util;

/**
 * ...
 * @author loudo
 */
class MathUtils
{
	@:generic
	inline static public function abs<T:Float>(n:T):T
	{
		if(n >= 0) {
			return n;
		}else {
			return -n;
		}
	}
	
	inline static public function linear(a:Float, b:Float, t:Float):Float
    {
		return ((b-a)*t)+a;
    }

	static public function angleLinear(angleA:Float, angleB:Float, spin:Int, t:Float):Float
	{
		if(spin == 0)
		{
			return angleA;
		}
		if(spin > 0)
		{
			if((angleB-angleA) < 0)
			{
				angleB += 360;
			}
		}
		else if(spin < 0)
		{
			if((angleB-angleA) > 0)
			{    
				angleB -= 360;
			}
		}

		return linear(angleA,angleB,t);
	}

	inline static public function quadratic(a:Float, b:Float, c:Float, t:Float):Float
	{
		return linear(linear(a,b,t),linear(b,c,t),t);
	}

	inline static public function cubic(a:Float, b:Float, c:Float, d:Float, t:Float):Float
	{
		return linear(quadratic(a,b,c,t),quadratic(b,c,d,t),t);
	}
	inline static public function quartic(a:Float, b:Float, c:Float, d:Float, e:Float, t:Float):Float
	{
		return linear(cubic(a,b,c,d,t),cubic(b,c,d,e,t),t);
	}
	inline static public function quintinc(a:Float, b:Float, c:Float, d:Float, e:Float, f:Float,t:Float):Float
	{
		return linear(quartic(a,b,c,d,e,t),quartic(b,c,d,e,f,t),t);
	}
	static public function cubicBezierAtTime( p1x:Float, p1y:Float, p2x:Float, p2y:Float, t:Float):Float
	{
		var duration:Float=1;
		var ax:Float=0;
		var bx:Float=0;
		var cx:Float=0;
		var ay:Float=0;
		var by:Float=0;
		var cy:Float=0;

		// `ax t^3 + bx t^2 + cx t' expanded using Horner's rule.
		// Calculate the polynomial coefficients, implicit first and last control points are (0,0) and (1,1).

		cx = 3.0 * p1x;
		bx = 3.0 * (p2x - p1x) - cx;
		ax = 1.0 - cx - bx;
		cy = 3.0 * p1y;
		by = 3.0 * (p2y - p1y) - cy;
		ay = 1.0 - cy - by;

		// Convert from input time to parametric value in curve, then from that to output time.
		return solve(ax,bx,cx,ay,by,cy,t, solveEpsilon(duration));
	}
	// Bezier requires a few helper functions, but the main function you actually use is going to be: float CubicBezierAtTime(float p1x,float p1y,float p2x,float p2y,float t)

	inline static function sampleCurve(a:Float, b:Float, c:Float, t:Float):Float
	{
		return ((a*t+b)*t+c)*t;
	}

	inline static function sampleCurveDerivativeX(ax:Float, bx:Float, cx:Float, t:Float):Float 
	{
		return (3.0*ax*t+2.0*bx)*t+cx;
	}

	// The epsilon value to pass given that the animation is going to run over |dur| seconds. The longer the

	// animation, the more precision is needed in the timing function result to avoid ugly discontinuities.

	inline static function solveEpsilon(duration:Float):Float 
	{
		return 1.0/(200.0*duration);
	}


	inline static function solve(ax:Float, bx:Float, cx:Float, ay:Float, by:Float, cy:Float, x:Float, epsilon:Float):Float 
	{
		return sampleCurve(ay,by,cy,solveCurveX(ax,bx,cx,x,epsilon));
	}

	static function solveCurveX(ax:Float, bx:Float, cx:Float, x:Float, epsilon:Float):Float
	{
		var t0:Float;
		var t1:Float;
		var t2:Float = x;
		var x2:Float;
		var d2:Float;

		// First try a few iterations of Newton's method -- normally very fast.
		for (i in 0...8) 
		{
			x2 = sampleCurve(ax, bx, cx, t2) - x; 
			if(abs(x2) < epsilon) {
				return t2;
			} 

			d2 = sampleCurveDerivativeX(ax, bx, cx, t2); 

			if(abs(d2) < 1e-6) {
				break;
			} 

			t2=t2-x2/d2;
		}

		// Fall back to the bisection method for reliability.
		t0 = 0.0; 
		t1 = 1.0; 
		t2 = x; 

		if(t2 < t0) {
			return t0;
		} 

		if(t2 > t1) 
		{
			return t1;
		}


		while(t0 < t1) 
		{
			x2 = sampleCurve(ax, bx, cx, t2); 
			if(abs(x2-x) < epsilon) {
				return t2;
			} 
			if(x > x2) {
				t0=t2;
			}else {
				t1=t2;
			} 
			t2=(t1-t0)*.5+t0;
		}

		return t2; // Failure.
	}
}