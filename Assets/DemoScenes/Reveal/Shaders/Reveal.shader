Shader "Custom/Reveal"
{
    Properties
    {
        [HDR]_MainColor("Main Color", Color) = (1,1,1,1)
        [HDR]_LineColor("Scan Line Color", Color) = (1,1,1,1)
        [HDR]_TrajectoryColor("Scan Trajectory Color", Color) = (0.3, 0.3, 0.3, 1)
        _LineSize("Scan Line Size", Float) = 0.02
        _TrajectorySize("Scan Trajectory Size", Range(0,1)) = 0.1
        _RevealTime("_RevealTime", Float) = 0
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent"

            //レンダーパイプラインを指定する。なくても動く。動作環境を制限する役割。
            "RenderPipeline" = "UniversalRenderPipeline"
        }
        Blend SrcAlpha OneMinusSrcAlpha

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

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldPos : WORLD_POS;
            };

            float4 _MainColor;
            float4 _LineColor;
            float _LineSize;
            float4 _TrajectoryColor;
            float _TrajectorySize;
            float _RevealTime;

            v2f vert(appdata v)
            {
                v2f o;
                //unity_ObjectToWorld × 頂点座標(v.vertex) = 描画しようとしてるピクセルのワールド座標　らしい
                //mulは行列の掛け算をやってくれる関数
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.vertex = TransformObjectToHClip(v.vertex);
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                //カメラの位置を中心として円形状にエフェクトを進める
                float3 worldPos = float3(i.worldPos.x, 0, i.worldPos.z);
                float3 cameraPos = float3(_WorldSpaceCameraPos.x, 0, _WorldSpaceCameraPos.z);
                float dist = distance(cameraPos, worldPos);
                //時間変化に伴い値を減算する
                float lineStartPosition = abs(dist - _TrajectorySize - _RevealTime);
                float lineEndPosition = abs(dist + _TrajectorySize - _RevealTime);
                //スキャンラインの大きさを計算　step(a,b) はbがaより大きい場合1を返す
                //すなわち、_LineSizeが大きくなればstepが1を返す値の範囲も大きくなる
                float scanline = step(lineStartPosition, _LineSize);
                //軌跡の大きさを計算 smoothstep(a,b,c) はcがa以下の時は0、b以上の時は1、0～1は補間
                //1 - smoothstep(a,b,c)とすることで補間値を逆転できる　
                //つまり 1 - smoothstep(a,b,c) はcがa以上の時は1、b以下の時は0、0～1は補間
                float trajectory = 1 - smoothstep(_LineSize, _LineSize + _TrajectorySize, lineStartPosition);
                //ここまでの計算結果を元に色を反映
                float4 color = lerp(_MainColor, _LineColor * scanline + _TrajectoryColor * trajectory, trajectory);
                //スキャンラインの進行度合いに応じて透明度を変化させる
                float alpha = step(lineStartPosition, lineEndPosition);
                color.a = alpha;
                clip(color.a - 0.01);
                return color;
            }
            ENDHLSL
        }
    }
}