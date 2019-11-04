Shader "Unlit/BlendingModes"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Color("Color", Color) = (0.5,0.5,0.5,0.5)
    }
    SubShader
	{
		Tags { 
			"RenderType" = "Transparent"						//Necesitamos cambiar el render type de(opaque) a Transparent porque queremos que se renderice después de otros objetos.
			"Queue" = "Transparent"								//Es una forma más exacta de decir como querremos que se renderice (="transparent+1" o sea después de que todos los transparent se rendericen)
		}

        Pass
        {
			//Zwrite off/on
			//ZTest off/on
			//ZTest LEqual/GEqual								//JuegosRTS

			//BLEND:
			//Additive
			//La sintaxis es: 
			// color =		Blend A * (1 or 0) B * (1 or 0) =		A * source(thisShader)(1 or 0) + B * Destination(backgroundColor)(1 or 0)	=> Que sería lo que es Additive

			//Alpha Blending (src = source)
			//Blend SrcAlpha OneMinusSrcAlpha						//Este modificas el valor alpha en el color para cmbiar la transparencia
			//color = A * thisShader + B * backgroundColor

			//Multiplicative
			//Blend Zero ScrColor									
			//color = A * 0 + B * backgroundColor

			//Blend One One					//
			//Blend One Zero				//

			//CULL:
			//Cull Back/Front/Off											//Como renderizaras las caras de tu objeto(normals para verse invisible o no)

			Zwrite off											// Le dice al ZBuffer que no importa si hay algo antes que me renderice (al que tenga este shader)
			
			Blend one one										// es una forma de decirle como va a manejarlo el fragment/pixel que viene de este shader y como lo blending(mezclar) con el target shader el destino de renderización

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
			#include "SharedMyFunction.cginc"								//Como libreria prueba alv

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

			VertexOutput vert (VertexInput v)
            {
				VertexOutput o;
				o.uv0 = v.uv0;
                o.clipSpacePos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float4 frag (VertexOutput o) : SV_Target
            {
                // sample the texture
				float4 col = _Color;
                return col;
            }
            ENDCG
        }
    }
}
