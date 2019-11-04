Shader "Unlit/WaterBottleWater"			//Liquid	
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Color("Color", Color) = (0.5,0.5,0.5,0.5)
	}
		SubShader
	{
		Tags {
				"RenderType" = "Transparent"
				"Queue" = "Geometry+1"					//Querremos que este se renderice después del Stencil(WatterBottleContentArea)
		}

		Pass
		{

			Stencil
				{
					Ref 2					//Ref es el valor que birght? (Brillo dentro del stencil buffer)
					Comp equal				//Si la comp (comparación) del stencil buffer es equal a 2! Tú tienes que keep el current value.
					Pass keep				//Pass significa que hará si la comparación es passable/succesfull. Bien mantendrá el valor sólo si es equal a 2, sino, no lo mantendrá
				}

			ZTest off						//Es para el Zbuffer, renderiza lo que está antes o nel, en este caso no! (ya que el agua esta dentro del content)

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
			float4 _Color;

			VertexOutput vert(VertexInput v)
			{
				VertexOutput o;
				o.uv0 = v.uv0;
				o.clipSpacePos = UnityObjectToClipPos(v.vertex);
				return o;
			}

			float4 frag(VertexOutput o) : SV_Target
			{
				return _Color;
			}
			ENDCG
		}
	}
}
