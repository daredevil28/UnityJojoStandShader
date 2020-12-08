Shader "JoJo/StandShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Offset ("Position of stand", Vector) = (1, 0.5, 0)
        _Bobbing ("How much the stand goes up and down", Float) = 0.1
        _Transparency ("Where it goes transparent", Float) = 0.8
        _Purple ("How much purple there is in the transparency", Float) = 0.2
        _Speed ("Time * _Speed", Float) = 1
        _Scale ("Scale / size", Float) = 1
        _Rotation ("Rotation", Float) = 0.03
    }
    SubShader
    {
        pass 
        {
            Tags {"RenderType"="Opaque"}
            //ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
        
            //Tags {"LightMode"="ForwardBase"}
            CGPROGRAM
            // use "vert" function as the vertex shader
            #pragma vertex vert

            // use "frag" function as the pixel (fragment) shader
            #pragma fragment frag
                
            uniform float4 _LightColor0;

            float4 _Offset;
            float _Bobbing;
            float _Transparency;
            float _Purple;
            float _Speed;
            float _Scale;
            float _Rotation;
            sampler2D _MainTex;

            
            // vertex shader inputs
            struct appdata
            {
                float4 vertex : POSITION; // vertex position
                float2 uv : TEXCOORD0; // texture coordinate
            };

            // vertex shader outputs ("vertex to fragment")
            struct v2f
            {
                float2 uv : TEXCOORD0; // texture coordinate
                float4 vertex : SV_POSITION; // clip space position
                float4 color : COLOR;
            };

            // vertex shader
            v2f vert (appdata v)
            {
                v2f o;
                // transform position to clip space
                // (multiply with model*view*projection matrix)
                o.color = v.vertex;
                v.vertex.xyz *= _Scale;
                v.vertex += _Offset;
                v.vertex.x += v.vertex.y * sin(_Time[1] * 0.4 * _Speed) * _Rotation;;
                v.vertex.y += sin(_Time[1] * 0.8 * _Speed) * _Bobbing;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
            
            // texture we will sample
            

            // pixel shader; returns low precision ("fixed4" type)
            // color ("SV_Target" semantic)
            fixed4 frag (v2f i) : SV_Target
            {
                // sample texture and return it

                float4 transparent = {0, 0, 0, 0};
                float4 col = lerp(transparent, tex2D(_MainTex, i.uv), max(min(i.color.y * 2 + _Transparency - _Purple, 1), 0));
                col.rb = lerp(transparent, tex2D(_MainTex, i.uv), max(min(i.color.y * 2 + _Transparency, 1), 0)).rb;
                if(all(_LightColor0))
                {
                    col.rgb *= min(_LightColor0, 1);
                }
                return col;
            }
        ENDCG
        }
    }
    Fallback "Diffuse"
}


