Shader "My/PulseShader" {
    Properties {
      _MainTex ("Texture", 2D) = "blue" {}
      _Color ("Color", Color) = (1, 0, 0, 1)
      _PDistance("PulseDistance", Float) = 0
      _PFadeDistance("FadeDistance", Float) = 100
      _PEdgeSoftness("EdgeSoftness", Float) = 5
      _Origin("PulseOrigin", Vector) = (0, 0, 0, 0)
    }
    
    SubShader {
      Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
      LOD 200

      ZWrite On
      Blend SrcAlpha OneMinusSrcAlpha

      CGPROGRAM

      // define finalcolor and vertex programs:
      #pragma surface surf Lambert finalcolor:mycolor vertex:myvert
      struct Input {
          float2 uv_MainTex;
          float3 worldPos;
          half alpha;
      };
      
      fixed4 _Color;
      sampler2D _MainTex;
      half _PDistance;
      half _PFadeDistance;
      half _PEdgeSoftness;
      float4 _Origin;

      void myvert (inout appdata_full v, out Input data) {
      	UNITY_INITIALIZE_OUTPUT(Input, data);
      }
      
      void mycolor (Input IN, SurfaceOutput o, inout fixed4 color) {
          // set the vertex color alpha to the value calculated: 
          half dis;
          half origin;
          dis = sqrt(pow((IN.worldPos.x - _Origin.x),2) + pow((IN.worldPos.y - _Origin.y), 2) + pow((IN.worldPos.z - _Origin.z), 2));
          if(_PDistance - dis <= 0)
          {
          	color.a = 1 - saturate(abs(_PDistance - dis)/_PEdgeSoftness);
          }
          else
          {
          	color.a = 1 - saturate(abs(_PDistance - dis)/_PFadeDistance);
          }
          
      }
      
      void surf (Input IN, inout SurfaceOutput o) {
          // simply copy the corresponding texture element color:
          o.Albedo = tex2D (_MainTex, IN.uv_MainTex).rgb * _Color.rgb;
      }
	  
      ENDCG
    } 
    Fallback "Diffuse"
  }