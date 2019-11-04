Shader "Unlit/Reflection"				//reflection
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
				o.normal = v.normal;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);		//Al no tener un input worldPos, tenemos que hacer uso de mul () y de la variable unity para que nos de la posWorld
				o.clipSpacePos = UnityObjectToClipPos(v.vertex);
				return o;
			}

			fixed4 frag(VertexOutput o) : SV_Target
			{
				float2 uv = o.uv0;

				//Lighting

				//Direct diffuse Light
				float3 lightDir = _WorldSpaceLightPos0.xyz;						//Es una variable que referencia la directional light. (Se agrego con la libreria)
				float3 lightColor = _LightColor0.rgb;							//Es una variable que referencia el color de la directional light (libreria).
				float lightFalloff = max(0, dot(lightDir, o.normal));
				float3 directDiffuseLight = lightColor * lightFalloff;

				//Ambient Light
				float3 ambientLight = float3(0.1, 0.1, 0.1);

				//Direct Specular Light (es la luz que brilla como gema)
				float3 camPos = _WorldSpaceCameraPos;							//Pasamos la posición de la camara para sacar la distancia con el fragmento en su spaceworld
				float3 fragToCamera = camPos - o.worldPos;					//Sacamos la posición del fragment shader para renderizar. (Su posición de mundo)
				float3 viewDir = normalize(fragToCamera);						// Se normaliza para...

				float3 viewReflect = reflect(-viewDir, o.normal);			// El vector de la camara dirigiendose a la camara :V, con la normal para sacar la reflection

				//return float4(viewReflect, 0);				//Resultado de la reflection con colores según la vista de la camara y sus ejes(que son como donde incidiría la luz).

				float specularFalloff = max(0, dot(viewReflect, lightDir));			//Se hace dot product del valor del vector reflection (Vr) y el vector luz (L), en donde incide para sacar la reflection con respecto a la luz.

				return float4(specularFalloff.xxx, 0);			// Resultado de la reflection como luz más pura.

				//Composite Light
				float3 diffuseLight = ambientLight + directDiffuseLight;
				float3 finalSurfaceColor = diffuseLight * _Color.rgb;


			}
			ENDCG
		}
	}
}