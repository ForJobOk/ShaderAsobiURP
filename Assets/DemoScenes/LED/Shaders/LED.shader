Shader "Custom/LED"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _PixShape("Pixel Shape Texture", 2D) = "white" {}
        _UV_X("Pixel num x", Range(0,1600)) = 960
        _UV_Y("Pixel num y", Range(0,1600)) = 360
        _Intensity("intensity", float) = 1
    }
    SubShader
    {
        Tags
        {
            //レンダリングのタイミング(順番)
            "RenderType" = "Opaque"
            //レンダーパイプラインを指定する。なくても動く。動作環境を制限する役割。
            "RenderPipeline" = "UniversalPipeline"
        }

        Pass
        {
            //HLSL言語を使うという宣言(おまじない)。ビルトインではCg言語だった。
            HLSLPROGRAM
            //vertという名前の関数がvertexシェーダーです　と宣言してGPUに教える。
            #pragma vertex vert
            //fragという名前の関数がfragmentシェーダーです　と宣言してGPUに教える。
            #pragma fragment frag

            //Core機能をまとめたhlslを参照可能にする。いろんな便利関数や事前定義された値が利用可能となる。
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            //頂点シェーダーに渡す構造体。名前は自分で定義可能。
            struct appdata
            {
                //オブジェクト空間における頂点座標を受け取るための変数
                float4 position : POSITION;

                //UV座標を受け取るための変数
                float2 uv : TEXCOORD0;
            };


            //フラグメントシェーダーに渡す構造体。名前は自分で定義可能。
            struct v2f
            {
                //頂点座標を受け取るための変数。
                float4 vertex : SV_POSITION;

                //UV座標を受け取るための変数。
                float2 uv : TEXCOORD0;
            };

            //テスクチャーサンプル用の変数。おまじない。
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_PixShape);
            SAMPLER(sampler_PixShape);

            //SRP Batcherへの対応。Textureは書かなくても勝手にやってくれる。
            //_MainTex_STはTextureをプロパティーに設定した際に自動で定義されるオフセットやタイリング用の値。
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float4 _PixShape_ST;
            float _UV_X, _UV_Y, _Intensity;
            CBUFFER_END

            v2f vert(appdata v)
            {
                v2f o;

                //"3Dの世界での座標は2D(スクリーン)においてはこの位置になりますよ"　という変換を関数を使って行っている。
                o.vertex = TransformObjectToHClip(v.position.xyz);

                //UV受け取り。TRANSFORM_TEXでオフセットやタイリングの処理を適用。
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                //変換結果を返す。フラグメントシェーダーへ渡る。
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                //縦横何個並べるか
                float2 size = float2(_UV_X, _UV_Y);
                float2 posterize = floor(i.uv / (1 / size)) * (1 / size) + 1 / size;
                //UVの値が1付近の場合、なぜかモザイクの位置がずれるので調整
                float2 clampPosterize = clamp(posterize, 0, 0.99);
                float4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, clampPosterize);

                float2 uv = i.uv * size;
                float4 pix = SAMPLE_TEXTURE2D(_PixShape, sampler_PixShape, uv);
                return col * pix * _Intensity;
            }
            ENDHLSL
        }
    }
}