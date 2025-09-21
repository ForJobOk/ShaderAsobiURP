Shader "Custom/GridEffect"
{
    Properties
    {
        _BaseColor ("Grid Color", Color) = (1,1,1,1)
        _GridColor ("Grid Color", Color) = (0,0,0,1)
        _GridCount ("Grid Count", Range(1, 100)) = 10
        _Speed ("Speed", Range(0, 100)) = 1
    }
    SubShader
    {
         Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
        }
         
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            float4 _BaseColor;
            float4 _GridColor;
            float _GridCount;
            float _Speed;

            // 0~1の疑似ランダムな値を返す関数。
            float rand(float2 co) 
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
            }
           
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                // fracで連続する0~1の値を計算。
                float2 gridUV = i.uv * _GridCount;

                // グリッドIDを計算し、グリッドごとに時間変化するハッシュ値を作成。
                int2 gridID = int2(floor(gridUV));
                float random = rand(float2(gridID));
                float hash = frac(random + _Time.x * _Speed);

                // ハッシュ値に応じてセルの色を決定。
                float interpolation = step(0.5, hash);
                float4 cellColor = lerp(_BaseColor, _GridColor, interpolation);
                return cellColor;
            }
            ENDHLSL
        }
    }
}