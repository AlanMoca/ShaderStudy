Shader "Unlit/WaterBottleContentArea"					//ShaderLab: Stencil
{
		SubShader
		{
			Tags {
				"RenderType" = "Transparent"
				"Queue" = "Geometry"
			}

			Pass
			{

				Stencil
				{
					Ref 2					//Ref es el valor que birght? (Brillo dentro del stencil buffer)
					Comp always				//Comp es el valor que compararemos con el existente stencil buffer (si es igual a 2 entonces pasa el fade(desvanecerse)?) El always nos dice que siempre se escribirá en el stencil buffer
					Pass replace			//Pass significa que hará si la comparación es passable/succesfull. Como always pass, always replace (remplazará) el current value (según yo no sé si l remplaza con) en el stencil buffer
				}

				ColorMask 0					//Le esta dando como orden de prioridad a la mascara de color. (Al ser cero.. )
				ZWrite off					// Le dice al ZBuffer que no importa si hay algo antes que me renderice (al que tenga este shader)

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"

				struct VertexInput
				{
					float4 vertex : POSITION;
					float2 uv0 : TEXCOORD0;
				};

				struct VertexOutput
				{
					float4 clipSpacePos : SV_POSITION;
					float2 uv0 : TEXCOORD0;
				};

				sampler2D _MainTex;

				VertexOutput vert(VertexInput v)
				{
					VertexOutput o;
					o.uv0 = v.uv0;
					o.clipSpacePos = UnityObjectToClipPos(v.vertex);
					return o;
				}

				float4 frag(VertexOutput o) : SV_Target
				{
					return float4(1,0,0,0);
				}
				ENDCG
			}
		}
}

