Shader "Unlit/PulseUnlitShader" {
	Properties {
		_MainTex ("Texture", 2D) = "white" {}
		_Origin("PulseOrigin", Vector) = (0, 0, 0, 0)
		_Distance("PulseDistance", Float) = 0
		_Frequency("Frequency", Range(0, 50)) = 50
		_Intensity("Intensity", Range(0, 10)) = 1
		_Color("Color", Color) = (1, 1, 1, 1)
		_Width("PulseWidth", Float) = 5
		_SpecCol("specular Color", Color) = (1.0,0.0,0.0,1.0)
		_Shine("Shine",Float) = 10
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass {
			Tags { "LightMode"="ForwardAdd" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};
			struct v2f {
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 color : COLOR;
			};

			sampler2D _MainTex;
			uniform float4 _LightColor0; 
			float4 	_Origin;
			half 	_Distance;
			half 	_Frequency;
			half 	_Intensity;
			fixed4 	_Color;
			half 	_Width;
			float4 	_SpecCol;
			half 	_Shine;
			float3	reflection;
			
			v2f vert (appdata v) {
				float4x4 modelMatrix = unity_ObjectToWorld;
				float3x3 modelMatrixInverse = unity_WorldToObject;
				float4 worldPos = mul(unity_ObjectToWorld, v.vertex);	
				float3 normal = normalize(mul(v.normal, modelMatrixInverse));
				float3 viewDirection = normalize(_WorldSpaceCameraPos - mul(modelMatrix, v.vertex).xyz);

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
				float pulseLightIntensity = pulseFade 
								  * _Intensity
							 	  * (1 - saturate(abs(_Distance - pulseDistance) / _Width));

				float4 pulseLight = _Color * pulseLightIntensity;
				/* END pulse light calculations */

				/* START specular light calculations */
				float4 vertexToPulse = worldPos - _Origin;
				float specularAttenuation = 1.0 / length(vertexToPulse);
				float4 specularDirection = normalize(vertexToPulse);

				float4 specularLight = _SpecCol
									* specularDirection 
								  * pulseLightIntensity
									* pow(max(0, dot(reflect(-specularDirection, normal), viewDirection)), _Shine);
				/* END specular light calculations */

				// initialise output sent to fragment shader
				v2f output;
				output.color = specularLight + diffuseLight + pulseLight;
				output.vertex = UnityObjectToClipPos(v.vertex);
				output.uv = v.uv;
				return output;
			}
			
			fixed4 frag(v2f i) : COLOR {
				return i.color;
			}

			ENDCG
		}
	}
}
