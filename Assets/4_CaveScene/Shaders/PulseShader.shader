﻿Shader "Unlit/PulseShader" {
	Properties {
		[Header(Textures)]
		_MainTex ("Main Texture", 2D) = "white" {}
		_BumpMap("Normal map", 2D)= "bump" {}

		[Header(Pulse Settings)]
		_Origin("PulseOrigin", Vector) = (0, 0, 0, 0)
		_Distance("PulseDistance", Float) = 0
		_MaxDistance("MaxDistance", Float) = 100
		_Width("PulseWidth", Float) = 5

		[Header(Specular Settings)]
		_SpecWidth("SpecularWidth", Float) = 5
		_SpecCol("Specular Color", Color) = (1, 0, 0, 1)
		_Shine("Shine",Float) = 10

		[Header(Reverb Settings)]
		_SpeedX("SpeedX", Float) = 3.0
		_SpeedY("SpeedY", Float) = 3.0
		_Scale("Scale", Range(0.005, 0.2)) = 0.03
		_ReverbBumpMap("Reverb Normal map", 2D)= "bump" {}

		[HideInInspector]
		_Frequency("Frequency", Range(0, 50)) = 50
		[HideInInspector]
		_Intensity("Intensity", Range(0, 10)) = 1
		[HideInInspector]
		_TileX("TileX", Float) = 5
		[HideInInspector]
		_TileY("TileY", Float) = 5
		[HideInInspector]
		_EnvironmentSpace("Environment Space", Float) = 1
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
		sampler2D _ReverbBumpMap;
		sampler2D _BumpMap;
		uniform float4 _BumpMap_ST;
		uniform float4 _MainTex_ST;
		uniform float4 _LightColor0; 
		uniform float4 _Origin;
		uniform float _Distance;
		uniform float _Frequency;
		uniform float _Intensity;
		uniform float _Width;
		uniform float	_SpecWidth;
		uniform float4 _SpecCol;
		uniform float _Shine;
		uniform float	_MaxDistance;
		uniform float _SpeedX;
		uniform float _SpeedY;
		uniform float _Scale;
		uniform float _TileX;
		uniform float _TileY;
		uniform float _EnvironmentSpace;

		v2f vert (appdata vIn) {
			float4x4 modelMatrix = unity_ObjectToWorld;
			float4x4 modelMatrixInverse = unity_WorldToObject;

			v2f output;
			output.tangentWorld = normalize(mul(modelMatrix, float4(vIn.tangent.xyz,0.0)).xyz);
			output.normalWorld = normalize(mul(float4(vIn.normal, 0.0),modelMatrixInverse).xyz);
			output.binormalWorld = normalize(cross(output.normalWorld,output.tangentWorld) * vIn.tangent.w);

			output.normal = normalize(mul(vIn.normal, modelMatrix));
			output.vertex = UnityObjectToClipPos(vIn.vertex);
			output.worldPos	= mul(modelMatrix, vIn.vertex);	
			output.uv = vIn.uv;
			return output;
		}
		
		fixed4 frag(v2f fIn) : SV_TARGET {			
			float3 viewDirection = normalize(_WorldSpaceCameraPos - fIn.worldPos.xyz);

			/*START Bumpmap calculations*/
			//Load bump texture
			float4 encodedTex = tex2D(_BumpMap, fIn.uv.xy);
			
			//Create bumpcoordinates for reflection
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
			float3 lightDirection; //direction of the light
			float attenuation; //intensity of light

			//if directional light
			if (_WorldSpaceLightPos0.w == 0) {
				attenuation = 1.0;
				lightDirection = normalize(_WorldSpaceLightPos0.xyz);
			} else {
				//else attenuated light - needs to account for distance
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
			//float4 pulseLight = float4(_SpecCol.r - normDistance, _SpecCol.g-normDistance, _SpecCol.b, 1) * pulseLightIntensity;
			/* END pulse light calculations */
			
			/* START specular light calculations */
			float4 vertexToPulse = _Origin - fIn.worldPos;	
			float4 specularDirection  = normalize(vertexToPulse);
			float specLightIntensity = pulseFade 
									 * (_Intensity * 2)
									 * (1 - saturate(abs(_Distance - pulseDistance) / _SpecWidth));

			if (distance(fIn.worldPos, _Origin) > _Distance) {
				specLightIntensity = 0;
			}
			float4 specularLight = float4(1 - normDistance, 0, normDistance, 1)
			//float4 specularLight = float4(_SpecCol.r - normDistance, 1 - normDistance, _SpecCol.b - normDistance, 1)
								 * specLightIntensity
								 * pow(max(0, dot(reflect(-specularDirection, normalDirection), viewDirection)), _Shine);

			/* END specular light calculations */

			/* START reverb calculations */
			float4 reverbMap = tex2D(_ReverbBumpMap, fIn.uv.xy);
			reverbMap.x += sin ((encodedTex.x + encodedTex.y) *_TileX + _Time.g * _SpeedX) * _Scale;	
			reverbMap.y += cos (encodedTex.y * _TileY + _Time.g * _SpeedY) * _Scale;
			localCoords = float3(
				2.0 * reverbMap.a - 1.0,
				2.0 * reverbMap.g - 1.0, 
				0.0
			);
			localCoords.z = sqrt(1.0 - dot(localCoords, localCoords));
			normalDirection = normalize(mul(localCoords, local2World));
			float reverbIntensity = saturate(1 - (_Distance / (_MaxDistance * 6))) 
									 * ((_Intensity / 300) *_EnvironmentSpace)
									 * (1 - saturate(abs(_Distance - pulseDistance) / _SpecWidth));
			if (distance(fIn.worldPos, _Origin) > _Distance) {
				reverbIntensity = 0;
			}
			float4 reverbLight = (reverbIntensity) * pow(max(0, dot(reflect(-specularDirection, normalDirection), viewDirection)), _Shine);
			/* END reverb calculations */

			// combine all light calculations
			float4 light = diffuseLight + specularLight + pulseLight + reverbLight;
			
			/*Change to this for original*/
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
