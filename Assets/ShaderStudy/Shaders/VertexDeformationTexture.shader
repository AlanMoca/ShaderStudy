Shader "Unlit/VertexDeformationTexture"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_ColorBottom("Color Bottom", Color) = (1,1,1,1)
		//_MainTex("Wind Pattern", Texture) = {}								//_MainText Es un nombre especial en unity! Va a hablar sobre el presunto color de la superficie
		_WindNoiseVariation("Wind Pattern", 2D) = "gray"{}
		_Gloss("Gloss", Range(0,1)) = 1
		_WindNoiseScale("Wind Noise Scale", float ) = 1
		_WindSpeed("Wind Speed", float) = 1
		_WindBendAmpMin("Wind Bend Amplitude Min", Range(-1,0)) = 1						//Controlar qué tanto se desplazará el pasto con el aire
		_WindBendAmpMax("Wind Bend Amplitude Max", Range(0,1)) = 1
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
			float _WindBendAmpMin;
			float _WindBendAmpMax;
			float4 _ColorBottom;
			sampler2D _WindNoiseVariation;
			float _WindNoiseScale;
			float _WindSpeed;

			VertexOutput vert(VertexInput v)
			{
				VertexOutput o;
				o.uv0 = v.uv0;
				o.normal = UnityObjectToWorldNormal(v.normal);

				float3 worldPosPreWind = mul(unity_ObjectToWorld, v.vertex);		//Es una transformación a coordenadas de mundo que requería propiamente el cesped (Es importante para la vertexDeformation definir cuando se requiere si antes o después)

				//Wind Noise Pattern
				float2 windDir = normalize(float2(1, 0));					// Con esto se modificará la posición de mundo respecto a las UV's (de la imagen noise)
				float2 noiseUVs = (worldPosPreWind.xz + windDir * _Time.y * _WindSpeed) / _WindNoiseScale;	//Supongo que es para que cuando este en cierta posición del mundo se vea cierta parte de la iagen like el quad (La imagen tien un offset de movimiento (windDir * _Time.y) y otro el quad mismo de movimiento)
				float noise = tex2Dlod(_WindNoiseVariation, float4(noiseUVs, 3, 3)).x;
				
				float deformAmp = lerp(_WindBendAmpMin, _WindBendAmpMin, noise);			// Con esto condicionaremos a nuestra noiseTexture a deformarse sólo un máximo y un mínimo.

				v.vertex.x += sin(_Time.y) * v.colors.r * deformAmp * noise;				//Con esto el pasto subiría y bajaría sólo en su parte de color, en la parte negra (la base), no...? El.x es ára donde afectará el sin
				//v.vertex.x += v.colors.r * deformAmp;					Lo correcto pero porqué a mí no me funciona?

				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.clipSpacePos = UnityObjectToClipPos(v.vertex);
				return o;
			}

			fixed4 frag(VertexOutput o) : SV_Target
			{
				//Esto sólo se puso aquí (fragmentShader) para poder debuggear en el fragment, una vez listo se copio al vertexShader
				//float2 windDir = normalize(float2(1,0));					// Con esto se modificará la posición de mundo respecto a las UV's (de la imagen noise)
				//float2 noiseUVs = (o.worldPos.xz + windDir * _Time.y * _WindSpeed) / _WindNoiseScale;	//Supongo que es para que cuando este en cierta posición del mundo se vea cierta parte de la iagen like el quad (La imagen tien un offset de movimiento (windDir * _Time.y) y otro el quad mismo de movimiento)
				//float noise = tex2Dlod(_WindNoiseVariation, float4(noiseUVs,3,3 )).x;				
				//return noise;

				float t = o.uv0.y;
				float3 grassColor = lerp(_ColorBottom, _Color, t);

				return float4(grassColor, 1);

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
