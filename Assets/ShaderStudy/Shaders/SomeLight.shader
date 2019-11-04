Shader "Unlit/SomeLight"															
{
	Properties																			//Todas las cosas que definiran el material (inputs)
	{
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

				float3 lightDir = normalize(float3(1, 1, 1));				//Las luces siempre se deben normalizar por algo que no recuerdo.
				//float lightFalloff = dot(lightDir, o.normal);				// Float porque recuerda que devuelve un escalar
				float lightFalloff = max(0,dot(lightDir, o.normal));		// Max para evitar la parte negra, ya que hay puntos negativos en el dot cuando incide con la luz.
				float3 lightColor = float3(0.9, 0.82, 0.7);
				float3 diffuseLight = lightColor * lightFalloff;			// Como la luz incidirá en nuestro objeto
				//return float4(diffuseLight, 0);

				float3 ambientLight = float3(0.2, 0.4, 0.4);				// La luz que saca nuestro objeto? :V
				//return float4(ambientLight, 0);

				return float4(ambientLight + diffuseLight, 0);				// La combinación de las dos luces
			}
			ENDCG																		
		}
	}
}
