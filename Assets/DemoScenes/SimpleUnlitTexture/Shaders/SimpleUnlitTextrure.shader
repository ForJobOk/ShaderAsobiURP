Shader "Custom/SimpleUnlitTextrure"
{
    //プロパティーブロック。ビルトインと同様に外部から操作可能な設定値を定義できる。
    Properties
    {
        //ここに書いたものがInspectorに表示される。
        _Color("MainColor",Color) = (0,0,0,0)
        _MainTex ("Texture", 2D) = "white" {}
    }

    //サブシェーダーブロック。ここに処理を書いていく。
    SubShader
    {
        //タグ。サブシェーダーブロック、もしくはパスが実行されるタイミングや条件を記述する。
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

            //変数の宣言。Propertiesで定義した名前と一致させる。
            float4 _Color;

            //テスクチャーサンプル用の変数。おまじない。
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            //SRP Batcherへの対応。Textureは書かなくても勝手にやってくれる。
            //_MainTex_STはTextureをプロパティーに設定した際に自動で定義されるオフセットやタイリング用の値。
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            CBUFFER_END

            //頂点シェーダー。引数には事前定義した構造体が渡ってくる。
            v2f vert(appdata v)
            {
                //先ほど宣言した構造体のオブジェクトを作る。
                v2f o;

                //"3Dの世界での座標は2D(スクリーン)においてはこの位置になりますよ"　という変換を関数を使って行っている。
                o.vertex = TransformObjectToHClip(v.position.xyz);

                //UV受け取り。TRANSFORM_TEXでオフセットやタイリングの処理を適用。
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                //変換結果を返す。フラグメントシェーダーへ渡る。
                return o;
            }

            //フラグメントシェーダー。引数には頂点シェーダーで処理された構造体が渡ってくる。
            float4 frag(v2f i) : SV_Target
            {
                //テスクチャーのサンプリング。
                float4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);

                //テクスチャーのサンプリング結果とColorプロパティーの値をかけあわせる。
                return col * _Color;
            }
            ENDHLSL
        }
    }
}