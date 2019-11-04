Shader "Unlit/Interpolate"																//El name path del shader
{
	Properties																			//Todas las cosas que definiran el material (inputs)
	{
		//_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader																			//Aquí es donde realmente el shader inicia y esta compuesto (en unity) del Vertex y Fragment Shader
	{
		Tags { "RenderType" = "Opaque" }

		Pass
		{
			CGPROGRAM																	//Es el indicador que aquí inicia nuestro programa (Lenguaje GLSL)
			#pragma vertex vert															//#pragma es un precompilador que te dice cuál es el nombre del vertex y fragment shader
			#pragma fragment frag

			#include "UnityCG.cginc"													// Es de unity y ayuda para lucer y otras cosas, siempre agregar.

			struct VertexInput															// appdata (le cambie el nombre a Vertex Input) Es la mesh data como: Vertex position, vertex normal, UVs coordinates, tangents, vertex colors, etc
			{																			//  En pocas palabras qué data quiero para la mesh?
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv0 : TEXCOORD0;
			};

			struct VertexOutput															// v2f (Le cambie el nombre a VertexOutput) Es de output para el Vertex Shader y  el "input" para el fragment shader
			{
				float4 clipSpacePos : SV_POSITION;		//Está heredando?				// Le cambie el nombre de vertex a clipSpacePos (que es la posición relativa al frustrum de la camara)
				float2 uv0 : TEXCOORD0;
				float3 normal : TEXCOORD1;				//La siguiente interpolación? (TEXCOORD0/1, se refieren siempre a Interpolaters)
			};

			VertexOutput vert(VertexInput v)											//La funcion del Vertex shader
			{
				VertexOutput o;
				o.uv0 = v.uv0;
				o.normal = v.normal;
				o.clipSpacePos = UnityObjectToClipPos(v.vertex);						//La función de unity pasará las coordenadas locales del modelo a coordenadas clip space de la camara (Metemos los vertices input y guardamos en el output de estructura)
				return o;
			}

			// NOTA: El cambio que se efectua dentro de estas dos funciones prevalece, por eso aunque no llames a la función vert, esta guardará los cambios hechos y supongo los valores de la estructura se modificaran

			fixed4 frag(VertexOutput o) : SV_Target									//La funcion del Fragment shader (SV_Target es a special semantic para la posición del vertex en clipSpace)
			{
				float2 uv = o.uv0;
				//float3 normals = o.normal;					//Rango -1 to 1 (Hará una interpolación entre RGB en sus vertices pero guardará algo del negro y blanco!)
				float3 normals = o.normal / 2 + 0.5;		//Rango 0 to 1 (Hará una interpolación entre RGB en sus vertices pero guardará algo sólo del blanco al eliminar la parte negativa!)
				return float4(normals, 0);					//Con esto se visualizarán todas las normales y no sólo las UV's
			}
			ENDCG																		//Es el indicador que aquí inicia nuestro programa (Lenguaje GLSL)
		}
	}
}
