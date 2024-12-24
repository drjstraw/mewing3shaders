#version 460

uniform sampler2D gtexture;
uniform sampler2D lightmap;
uniform sampler2D depthtex0;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;
uniform mat4 modelViewMatrixInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform int heldBlockLightValue;
uniform float frameTimeCounter;

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform vec3 cameraPosition;

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 outColor0;

in vec2 texCoord;
in vec3 foliageColor;
in vec2 lightMapCoords;
in vec3 blockNormal;
in vec3 lightPosition;
in vec3 viewSpacePosition;
in vec3 sunPositionOut;
in vec3 worldSpaceVertexPosition;

const float GRID_SIZE = 0.05;

void main() {

    vec3 lightDirectionWorldSpace =  mat3(gbufferModelViewInverse) * normalize(lightPosition);
    vec3 sunDirectionWorldSpace =  mat3(gbufferModelViewInverse) * normalize(lightPosition);

    vec3 lightColor = clamp((texture(lightmap, lightMapCoords).rgb), 0, 1);

    vec3 directionalLightColor = vec3(dot(blockNormal, lightDirectionWorldSpace));
    directionalLightColor = clamp(directionalLightColor, 0.0, 1.0);

    vec3 ambientLight = vec3(0.2);

    if (lightDirectionWorldSpace == sunDirectionWorldSpace) {
        directionalLightColor *= vec3(1, 0.95, 0.87);
        ambientLight *= vec3(1, 0.95, 0.87);
    } else {
        directionalLightColor *= vec3(0.83, 0.88, 1);
        ambientLight *= vec3(0.83, 0.88, 1);
    }

    vec3 globalPosition = worldSpaceVertexPosition + cameraPosition;
    vec3 globalPositionFrac = globalPosition - floor(globalPosition);
    vec3 negativeGlobalPositionFrac = 1 - globalPositionFrac;
    vec3 minimum = min(globalPositionFrac, negativeGlobalPositionFrac);
    float grid = step(1.5, (1 - step(GRID_SIZE, minimum.x)) + (1 - step(GRID_SIZE, minimum.y)) + (1 - step(GRID_SIZE, minimum.z)));

    float dist_lines = mod(sqrt(length(worldSpaceVertexPosition)) - frameTimeCounter * 2, 5) / 5;
    vec3 dist_lines_color = (pow(dist_lines, 4) + grid * pow(dist_lines, 4)) * vec3(0.4, 0.6, 0.9);

    vec3 light = ambientLight + directionalLightColor;

    vec3 color = foliageColor * light * lightColor * lightColor + dist_lines_color;

    vec4 outputColorData = texture(gtexture, texCoord);
    //vec3 outputColor = outputColorData.rgb * color;
    vec3 outputColor = outputColorData.rgb * color;
    float transparency = outputColorData.a;
    if (transparency < 0.1) {
        discard;
    }

    //float var1 = clamp((heldBlockLightValue - distanceFromCamera) / heldBlockLightValue, 0, 1);
    //float var2 = var1 * var1;
    //vec3 var3 = vec3(1 + ((float(heldBlockLightValue) / 16 * var2) / 2));
    outColor0 = vec4(outputColor, transparency);
}