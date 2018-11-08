Shader "Unlit/PulseUnlitShader" {
	Properties {
		_MainTex ("Texture", 2D) = "white" {}
		_Origin("PulseOrigin", Vector) = (0, 0, 0, 0)
		_Distance("PulseDistance", Float) = 0
		_Frequency("Frequency", Range(0, 50)) = 50
		_Intensity("Intensity", Range(0, 10)) = 1
		_Width("PulseWidth", Float) = 5
		_SpecCol("specular Color", Color) = (1.0,0.0,0.0,1.0)
		_Shine("Shine",Float) = 10
		_MaxHeight("MaxHeight", Float) = 1.0
		_MaxDistance("MaxDistance", Float) = 100
	}
	CGINCLUDE
		#include "UnityCG.cginc"

		struct appdata {
			float4 vertex : POSITION;
			float4 uv : TEXCOORD0;
			float3 normal : NORMAL;
		};
		struct v2f {
			float4 uv : TEXCOORD0;
			float4 vertex : SV_POSITION;
			float4 color : COLOR;
		};

		sampler2D _MainTex;
		uniform float4 _LightColor0; 
		uniform float4 	_Origin;
		uniform half 	_Distance;
		uniform half 	_Frequency;
		uniform half 	_Intensity;
		uniform half 	_Width;
		uniform float4 	_SpecCol;
		uniform half 	_Shine;
		uniform float3	reflection;
		uniform float _MaxHeight;
		uniform float _MaxDistance;
		
		v2f vert (appdata v) {
			float4x4 modelMatrix = unity_ObjectToWorld;
			float3x3 modelMatrixInverse = unity_WorldToObject;
			float4 worldPos = mul(modelMatrix, v.vertex);	
			float3 normal = normalize(mul(v.normal, modelMatrixInverse));
			float3 viewDirection = normalize(_WorldSpaceCameraPos - mul(modelMatrix, v.vertex).xyz);

			
			// make bump map
						float4 bumpColor = tex2Dlod(_MainTex, v.uv);
						// make it grayscale
			float df = 0.30*bumpColor.x + 0.59*bumpColor.y + 0.11*bumpColor.z;
			float4 newVertexPos = float4(v.normal * df * _MaxHeight, 0.0) + v.vertex;
						//output.pos = UnityObjectToClipPos(v.vertex+newVertexPos);
			
			
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
				float4 vertexToLightSource = _WorldSpaceLightPos0 - worldPos;
				attenuation = 1.0 / length(vertexToLightSource);
				lightDirection = normalize(vertexToLightSource);
			}

			float4 diffuseLight = attenuation 
								* _LightColor0 
								* max(0.0, dot(normal, lightDirection));
			/* END diffuse light calculations */

			/* START pulse light calculations */

			half pulseDistance = distance(worldPos, _Origin);
			half pulseFade = saturate(1 - (_Distance / _Frequency));
			float normDistance = _Distance / _MaxDistance; 
			float r = 1 - normDistance;
			float pulseLightIntensity = pulseFade 
								* _Intensity
								* (1 - saturate(abs(_Distance - pulseDistance) / _Width));
								
			float4 pulseLight = float4(r, 0.8, 0.7, 1) * pulseLightIntensity;
			/* END pulse light calculations */

			/* START specular light calculations */
			float4 vertexToPulse = worldPos - _Origin;
			float specularAttenuation = 1.0 / length(vertexToPulse);
			float4 specularDirection = normalize(vertexToPulse);

			float4 specularLight = _SpecCol
								* specularDirection 
								* pulseLightIntensity
								* pow(max(0, dot(reflect(specularDirection, normal), viewDirection)), _Shine);
			/* END specular light calculations */


			// initialise output sent to fragment shader
			v2f output;
			output.color = specularLight + diffuseLight + pulseLight;
			output.vertex = UnityObjectToClipPos(v.vertex);
			output.uv = v.uv;
			return output;
		}
		
		fixed4 frag(v2f i) : COLOR {
			return tex2D(_MainTex, i.uv.xy) * i.color;

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
