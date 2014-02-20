package spriter.util;

/**
 * ...
 * @author ClockworkMagpie  at https://bitbucket.org/ClockworkMagpie/haxe-spriter/src/0a31fcb078dc7b8c6293a6120de70bbc425f9428/spriter/internal/Util.hx?at=master
 */
class SpriterUtil
{

	inline static public function toRadians(deg : Float) : Float
    {
        return deg * Math.PI / 180;
    }
    
    inline static public function lerp(aa : Float, bb : Float,  tt : Float) : Float
    {
        return ((bb - aa) * tt) + aa;
    }

    static public function angleLerp(aa : Float, bb : Float, spin : Int, tt : Float) : Float
    {
        if(spin == 0)
        {
            return aa;
        }

        if(spin > 0)
        {
            if(bb - aa < 0)
            {
                bb += 360;
            }
        }
        else if(spin < 0)
        {
            if(bb - aa > 0)
            {
                bb -= 360;
            }
        }

        return lerp(aa, bb, tt);
    }

    static public function quadratic(aa : Float, bb: Float,
                                      cc : Float, tt : Float) : Float
    {
        return lerp(lerp(aa, bb, tt), lerp(bb, cc, tt), tt);
    }

    static public function cubic(aa : Float, bb: Float,
                                  cc : Float, dd : Float,
                                  tt : Float) : Float
    {
        return lerp(quadratic(aa, bb, cc, tt),
                    quadratic(bb, cc, dd, tt),
                    tt);
    }
	
}