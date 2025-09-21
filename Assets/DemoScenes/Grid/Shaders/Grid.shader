Shader "Custom/Grid"
{
    Properties
    {
        _GridCount ("Grid Count", Range(1, 100)) = 10
        _GridLineSize ("Grid Line Size", Range(0.02, 1)) = 0.1
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
            
            float _GridCount;
            float _GridLineSize;
           
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
                float2 fracUV = frac(gridUV + _GridLineSize / 2);

                // 境界エッジを作成する。0 or 1を作って、境界線とそれ以外を塗り分ける。
                float edgeX = step(_GridLineSize, fracUV.x);
                float edgeY = step(_GridLineSize, fracUV.y);

                // edgeXとedgeYはそれぞれ0 or 1なので、掛け算をすることで両方の境界線上のみ1になる。
                float edge = edgeX * edgeY;
                return edge;
            }
            ENDHLSL
        }
    }
}