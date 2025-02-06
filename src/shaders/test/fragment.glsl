#define PI 3.141592653
#define MAX_STEPS 100
#define MAX_DISTANCE 100.0
#define SURFACE_DISTANCE 0.01



uniform float uTime;
uniform vec3 uColorA;
uniform vec3 uColorB;
uniform vec2 uResolution;
uniform sampler2D tDiffuse;
uniform float uRotationAngle;

varying vec2 vUv;


float circle(vec2 uv, float radius, vec2 center){
    float c = sqrt(pow(uv.x - center.x, 2.0) + pow(uv.y - center.y, 2.0));
    float outerRing = step(radius + 0.005, c);
    float innerRing = step(c, radius);


    c = 1.0 - (outerRing + innerRing);

    return c;
}
vec3 circleObjects(vec2 uv, float radius, vec2 center, vec3 color){

    float c = sqrt(pow(uv.x - center.x, 2.0) + pow(uv.y - center.y, 2.0));
    float outerRing = step(radius, c);


    color = color * (1.0 - (outerRing));

    return color;
}

float lineDraw(vec2 uv, vec2 startPoint, vec2 direction, float dist){
    direction = normalize(direction);
    vec2 perpendicular = vec2(-direction.y, direction.x);
    perpendicular = normalize(perpendicular);
    
    vec2 pointToStart = uv - startPoint;
    float thickness = 0.002; // Adjust this value to change line thickness
    
    // Check if point is between start and end points
    float projection = dot(pointToStart, direction);
    float withinLine = step(0.0, projection) * step(projection, (dist));
    
    // Check if point is within thickness distance from line
    float distance = abs(dot(perpendicular, pointToStart));
    float withinThickness = step(distance, thickness);
    
    return withinLine * withinThickness;
}

float getDist(vec2 point){
    vec3 spheres[3] = vec3[3](
        vec3(-0.2, -0.3, 0.15),  // x, y, radius
        vec3(0.5, 0.5, 0.2),
        vec3(0.7, -0.1, 0.35)
    );
    
    float minDist = 1.0;
    for(int i = 0; i < spheres.length(); i++) {
        float sphereDist = length(point - spheres[i].xy) - spheres[i].z;
        minDist = min(minDist, sphereDist);
    }
    
    return minDist;
}

vec3 rayMarch(vec2 uv, vec2 startPoint, vec2 direction){
    vec3 color = vec3(0.0);
    float distanceFromOrigin = 0.0;
    float dist = 0.0;

    for(int i = 0; i < MAX_STEPS; i++){
        vec2 ray = startPoint + direction * distanceFromOrigin;
        dist = getDist(ray);

        color += circle(uv, dist,ray);

        distanceFromOrigin += dist;
        if(distanceFromOrigin > MAX_DISTANCE || dist < SURFACE_DISTANCE){
            break;
        }
    }
    float line = lineDraw(uv, startPoint, direction, distanceFromOrigin);
    color += line;
    return color;
}


void main(){
    vec3 col = vec3(0.0);
    vec2 uv = (gl_FragCoord.xy - 0.5 * uResolution.xy) / uResolution.y;
    col = vec3(0.05);

    col += vec3(circleObjects(uv, 0.15, vec2(-0.2,-0.3), vec3(0.2)));
    col += vec3(circleObjects(uv, 0.2, vec2(0.5, 0.5), vec3(0.2)));
    col += vec3(circleObjects(uv, 0.35, vec2(0.7, -0.1), vec3(0.2)));

    vec3 camera = (circleObjects(uv, 0.01, vec2(-1.0, 0.2), vec3(0.9)));

    float rotationAngle = radians(uRotationAngle);

    float angle = (radians(45.0) * sin(uTime * 0.1));
    vec3 line = rayMarch(uv,vec2(-1.0, 0.2), vec2((cos(angle)), -sin(angle)));
    // vec3 line = rayMarch(uv,vec2(-1.0, 0.2), normalize(vec2(0.1, 0.005)));
    // vec3 line = rayMarch(uv,vec2(-1.0, 0.2), normalize(vec2(cos(rotationAngle), sin(rotationAngle))));


    col += vec3(line);
    col += camera;


    gl_FragColor = vec4(col, 1.0);
}


// float getDist(vec3 point){
//     vec4 sphere = vec4(0.0, 1.0, 6.0, 1.0);
//     float sphereDist = length(point - sphere.xyz) - sphere.w;

//     float planeDist = point.y;

//     float result = min(sphereDist, planeDist);
//     return result;
// }


// float rayMarch(vec3 rayOrigin, vec3 rayDirection){
//     float distanceFromOrigin = 0.0;
//     for(int i = 0; i < MAX_STEPS; i++){
//         vec3 ray = rayOrigin + rayDirection * distanceFromOrigin;
//         float dist = getDist(ray);
//         distanceFromOrigin += dist;

//         if(distanceFromOrigin > MAX_DISTANCE || dist < SURFACE_DISTANCE){
//             break;
//         }
//     }

//     return distanceFromOrigin;
// }

// vec3 getNormal(vec3 point){
//     float dist = getDist(point);
//     vec2 epsilon = vec2(0.01, 0.0);

//     vec3 normal = dist - vec3(
//         getDist(point - epsilon.xyy),
//         getDist(point - epsilon.yxy),
//         getDist(point - epsilon.yyx)
//     );

//     return normalize(normal);
// }

// float getLight(vec3 point){
//     vec3 lightPos = vec3(0.0, 5.0, 6.0);
//     lightPos.xz += vec2(sin(uTime),cos(uTime)) * 2.0;
//     vec3 lightDirection = normalize(lightPos - point);

//     vec3 normal = getNormal(point);
//     float diff = clamp(dot(normal, lightDirection), 0.0, 1.0);


//     float shadow = rayMarch(point + normal*SURFACE_DISTANCE * 2.0, lightDirection);
//     if(shadow < length(lightPos- point)){
//         diff *= 0.2;
//     }


//     return diff;
// }

// void main()
// {
//     vec2 uv = (gl_FragCoord.xy - 0.5 * uResolution.xy) / uResolution.y;
//     // vec2 uv = vUv - 0.5;
//     vec3 col = vec3(0.0);

//     vec3 camera = vec3(0.0, 1.0, 0.0);
//     vec3 rayDirection = normalize(vec3(uv.x, uv.y, 1.0));

//     float dist = rayMarch(camera, rayDirection);
//     vec3 point = camera + rayDirection * dist;

//     float diffuseLight = getLight(point);
//     vec3 normal = getNormal(point);

//     col += vec3(diffuseLight);
//     // col += normal;


//     gl_FragColor = vec4(col, 1.0);
// }