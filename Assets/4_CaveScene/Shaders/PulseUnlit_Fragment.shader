Shader "Unlit/PulseUnlit_Fragment" {
	Properties {
		[Header(Textures)]
		_MainTex ("Main Texture", 2D) = "white" {}
		_BumpMap("Normal map", 2D)= "bump" {}

		[Header(Pulse Settings)]
		_Origin("PulseOrigin", Vector) = (0, 0, 0, 0)
		_Distance("PulseDistance", Float) = 0
		_Width("PulseWidth", Float) = 5
		_MaxDistance("MaxDistance", Float) = 100
		[HideInInspector]
		_Frequency("Frequency", Range(0, 50)) = 50
		[HideInInspector]
		_Intensity("Intensity", Range(0, 10)) = 1

		[Header(Specular Settings)]
		_SpecWidth("SpecularWidth", Float) = 5
		_SpecCol("Specular Color", Color) = (1.0,0.0,0.0,1.0)
		_Shine("Shine",Float) = 10

		[Header(Distortion Settings)]
		_SpeedX("SpeedX", float)=3.0
		//_SpeedY("SpeedY", float)=3.0
		//_Scale("Scale", Range(0.005, 0.2)) = 0.03
		_ReverbIntensity("Reverb Intensity", Range(0, 1)) = 1
		//[HideInInspector]
		//_TileX("TileX", float)=5
		//[HideInInspector]
		//_TileY("TileY", float)=5
	}
	CGINCLUDE
		#include "UnityCG.cginc"

		struct appdata {
			float4 vertex : POSITION;
			float4 uv : TEXCOORD0;
			float3 normal : NORMAL;
			float4 tangent : TANGENT;
		};
		struct v2f {
			float4 vertex : SV_POSITION;
			float4 uv : TEXCOORD0;
			float4 worldPos : TEXCOORD1;
			float3 tangentWorld : TEXCOORD2;  
			float3 normalWorld : TEXCOORD3;
			float3 binormalWorld : TEXCOORD4;
			float3 normal : NORMAL;
		};

		sampler2D _MainTex;
		sampler2D _BumpMap;
		uniform float4 _BumpMap_ST;
		uniform float4 _MainTex_ST;
		uniform float4 _LightColor0; 
		uniform float4 _Origin;
		uniform half _Distance;
		uniform half _Frequency;
		uniform half _Intensity;
		uniform half _Width;
		uniform float	_SpecWidth;
		uniform float4 _SpecCol;
		uniform half 	_Shine;
		uniform float3	reflection;
		uniform float	_MaxDistance;
		uniform float _SpeedX;
		//uniform float _SpeedY;
		uniform float _ReverbIntensity;
		//uniform float _Scale;
		//uniform float _TileX;
		//uniform float _TileY;

		v2f vert (appdata vIn) {
			float4x4 modelMatrix = unity_ObjectToWorld;
			float4x4 modelMatrixInverse = unity_WorldToObject;

			v2f output;
			output.tangentWorld =
					 normalize(mul(modelMatrix, float4(vIn.tangent.xyz,0.0)).xyz);
			output.normalWorld =
					normalize(mul(float4(vIn.normal, 0.0),modelMatrixInverse).xyz);
			output.binormalWorld =
					normalize(cross(output.normalWorld,output.tangentWorld) * vIn.tangent.w);

			output.normal = normalize(mul(vIn.normal, modelMatrix));
			output.worldPos	= mul(modelMatrix, vIn.vertex);	
			output.vertex = UnityObjectToClipPos(vIn.vertex);
			output.uv = vIn.uv;
			return output;
		}
		
		fixed4 frag(v2f fIn) : SV_TARGET {			
			float3 viewDirection = normalize(_WorldSpaceCameraPos - fIn.worldPos.xyz);

			/*START Bumpmap calculations*/
			//Load bump texture
			float4 encodedTex = tex2D(_BumpMap, fIn.uv.xy);
			
			//Create bumpcoordinates for reflection?
			float3 localCoords = float3(
				2.0 * encodedTex.a - 1.0,
				2.0 * encodedTex.g - 1.0, 
				0.0
			);
			localCoords.z = sqrt(1.0 - dot(localCoords, localCoords));

			//Convert to world coordinates
			float3x3 local2World = float3x3(
			   fIn.tangentWorld,
			   fIn.binormalWorld,
			   fIn.normalWorld
			);
			float3 normalDirection = normalize(mul(localCoords,local2World));
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

			float4 diffuseLight = attenuation 
								* _LightColor0
								* max(0.0, dot(fIn.normal, lightDirection));
			/* END diffuse light calculations */

			/* START pulse light calculations */
			half pulseDistance = distance(fIn.worldPos, _Origin);
			half pulseFade = saturate(1 - (_Distance / _Frequency));
			float normDistance = _Distance / _MaxDistance; 
			float pulseLightIntensity = pulseFade 
									  * _Intensity
									  * (1 - saturate(abs(_Distance - pulseDistance) / _Width));

			float4 pulseLight = float4(1 - normDistance, 0, normDistance, 1) * pulseLightIntensity;
			/* END pulse light calculations */
			
			/* START specular light calculations */
			float4 vertexToPulse = _Origin - fIn.worldPos;	
			float4 specularDirection  = normalize(vertexToPulse);
			float specLightIntensity = pulseFade 
									* _Intensity
									* (1 - saturate(abs((_Distance - (_SpecWidth / 2)) - pulseDistance) / _SpecWidth));

			
			float4 specularLight = float4(1 - normDistance, 0, normDistance, 1)
									* specLightIntensity
									* pow(max(0, dot(reflect(-specularDirection, normalDirection), viewDirection)), _Shine);
			/* END specular light calculations */

			// /* START reverb simulation calculations */
			// float distortedX = sin((encodedTex.x + encodedTex.y) *_TileX + _Time.g * _SpeedX) * _Scale;	
			// float distortedY = cos(encodedTex.y * _TileY + _Time.g * _SpeedY) * _Scale;
			float reverbIntensity = pulseFade 
										* _ReverbIntensity
										* (1 - saturate(abs((_Distance - (_SpecWidth / 2)) - pulseDistance) / _SpecWidth));
			float4 reverbLight = reverbIntensity 
										* sin(_Time.g * 0.1 * fIn.vertex.x) 
										* cos(_Time.g * 0.1 * fIn.vertex.y);
			/* END reverb simulation calculations */

			// combine all light calculations
			float4 light = diffuseLight + specularLight + pulseLight + reverbLight;
			
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
