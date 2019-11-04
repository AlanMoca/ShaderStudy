Shader "Unlit/Fresnel"
{
	Properties																			//Todas las cosas que definiran el material (inputs)
	{
		_Color("Color", Color) = (1,1,1,0)											//Creo que cada uno de estos tienen su variable definida en unity
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
				float3 worldPos : TEXCOORD2;					//Variable que nos ayudará a interpolar para encontrar la posición de mundo de la mesh.
			};

			float4 _Color;

			VertexOutput vert(VertexInput v)
			{
				VertexOutput o;
				o.uv0 = v.uv0;
				o.normal = UnityObjectToWorldNormal(v.normal); //No se desde qué shader debí haber cambiado esta linea :'V
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.clipSpacePos = UnityObjectToClipPos(v.vertex);
				return o;
			}

			fixed4 frag(VertexOutput o) : SV_Target
			{
				float3 normal = normalize(o.normal); 

				float3 lightDir = _WorldSpaceLightPos0.xyz;		
				float3 lightColor = _LightColor0.rgb;	
				
				float lightFalloff = max(0, dot(lightDir, normal));
				float3 directDiffuseLight = lightColor * lightFalloff;

				float3 ambientLight = float3(0.1, 0.1, 0.1);

				float3 camPos = _WorldSpaceCameraPos;							
				float3 fragToCamera = camPos - o.worldPos;	
				float3 viewDir = normalize(fragToCamera);
				float specularFalloff = max(0, dot(viewDir, lightDir));	

				float3 directSpecular = specularFalloff * lightColor;
				float3 diffuseLight = ambientLight + directDiffuseLight;
				float3 finalSurfaceColor = diffuseLight * _Color.rgb + directSpecular;

				float fresnel = pow((1.0 - max(0, dot(viewDir, normal))), 3);		//Formula del fresnel vector vista con vector normal (así dará el efecto dependiendo desde que angulo lo veas)
				finalSurfaceColor += fresnel * saturate(normal.y) * lightColor;					//Lo estas sumando a lo que ya hay y lo saturas sólo con su normal en y, para que sea horizontal...?
				
				return float4(finalSurfaceColor, 1);

			}
			ENDCG
		}
	}
}