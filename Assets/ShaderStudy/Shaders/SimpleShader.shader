Shader "Unlit/SimpleShader"																//El name path del shader
{
    Properties																			//Todas las cosas que definiran el material (inputs)
    {
        //_MainTex ("Texture", 2D) = "white" {}
    }
    SubShader																			//Aquí es donde realmente el shader inicia y esta compuesto (en unity) del Vertex y Fragment Shader
    {
        Tags { "RenderType"="Opaque" }													// Esto le ayuda a unity a saber en que parte de su pipeline debería renderizar y en qué orden.

        Pass																			//Algunos shaders hacen render en multiples pasadas, otros en sólo una
        {
            CGPROGRAM																	//Es el indicador que aquí inicia nuestro programa (Lenguaje GLSL)
            #pragma vertex vert															//#pragma es un precompilador que te dice cuál es el nombre del vertex y fragment shader
            #pragma fragment frag

            #include "UnityCG.cginc"													// Es de unity y ayuda para lucer y otras cosas, siempre agregar.

            struct VertexInput															// appdata (le cambie el nombre a Vertex Input) Es la mesh data como: Vertex position, vertex normal, UVs coordinates, tangents, vertex colors, etc
            {																			//  En pocas palabras qué data quiero para la mesh?
                float4 vertex : POSITION;												
				//float4 colors : COLOR;												// Las variables que pasamos que querremos de la Mesh
				//float4 normal: NORMAL;
				//float4 tangent : TANGENT;
				float2 uv0 : TEXCOORD0;
				//float4 uv1 : TEXCOORD1;												// TEXCOORD0 es un canal especifico por donde se pasa la uv0 por lo que entiendo
            };

            struct VertexOutput															// v2f (Le cambie el nombre a VertexOutput) Es de output para el Vertex Shader y  el "input" para el fragment shader
            {
                float4 clipSpacePos : SV_POSITION;		//Está heredando?				// Le cambie el nombre de vertex a clipSpacePos (que es la posición relativa al frustrum de la camara)
				float2 uv0 : TEXCOORD0;
            };

            //sampler2D _MainTex;														// Son variables simples que sualmente tienen una correspondencia con las propiedades
            //float4 _MainTex_ST;

			VertexOutput vert (VertexInput v)											//La funcion del Vertex shader
            {
				VertexOutput o;
				o.uv0 = v.uv0;
                o.clipSpacePos = UnityObjectToClipPos(v.vertex);						//La función de unity pasará las coordenadas locales del modelo a coordenadas clip space de la camara (Metemos los vertices input y guardamos en el output de estructura)
                return o;
            }

			// NOTA: El cambio que se efectua dentro de estas dos funciones prevalece, por eso aunque no llames a la función vert, esta guardará los cambios hechos y supongo los valores de la estructura se modificaran

            fixed4 frag (VertexOutput o) : SV_Target									//La funcion del Fragment shader (SV_Target es a special semantic para la posición del vertex en clipSpace)
            {
				//float3 clipPos = o.clipSpacePos.xyz;
				//return float4(clipPos, 0);
				float2 uv = o.uv0;
				//return float4(uv, 0, 0);
				//return float4(uv.xxx, 0);
				return float4(uv.yyy, 0);
				
            }
            ENDCG																		//Es el indicador que aquí inicia nuestro programa (Lenguaje GLSL)
        }
    }
}
