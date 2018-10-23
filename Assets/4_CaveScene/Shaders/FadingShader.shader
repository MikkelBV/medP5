Shader "Unlit/FadingShader"
{
	Properties {
		_MainTex ("Base (RGB) Trans (A)", 2D) = "blue" {}
		_BumpMap ("Normalmap", 2D) = "bump" {}
		_Color ("Color", Color) = (1, 0, 0, 1)
		_PDistance("PulseDistance", Float) = 0
		_PFadeDistance("FadeDistance", Float) = 10
		_PEdgeSoftness("EdgeSoftness", Float) = 5
		_Origin("PulseOrigin", Vector) = (0, 0, 0, 0)
    _Frequency("Frequency", Range(0, 200)) = 200
    _Intensity("Intensity", Range(0, 10)) = 1
		
		_RimColor("Rim Color", Color) = (1,1,1,1)
		_RimPower("Rim Power", Range(0.5, 8.0)) = 1.059702
		_RimOn("Rim On", Range(0, 1)) = 0.0
	}
    
    SubShader {
      Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
      LOD 200

      ZWrite On
      ZTest LEqual
      Blend SrcAlpha OneMinusSrcAlpha

      CGPROGRAM

      // define finalcolor and vertex programs:
      #pragma surface surf Lambert finalcolor:mycolor vertex:myvert
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

      void myvert (inout appdata_full v, out Input data) {
      	UNITY_INITIALIZE_OUTPUT(Input, data);
      }
      
      void mycolor (Input IN, SurfaceOutput o, inout fixed4 color) {
				half dis;
				half interval;
				half origin;
				fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;

				color.a = 1;
				dis = distance(IN.worldPos, _Origin);

				half fade = 1 - (distance(_PDistance, _Origin) / _Frequency);

				if (fade < 0) {
					fade = 0;
				} else if (fade > 1) {
					fade = 1;
				}

				color.rgb = color.rgb * fade * _Intensity * (1 - saturate(abs(_PDistance - dis) / _PFadeDistance));
      }
      
      void surf (Input IN, inout SurfaceOutput o) {
				fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
				half dis = distance(IN.worldPos, _Origin);

				o.Albedo = c.rgb;
				o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
				
				if(_RimOn > 0) {
					half rim = 1.0 - saturate(dot(normalize(IN.viewDir), o.Normal));
					o.Emission = _RimColor.rgb * pow(rim, _RimPower);
				}
      }
	  
      ENDCG
    } 
    Fallback "Diffuse"
}
