Shader "Custom/Rim"
{
    Properties
    {
        _TintColor("Tint Color", Color) = (0,0.5,1,1)
        _RimColor("Rim Color", Color) = (0,1,1,1)
        _RimPower("Rim Power", Range(0,1)) = 0.4
    }

    Category
    {
        Tags
        {
            "Queue" = "Transparent"
            "RenderType" = "Transparent"
            "RenderPipeline" = "UniversalPipeline"
        }
        Blend SrcAlpha OneMinusSrcAlpha

        SubShader
        {
            Pass
            {
                Tags
                {
                    "LightMode" = "UniversalForward"
                }
                
                ColorMask 0
            }

            Pass
            {
                HLSLPROGRAM
                #pragma vertex vert
                #pragma fragment frag

                //Core機能をまとめたhlslを参照可能にする。いろんな便利関数や事前定義された値が利用可能となる。
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"


                float4 _TintColor;
                float4 _RimColor;
                float _RimPower;

                struct appdata_t
                {
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                };

                struct v2f
                {
                    float4 vertex : SV_POSITION;
                    float3 world_pos : TEXCOORD0;
                    float3 normalDir : TEXCOORD1;
                };

                v2f vert(appdata_t v)
                {
                    v2f o;

                    o.vertex = TransformObjectToHClip(v.vertex);
                    o.world_pos = mul(unity_ObjectToWorld, v.vertex).xyz;
                    o.normalDir = TransformObjectToWorldNormal(v.normal);
                    return o;
                }

                float4 frag(v2f i) : SV_Target
                {
                    //カメラのベクトルを計算
                    float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.world_pos.xyz);
                    //法線とカメラのベクトルの内積を計算し、補間値を算出
                    half rim = 1.0 - saturate(dot(viewDirection, i.normalDir));
                    //補間値で塗分け
                    float4 col = lerp(_TintColor, _RimColor, rim * _RimPower);
                    return col;
                }
                ENDHLSL
            }
        }
    }
}