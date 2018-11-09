// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Cg normal mapping" {
   Properties {
      _BumpMap ("Normal Map", 2D) = "bump" {}
      _Color ("Diffuse Material Color", Color) = (1,1,1,1) 
      _SpecColor ("Specular Material Color", Color) = (1,1,1,1) 
      _Shininess ("Shininess", Float) = 10
   }

   CGINCLUDE // common code for all passes of all subshaders

      #include "UnityCG.cginc"
      uniform float4 _LightColor0; 
      // color of light source (from "Lighting.cginc")

      // User-specified properties
      uniform sampler2D _BumpMap;   
      uniform float4 _BumpMap_ST;
      uniform float4 _Color; 
      uniform float4 _SpecColor; 
      uniform float _Shininess;

      struct vertexInput {
         float4 vertex : POSITION;
         float4 texcoord : TEXCOORD0;
         float3 normal : NORMAL;
         float4 tangent : TANGENT;
      };
      struct vertexOutput {
         float4 pos : SV_POSITION;
         float4 posWorld : TEXCOORD0;
         // position of the vertex (and fragment) in world space 
         float4 tex : TEXCOORD1;
         float3 tangentWorld : TEXCOORD2;  
         float3 normalWorld : TEXCOORD3;
         float3 binormalWorld : TEXCOORD4;
      };

      vertexOutput vert(vertexInput input) 
      {
         vertexOutput output;

         float4x4 modelMatrix = unity_ObjectToWorld;
         float4x4 modelMatrixInverse = unity_WorldToObject;

        output.tangentWorld = normalize(
            mul(modelMatrix, float4(input.tangent.xyz, 0.0)).xyz);
         output.normalWorld = normalize(
            mul(float4(input.normal, 0.0), modelMatrixInverse).xyz);
         output.binormalWorld = normalize(
            cross(output.normalWorld, output.tangentWorld) 
            * input.tangent.w); // tangent.w is specific to Unity

         output.posWorld = mul(modelMatrix, input.vertex);
         output.tex = input.texcoord;
         output.pos = UnityObjectToClipPos(input.vertex);
         return output;
      }
    
    
      // fragment shader with ambient lighting
      float4 fragWithAmbient(vertexOutput input) : COLOR
      {
         // in principle we have to normalize tangentWorld,
         // binormalWorld, and normalWorld again; however, the 
         // potential problems are small since we use this 
         // matrix only to compute "normalDirection", 
         // which we normalize anyways

         float4 encodedNormal = tex2D(_BumpMap, 
            _BumpMap_ST.xy * input.tex.xy + _BumpMap_ST.zw);
         float3 localCoords = float3(2.0 * encodedNormal.a - 1.0, 
                                     2.0 * encodedNormal.g - 1.0, 0.0);
                                     localCoords.z = sqrt(1.0 - dot(localCoords, localCoords));
    

         float3x3 local2WorldTranspose = float3x3(
            input.tangentWorld, 
            input.binormalWorld, 
            input.normalWorld);
         float3 normalDirection = 
            normalize(mul(localCoords, local2WorldTranspose));

         float3 viewDirection = normalize(
            _WorldSpaceCameraPos - input.posWorld.xyz);
         float3 lightDirection;
         float attenuation;

         if (0.0 == _WorldSpaceLightPos0.w) // directional light?
         { 
            attenuation = 1.0; // no attenuation
            lightDirection = normalize(_WorldSpaceLightPos0.xyz);
         } 
         else // point or spot light
         {
            float3 vertexToLightSource = 
               _WorldSpaceLightPos0.xyz - input.posWorld.xyz;
            float distance = length(vertexToLightSource);
            attenuation = 1.0 / distance; // linear attenuation 
            lightDirection = normalize(vertexToLightSource);
         }

         float3 ambientLighting = 
            UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;

         float3 diffuseReflection = 
            attenuation * _LightColor0.rgb * _Color.rgb
            * max(0.0, dot(localCoords, lightDirection));

         float3 specularReflection;
         if (dot(localCoords, lightDirection) < 0.0) 
            // light source on the wrong side?
         {
            specularReflection = float3(0.0, 0.0, 0.0); 
            // no specular reflection
         }
         else // light source on the right side
         {
            specularReflection = attenuation * _LightColor0.rgb 
               * _SpecColor.rgb * pow(max(0.0, dot(
               reflect(-lightDirection, localCoords), 
               viewDirection)), _Shininess);
         }
         return float4(ambientLighting + diffuseReflection 
            + specularReflection, 1.0);
      }
      
      // fragment shader for pass 2 without ambient lighting 
      float4 fragWithoutAmbient(vertexOutput input) : COLOR
      {
        // in principle we have to normalize tangentWorld,
        // binormalWorld, and normalWorld again; however, the  
        // potential problems are small since we use this 
        // matrix only to compute "normalDirection", 
        // which we normalize anyways

        float4 encodedNormal = tex2D(_BumpMap, _BumpMap_ST.xy * input.tex.xy + _BumpMap_ST.zw);
        float3 localCoords = float3(2.0 * encodedNormal.a - 1.0, 
            2.0 * encodedNormal.g - 1.0, 0.0);
        localCoords.z = sqrt(1.0 - dot(localCoords, localCoords));
           // approximation without sqrt:  localCoords.z = 
           // 1.0 - 0.5 * dot(localCoords, localCoords);

        float3x3 local2WorldTranspose = float3x3(
           input.tangentWorld,
           input.binormalWorld, 
           input.normalWorld);
        float3 normalDirection = 
           normalize(mul(localCoords, local2WorldTranspose));

        float3 viewDirection = normalize(
           _WorldSpaceCameraPos - input.posWorld.xyz);
        float3 lightDirection;
        float attenuation;

        if (0.0 == _WorldSpaceLightPos0.w) // directional light?
        {
           attenuation = 1.0; // no attenuation
           lightDirection = normalize(_WorldSpaceLightPos0.xyz);
        } 
        else // point or spot light
        {
           float3 vertexToLightSource = 
              _WorldSpaceLightPos0.xyz - input.posWorld.xyz;
           float distance = length(vertexToLightSource);
           attenuation = 1.0 / distance; // linear attenuation 
           lightDirection = normalize(vertexToLightSource);
        }

        float3 diffuseReflection = 
           attenuation * _LightColor0.rgb * _Color.rgb
           * max(0.0, dot(localCoords, lightDirection));

        float3 specularReflection;
        if (dot(localCoords, lightDirection) < 0.0) 
           // light source on the wrong side?
        {
           specularReflection = float3(0.0, 0.0, 0.0); 
              // no specular reflection
        }
        else // light source on the right side
        {
           specularReflection = attenuation * _LightColor0.rgb 
              * _SpecColor.rgb * pow(max(0.0, dot(
              reflect(-lightDirection, localCoords), 
              viewDirection)), _Shininess);
        }
        return float4(diffuseReflection + specularReflection, 1.0);
      }
   ENDCG

   SubShader {
      Pass {      
         Tags { "LightMode" = "ForwardBase" } 
            // pass for ambient light and first light source
 
         CGPROGRAM
            #pragma vertex vert  
            #pragma fragment fragWithAmbient  
            // the functions are defined in the CGINCLUDE part
         ENDCG
      }
 
      Pass {      
         Tags { "LightMode" = "ForwardAdd" } 
            // pass for additional light sources
         Blend One One // additive blending 
 
         CGPROGRAM
            #pragma vertex vert  
            #pragma fragment fragWithoutAmbient
            // the functions are defined in the CGINCLUDE part
         ENDCG
      }
   }
}
