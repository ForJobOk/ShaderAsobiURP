Shader "Custom/TransparencyEdge"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Edge ("Edge", Range(0, 1)) = 0.5
        _Alpha ("Alpha", Range(0, 1)) = 0.8
    }
    SubShader
    {
        //タグ。サブシェーダーブロック、もしくはパスが実行されるタイミングや条件を記述する。
        Tags
        {
            //レンダリングのタイミング(順番)
            "RenderType" = "Tranparent"
            //レンダーパイプラインを指定する。なくても動く。動作環境を制限する役割。
            "RenderPipeline" = "UniversalPipeline"
        }

        //不当明度を利用するときに必要 文字通り、1 - フラグメントシェーダーのAlpha値　という意味
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            //Core機能をまとめたhlslを参照可能にする。いろんな便利関数や事前定義された値が利用可能となる。
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Edge;
            float _Alpha;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                float4 col = tex2D(_MainTex, i.uv);
                float2 centerUV = float2(0.5, 0.5);
                float dist = distance(i.uv, centerUV);
                float transparency = saturate(1.5 - dist / _Edge);
                col.a = transparency * _Alpha;
                return col * i.color;
            }
            ENDHLSL
        }
    }
}