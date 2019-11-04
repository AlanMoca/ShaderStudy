Shader "Unlit/Glass"
{
	Properties
	{
		_MainTex("Fake Reflection", 2D) = "white" {}
		_OpacityEdge("Opacity Edge", Range(0,1)) = 0.5
		_OpacityInner("Opacity Inner", Range(0,1)) = 0.5
		_ReflectionScale("Reflection Scale", float) = 1
	}
		SubShader
	{
		Tags {
			"RenderType" = "Transparent"
			"Queue" = "Transparent"
		}

		Pass
		{
			
			//Cull off														//Se tiene que quitar porque hay multiples layers queriendose sobre poner
			ZWrite off
			Blend One One

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			struct VertexInput
			{
				float4 vertex : POSITION;
				float2 uv0 : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct VertexOutput
			{
				float4 clipSpacePos : SV_POSITION;
				float2 uv0 : TEXCOORD0;
				float3 normal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
			};

			sampler2D _MainTex;
			float _OpacityEdge;
			float _OpacityInner;
			float _ReflectionScale;

			VertexOutput vert(VertexInput v)
			{
				VertexOutput o;
				o.uv0 = v.uv0;
				o.normal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.clipSpacePos = UnityObjectToClipPos(v.vertex);
				return o;
			}

			float4 frag(VertexOutput o) : SV_Target
			{

				float3 normal = normalize(o.normal);
				float3 camPos = _WorldSpaceCameraPos;
				float3 fragToCamera = camPos - o.worldPos;
				float3 viewDir = normalize(fragToCamera);
				float3 viewReflect = reflect(-viewDir, normal);

				float fresnel = 1.0 - max(0, dot(normal, viewDir));									//1 - CLAMP entre la dirección de la camara y la normal del objeto
				//fresnel = pow(fresnel, 5);
				fresnel = fresnel * fresnel * fresnel * fresnel * fresnel;						//Es más optimo que la función de potencia x'D

				float fresnelFade = lerp(_OpacityInner, _OpacityEdge, fresnel);				//Es respecto al fresnel peroo (fake reflections)

				float3 viewSpaceReflection = mul(UNITY_MATRIX_V, float4(viewReflect, 0)).xyz;		//Matrix que da el efecto de vaso!

				float distoredRef1 = tex2D(_MainTex, viewSpaceReflection.xy / _ReflectionScale).x;

				return float4(distoredRef1.xxx, 1) * fresnelFade;

				//return float4(distoredRef1.xxx, 1) * _OpacityEdge * fresnel;				//Transparente! :3
			}
			ENDCG
		}
	}
}
