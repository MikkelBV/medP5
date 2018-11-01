// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/PulseUnlitShader" {
	Properties {
		_MainTex ("Texture", 2D) = "white" {}
		_Origin("PulseOrigin", Vector) = (0, 0, 0, 0)
		_Distance("PulseDistance", Float) = 0
    _Frequency("Frequency", Range(0, 50)) = 50
    _Intensity("Intensity", Range(0, 10)) = 1
		_Color("Color", Color) = (1, 0, 0, 1)
		_Width("PulseWidth", Float) = 5
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass {
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
      float4 _Origin;
      half _Distance;
      half _Frequency;
      half _Intensity;
      fixed4 _Color;
			half _Width;
			
			v2f vert (appdata v) {
				float3 worldPos = mul (unity_ObjectToWorld, v.vertex).xyz;			
				half dis = distance(worldPos, _Origin);
				half fade = saturate(1 - (_Distance / _Frequency));
				
				float4 c = _Color
									* fade 
									* _Intensity
									* (1 - saturate(abs(_Distance - dis) / _Width));

				v2f output;
				output.vertex = UnityObjectToClipPos(v.vertex);
				output.uv = v.uv;
				output.color = c;
				return output;
			}
			
			fixed4 frag (v2f i) : COLOR {
				return i.color;
			}
			ENDCG
		}
	}
}
