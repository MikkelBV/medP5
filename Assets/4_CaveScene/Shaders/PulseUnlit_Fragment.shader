Shader "Unlit/PulseUnlit_Fragment" {
	Properties {
		_MainTex ("Texture", 2D) = "white" {}
		_BumpMap("Normal map", 2D)= "bump" {}
		_Origin("PulseOrigin", Vector) = (0, 0, 0, 0)
		_Distance("PulseDistance", Float) = 0
		_Frequency("Frequency", Range(0, 50)) = 50
		_Intensity("Intensity", Range(0, 10)) = 1
		_Width("PulseWidth", Float) = 5
		_SpecWidth("SpecularWidth", Float) = 5
		_SpecCol("Specular Color", Color) = (1.0,0.0,0.0,1.0)
		_Shine("Shine",Float) = 10
		_MaxDistance("MaxDistance", Float) = 100
	}
	CGINCLUDE
		#include "UnityCG.cginc"

		struct vertexInput {
			float4 vertex : POSITION;
			float4 uv : TEXCOORD0;
			float3 normal : NORMAL;
		};
		struct fragmentInput {
			float4 vertex : SV_POSITION;
			float4 color : COLOR;
			float4 uv : TEXCOORD0;
			float4 worldPos : TEXCOORD1;
		};

		sampler2D _MainTex;
		sampler2D _BumpMap;
		uniform float4	_LightColor0; 
		uniform float4 	_Origin;
		uniform half 	_Distance;
		uniform half 	_Frequency;
		uniform half 	_Intensity;
		uniform half 	_Width;
		uniform float	_SpecWidth;
		uniform float4 	_SpecCol;
		uniform half 	_Shine;
		uniform float3	reflection;
		uniform float	_MaxDistance;
		
		fragmentInput vert (vertexInput vIn) {
			fragmentInput output;

			float4x4 modelMatrix = unity_ObjectToWorld;
			float3x3 modelMatrixInverse = unity_WorldToObject;
			float3 normal = normalize(mul(vIn.normal, modelMatrixInverse));
			
			output.worldPos	= mul(modelMatrix, vIn.vertex);	
			output.vertex = UnityObjectToClipPos(vIn.vertex);
			output.uv = vIn.uv;
			return output;
		}
		
		fixed4 frag(fragmentInput fIn) : COLOR {

			float3 viewDirection = normalize(_WorldSpaceCameraPos - fIn.worldPos.xyz);
			
			/*START Bumpmap calculations*/
			float4 encodedTex = tex2D(_BumpMap,
			 						  fIn.uv.xy);

			float3 localCoords = float3(2.0 * encodedTex.a - 1.0,
										2.0 * encodedTex.g - 1.0, 
										0.0);
			/*END Bumpmap calculations*/


			/* START diffuse light calculations */
			// for DIRECTIONAL LIGHT, _WorldSpaceLightPos0.w will be 0, for other lights it is 1
			// https://docs.unity3d.com/Manual/SL-UnityShaderVariables.html
			float3 lightDirection;
			float attenuation; // intensity of light, e.g. point light is more attenuated when far away

			if (_WorldSpaceLightPos0.w == 0) {
				attenuation = 1.0;
				lightDirection = normalize(_WorldSpaceLightPos0.xyz);
			} else {
				// when working with anything other than directional light, we also need to account for the distance to the light
				float3 vertexToLightSource = _WorldSpaceLightPos0 - fIn.worldPos;
				attenuation = 1.0 / length(vertexToLightSource);
				lightDirection = normalize(vertexToLightSource);
			}

        	float3 diffuseLight = attenuation 
                                * _LightColor0
                                * max(0.0, dot(localCoords, lightDirection));
			/* END diffuse light calculations */

			/* START pulse light calculations */
			half pulseDistance = distance(fIn.worldPos, _Origin);
			half pulseFade = saturate(1 - (_Distance / _Frequency));
			float normDistance = _Distance / _MaxDistance; 
			float r = 1 - normDistance;
			float pulseLightIntensity = pulseFade 
							   	      * _Intensity
								      * (1 - saturate(abs(_Distance - pulseDistance) / _Width));

			float specLightIntensity = pulseFade 
							   	      * _Intensity
								      * (1 - saturate(abs(_Distance - pulseDistance) / _SpecWidth));

			float4 pulseLight = float4(r, 0.0, normDistance, 1) * pulseLightIntensity;
			/* END pulse light calculations */

			/* START specular light calculations */
			float4 vertexToPulse = _Origin - fIn.worldPos;	
			float4 specularDirection  = normalize(vertexToPulse);
			
			float4 specularLight = _SpecCol
								 * specLightIntensity
								 * pow(max(0, dot(reflect(-specularDirection, localCoords), viewDirection)), _Shine);				 			
			/* END specular light calculations */


			// initialise output sent to fragment shader

			//output.color = specularLight + diffuseLight + pulseLight;
			//return tex2D(_MainTex, i.uv.xy) * i.color;
			float4 light = float4(diffuseLight + specularLight + pulseLight, 1.0);
			return tex2D(_MainTex, fIn.uv.xy) * light;
		}
	ENDCG

	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass {      
			Tags { "LightMode" = "ForwardBase" } 

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}

		Pass {
			Tags { "LightMode"="ForwardAdd" }
			Blend One One 
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
}
