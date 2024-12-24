#version 460

in vec3 vaPosition;  //vertextPos
in vec2 vaUV0;
in ivec2 vaUV2;
in vec4 vaColor;
in vec3 vaNormal;

uniform vec3 chunkOffset;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform vec3 cameraPosition;
uniform mat4 gbufferModelViewInverse;
uniform vec3 shadowLightPosition; 
uniform vec3 sunPosition;     

out vec2 texCoord;
out vec3 foliageColor;
out vec2 lightMapCoords;
out vec3 blockNormal;
out vec3 lightPosition;
out vec3 sunPositionOut;
out vec3 worldSpaceVertexPosition;

void main() {

    //worldSpaceVertexPosition = cameraPosition +(gbufferModelViewInverse * projectionMatrix * modelViewMatrix * vec4(vaPosition + chunkOffset, 1)).xyz;
    worldSpaceVertexPosition =  vaPosition + chunkOffset;
    texCoord = vaUV0;
    lightMapCoords = vaUV2 * (1.0 / 256.0) + (1.0 / 32.0);

    lightPosition = shadowLightPosition.xyz;
    sunPositionOut = sunPosition.xyz;
    foliageColor = vaColor.rgb;
    blockNormal = vaNormal;

    //vec4 offset = vec4(0, pow(0.1 * distanceFromCamera, 2), 0, 0);
    //vec3 offset = vec3(0,0,0.5);

    gl_Position = projectionMatrix * modelViewMatrix * vec4(vaPosition + chunkOffset, 1);
}