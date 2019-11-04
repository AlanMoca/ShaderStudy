Shader "Unlit/VertexDeformationNormals"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_Gloss("Gloss", Range(0,1)) = 1
		_ExtrudeDistance("Extrude Distance", Range(0,1)) = 0
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
				float4 colors: COLOR;									//Sólo e usará para la data de los vertexColors de la propia mesh(3DSMAX)
			};

			struct VertexOutput
			{
				float4 clipSpacePos : SV_POSITION;
				float2 uv0 : TEXCOORD0;
				float3 normal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
			};

			float4 _Color;
			float _Gloss;
			float _ExtrudeDistance;

			VertexOutput vert(VertexInput v)
			{
				VertexOutput o;
				o.uv0 = v.uv0;

				v.vertex.xyz += v.normal * _ExtrudeDistance;						//Ahora se toma el vertex y se le agrega la dirección de la normal multiplicado por que tanto queremos que se distancie

				o.normal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.clipSpacePos = UnityObjectToClipPos(v.vertex);
				return o;
			}

			fixed4 frag(VertexOutput o) : SV_Target
			{
				float t = o.uv0.y;

				float3 normal = normalize(o.normal);

				//Lighting
				float3 lightDir = _WorldSpaceLightPos0.xyz;
				float3 lightColor = _LightColor0.rgb;

				//Direct diffuse Light
				float lightFalloff = max(0, dot(lightDir, normal));
				float3 directDiffuseLight = lightColor * lightFalloff;

				//Ambient Light
				float3 ambientLight = float3(0.1, 0.1, 0.1);

				//Direct Specular Light (es la luz que brilla como gema)
				float3 camPos = _WorldSpaceCameraPos;
				float3 fragToCamera = camPos - o.worldPos;
				float3 viewDir = normalize(fragToCamera);

				float3 viewReflect = reflect(-viewDir, normal);
				float specularFalloff = max(0, dot(viewReflect, lightDir));
				float specularExponent = exp2(_Gloss * 11);
				specularFalloff = pow(specularFalloff, specularExponent);
				specularFalloff *= _Gloss;

				float3 directSpecular = specularFalloff * lightColor;
				float3 diffuseLight = ambientLight + directDiffuseLight;
				float3 finalSurfaceColor = diffuseLight * _Color.rgb + directSpecular;

				return float4(finalSurfaceColor, 0);

			}
			ENDCG
		}
	}
}