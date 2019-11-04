Shader "Unlit/SomeLight2"			//Vuelve al material del color que es :V
{
	Properties																			//Todas las cosas que definiran el material (inputs)
	{
		_Color ("Color", Color) = (1,1,1,0)											//Creo que cada uno de estos tienen su variable definida en unity
		//_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert															
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv0 : TEXCOORD0;
			};

			struct VertexOutput
			{
				float4 clipSpacePos : SV_POSITION;
				float2 uv0 : TEXCOORD0;
				float3 normal : TEXCOORD1;
			};

			float4 _Color;

			VertexOutput vert(VertexInput v)
			{
				VertexOutput o;
				o.uv0 = v.uv0;
				o.normal = v.normal;
				o.clipSpacePos = UnityObjectToClipPos(v.vertex);
				return o;
			}

			fixed4 frag(VertexOutput o) : SV_Target
			{
				float2 uv = o.uv0;

				//Lighting
				float3 lightDir = _WorldSpaceLightPos0.xyz;						//Es una variable que referencia la directional light. (Se agrego con la libreria)
				float3 lightColor = _LightColor0.rgb;							//Es una variable que referencia el color de la directional light (libreria).
				float lightFalloff = max(0, dot(lightDir, o.normal));
				float3 directDiffuseLight = lightColor * lightFalloff;
				float3 ambientLight = float3(0.1, 0.1, 0.1);
				return float4(ambientLight + directDiffuseLight, 0);				// La combinación de las dos luces
			}
			ENDCG
		}
	}
}