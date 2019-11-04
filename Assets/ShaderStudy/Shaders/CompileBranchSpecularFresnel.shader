Shader "Unlit/CompileBranchSpecularFresnel"
{
	Properties																			//Todas las cosas que definiran el material (inputs)
	{
		_Color("Color", Color) = (1,1,1,0)											//Creo que cada uno de estos tienen su variable definida en unity
		//_MainTex ("Texture", 2D) = "white" {}
		[Toggle(USE_SPECULAR)]
		_UseSec("Use Specular", float) = 1
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }

			Pass
			{
				CGPROGRAM

				//#define USE_SPECULAR 1							// Es como un bool. True/False. Es como un preprocesado y para ver cambios lo pones en 0. (Opcion 1)

				#pragma vertex vert															
				#pragma fragment frag

				#pragma shader_feature USE_SPECULAR					//Esto permitirá que se compile de dos formas. Una para cuando este activado y la otra desactivado. (Opcion 2)

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
					#if USE_SPECULAR
						float3 worldPos : TEXCOORD2;					//Variable que nos ayudará a interpolar para encontrar la posición de mundo de la mesh.
					#endif
					
				};

				float4 _Color;

				VertexOutput vert(VertexInput v)
				{
					VertexOutput o;
					o.uv0 = v.uv0;
					o.normal = UnityObjectToWorldNormal(v.normal); //No se desde qué shader debí haber cambiado esta linea :'V
					#if USE_SPECULAR
						o.worldPos = mul(unity_ObjectToWorld, v.vertex);
					#endif
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

					float3 diffuseLight = ambientLight + directDiffuseLight;
					float3 finalSurfaceColor = diffuseLight * _Color.rgb;

					#if USE_SPECULAR
						float3 camPos = _WorldSpaceCameraPos;
						float3 fragToCamera = camPos - o.worldPos;
						float3 viewDir = normalize(fragToCamera);
						float specularFalloff = max(0, dot(viewDir, lightDir));
						float3 directSpecular = specularFalloff * lightColor;
						finalSurfaceColor += directSpecular;
						float fresnel = pow((1.0 - max(0, dot(viewDir, normal))), 3);
						finalSurfaceColor += fresnel * saturate(normal.y) * lightColor;
					#endif
					return float4(finalSurfaceColor, 1);
				}
				ENDCG
			}
		}
}