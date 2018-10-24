Shader "Unlit/FadingLightShader"
{
	Properties {
		_MainTex ("Base (RGB) Trans (A)", 2D) = "blue" {}
		_BumpMap ("Normalmap", 2D) = "bump" {}
		_Color ("Color", Color) = (1, 0, 0, 1)
		_PDistance("PulseDistance", Float) = 0
		_PFadeDistance("FadeDistance", Float) = 10
		_PEdgeSoftness("EdgeSoftness", Float) = 5
		_Origin("PulseOrigin", Vector) = (0, 0, 0, 0)
    _Frequency("Frequency", Range(0, 50)) = 50
    _Intensity("Intensity", Range(0, 10)) = 0
		
		_RimColor("Rim Color", Color) = (1,1,1,1)
		_RimPower("Rim Power", Range(0.5, 8.0)) = 1.059702
		_RimOn("Rim On", Range(0, 1)) = 0.0
	}
    
    SubShader {
		  Tags { "RenderType"="Opaque" }      
      LOD 200

      CGPROGRAM

      #pragma surface surf Lambert vertex:vert fullforwardshadows finalcolor:color
      #pragma target 3.0

      struct Input {
          float2 uv_MainTex;
          float2 uv_BumpMap;
          float3 worldPos;
          float3 viewDir;
          half alpha;
      };
      
      fixed4 _Color;
      sampler2D _MainTex;
      sampler2D _BumpMap;
      half _PDistance;
      half _PFadeDistance;
      half _PEdgeSoftness;
      float4 _Origin;
      half _Frequency;
      half _Intensity;
      
      float4 _RimColor;
      float _RimPower;
      float _RimOn;

      void vert (inout appdata_full v, out Input data) {
      	UNITY_INITIALIZE_OUTPUT(Input, data);
      }
      
      void color (Input IN, SurfaceOutput o, inout fixed4 color) {
				half dis;
				fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;

				color.a = 1;
				dis = distance(IN.worldPos, _Origin);

				half fade = 1 - (_PDistance / _Frequency);

        if (fade > 0 && fade < 1 ) {
				  color.rgb = color.rgb + (c.rgb * fade * _Intensity * (1 - saturate(abs(_PDistance - dis) / _PFadeDistance)));
				}
      }
      
      void surf (Input IN, inout SurfaceOutput o) {
				fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
				o.Albedo = c.rgb;
				o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
      }
      ENDCG
    } 
    Fallback "Diffuse"
}
