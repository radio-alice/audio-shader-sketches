#version 150

uniform float time;
uniform vec2 resolution;
uniform vec2 mouse;
uniform vec3 spectrum;

uniform sampler2D prevFrame;
uniform sampler2D prevPass;

out vec4 fragColor;

#define PI 3.14159265359

vec3 colorA = vec3(0.0, 0.0, 1.0);
vec3 colorB = vec3(0.0, 1.0, 0.0);
vec3 colorC = vec3(1.0, 0.0, 0.0);

vec3 hsb2rgb( in vec3 c ){
    vec3 rgb = clamp(abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),
                             6.0)-3.0)-1.0,
                     0.0,
                     1.0 );
    rgb = rgb*rgb*(3.0-2.0*rgb);
    return c.z * mix(vec3(1.0), rgb, c.y);
}

vec3 fade(vec3 x) { return x * x * x * (x * (x * 6 - 15) + 10); }

vec3 phash(vec3 p)
{
    p = fract(mat3(1.2989833, 7.8233198, 2.3562332,
                   6.7598192, 3.4857334, 8.2837193,
                   2.9175399, 2.9884245, 5.4987265) * p);
    p = ((2384.2345 * p - 1324.3438) * p + 3884.2243) * p - 4921.2354;
    return normalize(fract(p) * 2 - 1);
}

float cnoise(vec3 p)
{
    vec3 ip = floor(p);
    vec3 fp = fract(p);
    float d000 = dot(phash(ip), fp);
    float d001 = dot(phash(ip + vec3(0, 0, 1)), fp - vec3(0, 0, 1));
    float d010 = dot(phash(ip + vec3(0, 1, 0)), fp - vec3(0, 1, 0));
    float d011 = dot(phash(ip + vec3(0, 1, 1)), fp - vec3(0, 1, 1));
    float d100 = dot(phash(ip + vec3(1, 0, 0)), fp - vec3(1, 0, 0));
    float d101 = dot(phash(ip + vec3(1, 0, 1)), fp - vec3(1, 0, 1));
    float d110 = dot(phash(ip + vec3(1, 1, 0)), fp - vec3(1, 1, 0));
    float d111 = dot(phash(ip + vec3(1, 1, 1)), fp - vec3(1, 1, 1));
    fp = fade(fp);
    return mix(mix(mix(d000, d001, fp.z), mix(d010, d011, fp.z), fp.y),
               mix(mix(d100, d101, fp.z), mix(d110, d111, fp.z), fp.y), fp.x);
}

vec3 grayify(vec3 col){
    return vec3(col.r+col.g+col.b);
    }

void main() {
    float amp = spectrum.y * 10 + 1;
    vec2 st = gl_FragCoord.xy/resolution;
    vec3 pct = vec3(st.x);
    vec3 color = vec3(0.0);

    vec2 toCenter = vec2(0.5)-st + vec2(cnoise(vec3(time/15.0)), cnoise(vec3(time/22.0)));
    float angle = atan(toCenter.y,toCenter.x);
    float radius = length(toCenter)*7.0;
    float hue = ((angle/(PI*2.0)* amp)+ 0.5 * 100.0);
    float brightness = ((angle/(PI*1.0)* 10* amp));
    color = hsb2rgb(vec3(radius - amp*40, hue / 0.8, sin(brightness)*0.1)); //CHANGE HERE
    color += texture(prevFrame, st).r * min(mouse.x * 5, 0.8 + amp);

    fragColor = vec4(color,1.0);
}