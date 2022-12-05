Shader "URPMine/RockWallURPZWriteOn"
{
    Properties
    {
        _size("size", Float) = 1
        [NoScaleOffset]_front("front", 2D) = "white" {}
        [NoScaleOffset]_side("side", 2D) = "white" {}
        _Alpha("Alpha", Range(0, 1)) = 1
        _Position("PlayerPosition (1)", Vector) = (0.5, 0.5, 0, 0)
        _CircleSize("CircleSize", Range(0, 1)) = 1
        _CircleSmoothnes("CircleSmoothnes", Float) = 0
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
        SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue" = "Transparent"
            "ShaderGraphShader" = "true"
            "ShaderGraphTargetId" = "UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _CLUSTERED_RENDERING
        // GraphKeywords: <None>

        // Defines

        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 WorldSpacePosition;
             float3 AbsoluteWorldSpacePosition;
             float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float3 interp3 : INTERP3;
             float2 interp4 : INTERP4;
             float2 interp5 : INTERP5;
             float3 interp6 : INTERP6;
             float4 interp7 : INTERP7;
             float4 interp8 : INTERP8;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

        PackedVaryings PackVaryings(Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz = input.positionWS;
            output.interp1.xyz = input.normalWS;
            output.interp2.xyzw = input.tangentWS;
            output.interp3.xyz = input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp4.xy = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.interp5.xy = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp6.xyz = input.sh;
            #endif
            output.interp7.xyzw = input.fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.interp8.xyzw = input.shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

        Varyings UnpackVaryings(PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.viewDirectionWS = input.interp3.xyz;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.interp4.xy;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.interp5.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp6.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp7.xyzw;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.interp8.xyzw;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }


        // --------------------------------------------------
        // Graph

        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _size;
        float4 _front_TexelSize;
        float4 _side_TexelSize;
        float _Alpha;
        float _CircleSize;
        float4 _Position;
        float _CircleSmoothnes;
        CBUFFER_END

            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_front);
            SAMPLER(sampler_front);
            TEXTURE2D(_side);
            SAMPLER(sampler_side);

            // Graph Includes
            // GraphIncludes: <None>

            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif

            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif

            // Graph Functions

            void Unity_Absolute_float(float In, out float Out)
            {
                Out = abs(In);
            }

            void Unity_Comparison_Greater_float(float A, float B, out float Out)
            {
                Out = A > B ? 1 : 0;
            }

            void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
            {
                Out = A * B;
            }

            void Unity_Rotate_Degrees_float(float2 UV, float2 Center, float Rotation, out float2 Out)
            {
                //rotation matrix
                Rotation = Rotation * (3.1415926f / 180.0f);
                UV -= Center;
                float s = sin(Rotation);
                float c = cos(Rotation);

                //center rotation matrix
                float2x2 rMatrix = float2x2(c, -s, s, c);
                rMatrix *= 0.5;
                rMatrix += 0.5;
                rMatrix = rMatrix * 2 - 1;

                //multiply the UVs by the rotation matrix
                UV.xy = mul(UV.xy, rMatrix);
                UV += Center;

                Out = UV;
            }

            void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
            {
                Out = Predicate ? True : False;
            }

            void Unity_Remap_float4(float4 In, float2 InMinMax, float2 OutMinMax, out float4 Out)
            {
                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
            }

            void Unity_Add_float4(float4 A, float4 B, out float4 Out)
            {
                Out = A + B;
            }

            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
            {
                Out = UV * Tiling + Offset;
            }

            void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
            {
                Out = A - B;
            }

            void Unity_Divide_float(float A, float B, out float Out)
            {
                Out = A / B;
            }

            void Unity_Multiply_float_float(float A, float B, out float Out)
            {
                Out = A * B;
            }

            void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
            {
                Out = A / B;
            }

            void Unity_Length_float2(float2 In, out float Out)
            {
                Out = length(In);
            }

            void Unity_OneMinus_float(float In, out float Out)
            {
                Out = 1 - In;
            }

            void Unity_Saturate_float(float In, out float Out)
            {
                Out = saturate(In);
            }

            void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
            {
                Out = smoothstep(Edge1, Edge2, In);
            }

            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };

            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }

            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif

            // Graph Pixel
            struct SurfaceDescription
            {
                float3 BaseColor;
                float3 NormalTS;
                float3 Emission;
                float Metallic;
                float Smoothness;
                float Occlusion;
                float Alpha;
            };

            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                float _Split_e3c2fdf12dbc4838a8bd514815889da8_R_1 = IN.WorldSpaceNormal[0];
                float _Split_e3c2fdf12dbc4838a8bd514815889da8_G_2 = IN.WorldSpaceNormal[1];
                float _Split_e3c2fdf12dbc4838a8bd514815889da8_B_3 = IN.WorldSpaceNormal[2];
                float _Split_e3c2fdf12dbc4838a8bd514815889da8_A_4 = 0;
                float _Absolute_54fb81dd1c194d60b704c9f81498ffc9_Out_1;
                Unity_Absolute_float(_Split_e3c2fdf12dbc4838a8bd514815889da8_R_1, _Absolute_54fb81dd1c194d60b704c9f81498ffc9_Out_1);
                float _Comparison_6e7dfe17f5834279863585dd909d6b85_Out_2;
                Unity_Comparison_Greater_float(_Absolute_54fb81dd1c194d60b704c9f81498ffc9_Out_1, 0.5, _Comparison_6e7dfe17f5834279863585dd909d6b85_Out_2);
                UnityTexture2D _Property_95f1b87d5b974a7e8e84e0e2062aec06_Out_0 = UnityBuildTexture2DStructNoScale(_side);
                float _Split_091acb0967a542d5a282773762d4fcea_R_1 = IN.AbsoluteWorldSpacePosition[0];
                float _Split_091acb0967a542d5a282773762d4fcea_G_2 = IN.AbsoluteWorldSpacePosition[1];
                float _Split_091acb0967a542d5a282773762d4fcea_B_3 = IN.AbsoluteWorldSpacePosition[2];
                float _Split_091acb0967a542d5a282773762d4fcea_A_4 = 0;
                float2 _Vector2_9cb3ee01611c48a1bcef7c9c847c8fa7_Out_0 = float2(_Split_091acb0967a542d5a282773762d4fcea_G_2, _Split_091acb0967a542d5a282773762d4fcea_B_3);
                float _Property_0ad1939b470a44f8be3e74a775ca3ed3_Out_0 = _size;
                float _Float_620d3ee1a57d48f98f837d44647977bc_Out_0 = _Property_0ad1939b470a44f8be3e74a775ca3ed3_Out_0;
                float2 _Multiply_6d7b5b0483d6477385ad7919aa9270ba_Out_2;
                Unity_Multiply_float2_float2(_Vector2_9cb3ee01611c48a1bcef7c9c847c8fa7_Out_0, (_Float_620d3ee1a57d48f98f837d44647977bc_Out_0.xx), _Multiply_6d7b5b0483d6477385ad7919aa9270ba_Out_2);
                float2 _Rotate_6bb4154ca8ad4704846be74d0292cc2f_Out_3;
                Unity_Rotate_Degrees_float(_Multiply_6d7b5b0483d6477385ad7919aa9270ba_Out_2, float2 (0.5, 0.5), -90, _Rotate_6bb4154ca8ad4704846be74d0292cc2f_Out_3);
                float4 _SampleTexture2D_2fd545645ee448609b600edb51209aaa_RGBA_0 = SAMPLE_TEXTURE2D(_Property_95f1b87d5b974a7e8e84e0e2062aec06_Out_0.tex, _Property_95f1b87d5b974a7e8e84e0e2062aec06_Out_0.samplerstate, _Property_95f1b87d5b974a7e8e84e0e2062aec06_Out_0.GetTransformedUV(_Rotate_6bb4154ca8ad4704846be74d0292cc2f_Out_3));
                float _SampleTexture2D_2fd545645ee448609b600edb51209aaa_R_4 = _SampleTexture2D_2fd545645ee448609b600edb51209aaa_RGBA_0.r;
                float _SampleTexture2D_2fd545645ee448609b600edb51209aaa_G_5 = _SampleTexture2D_2fd545645ee448609b600edb51209aaa_RGBA_0.g;
                float _SampleTexture2D_2fd545645ee448609b600edb51209aaa_B_6 = _SampleTexture2D_2fd545645ee448609b600edb51209aaa_RGBA_0.b;
                float _SampleTexture2D_2fd545645ee448609b600edb51209aaa_A_7 = _SampleTexture2D_2fd545645ee448609b600edb51209aaa_RGBA_0.a;
                float _Split_19ff8587983246ac85c970e145e7295e_R_1 = IN.WorldSpaceNormal[0];
                float _Split_19ff8587983246ac85c970e145e7295e_G_2 = IN.WorldSpaceNormal[1];
                float _Split_19ff8587983246ac85c970e145e7295e_B_3 = IN.WorldSpaceNormal[2];
                float _Split_19ff8587983246ac85c970e145e7295e_A_4 = 0;
                float _Absolute_317391fafaa84374beca803aa565632c_Out_1;
                Unity_Absolute_float(_Split_19ff8587983246ac85c970e145e7295e_G_2, _Absolute_317391fafaa84374beca803aa565632c_Out_1);
                float _Comparison_08509dcd8b844663a8b9a254806453e0_Out_2;
                Unity_Comparison_Greater_float(_Absolute_317391fafaa84374beca803aa565632c_Out_1, 0.5, _Comparison_08509dcd8b844663a8b9a254806453e0_Out_2);
                UnityTexture2D _Property_d862f312261a47fc87211c138e9e2d65_Out_0 = UnityBuildTexture2DStructNoScale(_side);
                float _Split_33dfc647fa994b33bac6870687224f37_R_1 = IN.AbsoluteWorldSpacePosition[0];
                float _Split_33dfc647fa994b33bac6870687224f37_G_2 = IN.AbsoluteWorldSpacePosition[1];
                float _Split_33dfc647fa994b33bac6870687224f37_B_3 = IN.AbsoluteWorldSpacePosition[2];
                float _Split_33dfc647fa994b33bac6870687224f37_A_4 = 0;
                float2 _Vector2_5fb462bf0b6f4a18ac68e33ab02ca2de_Out_0 = float2(_Split_33dfc647fa994b33bac6870687224f37_R_1, _Split_33dfc647fa994b33bac6870687224f37_B_3);
                float _Property_03059c193ea74dd8b388680b85f07648_Out_0 = _size;
                float _Float_9d01c34c368948508ad404d5536aca12_Out_0 = _Property_03059c193ea74dd8b388680b85f07648_Out_0;
                float2 _Multiply_18516a081d504359bcad3aa790750518_Out_2;
                Unity_Multiply_float2_float2(_Vector2_5fb462bf0b6f4a18ac68e33ab02ca2de_Out_0, (_Float_9d01c34c368948508ad404d5536aca12_Out_0.xx), _Multiply_18516a081d504359bcad3aa790750518_Out_2);
                float4 _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_RGBA_0 = SAMPLE_TEXTURE2D(_Property_d862f312261a47fc87211c138e9e2d65_Out_0.tex, _Property_d862f312261a47fc87211c138e9e2d65_Out_0.samplerstate, _Property_d862f312261a47fc87211c138e9e2d65_Out_0.GetTransformedUV(_Multiply_18516a081d504359bcad3aa790750518_Out_2));
                float _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_R_4 = _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_RGBA_0.r;
                float _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_G_5 = _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_RGBA_0.g;
                float _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_B_6 = _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_RGBA_0.b;
                float _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_A_7 = _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_RGBA_0.a;
                UnityTexture2D _Property_3a54904fa5c74bbeb60261b8a76a189a_Out_0 = UnityBuildTexture2DStructNoScale(_front);
                float _Split_c79f25e24b934932b5cad363a3977e09_R_1 = IN.AbsoluteWorldSpacePosition[0];
                float _Split_c79f25e24b934932b5cad363a3977e09_G_2 = IN.AbsoluteWorldSpacePosition[1];
                float _Split_c79f25e24b934932b5cad363a3977e09_B_3 = IN.AbsoluteWorldSpacePosition[2];
                float _Split_c79f25e24b934932b5cad363a3977e09_A_4 = 0;
                float2 _Vector2_8457483515df467abc99f05f2c2f6398_Out_0 = float2(_Split_c79f25e24b934932b5cad363a3977e09_R_1, _Split_c79f25e24b934932b5cad363a3977e09_G_2);
                float _Property_fc91ea867aa4477485726d431d8da229_Out_0 = _size;
                float _Float_7e1bc66811ba41edb7a1f6e6df7f1d37_Out_0 = _Property_fc91ea867aa4477485726d431d8da229_Out_0;
                float2 _Multiply_b8fc0cf2c6414beabf7bce2b9ff68cb8_Out_2;
                Unity_Multiply_float2_float2(_Vector2_8457483515df467abc99f05f2c2f6398_Out_0, (_Float_7e1bc66811ba41edb7a1f6e6df7f1d37_Out_0.xx), _Multiply_b8fc0cf2c6414beabf7bce2b9ff68cb8_Out_2);
                float4 _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_RGBA_0 = SAMPLE_TEXTURE2D(_Property_3a54904fa5c74bbeb60261b8a76a189a_Out_0.tex, _Property_3a54904fa5c74bbeb60261b8a76a189a_Out_0.samplerstate, _Property_3a54904fa5c74bbeb60261b8a76a189a_Out_0.GetTransformedUV(_Multiply_b8fc0cf2c6414beabf7bce2b9ff68cb8_Out_2));
                float _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_R_4 = _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_RGBA_0.r;
                float _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_G_5 = _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_RGBA_0.g;
                float _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_B_6 = _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_RGBA_0.b;
                float _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_A_7 = _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_RGBA_0.a;
                float4 _Branch_09c1cdaea5f54a1d86615c158f30696f_Out_3;
                Unity_Branch_float4(_Comparison_08509dcd8b844663a8b9a254806453e0_Out_2, _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_RGBA_0, _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_RGBA_0, _Branch_09c1cdaea5f54a1d86615c158f30696f_Out_3);
                float4 _Branch_33ebb3d9ed944f64b6d69749f158256c_Out_3;
                Unity_Branch_float4(_Comparison_6e7dfe17f5834279863585dd909d6b85_Out_2, _SampleTexture2D_2fd545645ee448609b600edb51209aaa_RGBA_0, _Branch_09c1cdaea5f54a1d86615c158f30696f_Out_3, _Branch_33ebb3d9ed944f64b6d69749f158256c_Out_3);
                float _Property_94721ec2508f4046b88413c6bd4e982e_Out_0 = _CircleSmoothnes;
                float4 _ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                float4 _Property_fd84b0cc463c44558e196f2b6699bb15_Out_0 = _Position;
                float4 _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3;
                Unity_Remap_float4(_Property_fd84b0cc463c44558e196f2b6699bb15_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3);
                float4 _Add_4b02f63dcd7e45e188328b812f76fa99_Out_2;
                Unity_Add_float4(_ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0, _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3, _Add_4b02f63dcd7e45e188328b812f76fa99_Out_2);
                float2 _TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3;
                Unity_TilingAndOffset_float((_ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0.xy), float2 (1, 1), (_Add_4b02f63dcd7e45e188328b812f76fa99_Out_2.xy), _TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3);
                float2 _Multiply_177cb9485e70424c8b113020b5fa561e_Out_2;
                Unity_Multiply_float2_float2(_TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3, float2(2, 2), _Multiply_177cb9485e70424c8b113020b5fa561e_Out_2);
                float2 _Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2;
                Unity_Subtract_float2(_Multiply_177cb9485e70424c8b113020b5fa561e_Out_2, float2(1, 1), _Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2);
                float _Divide_0183d4739fe2443987608ab3169a13d9_Out_2;
                Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_0183d4739fe2443987608ab3169a13d9_Out_2);
                float _Property_817685bafbc74ff594205cd2bbec6848_Out_0 = _CircleSize;
                float _Multiply_3046c926d1e34dce9c8963423a59249d_Out_2;
                Unity_Multiply_float_float(_Divide_0183d4739fe2443987608ab3169a13d9_Out_2, _Property_817685bafbc74ff594205cd2bbec6848_Out_0, _Multiply_3046c926d1e34dce9c8963423a59249d_Out_2);
                float2 _Vector2_fea5299f99e247c4ade509c5e8082e2d_Out_0 = float2(_Multiply_3046c926d1e34dce9c8963423a59249d_Out_2, _Property_817685bafbc74ff594205cd2bbec6848_Out_0);
                float2 _Divide_15271b15b3774cec9b09b48583a269d4_Out_2;
                Unity_Divide_float2(_Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2, _Vector2_fea5299f99e247c4ade509c5e8082e2d_Out_0, _Divide_15271b15b3774cec9b09b48583a269d4_Out_2);
                float _Length_8cc50efaa80e489482f7f21fa7901007_Out_1;
                Unity_Length_float2(_Divide_15271b15b3774cec9b09b48583a269d4_Out_2, _Length_8cc50efaa80e489482f7f21fa7901007_Out_1);
                float _OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1;
                Unity_OneMinus_float(_Length_8cc50efaa80e489482f7f21fa7901007_Out_1, _OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1);
                float _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1;
                Unity_Saturate_float(_OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1, _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1);
                float _Smoothstep_d81123febc5349c78b41d5023455b828_Out_3;
                Unity_Smoothstep_float(0, _Property_94721ec2508f4046b88413c6bd4e982e_Out_0, _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1, _Smoothstep_d81123febc5349c78b41d5023455b828_Out_3);
                float _Property_84f7f817f25348a3bec32f2049267d9d_Out_0 = _Alpha;
                float _Multiply_288a1c15da154ed2b2f4093423b86332_Out_2;
                Unity_Multiply_float_float(_Smoothstep_d81123febc5349c78b41d5023455b828_Out_3, _Property_84f7f817f25348a3bec32f2049267d9d_Out_0, _Multiply_288a1c15da154ed2b2f4093423b86332_Out_2);
                float _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1;
                Unity_OneMinus_float(_Multiply_288a1c15da154ed2b2f4093423b86332_Out_2, _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1);
                surface.BaseColor = (_Branch_33ebb3d9ed944f64b6d69749f158256c_Out_3.xyz);
                surface.NormalTS = IN.TangentSpaceNormal;
                surface.Emission = float3(0, 0, 0);
                surface.Metallic = 0;
                surface.Smoothness = 0.5;
                surface.Occlusion = 1;
                surface.Alpha = _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1;
                return surface;
            }

            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                output.ObjectSpaceNormal = input.normalOS;
                output.ObjectSpaceTangent = input.tangentOS.xyz;
                output.ObjectSpacePosition = input.positionOS;

                return output;
            }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

            #ifdef HAVE_VFX_MODIFICATION
                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

            #endif



                // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                float3 unnormalizedNormalWS = input.normalWS;
                const float renormFactor = 1.0 / length(unnormalizedNormalWS);


                output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                output.WorldSpacePosition = input.positionWS;
                output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
                output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                    return output;
            }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif

            ENDHLSL
            }
            Pass
            {
                Name "GBuffer"
                Tags
                {
                    "LightMode" = "UniversalGBuffer"
                }

                // Render State
                Cull Back
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                ZTest LEqual
                ZWrite Off

                // Debug
                // <None>

                // --------------------------------------------------
                // Pass

                HLSLPROGRAM

                // Pragmas
                #pragma target 4.5
                #pragma exclude_renderers gles gles3 glcore
                #pragma multi_compile_instancing
                #pragma multi_compile_fog
                #pragma instancing_options renderinglayer
                #pragma multi_compile _ DOTS_INSTANCING_ON
                #pragma vertex vert
                #pragma fragment frag

                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>

                // Keywords
                #pragma multi_compile _ LIGHTMAP_ON
                #pragma multi_compile _ DYNAMICLIGHTMAP_ON
                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
                #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
                #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
                #pragma multi_compile_fragment _ _SHADOWS_SOFT
                #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
                #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
                #pragma multi_compile _ SHADOWS_SHADOWMASK
                #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
                #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
                #pragma multi_compile_fragment _ _LIGHT_LAYERS
                #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
                #pragma multi_compile_fragment _ DEBUG_DISPLAY
                // GraphKeywords: <None>

                // Defines

                #define _NORMALMAP 1
                #define _NORMAL_DROPOFF_TS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD1
                #define ATTRIBUTES_NEED_TEXCOORD2
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_NORMAL_WS
                #define VARYINGS_NEED_TANGENT_WS
                #define VARYINGS_NEED_VIEWDIRECTION_WS
                #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                #define VARYINGS_NEED_SHADOW_COORD
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_GBUFFER
                #define _FOG_FRAGMENT 1
                #define _SURFACE_TYPE_TRANSPARENT 1
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                // custom interpolator pre-include
                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                // --------------------------------------------------
                // Structs and Packing

                // custom interpolators pre packing
                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                     float4 uv1 : TEXCOORD1;
                     float4 uv2 : TEXCOORD2;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 positionWS;
                     float3 normalWS;
                     float4 tangentWS;
                     float3 viewDirectionWS;
                    #if defined(LIGHTMAP_ON)
                     float2 staticLightmapUV;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                     float2 dynamicLightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                     float3 sh;
                    #endif
                     float4 fogFactorAndVertexLight;
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                     float4 shadowCoord;
                    #endif
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float3 WorldSpaceNormal;
                     float3 TangentSpaceNormal;
                     float3 WorldSpacePosition;
                     float3 AbsoluteWorldSpacePosition;
                     float4 ScreenPosition;
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float3 interp0 : INTERP0;
                     float3 interp1 : INTERP1;
                     float4 interp2 : INTERP2;
                     float3 interp3 : INTERP3;
                     float2 interp4 : INTERP4;
                     float2 interp5 : INTERP5;
                     float3 interp6 : INTERP6;
                     float4 interp7 : INTERP7;
                     float4 interp8 : INTERP8;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };

                PackedVaryings PackVaryings(Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.interp0.xyz = input.positionWS;
                    output.interp1.xyz = input.normalWS;
                    output.interp2.xyzw = input.tangentWS;
                    output.interp3.xyz = input.viewDirectionWS;
                    #if defined(LIGHTMAP_ON)
                    output.interp4.xy = input.staticLightmapUV;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                    output.interp5.xy = input.dynamicLightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.interp6.xyz = input.sh;
                    #endif
                    output.interp7.xyzw = input.fogFactorAndVertexLight;
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    output.interp8.xyzw = input.shadowCoord;
                    #endif
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }

                Varyings UnpackVaryings(PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.normalWS = input.interp1.xyz;
                    output.tangentWS = input.interp2.xyzw;
                    output.viewDirectionWS = input.interp3.xyz;
                    #if defined(LIGHTMAP_ON)
                    output.staticLightmapUV = input.interp4.xy;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                    output.dynamicLightmapUV = input.interp5.xy;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.sh = input.interp6.xyz;
                    #endif
                    output.fogFactorAndVertexLight = input.interp7.xyzw;
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    output.shadowCoord = input.interp8.xyzw;
                    #endif
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }


                // --------------------------------------------------
                // Graph

                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float _size;
                float4 _front_TexelSize;
                float4 _side_TexelSize;
                float _Alpha;
                float _CircleSize;
                float4 _Position;
                float _CircleSmoothnes;
                CBUFFER_END

                    // Object and Global properties
                    SAMPLER(SamplerState_Linear_Repeat);
                    TEXTURE2D(_front);
                    SAMPLER(sampler_front);
                    TEXTURE2D(_side);
                    SAMPLER(sampler_side);

                    // Graph Includes
                    // GraphIncludes: <None>

                    // -- Property used by ScenePickingPass
                    #ifdef SCENEPICKINGPASS
                    float4 _SelectionID;
                    #endif

                    // -- Properties used by SceneSelectionPass
                    #ifdef SCENESELECTIONPASS
                    int _ObjectId;
                    int _PassValue;
                    #endif

                    // Graph Functions

                    void Unity_Absolute_float(float In, out float Out)
                    {
                        Out = abs(In);
                    }

                    void Unity_Comparison_Greater_float(float A, float B, out float Out)
                    {
                        Out = A > B ? 1 : 0;
                    }

                    void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                    {
                        Out = A * B;
                    }

                    void Unity_Rotate_Degrees_float(float2 UV, float2 Center, float Rotation, out float2 Out)
                    {
                        //rotation matrix
                        Rotation = Rotation * (3.1415926f / 180.0f);
                        UV -= Center;
                        float s = sin(Rotation);
                        float c = cos(Rotation);

                        //center rotation matrix
                        float2x2 rMatrix = float2x2(c, -s, s, c);
                        rMatrix *= 0.5;
                        rMatrix += 0.5;
                        rMatrix = rMatrix * 2 - 1;

                        //multiply the UVs by the rotation matrix
                        UV.xy = mul(UV.xy, rMatrix);
                        UV += Center;

                        Out = UV;
                    }

                    void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
                    {
                        Out = Predicate ? True : False;
                    }

                    void Unity_Remap_float4(float4 In, float2 InMinMax, float2 OutMinMax, out float4 Out)
                    {
                        Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                    }

                    void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                    {
                        Out = A + B;
                    }

                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                    {
                        Out = UV * Tiling + Offset;
                    }

                    void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                    {
                        Out = A - B;
                    }

                    void Unity_Divide_float(float A, float B, out float Out)
                    {
                        Out = A / B;
                    }

                    void Unity_Multiply_float_float(float A, float B, out float Out)
                    {
                        Out = A * B;
                    }

                    void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                    {
                        Out = A / B;
                    }

                    void Unity_Length_float2(float2 In, out float Out)
                    {
                        Out = length(In);
                    }

                    void Unity_OneMinus_float(float In, out float Out)
                    {
                        Out = 1 - In;
                    }

                    void Unity_Saturate_float(float In, out float Out)
                    {
                        Out = saturate(In);
                    }

                    void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                    {
                        Out = smoothstep(Edge1, Edge2, In);
                    }

                    // Custom interpolators pre vertex
                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                    // Graph Vertex
                    struct VertexDescription
                    {
                        float3 Position;
                        float3 Normal;
                        float3 Tangent;
                    };

                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                    {
                        VertexDescription description = (VertexDescription)0;
                        description.Position = IN.ObjectSpacePosition;
                        description.Normal = IN.ObjectSpaceNormal;
                        description.Tangent = IN.ObjectSpaceTangent;
                        return description;
                    }

                    // Custom interpolators, pre surface
                    #ifdef FEATURES_GRAPH_VERTEX
                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                    {
                    return output;
                    }
                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                    #endif

                    // Graph Pixel
                    struct SurfaceDescription
                    {
                        float3 BaseColor;
                        float3 NormalTS;
                        float3 Emission;
                        float Metallic;
                        float Smoothness;
                        float Occlusion;
                        float Alpha;
                    };

                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                    {
                        SurfaceDescription surface = (SurfaceDescription)0;
                        float _Split_e3c2fdf12dbc4838a8bd514815889da8_R_1 = IN.WorldSpaceNormal[0];
                        float _Split_e3c2fdf12dbc4838a8bd514815889da8_G_2 = IN.WorldSpaceNormal[1];
                        float _Split_e3c2fdf12dbc4838a8bd514815889da8_B_3 = IN.WorldSpaceNormal[2];
                        float _Split_e3c2fdf12dbc4838a8bd514815889da8_A_4 = 0;
                        float _Absolute_54fb81dd1c194d60b704c9f81498ffc9_Out_1;
                        Unity_Absolute_float(_Split_e3c2fdf12dbc4838a8bd514815889da8_R_1, _Absolute_54fb81dd1c194d60b704c9f81498ffc9_Out_1);
                        float _Comparison_6e7dfe17f5834279863585dd909d6b85_Out_2;
                        Unity_Comparison_Greater_float(_Absolute_54fb81dd1c194d60b704c9f81498ffc9_Out_1, 0.5, _Comparison_6e7dfe17f5834279863585dd909d6b85_Out_2);
                        UnityTexture2D _Property_95f1b87d5b974a7e8e84e0e2062aec06_Out_0 = UnityBuildTexture2DStructNoScale(_side);
                        float _Split_091acb0967a542d5a282773762d4fcea_R_1 = IN.AbsoluteWorldSpacePosition[0];
                        float _Split_091acb0967a542d5a282773762d4fcea_G_2 = IN.AbsoluteWorldSpacePosition[1];
                        float _Split_091acb0967a542d5a282773762d4fcea_B_3 = IN.AbsoluteWorldSpacePosition[2];
                        float _Split_091acb0967a542d5a282773762d4fcea_A_4 = 0;
                        float2 _Vector2_9cb3ee01611c48a1bcef7c9c847c8fa7_Out_0 = float2(_Split_091acb0967a542d5a282773762d4fcea_G_2, _Split_091acb0967a542d5a282773762d4fcea_B_3);
                        float _Property_0ad1939b470a44f8be3e74a775ca3ed3_Out_0 = _size;
                        float _Float_620d3ee1a57d48f98f837d44647977bc_Out_0 = _Property_0ad1939b470a44f8be3e74a775ca3ed3_Out_0;
                        float2 _Multiply_6d7b5b0483d6477385ad7919aa9270ba_Out_2;
                        Unity_Multiply_float2_float2(_Vector2_9cb3ee01611c48a1bcef7c9c847c8fa7_Out_0, (_Float_620d3ee1a57d48f98f837d44647977bc_Out_0.xx), _Multiply_6d7b5b0483d6477385ad7919aa9270ba_Out_2);
                        float2 _Rotate_6bb4154ca8ad4704846be74d0292cc2f_Out_3;
                        Unity_Rotate_Degrees_float(_Multiply_6d7b5b0483d6477385ad7919aa9270ba_Out_2, float2 (0.5, 0.5), -90, _Rotate_6bb4154ca8ad4704846be74d0292cc2f_Out_3);
                        float4 _SampleTexture2D_2fd545645ee448609b600edb51209aaa_RGBA_0 = SAMPLE_TEXTURE2D(_Property_95f1b87d5b974a7e8e84e0e2062aec06_Out_0.tex, _Property_95f1b87d5b974a7e8e84e0e2062aec06_Out_0.samplerstate, _Property_95f1b87d5b974a7e8e84e0e2062aec06_Out_0.GetTransformedUV(_Rotate_6bb4154ca8ad4704846be74d0292cc2f_Out_3));
                        float _SampleTexture2D_2fd545645ee448609b600edb51209aaa_R_4 = _SampleTexture2D_2fd545645ee448609b600edb51209aaa_RGBA_0.r;
                        float _SampleTexture2D_2fd545645ee448609b600edb51209aaa_G_5 = _SampleTexture2D_2fd545645ee448609b600edb51209aaa_RGBA_0.g;
                        float _SampleTexture2D_2fd545645ee448609b600edb51209aaa_B_6 = _SampleTexture2D_2fd545645ee448609b600edb51209aaa_RGBA_0.b;
                        float _SampleTexture2D_2fd545645ee448609b600edb51209aaa_A_7 = _SampleTexture2D_2fd545645ee448609b600edb51209aaa_RGBA_0.a;
                        float _Split_19ff8587983246ac85c970e145e7295e_R_1 = IN.WorldSpaceNormal[0];
                        float _Split_19ff8587983246ac85c970e145e7295e_G_2 = IN.WorldSpaceNormal[1];
                        float _Split_19ff8587983246ac85c970e145e7295e_B_3 = IN.WorldSpaceNormal[2];
                        float _Split_19ff8587983246ac85c970e145e7295e_A_4 = 0;
                        float _Absolute_317391fafaa84374beca803aa565632c_Out_1;
                        Unity_Absolute_float(_Split_19ff8587983246ac85c970e145e7295e_G_2, _Absolute_317391fafaa84374beca803aa565632c_Out_1);
                        float _Comparison_08509dcd8b844663a8b9a254806453e0_Out_2;
                        Unity_Comparison_Greater_float(_Absolute_317391fafaa84374beca803aa565632c_Out_1, 0.5, _Comparison_08509dcd8b844663a8b9a254806453e0_Out_2);
                        UnityTexture2D _Property_d862f312261a47fc87211c138e9e2d65_Out_0 = UnityBuildTexture2DStructNoScale(_side);
                        float _Split_33dfc647fa994b33bac6870687224f37_R_1 = IN.AbsoluteWorldSpacePosition[0];
                        float _Split_33dfc647fa994b33bac6870687224f37_G_2 = IN.AbsoluteWorldSpacePosition[1];
                        float _Split_33dfc647fa994b33bac6870687224f37_B_3 = IN.AbsoluteWorldSpacePosition[2];
                        float _Split_33dfc647fa994b33bac6870687224f37_A_4 = 0;
                        float2 _Vector2_5fb462bf0b6f4a18ac68e33ab02ca2de_Out_0 = float2(_Split_33dfc647fa994b33bac6870687224f37_R_1, _Split_33dfc647fa994b33bac6870687224f37_B_3);
                        float _Property_03059c193ea74dd8b388680b85f07648_Out_0 = _size;
                        float _Float_9d01c34c368948508ad404d5536aca12_Out_0 = _Property_03059c193ea74dd8b388680b85f07648_Out_0;
                        float2 _Multiply_18516a081d504359bcad3aa790750518_Out_2;
                        Unity_Multiply_float2_float2(_Vector2_5fb462bf0b6f4a18ac68e33ab02ca2de_Out_0, (_Float_9d01c34c368948508ad404d5536aca12_Out_0.xx), _Multiply_18516a081d504359bcad3aa790750518_Out_2);
                        float4 _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_RGBA_0 = SAMPLE_TEXTURE2D(_Property_d862f312261a47fc87211c138e9e2d65_Out_0.tex, _Property_d862f312261a47fc87211c138e9e2d65_Out_0.samplerstate, _Property_d862f312261a47fc87211c138e9e2d65_Out_0.GetTransformedUV(_Multiply_18516a081d504359bcad3aa790750518_Out_2));
                        float _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_R_4 = _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_RGBA_0.r;
                        float _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_G_5 = _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_RGBA_0.g;
                        float _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_B_6 = _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_RGBA_0.b;
                        float _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_A_7 = _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_RGBA_0.a;
                        UnityTexture2D _Property_3a54904fa5c74bbeb60261b8a76a189a_Out_0 = UnityBuildTexture2DStructNoScale(_front);
                        float _Split_c79f25e24b934932b5cad363a3977e09_R_1 = IN.AbsoluteWorldSpacePosition[0];
                        float _Split_c79f25e24b934932b5cad363a3977e09_G_2 = IN.AbsoluteWorldSpacePosition[1];
                        float _Split_c79f25e24b934932b5cad363a3977e09_B_3 = IN.AbsoluteWorldSpacePosition[2];
                        float _Split_c79f25e24b934932b5cad363a3977e09_A_4 = 0;
                        float2 _Vector2_8457483515df467abc99f05f2c2f6398_Out_0 = float2(_Split_c79f25e24b934932b5cad363a3977e09_R_1, _Split_c79f25e24b934932b5cad363a3977e09_G_2);
                        float _Property_fc91ea867aa4477485726d431d8da229_Out_0 = _size;
                        float _Float_7e1bc66811ba41edb7a1f6e6df7f1d37_Out_0 = _Property_fc91ea867aa4477485726d431d8da229_Out_0;
                        float2 _Multiply_b8fc0cf2c6414beabf7bce2b9ff68cb8_Out_2;
                        Unity_Multiply_float2_float2(_Vector2_8457483515df467abc99f05f2c2f6398_Out_0, (_Float_7e1bc66811ba41edb7a1f6e6df7f1d37_Out_0.xx), _Multiply_b8fc0cf2c6414beabf7bce2b9ff68cb8_Out_2);
                        float4 _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_RGBA_0 = SAMPLE_TEXTURE2D(_Property_3a54904fa5c74bbeb60261b8a76a189a_Out_0.tex, _Property_3a54904fa5c74bbeb60261b8a76a189a_Out_0.samplerstate, _Property_3a54904fa5c74bbeb60261b8a76a189a_Out_0.GetTransformedUV(_Multiply_b8fc0cf2c6414beabf7bce2b9ff68cb8_Out_2));
                        float _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_R_4 = _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_RGBA_0.r;
                        float _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_G_5 = _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_RGBA_0.g;
                        float _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_B_6 = _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_RGBA_0.b;
                        float _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_A_7 = _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_RGBA_0.a;
                        float4 _Branch_09c1cdaea5f54a1d86615c158f30696f_Out_3;
                        Unity_Branch_float4(_Comparison_08509dcd8b844663a8b9a254806453e0_Out_2, _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_RGBA_0, _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_RGBA_0, _Branch_09c1cdaea5f54a1d86615c158f30696f_Out_3);
                        float4 _Branch_33ebb3d9ed944f64b6d69749f158256c_Out_3;
                        Unity_Branch_float4(_Comparison_6e7dfe17f5834279863585dd909d6b85_Out_2, _SampleTexture2D_2fd545645ee448609b600edb51209aaa_RGBA_0, _Branch_09c1cdaea5f54a1d86615c158f30696f_Out_3, _Branch_33ebb3d9ed944f64b6d69749f158256c_Out_3);
                        float _Property_94721ec2508f4046b88413c6bd4e982e_Out_0 = _CircleSmoothnes;
                        float4 _ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                        float4 _Property_fd84b0cc463c44558e196f2b6699bb15_Out_0 = _Position;
                        float4 _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3;
                        Unity_Remap_float4(_Property_fd84b0cc463c44558e196f2b6699bb15_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3);
                        float4 _Add_4b02f63dcd7e45e188328b812f76fa99_Out_2;
                        Unity_Add_float4(_ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0, _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3, _Add_4b02f63dcd7e45e188328b812f76fa99_Out_2);
                        float2 _TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3;
                        Unity_TilingAndOffset_float((_ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0.xy), float2 (1, 1), (_Add_4b02f63dcd7e45e188328b812f76fa99_Out_2.xy), _TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3);
                        float2 _Multiply_177cb9485e70424c8b113020b5fa561e_Out_2;
                        Unity_Multiply_float2_float2(_TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3, float2(2, 2), _Multiply_177cb9485e70424c8b113020b5fa561e_Out_2);
                        float2 _Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2;
                        Unity_Subtract_float2(_Multiply_177cb9485e70424c8b113020b5fa561e_Out_2, float2(1, 1), _Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2);
                        float _Divide_0183d4739fe2443987608ab3169a13d9_Out_2;
                        Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_0183d4739fe2443987608ab3169a13d9_Out_2);
                        float _Property_817685bafbc74ff594205cd2bbec6848_Out_0 = _CircleSize;
                        float _Multiply_3046c926d1e34dce9c8963423a59249d_Out_2;
                        Unity_Multiply_float_float(_Divide_0183d4739fe2443987608ab3169a13d9_Out_2, _Property_817685bafbc74ff594205cd2bbec6848_Out_0, _Multiply_3046c926d1e34dce9c8963423a59249d_Out_2);
                        float2 _Vector2_fea5299f99e247c4ade509c5e8082e2d_Out_0 = float2(_Multiply_3046c926d1e34dce9c8963423a59249d_Out_2, _Property_817685bafbc74ff594205cd2bbec6848_Out_0);
                        float2 _Divide_15271b15b3774cec9b09b48583a269d4_Out_2;
                        Unity_Divide_float2(_Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2, _Vector2_fea5299f99e247c4ade509c5e8082e2d_Out_0, _Divide_15271b15b3774cec9b09b48583a269d4_Out_2);
                        float _Length_8cc50efaa80e489482f7f21fa7901007_Out_1;
                        Unity_Length_float2(_Divide_15271b15b3774cec9b09b48583a269d4_Out_2, _Length_8cc50efaa80e489482f7f21fa7901007_Out_1);
                        float _OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1;
                        Unity_OneMinus_float(_Length_8cc50efaa80e489482f7f21fa7901007_Out_1, _OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1);
                        float _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1;
                        Unity_Saturate_float(_OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1, _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1);
                        float _Smoothstep_d81123febc5349c78b41d5023455b828_Out_3;
                        Unity_Smoothstep_float(0, _Property_94721ec2508f4046b88413c6bd4e982e_Out_0, _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1, _Smoothstep_d81123febc5349c78b41d5023455b828_Out_3);
                        float _Property_84f7f817f25348a3bec32f2049267d9d_Out_0 = _Alpha;
                        float _Multiply_288a1c15da154ed2b2f4093423b86332_Out_2;
                        Unity_Multiply_float_float(_Smoothstep_d81123febc5349c78b41d5023455b828_Out_3, _Property_84f7f817f25348a3bec32f2049267d9d_Out_0, _Multiply_288a1c15da154ed2b2f4093423b86332_Out_2);
                        float _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1;
                        Unity_OneMinus_float(_Multiply_288a1c15da154ed2b2f4093423b86332_Out_2, _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1);
                        surface.BaseColor = (_Branch_33ebb3d9ed944f64b6d69749f158256c_Out_3.xyz);
                        surface.NormalTS = IN.TangentSpaceNormal;
                        surface.Emission = float3(0, 0, 0);
                        surface.Metallic = 0;
                        surface.Smoothness = 0.5;
                        surface.Occlusion = 1;
                        surface.Alpha = _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1;
                        return surface;
                    }

                    // --------------------------------------------------
                    // Build Graph Inputs
                    #ifdef HAVE_VFX_MODIFICATION
                    #define VFX_SRP_ATTRIBUTES Attributes
                    #define VFX_SRP_VARYINGS Varyings
                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                    #endif
                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                    {
                        VertexDescriptionInputs output;
                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                        output.ObjectSpaceNormal = input.normalOS;
                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                        output.ObjectSpacePosition = input.positionOS;

                        return output;
                    }
                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                    {
                        SurfaceDescriptionInputs output;
                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                    #ifdef HAVE_VFX_MODIFICATION
                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                    #endif



                        // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                        float3 unnormalizedNormalWS = input.normalWS;
                        const float renormFactor = 1.0 / length(unnormalizedNormalWS);


                        output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
                        output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                        output.WorldSpacePosition = input.positionWS;
                        output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
                        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                    #else
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                    #endif
                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                            return output;
                    }

                    // --------------------------------------------------
                    // Main

                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"

                    // --------------------------------------------------
                    // Visual Effect Vertex Invocations
                    #ifdef HAVE_VFX_MODIFICATION
                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                    #endif

                    ENDHLSL
                    }
                    Pass
                    {
                        Name "ShadowCaster"
                        Tags
                        {
                            "LightMode" = "ShadowCaster"
                        }

                        // Render State
                        Cull Back
                        ZTest LEqual
                        ZWrite On
                        ColorMask 0

                        // Debug
                        // <None>

                        // --------------------------------------------------
                        // Pass

                        HLSLPROGRAM

                        // Pragmas
                        #pragma target 4.5
                        #pragma exclude_renderers gles gles3 glcore
                        #pragma multi_compile_instancing
                        #pragma multi_compile _ DOTS_INSTANCING_ON
                        #pragma vertex vert
                        #pragma fragment frag

                        // DotsInstancingOptions: <None>
                        // HybridV1InjectedBuiltinProperties: <None>

                        // Keywords
                        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
                        // GraphKeywords: <None>

                        // Defines

                        #define _NORMALMAP 1
                        #define _NORMAL_DROPOFF_TS 1
                        #define ATTRIBUTES_NEED_NORMAL
                        #define ATTRIBUTES_NEED_TANGENT
                        #define VARYINGS_NEED_POSITION_WS
                        #define VARYINGS_NEED_NORMAL_WS
                        #define FEATURES_GRAPH_VERTEX
                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                        #define SHADERPASS SHADERPASS_SHADOWCASTER
                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                        // custom interpolator pre-include
                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                        // Includes
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                        // --------------------------------------------------
                        // Structs and Packing

                        // custom interpolators pre packing
                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                        struct Attributes
                        {
                             float3 positionOS : POSITION;
                             float3 normalOS : NORMAL;
                             float4 tangentOS : TANGENT;
                            #if UNITY_ANY_INSTANCING_ENABLED
                             uint instanceID : INSTANCEID_SEMANTIC;
                            #endif
                        };
                        struct Varyings
                        {
                             float4 positionCS : SV_POSITION;
                             float3 positionWS;
                             float3 normalWS;
                            #if UNITY_ANY_INSTANCING_ENABLED
                             uint instanceID : CUSTOM_INSTANCE_ID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                            #endif
                        };
                        struct SurfaceDescriptionInputs
                        {
                             float3 WorldSpacePosition;
                             float4 ScreenPosition;
                        };
                        struct VertexDescriptionInputs
                        {
                             float3 ObjectSpaceNormal;
                             float3 ObjectSpaceTangent;
                             float3 ObjectSpacePosition;
                        };
                        struct PackedVaryings
                        {
                             float4 positionCS : SV_POSITION;
                             float3 interp0 : INTERP0;
                             float3 interp1 : INTERP1;
                            #if UNITY_ANY_INSTANCING_ENABLED
                             uint instanceID : CUSTOM_INSTANCE_ID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                            #endif
                        };

                        PackedVaryings PackVaryings(Varyings input)
                        {
                            PackedVaryings output;
                            ZERO_INITIALIZE(PackedVaryings, output);
                            output.positionCS = input.positionCS;
                            output.interp0.xyz = input.positionWS;
                            output.interp1.xyz = input.normalWS;
                            #if UNITY_ANY_INSTANCING_ENABLED
                            output.instanceID = input.instanceID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            output.cullFace = input.cullFace;
                            #endif
                            return output;
                        }

                        Varyings UnpackVaryings(PackedVaryings input)
                        {
                            Varyings output;
                            output.positionCS = input.positionCS;
                            output.positionWS = input.interp0.xyz;
                            output.normalWS = input.interp1.xyz;
                            #if UNITY_ANY_INSTANCING_ENABLED
                            output.instanceID = input.instanceID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            output.cullFace = input.cullFace;
                            #endif
                            return output;
                        }


                        // --------------------------------------------------
                        // Graph

                        // Graph Properties
                        CBUFFER_START(UnityPerMaterial)
                        float _size;
                        float4 _front_TexelSize;
                        float4 _side_TexelSize;
                        float _Alpha;
                        float _CircleSize;
                        float4 _Position;
                        float _CircleSmoothnes;
                        CBUFFER_END

                            // Object and Global properties
                            SAMPLER(SamplerState_Linear_Repeat);
                            TEXTURE2D(_front);
                            SAMPLER(sampler_front);
                            TEXTURE2D(_side);
                            SAMPLER(sampler_side);

                            // Graph Includes
                            // GraphIncludes: <None>

                            // -- Property used by ScenePickingPass
                            #ifdef SCENEPICKINGPASS
                            float4 _SelectionID;
                            #endif

                            // -- Properties used by SceneSelectionPass
                            #ifdef SCENESELECTIONPASS
                            int _ObjectId;
                            int _PassValue;
                            #endif

                            // Graph Functions

                            void Unity_Remap_float4(float4 In, float2 InMinMax, float2 OutMinMax, out float4 Out)
                            {
                                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                            }

                            void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                            {
                                Out = A + B;
                            }

                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                            {
                                Out = UV * Tiling + Offset;
                            }

                            void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                            {
                                Out = A * B;
                            }

                            void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                            {
                                Out = A - B;
                            }

                            void Unity_Divide_float(float A, float B, out float Out)
                            {
                                Out = A / B;
                            }

                            void Unity_Multiply_float_float(float A, float B, out float Out)
                            {
                                Out = A * B;
                            }

                            void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                            {
                                Out = A / B;
                            }

                            void Unity_Length_float2(float2 In, out float Out)
                            {
                                Out = length(In);
                            }

                            void Unity_OneMinus_float(float In, out float Out)
                            {
                                Out = 1 - In;
                            }

                            void Unity_Saturate_float(float In, out float Out)
                            {
                                Out = saturate(In);
                            }

                            void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                            {
                                Out = smoothstep(Edge1, Edge2, In);
                            }

                            // Custom interpolators pre vertex
                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                            // Graph Vertex
                            struct VertexDescription
                            {
                                float3 Position;
                                float3 Normal;
                                float3 Tangent;
                            };

                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                            {
                                VertexDescription description = (VertexDescription)0;
                                description.Position = IN.ObjectSpacePosition;
                                description.Normal = IN.ObjectSpaceNormal;
                                description.Tangent = IN.ObjectSpaceTangent;
                                return description;
                            }

                            // Custom interpolators, pre surface
                            #ifdef FEATURES_GRAPH_VERTEX
                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                            {
                            return output;
                            }
                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                            #endif

                            // Graph Pixel
                            struct SurfaceDescription
                            {
                                float Alpha;
                            };

                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                            {
                                SurfaceDescription surface = (SurfaceDescription)0;
                                float _Property_94721ec2508f4046b88413c6bd4e982e_Out_0 = _CircleSmoothnes;
                                float4 _ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                float4 _Property_fd84b0cc463c44558e196f2b6699bb15_Out_0 = _Position;
                                float4 _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3;
                                Unity_Remap_float4(_Property_fd84b0cc463c44558e196f2b6699bb15_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3);
                                float4 _Add_4b02f63dcd7e45e188328b812f76fa99_Out_2;
                                Unity_Add_float4(_ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0, _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3, _Add_4b02f63dcd7e45e188328b812f76fa99_Out_2);
                                float2 _TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3;
                                Unity_TilingAndOffset_float((_ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0.xy), float2 (1, 1), (_Add_4b02f63dcd7e45e188328b812f76fa99_Out_2.xy), _TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3);
                                float2 _Multiply_177cb9485e70424c8b113020b5fa561e_Out_2;
                                Unity_Multiply_float2_float2(_TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3, float2(2, 2), _Multiply_177cb9485e70424c8b113020b5fa561e_Out_2);
                                float2 _Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2;
                                Unity_Subtract_float2(_Multiply_177cb9485e70424c8b113020b5fa561e_Out_2, float2(1, 1), _Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2);
                                float _Divide_0183d4739fe2443987608ab3169a13d9_Out_2;
                                Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_0183d4739fe2443987608ab3169a13d9_Out_2);
                                float _Property_817685bafbc74ff594205cd2bbec6848_Out_0 = _CircleSize;
                                float _Multiply_3046c926d1e34dce9c8963423a59249d_Out_2;
                                Unity_Multiply_float_float(_Divide_0183d4739fe2443987608ab3169a13d9_Out_2, _Property_817685bafbc74ff594205cd2bbec6848_Out_0, _Multiply_3046c926d1e34dce9c8963423a59249d_Out_2);
                                float2 _Vector2_fea5299f99e247c4ade509c5e8082e2d_Out_0 = float2(_Multiply_3046c926d1e34dce9c8963423a59249d_Out_2, _Property_817685bafbc74ff594205cd2bbec6848_Out_0);
                                float2 _Divide_15271b15b3774cec9b09b48583a269d4_Out_2;
                                Unity_Divide_float2(_Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2, _Vector2_fea5299f99e247c4ade509c5e8082e2d_Out_0, _Divide_15271b15b3774cec9b09b48583a269d4_Out_2);
                                float _Length_8cc50efaa80e489482f7f21fa7901007_Out_1;
                                Unity_Length_float2(_Divide_15271b15b3774cec9b09b48583a269d4_Out_2, _Length_8cc50efaa80e489482f7f21fa7901007_Out_1);
                                float _OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1;
                                Unity_OneMinus_float(_Length_8cc50efaa80e489482f7f21fa7901007_Out_1, _OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1);
                                float _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1;
                                Unity_Saturate_float(_OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1, _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1);
                                float _Smoothstep_d81123febc5349c78b41d5023455b828_Out_3;
                                Unity_Smoothstep_float(0, _Property_94721ec2508f4046b88413c6bd4e982e_Out_0, _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1, _Smoothstep_d81123febc5349c78b41d5023455b828_Out_3);
                                float _Property_84f7f817f25348a3bec32f2049267d9d_Out_0 = _Alpha;
                                float _Multiply_288a1c15da154ed2b2f4093423b86332_Out_2;
                                Unity_Multiply_float_float(_Smoothstep_d81123febc5349c78b41d5023455b828_Out_3, _Property_84f7f817f25348a3bec32f2049267d9d_Out_0, _Multiply_288a1c15da154ed2b2f4093423b86332_Out_2);
                                float _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1;
                                Unity_OneMinus_float(_Multiply_288a1c15da154ed2b2f4093423b86332_Out_2, _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1);
                                surface.Alpha = _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1;
                                return surface;
                            }

                            // --------------------------------------------------
                            // Build Graph Inputs
                            #ifdef HAVE_VFX_MODIFICATION
                            #define VFX_SRP_ATTRIBUTES Attributes
                            #define VFX_SRP_VARYINGS Varyings
                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                            #endif
                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                            {
                                VertexDescriptionInputs output;
                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                output.ObjectSpaceNormal = input.normalOS;
                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                output.ObjectSpacePosition = input.positionOS;

                                return output;
                            }
                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                            {
                                SurfaceDescriptionInputs output;
                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                            #ifdef HAVE_VFX_MODIFICATION
                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                            #endif







                                output.WorldSpacePosition = input.positionWS;
                                output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                            #else
                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                            #endif
                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                    return output;
                            }

                            // --------------------------------------------------
                            // Main

                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

                            // --------------------------------------------------
                            // Visual Effect Vertex Invocations
                            #ifdef HAVE_VFX_MODIFICATION
                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                            #endif

                            ENDHLSL
                            }
                            Pass
                            {
                                Name "DepthNormals"
                                Tags
                                {
                                    "LightMode" = "DepthNormals"
                                }

                                // Render State
                                Cull Back
                                ZTest LEqual
                                ZWrite On

                                // Debug
                                // <None>

                                // --------------------------------------------------
                                // Pass

                                HLSLPROGRAM

                                // Pragmas
                                #pragma target 4.5
                                #pragma exclude_renderers gles gles3 glcore
                                #pragma multi_compile_instancing
                                #pragma multi_compile _ DOTS_INSTANCING_ON
                                #pragma vertex vert
                                #pragma fragment frag

                                // DotsInstancingOptions: <None>
                                // HybridV1InjectedBuiltinProperties: <None>

                                // Keywords
                                // PassKeywords: <None>
                                // GraphKeywords: <None>

                                // Defines

                                #define _NORMALMAP 1
                                #define _NORMAL_DROPOFF_TS 1
                                #define ATTRIBUTES_NEED_NORMAL
                                #define ATTRIBUTES_NEED_TANGENT
                                #define ATTRIBUTES_NEED_TEXCOORD1
                                #define VARYINGS_NEED_POSITION_WS
                                #define VARYINGS_NEED_NORMAL_WS
                                #define VARYINGS_NEED_TANGENT_WS
                                #define FEATURES_GRAPH_VERTEX
                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                #define SHADERPASS SHADERPASS_DEPTHNORMALS
                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                // custom interpolator pre-include
                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                // Includes
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                // --------------------------------------------------
                                // Structs and Packing

                                // custom interpolators pre packing
                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                struct Attributes
                                {
                                     float3 positionOS : POSITION;
                                     float3 normalOS : NORMAL;
                                     float4 tangentOS : TANGENT;
                                     float4 uv1 : TEXCOORD1;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : INSTANCEID_SEMANTIC;
                                    #endif
                                };
                                struct Varyings
                                {
                                     float4 positionCS : SV_POSITION;
                                     float3 positionWS;
                                     float3 normalWS;
                                     float4 tangentWS;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                    #endif
                                };
                                struct SurfaceDescriptionInputs
                                {
                                     float3 TangentSpaceNormal;
                                     float3 WorldSpacePosition;
                                     float4 ScreenPosition;
                                };
                                struct VertexDescriptionInputs
                                {
                                     float3 ObjectSpaceNormal;
                                     float3 ObjectSpaceTangent;
                                     float3 ObjectSpacePosition;
                                };
                                struct PackedVaryings
                                {
                                     float4 positionCS : SV_POSITION;
                                     float3 interp0 : INTERP0;
                                     float3 interp1 : INTERP1;
                                     float4 interp2 : INTERP2;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                    #endif
                                };

                                PackedVaryings PackVaryings(Varyings input)
                                {
                                    PackedVaryings output;
                                    ZERO_INITIALIZE(PackedVaryings, output);
                                    output.positionCS = input.positionCS;
                                    output.interp0.xyz = input.positionWS;
                                    output.interp1.xyz = input.normalWS;
                                    output.interp2.xyzw = input.tangentWS;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    output.instanceID = input.instanceID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    output.cullFace = input.cullFace;
                                    #endif
                                    return output;
                                }

                                Varyings UnpackVaryings(PackedVaryings input)
                                {
                                    Varyings output;
                                    output.positionCS = input.positionCS;
                                    output.positionWS = input.interp0.xyz;
                                    output.normalWS = input.interp1.xyz;
                                    output.tangentWS = input.interp2.xyzw;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    output.instanceID = input.instanceID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    output.cullFace = input.cullFace;
                                    #endif
                                    return output;
                                }


                                // --------------------------------------------------
                                // Graph

                                // Graph Properties
                                CBUFFER_START(UnityPerMaterial)
                                float _size;
                                float4 _front_TexelSize;
                                float4 _side_TexelSize;
                                float _Alpha;
                                float _CircleSize;
                                float4 _Position;
                                float _CircleSmoothnes;
                                CBUFFER_END

                                    // Object and Global properties
                                    SAMPLER(SamplerState_Linear_Repeat);
                                    TEXTURE2D(_front);
                                    SAMPLER(sampler_front);
                                    TEXTURE2D(_side);
                                    SAMPLER(sampler_side);

                                    // Graph Includes
                                    // GraphIncludes: <None>

                                    // -- Property used by ScenePickingPass
                                    #ifdef SCENEPICKINGPASS
                                    float4 _SelectionID;
                                    #endif

                                    // -- Properties used by SceneSelectionPass
                                    #ifdef SCENESELECTIONPASS
                                    int _ObjectId;
                                    int _PassValue;
                                    #endif

                                    // Graph Functions

                                    void Unity_Remap_float4(float4 In, float2 InMinMax, float2 OutMinMax, out float4 Out)
                                    {
                                        Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                    }

                                    void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                    {
                                        Out = A + B;
                                    }

                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                    {
                                        Out = UV * Tiling + Offset;
                                    }

                                    void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                    {
                                        Out = A * B;
                                    }

                                    void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                    {
                                        Out = A - B;
                                    }

                                    void Unity_Divide_float(float A, float B, out float Out)
                                    {
                                        Out = A / B;
                                    }

                                    void Unity_Multiply_float_float(float A, float B, out float Out)
                                    {
                                        Out = A * B;
                                    }

                                    void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                    {
                                        Out = A / B;
                                    }

                                    void Unity_Length_float2(float2 In, out float Out)
                                    {
                                        Out = length(In);
                                    }

                                    void Unity_OneMinus_float(float In, out float Out)
                                    {
                                        Out = 1 - In;
                                    }

                                    void Unity_Saturate_float(float In, out float Out)
                                    {
                                        Out = saturate(In);
                                    }

                                    void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                    {
                                        Out = smoothstep(Edge1, Edge2, In);
                                    }

                                    // Custom interpolators pre vertex
                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                    // Graph Vertex
                                    struct VertexDescription
                                    {
                                        float3 Position;
                                        float3 Normal;
                                        float3 Tangent;
                                    };

                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                    {
                                        VertexDescription description = (VertexDescription)0;
                                        description.Position = IN.ObjectSpacePosition;
                                        description.Normal = IN.ObjectSpaceNormal;
                                        description.Tangent = IN.ObjectSpaceTangent;
                                        return description;
                                    }

                                    // Custom interpolators, pre surface
                                    #ifdef FEATURES_GRAPH_VERTEX
                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                    {
                                    return output;
                                    }
                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                    #endif

                                    // Graph Pixel
                                    struct SurfaceDescription
                                    {
                                        float3 NormalTS;
                                        float Alpha;
                                    };

                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                    {
                                        SurfaceDescription surface = (SurfaceDescription)0;
                                        float _Property_94721ec2508f4046b88413c6bd4e982e_Out_0 = _CircleSmoothnes;
                                        float4 _ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                        float4 _Property_fd84b0cc463c44558e196f2b6699bb15_Out_0 = _Position;
                                        float4 _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3;
                                        Unity_Remap_float4(_Property_fd84b0cc463c44558e196f2b6699bb15_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3);
                                        float4 _Add_4b02f63dcd7e45e188328b812f76fa99_Out_2;
                                        Unity_Add_float4(_ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0, _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3, _Add_4b02f63dcd7e45e188328b812f76fa99_Out_2);
                                        float2 _TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3;
                                        Unity_TilingAndOffset_float((_ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0.xy), float2 (1, 1), (_Add_4b02f63dcd7e45e188328b812f76fa99_Out_2.xy), _TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3);
                                        float2 _Multiply_177cb9485e70424c8b113020b5fa561e_Out_2;
                                        Unity_Multiply_float2_float2(_TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3, float2(2, 2), _Multiply_177cb9485e70424c8b113020b5fa561e_Out_2);
                                        float2 _Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2;
                                        Unity_Subtract_float2(_Multiply_177cb9485e70424c8b113020b5fa561e_Out_2, float2(1, 1), _Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2);
                                        float _Divide_0183d4739fe2443987608ab3169a13d9_Out_2;
                                        Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_0183d4739fe2443987608ab3169a13d9_Out_2);
                                        float _Property_817685bafbc74ff594205cd2bbec6848_Out_0 = _CircleSize;
                                        float _Multiply_3046c926d1e34dce9c8963423a59249d_Out_2;
                                        Unity_Multiply_float_float(_Divide_0183d4739fe2443987608ab3169a13d9_Out_2, _Property_817685bafbc74ff594205cd2bbec6848_Out_0, _Multiply_3046c926d1e34dce9c8963423a59249d_Out_2);
                                        float2 _Vector2_fea5299f99e247c4ade509c5e8082e2d_Out_0 = float2(_Multiply_3046c926d1e34dce9c8963423a59249d_Out_2, _Property_817685bafbc74ff594205cd2bbec6848_Out_0);
                                        float2 _Divide_15271b15b3774cec9b09b48583a269d4_Out_2;
                                        Unity_Divide_float2(_Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2, _Vector2_fea5299f99e247c4ade509c5e8082e2d_Out_0, _Divide_15271b15b3774cec9b09b48583a269d4_Out_2);
                                        float _Length_8cc50efaa80e489482f7f21fa7901007_Out_1;
                                        Unity_Length_float2(_Divide_15271b15b3774cec9b09b48583a269d4_Out_2, _Length_8cc50efaa80e489482f7f21fa7901007_Out_1);
                                        float _OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1;
                                        Unity_OneMinus_float(_Length_8cc50efaa80e489482f7f21fa7901007_Out_1, _OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1);
                                        float _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1;
                                        Unity_Saturate_float(_OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1, _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1);
                                        float _Smoothstep_d81123febc5349c78b41d5023455b828_Out_3;
                                        Unity_Smoothstep_float(0, _Property_94721ec2508f4046b88413c6bd4e982e_Out_0, _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1, _Smoothstep_d81123febc5349c78b41d5023455b828_Out_3);
                                        float _Property_84f7f817f25348a3bec32f2049267d9d_Out_0 = _Alpha;
                                        float _Multiply_288a1c15da154ed2b2f4093423b86332_Out_2;
                                        Unity_Multiply_float_float(_Smoothstep_d81123febc5349c78b41d5023455b828_Out_3, _Property_84f7f817f25348a3bec32f2049267d9d_Out_0, _Multiply_288a1c15da154ed2b2f4093423b86332_Out_2);
                                        float _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1;
                                        Unity_OneMinus_float(_Multiply_288a1c15da154ed2b2f4093423b86332_Out_2, _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1);
                                        surface.NormalTS = IN.TangentSpaceNormal;
                                        surface.Alpha = _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1;
                                        return surface;
                                    }

                                    // --------------------------------------------------
                                    // Build Graph Inputs
                                    #ifdef HAVE_VFX_MODIFICATION
                                    #define VFX_SRP_ATTRIBUTES Attributes
                                    #define VFX_SRP_VARYINGS Varyings
                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                    #endif
                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                    {
                                        VertexDescriptionInputs output;
                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                        output.ObjectSpaceNormal = input.normalOS;
                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                        output.ObjectSpacePosition = input.positionOS;

                                        return output;
                                    }
                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                    {
                                        SurfaceDescriptionInputs output;
                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                    #ifdef HAVE_VFX_MODIFICATION
                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                    #endif





                                        output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                                        output.WorldSpacePosition = input.positionWS;
                                        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                    #else
                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                    #endif
                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                            return output;
                                    }

                                    // --------------------------------------------------
                                    // Main

                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

                                    // --------------------------------------------------
                                    // Visual Effect Vertex Invocations
                                    #ifdef HAVE_VFX_MODIFICATION
                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                    #endif

                                    ENDHLSL
                                    }
                                    Pass
                                    {
                                        Name "Meta"
                                        Tags
                                        {
                                            "LightMode" = "Meta"
                                        }

                                        // Render State
                                        Cull Off

                                        // Debug
                                        // <None>

                                        // --------------------------------------------------
                                        // Pass

                                        HLSLPROGRAM

                                        // Pragmas
                                        #pragma target 4.5
                                        #pragma exclude_renderers gles gles3 glcore
                                        #pragma vertex vert
                                        #pragma fragment frag

                                        // DotsInstancingOptions: <None>
                                        // HybridV1InjectedBuiltinProperties: <None>

                                        // Keywords
                                        #pragma shader_feature _ EDITOR_VISUALIZATION
                                        // GraphKeywords: <None>

                                        // Defines

                                        #define _NORMALMAP 1
                                        #define _NORMAL_DROPOFF_TS 1
                                        #define ATTRIBUTES_NEED_NORMAL
                                        #define ATTRIBUTES_NEED_TANGENT
                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                        #define ATTRIBUTES_NEED_TEXCOORD1
                                        #define ATTRIBUTES_NEED_TEXCOORD2
                                        #define VARYINGS_NEED_POSITION_WS
                                        #define VARYINGS_NEED_NORMAL_WS
                                        #define VARYINGS_NEED_TEXCOORD0
                                        #define VARYINGS_NEED_TEXCOORD1
                                        #define VARYINGS_NEED_TEXCOORD2
                                        #define FEATURES_GRAPH_VERTEX
                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                        #define SHADERPASS SHADERPASS_META
                                        #define _FOG_FRAGMENT 1
                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                        // custom interpolator pre-include
                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                        // Includes
                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                        // --------------------------------------------------
                                        // Structs and Packing

                                        // custom interpolators pre packing
                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                        struct Attributes
                                        {
                                             float3 positionOS : POSITION;
                                             float3 normalOS : NORMAL;
                                             float4 tangentOS : TANGENT;
                                             float4 uv0 : TEXCOORD0;
                                             float4 uv1 : TEXCOORD1;
                                             float4 uv2 : TEXCOORD2;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                             uint instanceID : INSTANCEID_SEMANTIC;
                                            #endif
                                        };
                                        struct Varyings
                                        {
                                             float4 positionCS : SV_POSITION;
                                             float3 positionWS;
                                             float3 normalWS;
                                             float4 texCoord0;
                                             float4 texCoord1;
                                             float4 texCoord2;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                            #endif
                                        };
                                        struct SurfaceDescriptionInputs
                                        {
                                             float3 WorldSpaceNormal;
                                             float3 WorldSpacePosition;
                                             float3 AbsoluteWorldSpacePosition;
                                             float4 ScreenPosition;
                                        };
                                        struct VertexDescriptionInputs
                                        {
                                             float3 ObjectSpaceNormal;
                                             float3 ObjectSpaceTangent;
                                             float3 ObjectSpacePosition;
                                        };
                                        struct PackedVaryings
                                        {
                                             float4 positionCS : SV_POSITION;
                                             float3 interp0 : INTERP0;
                                             float3 interp1 : INTERP1;
                                             float4 interp2 : INTERP2;
                                             float4 interp3 : INTERP3;
                                             float4 interp4 : INTERP4;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                            #endif
                                        };

                                        PackedVaryings PackVaryings(Varyings input)
                                        {
                                            PackedVaryings output;
                                            ZERO_INITIALIZE(PackedVaryings, output);
                                            output.positionCS = input.positionCS;
                                            output.interp0.xyz = input.positionWS;
                                            output.interp1.xyz = input.normalWS;
                                            output.interp2.xyzw = input.texCoord0;
                                            output.interp3.xyzw = input.texCoord1;
                                            output.interp4.xyzw = input.texCoord2;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                            output.instanceID = input.instanceID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                            output.cullFace = input.cullFace;
                                            #endif
                                            return output;
                                        }

                                        Varyings UnpackVaryings(PackedVaryings input)
                                        {
                                            Varyings output;
                                            output.positionCS = input.positionCS;
                                            output.positionWS = input.interp0.xyz;
                                            output.normalWS = input.interp1.xyz;
                                            output.texCoord0 = input.interp2.xyzw;
                                            output.texCoord1 = input.interp3.xyzw;
                                            output.texCoord2 = input.interp4.xyzw;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                            output.instanceID = input.instanceID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                            output.cullFace = input.cullFace;
                                            #endif
                                            return output;
                                        }


                                        // --------------------------------------------------
                                        // Graph

                                        // Graph Properties
                                        CBUFFER_START(UnityPerMaterial)
                                        float _size;
                                        float4 _front_TexelSize;
                                        float4 _side_TexelSize;
                                        float _Alpha;
                                        float _CircleSize;
                                        float4 _Position;
                                        float _CircleSmoothnes;
                                        CBUFFER_END

                                            // Object and Global properties
                                            SAMPLER(SamplerState_Linear_Repeat);
                                            TEXTURE2D(_front);
                                            SAMPLER(sampler_front);
                                            TEXTURE2D(_side);
                                            SAMPLER(sampler_side);

                                            // Graph Includes
                                            // GraphIncludes: <None>

                                            // -- Property used by ScenePickingPass
                                            #ifdef SCENEPICKINGPASS
                                            float4 _SelectionID;
                                            #endif

                                            // -- Properties used by SceneSelectionPass
                                            #ifdef SCENESELECTIONPASS
                                            int _ObjectId;
                                            int _PassValue;
                                            #endif

                                            // Graph Functions

                                            void Unity_Absolute_float(float In, out float Out)
                                            {
                                                Out = abs(In);
                                            }

                                            void Unity_Comparison_Greater_float(float A, float B, out float Out)
                                            {
                                                Out = A > B ? 1 : 0;
                                            }

                                            void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                            {
                                                Out = A * B;
                                            }

                                            void Unity_Rotate_Degrees_float(float2 UV, float2 Center, float Rotation, out float2 Out)
                                            {
                                                //rotation matrix
                                                Rotation = Rotation * (3.1415926f / 180.0f);
                                                UV -= Center;
                                                float s = sin(Rotation);
                                                float c = cos(Rotation);

                                                //center rotation matrix
                                                float2x2 rMatrix = float2x2(c, -s, s, c);
                                                rMatrix *= 0.5;
                                                rMatrix += 0.5;
                                                rMatrix = rMatrix * 2 - 1;

                                                //multiply the UVs by the rotation matrix
                                                UV.xy = mul(UV.xy, rMatrix);
                                                UV += Center;

                                                Out = UV;
                                            }

                                            void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
                                            {
                                                Out = Predicate ? True : False;
                                            }

                                            void Unity_Remap_float4(float4 In, float2 InMinMax, float2 OutMinMax, out float4 Out)
                                            {
                                                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                            }

                                            void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                            {
                                                Out = A + B;
                                            }

                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                            {
                                                Out = UV * Tiling + Offset;
                                            }

                                            void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                            {
                                                Out = A - B;
                                            }

                                            void Unity_Divide_float(float A, float B, out float Out)
                                            {
                                                Out = A / B;
                                            }

                                            void Unity_Multiply_float_float(float A, float B, out float Out)
                                            {
                                                Out = A * B;
                                            }

                                            void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                            {
                                                Out = A / B;
                                            }

                                            void Unity_Length_float2(float2 In, out float Out)
                                            {
                                                Out = length(In);
                                            }

                                            void Unity_OneMinus_float(float In, out float Out)
                                            {
                                                Out = 1 - In;
                                            }

                                            void Unity_Saturate_float(float In, out float Out)
                                            {
                                                Out = saturate(In);
                                            }

                                            void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                            {
                                                Out = smoothstep(Edge1, Edge2, In);
                                            }

                                            // Custom interpolators pre vertex
                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                            // Graph Vertex
                                            struct VertexDescription
                                            {
                                                float3 Position;
                                                float3 Normal;
                                                float3 Tangent;
                                            };

                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                            {
                                                VertexDescription description = (VertexDescription)0;
                                                description.Position = IN.ObjectSpacePosition;
                                                description.Normal = IN.ObjectSpaceNormal;
                                                description.Tangent = IN.ObjectSpaceTangent;
                                                return description;
                                            }

                                            // Custom interpolators, pre surface
                                            #ifdef FEATURES_GRAPH_VERTEX
                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                            {
                                            return output;
                                            }
                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                            #endif

                                            // Graph Pixel
                                            struct SurfaceDescription
                                            {
                                                float3 BaseColor;
                                                float3 Emission;
                                                float Alpha;
                                            };

                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                            {
                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                float _Split_e3c2fdf12dbc4838a8bd514815889da8_R_1 = IN.WorldSpaceNormal[0];
                                                float _Split_e3c2fdf12dbc4838a8bd514815889da8_G_2 = IN.WorldSpaceNormal[1];
                                                float _Split_e3c2fdf12dbc4838a8bd514815889da8_B_3 = IN.WorldSpaceNormal[2];
                                                float _Split_e3c2fdf12dbc4838a8bd514815889da8_A_4 = 0;
                                                float _Absolute_54fb81dd1c194d60b704c9f81498ffc9_Out_1;
                                                Unity_Absolute_float(_Split_e3c2fdf12dbc4838a8bd514815889da8_R_1, _Absolute_54fb81dd1c194d60b704c9f81498ffc9_Out_1);
                                                float _Comparison_6e7dfe17f5834279863585dd909d6b85_Out_2;
                                                Unity_Comparison_Greater_float(_Absolute_54fb81dd1c194d60b704c9f81498ffc9_Out_1, 0.5, _Comparison_6e7dfe17f5834279863585dd909d6b85_Out_2);
                                                UnityTexture2D _Property_95f1b87d5b974a7e8e84e0e2062aec06_Out_0 = UnityBuildTexture2DStructNoScale(_side);
                                                float _Split_091acb0967a542d5a282773762d4fcea_R_1 = IN.AbsoluteWorldSpacePosition[0];
                                                float _Split_091acb0967a542d5a282773762d4fcea_G_2 = IN.AbsoluteWorldSpacePosition[1];
                                                float _Split_091acb0967a542d5a282773762d4fcea_B_3 = IN.AbsoluteWorldSpacePosition[2];
                                                float _Split_091acb0967a542d5a282773762d4fcea_A_4 = 0;
                                                float2 _Vector2_9cb3ee01611c48a1bcef7c9c847c8fa7_Out_0 = float2(_Split_091acb0967a542d5a282773762d4fcea_G_2, _Split_091acb0967a542d5a282773762d4fcea_B_3);
                                                float _Property_0ad1939b470a44f8be3e74a775ca3ed3_Out_0 = _size;
                                                float _Float_620d3ee1a57d48f98f837d44647977bc_Out_0 = _Property_0ad1939b470a44f8be3e74a775ca3ed3_Out_0;
                                                float2 _Multiply_6d7b5b0483d6477385ad7919aa9270ba_Out_2;
                                                Unity_Multiply_float2_float2(_Vector2_9cb3ee01611c48a1bcef7c9c847c8fa7_Out_0, (_Float_620d3ee1a57d48f98f837d44647977bc_Out_0.xx), _Multiply_6d7b5b0483d6477385ad7919aa9270ba_Out_2);
                                                float2 _Rotate_6bb4154ca8ad4704846be74d0292cc2f_Out_3;
                                                Unity_Rotate_Degrees_float(_Multiply_6d7b5b0483d6477385ad7919aa9270ba_Out_2, float2 (0.5, 0.5), -90, _Rotate_6bb4154ca8ad4704846be74d0292cc2f_Out_3);
                                                float4 _SampleTexture2D_2fd545645ee448609b600edb51209aaa_RGBA_0 = SAMPLE_TEXTURE2D(_Property_95f1b87d5b974a7e8e84e0e2062aec06_Out_0.tex, _Property_95f1b87d5b974a7e8e84e0e2062aec06_Out_0.samplerstate, _Property_95f1b87d5b974a7e8e84e0e2062aec06_Out_0.GetTransformedUV(_Rotate_6bb4154ca8ad4704846be74d0292cc2f_Out_3));
                                                float _SampleTexture2D_2fd545645ee448609b600edb51209aaa_R_4 = _SampleTexture2D_2fd545645ee448609b600edb51209aaa_RGBA_0.r;
                                                float _SampleTexture2D_2fd545645ee448609b600edb51209aaa_G_5 = _SampleTexture2D_2fd545645ee448609b600edb51209aaa_RGBA_0.g;
                                                float _SampleTexture2D_2fd545645ee448609b600edb51209aaa_B_6 = _SampleTexture2D_2fd545645ee448609b600edb51209aaa_RGBA_0.b;
                                                float _SampleTexture2D_2fd545645ee448609b600edb51209aaa_A_7 = _SampleTexture2D_2fd545645ee448609b600edb51209aaa_RGBA_0.a;
                                                float _Split_19ff8587983246ac85c970e145e7295e_R_1 = IN.WorldSpaceNormal[0];
                                                float _Split_19ff8587983246ac85c970e145e7295e_G_2 = IN.WorldSpaceNormal[1];
                                                float _Split_19ff8587983246ac85c970e145e7295e_B_3 = IN.WorldSpaceNormal[2];
                                                float _Split_19ff8587983246ac85c970e145e7295e_A_4 = 0;
                                                float _Absolute_317391fafaa84374beca803aa565632c_Out_1;
                                                Unity_Absolute_float(_Split_19ff8587983246ac85c970e145e7295e_G_2, _Absolute_317391fafaa84374beca803aa565632c_Out_1);
                                                float _Comparison_08509dcd8b844663a8b9a254806453e0_Out_2;
                                                Unity_Comparison_Greater_float(_Absolute_317391fafaa84374beca803aa565632c_Out_1, 0.5, _Comparison_08509dcd8b844663a8b9a254806453e0_Out_2);
                                                UnityTexture2D _Property_d862f312261a47fc87211c138e9e2d65_Out_0 = UnityBuildTexture2DStructNoScale(_side);
                                                float _Split_33dfc647fa994b33bac6870687224f37_R_1 = IN.AbsoluteWorldSpacePosition[0];
                                                float _Split_33dfc647fa994b33bac6870687224f37_G_2 = IN.AbsoluteWorldSpacePosition[1];
                                                float _Split_33dfc647fa994b33bac6870687224f37_B_3 = IN.AbsoluteWorldSpacePosition[2];
                                                float _Split_33dfc647fa994b33bac6870687224f37_A_4 = 0;
                                                float2 _Vector2_5fb462bf0b6f4a18ac68e33ab02ca2de_Out_0 = float2(_Split_33dfc647fa994b33bac6870687224f37_R_1, _Split_33dfc647fa994b33bac6870687224f37_B_3);
                                                float _Property_03059c193ea74dd8b388680b85f07648_Out_0 = _size;
                                                float _Float_9d01c34c368948508ad404d5536aca12_Out_0 = _Property_03059c193ea74dd8b388680b85f07648_Out_0;
                                                float2 _Multiply_18516a081d504359bcad3aa790750518_Out_2;
                                                Unity_Multiply_float2_float2(_Vector2_5fb462bf0b6f4a18ac68e33ab02ca2de_Out_0, (_Float_9d01c34c368948508ad404d5536aca12_Out_0.xx), _Multiply_18516a081d504359bcad3aa790750518_Out_2);
                                                float4 _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_RGBA_0 = SAMPLE_TEXTURE2D(_Property_d862f312261a47fc87211c138e9e2d65_Out_0.tex, _Property_d862f312261a47fc87211c138e9e2d65_Out_0.samplerstate, _Property_d862f312261a47fc87211c138e9e2d65_Out_0.GetTransformedUV(_Multiply_18516a081d504359bcad3aa790750518_Out_2));
                                                float _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_R_4 = _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_RGBA_0.r;
                                                float _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_G_5 = _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_RGBA_0.g;
                                                float _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_B_6 = _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_RGBA_0.b;
                                                float _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_A_7 = _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_RGBA_0.a;
                                                UnityTexture2D _Property_3a54904fa5c74bbeb60261b8a76a189a_Out_0 = UnityBuildTexture2DStructNoScale(_front);
                                                float _Split_c79f25e24b934932b5cad363a3977e09_R_1 = IN.AbsoluteWorldSpacePosition[0];
                                                float _Split_c79f25e24b934932b5cad363a3977e09_G_2 = IN.AbsoluteWorldSpacePosition[1];
                                                float _Split_c79f25e24b934932b5cad363a3977e09_B_3 = IN.AbsoluteWorldSpacePosition[2];
                                                float _Split_c79f25e24b934932b5cad363a3977e09_A_4 = 0;
                                                float2 _Vector2_8457483515df467abc99f05f2c2f6398_Out_0 = float2(_Split_c79f25e24b934932b5cad363a3977e09_R_1, _Split_c79f25e24b934932b5cad363a3977e09_G_2);
                                                float _Property_fc91ea867aa4477485726d431d8da229_Out_0 = _size;
                                                float _Float_7e1bc66811ba41edb7a1f6e6df7f1d37_Out_0 = _Property_fc91ea867aa4477485726d431d8da229_Out_0;
                                                float2 _Multiply_b8fc0cf2c6414beabf7bce2b9ff68cb8_Out_2;
                                                Unity_Multiply_float2_float2(_Vector2_8457483515df467abc99f05f2c2f6398_Out_0, (_Float_7e1bc66811ba41edb7a1f6e6df7f1d37_Out_0.xx), _Multiply_b8fc0cf2c6414beabf7bce2b9ff68cb8_Out_2);
                                                float4 _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_RGBA_0 = SAMPLE_TEXTURE2D(_Property_3a54904fa5c74bbeb60261b8a76a189a_Out_0.tex, _Property_3a54904fa5c74bbeb60261b8a76a189a_Out_0.samplerstate, _Property_3a54904fa5c74bbeb60261b8a76a189a_Out_0.GetTransformedUV(_Multiply_b8fc0cf2c6414beabf7bce2b9ff68cb8_Out_2));
                                                float _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_R_4 = _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_RGBA_0.r;
                                                float _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_G_5 = _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_RGBA_0.g;
                                                float _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_B_6 = _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_RGBA_0.b;
                                                float _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_A_7 = _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_RGBA_0.a;
                                                float4 _Branch_09c1cdaea5f54a1d86615c158f30696f_Out_3;
                                                Unity_Branch_float4(_Comparison_08509dcd8b844663a8b9a254806453e0_Out_2, _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_RGBA_0, _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_RGBA_0, _Branch_09c1cdaea5f54a1d86615c158f30696f_Out_3);
                                                float4 _Branch_33ebb3d9ed944f64b6d69749f158256c_Out_3;
                                                Unity_Branch_float4(_Comparison_6e7dfe17f5834279863585dd909d6b85_Out_2, _SampleTexture2D_2fd545645ee448609b600edb51209aaa_RGBA_0, _Branch_09c1cdaea5f54a1d86615c158f30696f_Out_3, _Branch_33ebb3d9ed944f64b6d69749f158256c_Out_3);
                                                float _Property_94721ec2508f4046b88413c6bd4e982e_Out_0 = _CircleSmoothnes;
                                                float4 _ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                                float4 _Property_fd84b0cc463c44558e196f2b6699bb15_Out_0 = _Position;
                                                float4 _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3;
                                                Unity_Remap_float4(_Property_fd84b0cc463c44558e196f2b6699bb15_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3);
                                                float4 _Add_4b02f63dcd7e45e188328b812f76fa99_Out_2;
                                                Unity_Add_float4(_ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0, _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3, _Add_4b02f63dcd7e45e188328b812f76fa99_Out_2);
                                                float2 _TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3;
                                                Unity_TilingAndOffset_float((_ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0.xy), float2 (1, 1), (_Add_4b02f63dcd7e45e188328b812f76fa99_Out_2.xy), _TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3);
                                                float2 _Multiply_177cb9485e70424c8b113020b5fa561e_Out_2;
                                                Unity_Multiply_float2_float2(_TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3, float2(2, 2), _Multiply_177cb9485e70424c8b113020b5fa561e_Out_2);
                                                float2 _Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2;
                                                Unity_Subtract_float2(_Multiply_177cb9485e70424c8b113020b5fa561e_Out_2, float2(1, 1), _Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2);
                                                float _Divide_0183d4739fe2443987608ab3169a13d9_Out_2;
                                                Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_0183d4739fe2443987608ab3169a13d9_Out_2);
                                                float _Property_817685bafbc74ff594205cd2bbec6848_Out_0 = _CircleSize;
                                                float _Multiply_3046c926d1e34dce9c8963423a59249d_Out_2;
                                                Unity_Multiply_float_float(_Divide_0183d4739fe2443987608ab3169a13d9_Out_2, _Property_817685bafbc74ff594205cd2bbec6848_Out_0, _Multiply_3046c926d1e34dce9c8963423a59249d_Out_2);
                                                float2 _Vector2_fea5299f99e247c4ade509c5e8082e2d_Out_0 = float2(_Multiply_3046c926d1e34dce9c8963423a59249d_Out_2, _Property_817685bafbc74ff594205cd2bbec6848_Out_0);
                                                float2 _Divide_15271b15b3774cec9b09b48583a269d4_Out_2;
                                                Unity_Divide_float2(_Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2, _Vector2_fea5299f99e247c4ade509c5e8082e2d_Out_0, _Divide_15271b15b3774cec9b09b48583a269d4_Out_2);
                                                float _Length_8cc50efaa80e489482f7f21fa7901007_Out_1;
                                                Unity_Length_float2(_Divide_15271b15b3774cec9b09b48583a269d4_Out_2, _Length_8cc50efaa80e489482f7f21fa7901007_Out_1);
                                                float _OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1;
                                                Unity_OneMinus_float(_Length_8cc50efaa80e489482f7f21fa7901007_Out_1, _OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1);
                                                float _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1;
                                                Unity_Saturate_float(_OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1, _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1);
                                                float _Smoothstep_d81123febc5349c78b41d5023455b828_Out_3;
                                                Unity_Smoothstep_float(0, _Property_94721ec2508f4046b88413c6bd4e982e_Out_0, _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1, _Smoothstep_d81123febc5349c78b41d5023455b828_Out_3);
                                                float _Property_84f7f817f25348a3bec32f2049267d9d_Out_0 = _Alpha;
                                                float _Multiply_288a1c15da154ed2b2f4093423b86332_Out_2;
                                                Unity_Multiply_float_float(_Smoothstep_d81123febc5349c78b41d5023455b828_Out_3, _Property_84f7f817f25348a3bec32f2049267d9d_Out_0, _Multiply_288a1c15da154ed2b2f4093423b86332_Out_2);
                                                float _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1;
                                                Unity_OneMinus_float(_Multiply_288a1c15da154ed2b2f4093423b86332_Out_2, _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1);
                                                surface.BaseColor = (_Branch_33ebb3d9ed944f64b6d69749f158256c_Out_3.xyz);
                                                surface.Emission = float3(0, 0, 0);
                                                surface.Alpha = _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1;
                                                return surface;
                                            }

                                            // --------------------------------------------------
                                            // Build Graph Inputs
                                            #ifdef HAVE_VFX_MODIFICATION
                                            #define VFX_SRP_ATTRIBUTES Attributes
                                            #define VFX_SRP_VARYINGS Varyings
                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                            #endif
                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                            {
                                                VertexDescriptionInputs output;
                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                output.ObjectSpaceNormal = input.normalOS;
                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                output.ObjectSpacePosition = input.positionOS;

                                                return output;
                                            }
                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                            {
                                                SurfaceDescriptionInputs output;
                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                            #ifdef HAVE_VFX_MODIFICATION
                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                            #endif



                                                // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                                                float3 unnormalizedNormalWS = input.normalWS;
                                                const float renormFactor = 1.0 / length(unnormalizedNormalWS);


                                                output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph


                                                output.WorldSpacePosition = input.positionWS;
                                                output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
                                                output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                            #else
                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                            #endif
                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                    return output;
                                            }

                                            // --------------------------------------------------
                                            // Main

                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

                                            // --------------------------------------------------
                                            // Visual Effect Vertex Invocations
                                            #ifdef HAVE_VFX_MODIFICATION
                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                            #endif

                                            ENDHLSL
                                            }
                                            Pass
                                            {
                                                Name "SceneSelectionPass"
                                                Tags
                                                {
                                                    "LightMode" = "SceneSelectionPass"
                                                }

                                                // Render State
                                                Cull Off

                                                // Debug
                                                // <None>

                                                // --------------------------------------------------
                                                // Pass

                                                HLSLPROGRAM

                                                // Pragmas
                                                #pragma target 4.5
                                                #pragma exclude_renderers gles gles3 glcore
                                                #pragma vertex vert
                                                #pragma fragment frag

                                                // DotsInstancingOptions: <None>
                                                // HybridV1InjectedBuiltinProperties: <None>

                                                // Keywords
                                                // PassKeywords: <None>
                                                // GraphKeywords: <None>

                                                // Defines

                                                #define _NORMALMAP 1
                                                #define _NORMAL_DROPOFF_TS 1
                                                #define ATTRIBUTES_NEED_NORMAL
                                                #define ATTRIBUTES_NEED_TANGENT
                                                #define VARYINGS_NEED_POSITION_WS
                                                #define FEATURES_GRAPH_VERTEX
                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                #define SHADERPASS SHADERPASS_DEPTHONLY
                                                #define SCENESELECTIONPASS 1
                                                #define ALPHA_CLIP_THRESHOLD 1
                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                // custom interpolator pre-include
                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                // Includes
                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                // --------------------------------------------------
                                                // Structs and Packing

                                                // custom interpolators pre packing
                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                struct Attributes
                                                {
                                                     float3 positionOS : POSITION;
                                                     float3 normalOS : NORMAL;
                                                     float4 tangentOS : TANGENT;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                    #endif
                                                };
                                                struct Varyings
                                                {
                                                     float4 positionCS : SV_POSITION;
                                                     float3 positionWS;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                    #endif
                                                };
                                                struct SurfaceDescriptionInputs
                                                {
                                                     float3 WorldSpacePosition;
                                                     float4 ScreenPosition;
                                                };
                                                struct VertexDescriptionInputs
                                                {
                                                     float3 ObjectSpaceNormal;
                                                     float3 ObjectSpaceTangent;
                                                     float3 ObjectSpacePosition;
                                                };
                                                struct PackedVaryings
                                                {
                                                     float4 positionCS : SV_POSITION;
                                                     float3 interp0 : INTERP0;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                    #endif
                                                };

                                                PackedVaryings PackVaryings(Varyings input)
                                                {
                                                    PackedVaryings output;
                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                    output.positionCS = input.positionCS;
                                                    output.interp0.xyz = input.positionWS;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                    output.instanceID = input.instanceID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                    output.cullFace = input.cullFace;
                                                    #endif
                                                    return output;
                                                }

                                                Varyings UnpackVaryings(PackedVaryings input)
                                                {
                                                    Varyings output;
                                                    output.positionCS = input.positionCS;
                                                    output.positionWS = input.interp0.xyz;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                    output.instanceID = input.instanceID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                    output.cullFace = input.cullFace;
                                                    #endif
                                                    return output;
                                                }


                                                // --------------------------------------------------
                                                // Graph

                                                // Graph Properties
                                                CBUFFER_START(UnityPerMaterial)
                                                float _size;
                                                float4 _front_TexelSize;
                                                float4 _side_TexelSize;
                                                float _Alpha;
                                                float _CircleSize;
                                                float4 _Position;
                                                float _CircleSmoothnes;
                                                CBUFFER_END

                                                    // Object and Global properties
                                                    SAMPLER(SamplerState_Linear_Repeat);
                                                    TEXTURE2D(_front);
                                                    SAMPLER(sampler_front);
                                                    TEXTURE2D(_side);
                                                    SAMPLER(sampler_side);

                                                    // Graph Includes
                                                    // GraphIncludes: <None>

                                                    // -- Property used by ScenePickingPass
                                                    #ifdef SCENEPICKINGPASS
                                                    float4 _SelectionID;
                                                    #endif

                                                    // -- Properties used by SceneSelectionPass
                                                    #ifdef SCENESELECTIONPASS
                                                    int _ObjectId;
                                                    int _PassValue;
                                                    #endif

                                                    // Graph Functions

                                                    void Unity_Remap_float4(float4 In, float2 InMinMax, float2 OutMinMax, out float4 Out)
                                                    {
                                                        Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                    }

                                                    void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                                    {
                                                        Out = A + B;
                                                    }

                                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                    {
                                                        Out = UV * Tiling + Offset;
                                                    }

                                                    void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                                    {
                                                        Out = A * B;
                                                    }

                                                    void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                                    {
                                                        Out = A - B;
                                                    }

                                                    void Unity_Divide_float(float A, float B, out float Out)
                                                    {
                                                        Out = A / B;
                                                    }

                                                    void Unity_Multiply_float_float(float A, float B, out float Out)
                                                    {
                                                        Out = A * B;
                                                    }

                                                    void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                                    {
                                                        Out = A / B;
                                                    }

                                                    void Unity_Length_float2(float2 In, out float Out)
                                                    {
                                                        Out = length(In);
                                                    }

                                                    void Unity_OneMinus_float(float In, out float Out)
                                                    {
                                                        Out = 1 - In;
                                                    }

                                                    void Unity_Saturate_float(float In, out float Out)
                                                    {
                                                        Out = saturate(In);
                                                    }

                                                    void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                                    {
                                                        Out = smoothstep(Edge1, Edge2, In);
                                                    }

                                                    // Custom interpolators pre vertex
                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                    // Graph Vertex
                                                    struct VertexDescription
                                                    {
                                                        float3 Position;
                                                        float3 Normal;
                                                        float3 Tangent;
                                                    };

                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                    {
                                                        VertexDescription description = (VertexDescription)0;
                                                        description.Position = IN.ObjectSpacePosition;
                                                        description.Normal = IN.ObjectSpaceNormal;
                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                        return description;
                                                    }

                                                    // Custom interpolators, pre surface
                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                    {
                                                    return output;
                                                    }
                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                    #endif

                                                    // Graph Pixel
                                                    struct SurfaceDescription
                                                    {
                                                        float Alpha;
                                                    };

                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                    {
                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                        float _Property_94721ec2508f4046b88413c6bd4e982e_Out_0 = _CircleSmoothnes;
                                                        float4 _ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                                        float4 _Property_fd84b0cc463c44558e196f2b6699bb15_Out_0 = _Position;
                                                        float4 _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3;
                                                        Unity_Remap_float4(_Property_fd84b0cc463c44558e196f2b6699bb15_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3);
                                                        float4 _Add_4b02f63dcd7e45e188328b812f76fa99_Out_2;
                                                        Unity_Add_float4(_ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0, _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3, _Add_4b02f63dcd7e45e188328b812f76fa99_Out_2);
                                                        float2 _TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3;
                                                        Unity_TilingAndOffset_float((_ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0.xy), float2 (1, 1), (_Add_4b02f63dcd7e45e188328b812f76fa99_Out_2.xy), _TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3);
                                                        float2 _Multiply_177cb9485e70424c8b113020b5fa561e_Out_2;
                                                        Unity_Multiply_float2_float2(_TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3, float2(2, 2), _Multiply_177cb9485e70424c8b113020b5fa561e_Out_2);
                                                        float2 _Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2;
                                                        Unity_Subtract_float2(_Multiply_177cb9485e70424c8b113020b5fa561e_Out_2, float2(1, 1), _Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2);
                                                        float _Divide_0183d4739fe2443987608ab3169a13d9_Out_2;
                                                        Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_0183d4739fe2443987608ab3169a13d9_Out_2);
                                                        float _Property_817685bafbc74ff594205cd2bbec6848_Out_0 = _CircleSize;
                                                        float _Multiply_3046c926d1e34dce9c8963423a59249d_Out_2;
                                                        Unity_Multiply_float_float(_Divide_0183d4739fe2443987608ab3169a13d9_Out_2, _Property_817685bafbc74ff594205cd2bbec6848_Out_0, _Multiply_3046c926d1e34dce9c8963423a59249d_Out_2);
                                                        float2 _Vector2_fea5299f99e247c4ade509c5e8082e2d_Out_0 = float2(_Multiply_3046c926d1e34dce9c8963423a59249d_Out_2, _Property_817685bafbc74ff594205cd2bbec6848_Out_0);
                                                        float2 _Divide_15271b15b3774cec9b09b48583a269d4_Out_2;
                                                        Unity_Divide_float2(_Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2, _Vector2_fea5299f99e247c4ade509c5e8082e2d_Out_0, _Divide_15271b15b3774cec9b09b48583a269d4_Out_2);
                                                        float _Length_8cc50efaa80e489482f7f21fa7901007_Out_1;
                                                        Unity_Length_float2(_Divide_15271b15b3774cec9b09b48583a269d4_Out_2, _Length_8cc50efaa80e489482f7f21fa7901007_Out_1);
                                                        float _OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1;
                                                        Unity_OneMinus_float(_Length_8cc50efaa80e489482f7f21fa7901007_Out_1, _OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1);
                                                        float _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1;
                                                        Unity_Saturate_float(_OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1, _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1);
                                                        float _Smoothstep_d81123febc5349c78b41d5023455b828_Out_3;
                                                        Unity_Smoothstep_float(0, _Property_94721ec2508f4046b88413c6bd4e982e_Out_0, _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1, _Smoothstep_d81123febc5349c78b41d5023455b828_Out_3);
                                                        float _Property_84f7f817f25348a3bec32f2049267d9d_Out_0 = _Alpha;
                                                        float _Multiply_288a1c15da154ed2b2f4093423b86332_Out_2;
                                                        Unity_Multiply_float_float(_Smoothstep_d81123febc5349c78b41d5023455b828_Out_3, _Property_84f7f817f25348a3bec32f2049267d9d_Out_0, _Multiply_288a1c15da154ed2b2f4093423b86332_Out_2);
                                                        float _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1;
                                                        Unity_OneMinus_float(_Multiply_288a1c15da154ed2b2f4093423b86332_Out_2, _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1);
                                                        surface.Alpha = _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1;
                                                        return surface;
                                                    }

                                                    // --------------------------------------------------
                                                    // Build Graph Inputs
                                                    #ifdef HAVE_VFX_MODIFICATION
                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                    #define VFX_SRP_VARYINGS Varyings
                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                    #endif
                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                    {
                                                        VertexDescriptionInputs output;
                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                        output.ObjectSpaceNormal = input.normalOS;
                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                        output.ObjectSpacePosition = input.positionOS;

                                                        return output;
                                                    }
                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                    {
                                                        SurfaceDescriptionInputs output;
                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                    #ifdef HAVE_VFX_MODIFICATION
                                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                    #endif







                                                        output.WorldSpacePosition = input.positionWS;
                                                        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                    #else
                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                    #endif
                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                            return output;
                                                    }

                                                    // --------------------------------------------------
                                                    // Main

                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

                                                    // --------------------------------------------------
                                                    // Visual Effect Vertex Invocations
                                                    #ifdef HAVE_VFX_MODIFICATION
                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                    #endif

                                                    ENDHLSL
                                                    }
                                                    Pass
                                                    {
                                                        Name "ScenePickingPass"
                                                        Tags
                                                        {
                                                            "LightMode" = "Picking"
                                                        }

                                                        // Render State
                                                        Cull Back

                                                        // Debug
                                                        // <None>

                                                        // --------------------------------------------------
                                                        // Pass

                                                        HLSLPROGRAM

                                                        // Pragmas
                                                        #pragma target 4.5
                                                        #pragma exclude_renderers gles gles3 glcore
                                                        #pragma vertex vert
                                                        #pragma fragment frag

                                                        // DotsInstancingOptions: <None>
                                                        // HybridV1InjectedBuiltinProperties: <None>

                                                        // Keywords
                                                        // PassKeywords: <None>
                                                        // GraphKeywords: <None>

                                                        // Defines

                                                        #define _NORMALMAP 1
                                                        #define _NORMAL_DROPOFF_TS 1
                                                        #define ATTRIBUTES_NEED_NORMAL
                                                        #define ATTRIBUTES_NEED_TANGENT
                                                        #define VARYINGS_NEED_POSITION_WS
                                                        #define FEATURES_GRAPH_VERTEX
                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                        #define SHADERPASS SHADERPASS_DEPTHONLY
                                                        #define SCENEPICKINGPASS 1
                                                        #define ALPHA_CLIP_THRESHOLD 1
                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                        // custom interpolator pre-include
                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                        // Includes
                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                        // --------------------------------------------------
                                                        // Structs and Packing

                                                        // custom interpolators pre packing
                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                        struct Attributes
                                                        {
                                                             float3 positionOS : POSITION;
                                                             float3 normalOS : NORMAL;
                                                             float4 tangentOS : TANGENT;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                            #endif
                                                        };
                                                        struct Varyings
                                                        {
                                                             float4 positionCS : SV_POSITION;
                                                             float3 positionWS;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                            #endif
                                                        };
                                                        struct SurfaceDescriptionInputs
                                                        {
                                                             float3 WorldSpacePosition;
                                                             float4 ScreenPosition;
                                                        };
                                                        struct VertexDescriptionInputs
                                                        {
                                                             float3 ObjectSpaceNormal;
                                                             float3 ObjectSpaceTangent;
                                                             float3 ObjectSpacePosition;
                                                        };
                                                        struct PackedVaryings
                                                        {
                                                             float4 positionCS : SV_POSITION;
                                                             float3 interp0 : INTERP0;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                            #endif
                                                        };

                                                        PackedVaryings PackVaryings(Varyings input)
                                                        {
                                                            PackedVaryings output;
                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                            output.positionCS = input.positionCS;
                                                            output.interp0.xyz = input.positionWS;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                            output.instanceID = input.instanceID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                            output.cullFace = input.cullFace;
                                                            #endif
                                                            return output;
                                                        }

                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                        {
                                                            Varyings output;
                                                            output.positionCS = input.positionCS;
                                                            output.positionWS = input.interp0.xyz;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                            output.instanceID = input.instanceID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                            output.cullFace = input.cullFace;
                                                            #endif
                                                            return output;
                                                        }


                                                        // --------------------------------------------------
                                                        // Graph

                                                        // Graph Properties
                                                        CBUFFER_START(UnityPerMaterial)
                                                        float _size;
                                                        float4 _front_TexelSize;
                                                        float4 _side_TexelSize;
                                                        float _Alpha;
                                                        float _CircleSize;
                                                        float4 _Position;
                                                        float _CircleSmoothnes;
                                                        CBUFFER_END

                                                            // Object and Global properties
                                                            SAMPLER(SamplerState_Linear_Repeat);
                                                            TEXTURE2D(_front);
                                                            SAMPLER(sampler_front);
                                                            TEXTURE2D(_side);
                                                            SAMPLER(sampler_side);

                                                            // Graph Includes
                                                            // GraphIncludes: <None>

                                                            // -- Property used by ScenePickingPass
                                                            #ifdef SCENEPICKINGPASS
                                                            float4 _SelectionID;
                                                            #endif

                                                            // -- Properties used by SceneSelectionPass
                                                            #ifdef SCENESELECTIONPASS
                                                            int _ObjectId;
                                                            int _PassValue;
                                                            #endif

                                                            // Graph Functions

                                                            void Unity_Remap_float4(float4 In, float2 InMinMax, float2 OutMinMax, out float4 Out)
                                                            {
                                                                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                            }

                                                            void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                                            {
                                                                Out = A + B;
                                                            }

                                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                            {
                                                                Out = UV * Tiling + Offset;
                                                            }

                                                            void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                                            {
                                                                Out = A * B;
                                                            }

                                                            void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                                            {
                                                                Out = A - B;
                                                            }

                                                            void Unity_Divide_float(float A, float B, out float Out)
                                                            {
                                                                Out = A / B;
                                                            }

                                                            void Unity_Multiply_float_float(float A, float B, out float Out)
                                                            {
                                                                Out = A * B;
                                                            }

                                                            void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                                            {
                                                                Out = A / B;
                                                            }

                                                            void Unity_Length_float2(float2 In, out float Out)
                                                            {
                                                                Out = length(In);
                                                            }

                                                            void Unity_OneMinus_float(float In, out float Out)
                                                            {
                                                                Out = 1 - In;
                                                            }

                                                            void Unity_Saturate_float(float In, out float Out)
                                                            {
                                                                Out = saturate(In);
                                                            }

                                                            void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                                            {
                                                                Out = smoothstep(Edge1, Edge2, In);
                                                            }

                                                            // Custom interpolators pre vertex
                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                            // Graph Vertex
                                                            struct VertexDescription
                                                            {
                                                                float3 Position;
                                                                float3 Normal;
                                                                float3 Tangent;
                                                            };

                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                            {
                                                                VertexDescription description = (VertexDescription)0;
                                                                description.Position = IN.ObjectSpacePosition;
                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                return description;
                                                            }

                                                            // Custom interpolators, pre surface
                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                            {
                                                            return output;
                                                            }
                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                            #endif

                                                            // Graph Pixel
                                                            struct SurfaceDescription
                                                            {
                                                                float Alpha;
                                                            };

                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                            {
                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                float _Property_94721ec2508f4046b88413c6bd4e982e_Out_0 = _CircleSmoothnes;
                                                                float4 _ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                                                float4 _Property_fd84b0cc463c44558e196f2b6699bb15_Out_0 = _Position;
                                                                float4 _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3;
                                                                Unity_Remap_float4(_Property_fd84b0cc463c44558e196f2b6699bb15_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3);
                                                                float4 _Add_4b02f63dcd7e45e188328b812f76fa99_Out_2;
                                                                Unity_Add_float4(_ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0, _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3, _Add_4b02f63dcd7e45e188328b812f76fa99_Out_2);
                                                                float2 _TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3;
                                                                Unity_TilingAndOffset_float((_ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0.xy), float2 (1, 1), (_Add_4b02f63dcd7e45e188328b812f76fa99_Out_2.xy), _TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3);
                                                                float2 _Multiply_177cb9485e70424c8b113020b5fa561e_Out_2;
                                                                Unity_Multiply_float2_float2(_TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3, float2(2, 2), _Multiply_177cb9485e70424c8b113020b5fa561e_Out_2);
                                                                float2 _Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2;
                                                                Unity_Subtract_float2(_Multiply_177cb9485e70424c8b113020b5fa561e_Out_2, float2(1, 1), _Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2);
                                                                float _Divide_0183d4739fe2443987608ab3169a13d9_Out_2;
                                                                Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_0183d4739fe2443987608ab3169a13d9_Out_2);
                                                                float _Property_817685bafbc74ff594205cd2bbec6848_Out_0 = _CircleSize;
                                                                float _Multiply_3046c926d1e34dce9c8963423a59249d_Out_2;
                                                                Unity_Multiply_float_float(_Divide_0183d4739fe2443987608ab3169a13d9_Out_2, _Property_817685bafbc74ff594205cd2bbec6848_Out_0, _Multiply_3046c926d1e34dce9c8963423a59249d_Out_2);
                                                                float2 _Vector2_fea5299f99e247c4ade509c5e8082e2d_Out_0 = float2(_Multiply_3046c926d1e34dce9c8963423a59249d_Out_2, _Property_817685bafbc74ff594205cd2bbec6848_Out_0);
                                                                float2 _Divide_15271b15b3774cec9b09b48583a269d4_Out_2;
                                                                Unity_Divide_float2(_Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2, _Vector2_fea5299f99e247c4ade509c5e8082e2d_Out_0, _Divide_15271b15b3774cec9b09b48583a269d4_Out_2);
                                                                float _Length_8cc50efaa80e489482f7f21fa7901007_Out_1;
                                                                Unity_Length_float2(_Divide_15271b15b3774cec9b09b48583a269d4_Out_2, _Length_8cc50efaa80e489482f7f21fa7901007_Out_1);
                                                                float _OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1;
                                                                Unity_OneMinus_float(_Length_8cc50efaa80e489482f7f21fa7901007_Out_1, _OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1);
                                                                float _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1;
                                                                Unity_Saturate_float(_OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1, _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1);
                                                                float _Smoothstep_d81123febc5349c78b41d5023455b828_Out_3;
                                                                Unity_Smoothstep_float(0, _Property_94721ec2508f4046b88413c6bd4e982e_Out_0, _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1, _Smoothstep_d81123febc5349c78b41d5023455b828_Out_3);
                                                                float _Property_84f7f817f25348a3bec32f2049267d9d_Out_0 = _Alpha;
                                                                float _Multiply_288a1c15da154ed2b2f4093423b86332_Out_2;
                                                                Unity_Multiply_float_float(_Smoothstep_d81123febc5349c78b41d5023455b828_Out_3, _Property_84f7f817f25348a3bec32f2049267d9d_Out_0, _Multiply_288a1c15da154ed2b2f4093423b86332_Out_2);
                                                                float _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1;
                                                                Unity_OneMinus_float(_Multiply_288a1c15da154ed2b2f4093423b86332_Out_2, _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1);
                                                                surface.Alpha = _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1;
                                                                return surface;
                                                            }

                                                            // --------------------------------------------------
                                                            // Build Graph Inputs
                                                            #ifdef HAVE_VFX_MODIFICATION
                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                            #define VFX_SRP_VARYINGS Varyings
                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                            #endif
                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                            {
                                                                VertexDescriptionInputs output;
                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                output.ObjectSpacePosition = input.positionOS;

                                                                return output;
                                                            }
                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                            {
                                                                SurfaceDescriptionInputs output;
                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                            #endif







                                                                output.WorldSpacePosition = input.positionWS;
                                                                output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                            #else
                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                            #endif
                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                    return output;
                                                            }

                                                            // --------------------------------------------------
                                                            // Main

                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

                                                            // --------------------------------------------------
                                                            // Visual Effect Vertex Invocations
                                                            #ifdef HAVE_VFX_MODIFICATION
                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                            #endif

                                                            ENDHLSL
                                                            }
                                                            Pass
                                                            {
                                                                // Name: <None>
                                                                Tags
                                                                {
                                                                    "LightMode" = "Universal2D"
                                                                }

                                                                // Render State
                                                                Cull Back
                                                                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                                                                ZTest LEqual
                                                                ZWrite Off

                                                                // Debug
                                                                // <None>

                                                                // --------------------------------------------------
                                                                // Pass

                                                                HLSLPROGRAM

                                                                // Pragmas
                                                                #pragma target 4.5
                                                                #pragma exclude_renderers gles gles3 glcore
                                                                #pragma vertex vert
                                                                #pragma fragment frag

                                                                // DotsInstancingOptions: <None>
                                                                // HybridV1InjectedBuiltinProperties: <None>

                                                                // Keywords
                                                                // PassKeywords: <None>
                                                                // GraphKeywords: <None>

                                                                // Defines

                                                                #define _NORMALMAP 1
                                                                #define _NORMAL_DROPOFF_TS 1
                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                #define VARYINGS_NEED_POSITION_WS
                                                                #define VARYINGS_NEED_NORMAL_WS
                                                                #define FEATURES_GRAPH_VERTEX
                                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                #define SHADERPASS SHADERPASS_2D
                                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                // custom interpolator pre-include
                                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                // Includes
                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                // --------------------------------------------------
                                                                // Structs and Packing

                                                                // custom interpolators pre packing
                                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                struct Attributes
                                                                {
                                                                     float3 positionOS : POSITION;
                                                                     float3 normalOS : NORMAL;
                                                                     float4 tangentOS : TANGENT;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                                    #endif
                                                                };
                                                                struct Varyings
                                                                {
                                                                     float4 positionCS : SV_POSITION;
                                                                     float3 positionWS;
                                                                     float3 normalWS;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                    #endif
                                                                };
                                                                struct SurfaceDescriptionInputs
                                                                {
                                                                     float3 WorldSpaceNormal;
                                                                     float3 WorldSpacePosition;
                                                                     float3 AbsoluteWorldSpacePosition;
                                                                     float4 ScreenPosition;
                                                                };
                                                                struct VertexDescriptionInputs
                                                                {
                                                                     float3 ObjectSpaceNormal;
                                                                     float3 ObjectSpaceTangent;
                                                                     float3 ObjectSpacePosition;
                                                                };
                                                                struct PackedVaryings
                                                                {
                                                                     float4 positionCS : SV_POSITION;
                                                                     float3 interp0 : INTERP0;
                                                                     float3 interp1 : INTERP1;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                    #endif
                                                                };

                                                                PackedVaryings PackVaryings(Varyings input)
                                                                {
                                                                    PackedVaryings output;
                                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                                    output.positionCS = input.positionCS;
                                                                    output.interp0.xyz = input.positionWS;
                                                                    output.interp1.xyz = input.normalWS;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                    output.instanceID = input.instanceID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                    output.cullFace = input.cullFace;
                                                                    #endif
                                                                    return output;
                                                                }

                                                                Varyings UnpackVaryings(PackedVaryings input)
                                                                {
                                                                    Varyings output;
                                                                    output.positionCS = input.positionCS;
                                                                    output.positionWS = input.interp0.xyz;
                                                                    output.normalWS = input.interp1.xyz;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                    output.instanceID = input.instanceID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                    output.cullFace = input.cullFace;
                                                                    #endif
                                                                    return output;
                                                                }


                                                                // --------------------------------------------------
                                                                // Graph

                                                                // Graph Properties
                                                                CBUFFER_START(UnityPerMaterial)
                                                                float _size;
                                                                float4 _front_TexelSize;
                                                                float4 _side_TexelSize;
                                                                float _Alpha;
                                                                float _CircleSize;
                                                                float4 _Position;
                                                                float _CircleSmoothnes;
                                                                CBUFFER_END

                                                                    // Object and Global properties
                                                                    SAMPLER(SamplerState_Linear_Repeat);
                                                                    TEXTURE2D(_front);
                                                                    SAMPLER(sampler_front);
                                                                    TEXTURE2D(_side);
                                                                    SAMPLER(sampler_side);

                                                                    // Graph Includes
                                                                    // GraphIncludes: <None>

                                                                    // -- Property used by ScenePickingPass
                                                                    #ifdef SCENEPICKINGPASS
                                                                    float4 _SelectionID;
                                                                    #endif

                                                                    // -- Properties used by SceneSelectionPass
                                                                    #ifdef SCENESELECTIONPASS
                                                                    int _ObjectId;
                                                                    int _PassValue;
                                                                    #endif

                                                                    // Graph Functions

                                                                    void Unity_Absolute_float(float In, out float Out)
                                                                    {
                                                                        Out = abs(In);
                                                                    }

                                                                    void Unity_Comparison_Greater_float(float A, float B, out float Out)
                                                                    {
                                                                        Out = A > B ? 1 : 0;
                                                                    }

                                                                    void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                                                    {
                                                                        Out = A * B;
                                                                    }

                                                                    void Unity_Rotate_Degrees_float(float2 UV, float2 Center, float Rotation, out float2 Out)
                                                                    {
                                                                        //rotation matrix
                                                                        Rotation = Rotation * (3.1415926f / 180.0f);
                                                                        UV -= Center;
                                                                        float s = sin(Rotation);
                                                                        float c = cos(Rotation);

                                                                        //center rotation matrix
                                                                        float2x2 rMatrix = float2x2(c, -s, s, c);
                                                                        rMatrix *= 0.5;
                                                                        rMatrix += 0.5;
                                                                        rMatrix = rMatrix * 2 - 1;

                                                                        //multiply the UVs by the rotation matrix
                                                                        UV.xy = mul(UV.xy, rMatrix);
                                                                        UV += Center;

                                                                        Out = UV;
                                                                    }

                                                                    void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
                                                                    {
                                                                        Out = Predicate ? True : False;
                                                                    }

                                                                    void Unity_Remap_float4(float4 In, float2 InMinMax, float2 OutMinMax, out float4 Out)
                                                                    {
                                                                        Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                                    }

                                                                    void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                                                    {
                                                                        Out = A + B;
                                                                    }

                                                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                    {
                                                                        Out = UV * Tiling + Offset;
                                                                    }

                                                                    void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                                                    {
                                                                        Out = A - B;
                                                                    }

                                                                    void Unity_Divide_float(float A, float B, out float Out)
                                                                    {
                                                                        Out = A / B;
                                                                    }

                                                                    void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                    {
                                                                        Out = A * B;
                                                                    }

                                                                    void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                                                    {
                                                                        Out = A / B;
                                                                    }

                                                                    void Unity_Length_float2(float2 In, out float Out)
                                                                    {
                                                                        Out = length(In);
                                                                    }

                                                                    void Unity_OneMinus_float(float In, out float Out)
                                                                    {
                                                                        Out = 1 - In;
                                                                    }

                                                                    void Unity_Saturate_float(float In, out float Out)
                                                                    {
                                                                        Out = saturate(In);
                                                                    }

                                                                    void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                                                    {
                                                                        Out = smoothstep(Edge1, Edge2, In);
                                                                    }

                                                                    // Custom interpolators pre vertex
                                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                    // Graph Vertex
                                                                    struct VertexDescription
                                                                    {
                                                                        float3 Position;
                                                                        float3 Normal;
                                                                        float3 Tangent;
                                                                    };

                                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                    {
                                                                        VertexDescription description = (VertexDescription)0;
                                                                        description.Position = IN.ObjectSpacePosition;
                                                                        description.Normal = IN.ObjectSpaceNormal;
                                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                                        return description;
                                                                    }

                                                                    // Custom interpolators, pre surface
                                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                    {
                                                                    return output;
                                                                    }
                                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                    #endif

                                                                    // Graph Pixel
                                                                    struct SurfaceDescription
                                                                    {
                                                                        float3 BaseColor;
                                                                        float Alpha;
                                                                    };

                                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                    {
                                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                                        float _Split_e3c2fdf12dbc4838a8bd514815889da8_R_1 = IN.WorldSpaceNormal[0];
                                                                        float _Split_e3c2fdf12dbc4838a8bd514815889da8_G_2 = IN.WorldSpaceNormal[1];
                                                                        float _Split_e3c2fdf12dbc4838a8bd514815889da8_B_3 = IN.WorldSpaceNormal[2];
                                                                        float _Split_e3c2fdf12dbc4838a8bd514815889da8_A_4 = 0;
                                                                        float _Absolute_54fb81dd1c194d60b704c9f81498ffc9_Out_1;
                                                                        Unity_Absolute_float(_Split_e3c2fdf12dbc4838a8bd514815889da8_R_1, _Absolute_54fb81dd1c194d60b704c9f81498ffc9_Out_1);
                                                                        float _Comparison_6e7dfe17f5834279863585dd909d6b85_Out_2;
                                                                        Unity_Comparison_Greater_float(_Absolute_54fb81dd1c194d60b704c9f81498ffc9_Out_1, 0.5, _Comparison_6e7dfe17f5834279863585dd909d6b85_Out_2);
                                                                        UnityTexture2D _Property_95f1b87d5b974a7e8e84e0e2062aec06_Out_0 = UnityBuildTexture2DStructNoScale(_side);
                                                                        float _Split_091acb0967a542d5a282773762d4fcea_R_1 = IN.AbsoluteWorldSpacePosition[0];
                                                                        float _Split_091acb0967a542d5a282773762d4fcea_G_2 = IN.AbsoluteWorldSpacePosition[1];
                                                                        float _Split_091acb0967a542d5a282773762d4fcea_B_3 = IN.AbsoluteWorldSpacePosition[2];
                                                                        float _Split_091acb0967a542d5a282773762d4fcea_A_4 = 0;
                                                                        float2 _Vector2_9cb3ee01611c48a1bcef7c9c847c8fa7_Out_0 = float2(_Split_091acb0967a542d5a282773762d4fcea_G_2, _Split_091acb0967a542d5a282773762d4fcea_B_3);
                                                                        float _Property_0ad1939b470a44f8be3e74a775ca3ed3_Out_0 = _size;
                                                                        float _Float_620d3ee1a57d48f98f837d44647977bc_Out_0 = _Property_0ad1939b470a44f8be3e74a775ca3ed3_Out_0;
                                                                        float2 _Multiply_6d7b5b0483d6477385ad7919aa9270ba_Out_2;
                                                                        Unity_Multiply_float2_float2(_Vector2_9cb3ee01611c48a1bcef7c9c847c8fa7_Out_0, (_Float_620d3ee1a57d48f98f837d44647977bc_Out_0.xx), _Multiply_6d7b5b0483d6477385ad7919aa9270ba_Out_2);
                                                                        float2 _Rotate_6bb4154ca8ad4704846be74d0292cc2f_Out_3;
                                                                        Unity_Rotate_Degrees_float(_Multiply_6d7b5b0483d6477385ad7919aa9270ba_Out_2, float2 (0.5, 0.5), -90, _Rotate_6bb4154ca8ad4704846be74d0292cc2f_Out_3);
                                                                        float4 _SampleTexture2D_2fd545645ee448609b600edb51209aaa_RGBA_0 = SAMPLE_TEXTURE2D(_Property_95f1b87d5b974a7e8e84e0e2062aec06_Out_0.tex, _Property_95f1b87d5b974a7e8e84e0e2062aec06_Out_0.samplerstate, _Property_95f1b87d5b974a7e8e84e0e2062aec06_Out_0.GetTransformedUV(_Rotate_6bb4154ca8ad4704846be74d0292cc2f_Out_3));
                                                                        float _SampleTexture2D_2fd545645ee448609b600edb51209aaa_R_4 = _SampleTexture2D_2fd545645ee448609b600edb51209aaa_RGBA_0.r;
                                                                        float _SampleTexture2D_2fd545645ee448609b600edb51209aaa_G_5 = _SampleTexture2D_2fd545645ee448609b600edb51209aaa_RGBA_0.g;
                                                                        float _SampleTexture2D_2fd545645ee448609b600edb51209aaa_B_6 = _SampleTexture2D_2fd545645ee448609b600edb51209aaa_RGBA_0.b;
                                                                        float _SampleTexture2D_2fd545645ee448609b600edb51209aaa_A_7 = _SampleTexture2D_2fd545645ee448609b600edb51209aaa_RGBA_0.a;
                                                                        float _Split_19ff8587983246ac85c970e145e7295e_R_1 = IN.WorldSpaceNormal[0];
                                                                        float _Split_19ff8587983246ac85c970e145e7295e_G_2 = IN.WorldSpaceNormal[1];
                                                                        float _Split_19ff8587983246ac85c970e145e7295e_B_3 = IN.WorldSpaceNormal[2];
                                                                        float _Split_19ff8587983246ac85c970e145e7295e_A_4 = 0;
                                                                        float _Absolute_317391fafaa84374beca803aa565632c_Out_1;
                                                                        Unity_Absolute_float(_Split_19ff8587983246ac85c970e145e7295e_G_2, _Absolute_317391fafaa84374beca803aa565632c_Out_1);
                                                                        float _Comparison_08509dcd8b844663a8b9a254806453e0_Out_2;
                                                                        Unity_Comparison_Greater_float(_Absolute_317391fafaa84374beca803aa565632c_Out_1, 0.5, _Comparison_08509dcd8b844663a8b9a254806453e0_Out_2);
                                                                        UnityTexture2D _Property_d862f312261a47fc87211c138e9e2d65_Out_0 = UnityBuildTexture2DStructNoScale(_side);
                                                                        float _Split_33dfc647fa994b33bac6870687224f37_R_1 = IN.AbsoluteWorldSpacePosition[0];
                                                                        float _Split_33dfc647fa994b33bac6870687224f37_G_2 = IN.AbsoluteWorldSpacePosition[1];
                                                                        float _Split_33dfc647fa994b33bac6870687224f37_B_3 = IN.AbsoluteWorldSpacePosition[2];
                                                                        float _Split_33dfc647fa994b33bac6870687224f37_A_4 = 0;
                                                                        float2 _Vector2_5fb462bf0b6f4a18ac68e33ab02ca2de_Out_0 = float2(_Split_33dfc647fa994b33bac6870687224f37_R_1, _Split_33dfc647fa994b33bac6870687224f37_B_3);
                                                                        float _Property_03059c193ea74dd8b388680b85f07648_Out_0 = _size;
                                                                        float _Float_9d01c34c368948508ad404d5536aca12_Out_0 = _Property_03059c193ea74dd8b388680b85f07648_Out_0;
                                                                        float2 _Multiply_18516a081d504359bcad3aa790750518_Out_2;
                                                                        Unity_Multiply_float2_float2(_Vector2_5fb462bf0b6f4a18ac68e33ab02ca2de_Out_0, (_Float_9d01c34c368948508ad404d5536aca12_Out_0.xx), _Multiply_18516a081d504359bcad3aa790750518_Out_2);
                                                                        float4 _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_RGBA_0 = SAMPLE_TEXTURE2D(_Property_d862f312261a47fc87211c138e9e2d65_Out_0.tex, _Property_d862f312261a47fc87211c138e9e2d65_Out_0.samplerstate, _Property_d862f312261a47fc87211c138e9e2d65_Out_0.GetTransformedUV(_Multiply_18516a081d504359bcad3aa790750518_Out_2));
                                                                        float _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_R_4 = _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_RGBA_0.r;
                                                                        float _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_G_5 = _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_RGBA_0.g;
                                                                        float _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_B_6 = _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_RGBA_0.b;
                                                                        float _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_A_7 = _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_RGBA_0.a;
                                                                        UnityTexture2D _Property_3a54904fa5c74bbeb60261b8a76a189a_Out_0 = UnityBuildTexture2DStructNoScale(_front);
                                                                        float _Split_c79f25e24b934932b5cad363a3977e09_R_1 = IN.AbsoluteWorldSpacePosition[0];
                                                                        float _Split_c79f25e24b934932b5cad363a3977e09_G_2 = IN.AbsoluteWorldSpacePosition[1];
                                                                        float _Split_c79f25e24b934932b5cad363a3977e09_B_3 = IN.AbsoluteWorldSpacePosition[2];
                                                                        float _Split_c79f25e24b934932b5cad363a3977e09_A_4 = 0;
                                                                        float2 _Vector2_8457483515df467abc99f05f2c2f6398_Out_0 = float2(_Split_c79f25e24b934932b5cad363a3977e09_R_1, _Split_c79f25e24b934932b5cad363a3977e09_G_2);
                                                                        float _Property_fc91ea867aa4477485726d431d8da229_Out_0 = _size;
                                                                        float _Float_7e1bc66811ba41edb7a1f6e6df7f1d37_Out_0 = _Property_fc91ea867aa4477485726d431d8da229_Out_0;
                                                                        float2 _Multiply_b8fc0cf2c6414beabf7bce2b9ff68cb8_Out_2;
                                                                        Unity_Multiply_float2_float2(_Vector2_8457483515df467abc99f05f2c2f6398_Out_0, (_Float_7e1bc66811ba41edb7a1f6e6df7f1d37_Out_0.xx), _Multiply_b8fc0cf2c6414beabf7bce2b9ff68cb8_Out_2);
                                                                        float4 _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_RGBA_0 = SAMPLE_TEXTURE2D(_Property_3a54904fa5c74bbeb60261b8a76a189a_Out_0.tex, _Property_3a54904fa5c74bbeb60261b8a76a189a_Out_0.samplerstate, _Property_3a54904fa5c74bbeb60261b8a76a189a_Out_0.GetTransformedUV(_Multiply_b8fc0cf2c6414beabf7bce2b9ff68cb8_Out_2));
                                                                        float _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_R_4 = _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_RGBA_0.r;
                                                                        float _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_G_5 = _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_RGBA_0.g;
                                                                        float _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_B_6 = _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_RGBA_0.b;
                                                                        float _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_A_7 = _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_RGBA_0.a;
                                                                        float4 _Branch_09c1cdaea5f54a1d86615c158f30696f_Out_3;
                                                                        Unity_Branch_float4(_Comparison_08509dcd8b844663a8b9a254806453e0_Out_2, _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_RGBA_0, _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_RGBA_0, _Branch_09c1cdaea5f54a1d86615c158f30696f_Out_3);
                                                                        float4 _Branch_33ebb3d9ed944f64b6d69749f158256c_Out_3;
                                                                        Unity_Branch_float4(_Comparison_6e7dfe17f5834279863585dd909d6b85_Out_2, _SampleTexture2D_2fd545645ee448609b600edb51209aaa_RGBA_0, _Branch_09c1cdaea5f54a1d86615c158f30696f_Out_3, _Branch_33ebb3d9ed944f64b6d69749f158256c_Out_3);
                                                                        float _Property_94721ec2508f4046b88413c6bd4e982e_Out_0 = _CircleSmoothnes;
                                                                        float4 _ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                                                        float4 _Property_fd84b0cc463c44558e196f2b6699bb15_Out_0 = _Position;
                                                                        float4 _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3;
                                                                        Unity_Remap_float4(_Property_fd84b0cc463c44558e196f2b6699bb15_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3);
                                                                        float4 _Add_4b02f63dcd7e45e188328b812f76fa99_Out_2;
                                                                        Unity_Add_float4(_ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0, _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3, _Add_4b02f63dcd7e45e188328b812f76fa99_Out_2);
                                                                        float2 _TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3;
                                                                        Unity_TilingAndOffset_float((_ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0.xy), float2 (1, 1), (_Add_4b02f63dcd7e45e188328b812f76fa99_Out_2.xy), _TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3);
                                                                        float2 _Multiply_177cb9485e70424c8b113020b5fa561e_Out_2;
                                                                        Unity_Multiply_float2_float2(_TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3, float2(2, 2), _Multiply_177cb9485e70424c8b113020b5fa561e_Out_2);
                                                                        float2 _Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2;
                                                                        Unity_Subtract_float2(_Multiply_177cb9485e70424c8b113020b5fa561e_Out_2, float2(1, 1), _Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2);
                                                                        float _Divide_0183d4739fe2443987608ab3169a13d9_Out_2;
                                                                        Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_0183d4739fe2443987608ab3169a13d9_Out_2);
                                                                        float _Property_817685bafbc74ff594205cd2bbec6848_Out_0 = _CircleSize;
                                                                        float _Multiply_3046c926d1e34dce9c8963423a59249d_Out_2;
                                                                        Unity_Multiply_float_float(_Divide_0183d4739fe2443987608ab3169a13d9_Out_2, _Property_817685bafbc74ff594205cd2bbec6848_Out_0, _Multiply_3046c926d1e34dce9c8963423a59249d_Out_2);
                                                                        float2 _Vector2_fea5299f99e247c4ade509c5e8082e2d_Out_0 = float2(_Multiply_3046c926d1e34dce9c8963423a59249d_Out_2, _Property_817685bafbc74ff594205cd2bbec6848_Out_0);
                                                                        float2 _Divide_15271b15b3774cec9b09b48583a269d4_Out_2;
                                                                        Unity_Divide_float2(_Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2, _Vector2_fea5299f99e247c4ade509c5e8082e2d_Out_0, _Divide_15271b15b3774cec9b09b48583a269d4_Out_2);
                                                                        float _Length_8cc50efaa80e489482f7f21fa7901007_Out_1;
                                                                        Unity_Length_float2(_Divide_15271b15b3774cec9b09b48583a269d4_Out_2, _Length_8cc50efaa80e489482f7f21fa7901007_Out_1);
                                                                        float _OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1;
                                                                        Unity_OneMinus_float(_Length_8cc50efaa80e489482f7f21fa7901007_Out_1, _OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1);
                                                                        float _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1;
                                                                        Unity_Saturate_float(_OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1, _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1);
                                                                        float _Smoothstep_d81123febc5349c78b41d5023455b828_Out_3;
                                                                        Unity_Smoothstep_float(0, _Property_94721ec2508f4046b88413c6bd4e982e_Out_0, _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1, _Smoothstep_d81123febc5349c78b41d5023455b828_Out_3);
                                                                        float _Property_84f7f817f25348a3bec32f2049267d9d_Out_0 = _Alpha;
                                                                        float _Multiply_288a1c15da154ed2b2f4093423b86332_Out_2;
                                                                        Unity_Multiply_float_float(_Smoothstep_d81123febc5349c78b41d5023455b828_Out_3, _Property_84f7f817f25348a3bec32f2049267d9d_Out_0, _Multiply_288a1c15da154ed2b2f4093423b86332_Out_2);
                                                                        float _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1;
                                                                        Unity_OneMinus_float(_Multiply_288a1c15da154ed2b2f4093423b86332_Out_2, _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1);
                                                                        surface.BaseColor = (_Branch_33ebb3d9ed944f64b6d69749f158256c_Out_3.xyz);
                                                                        surface.Alpha = _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1;
                                                                        return surface;
                                                                    }

                                                                    // --------------------------------------------------
                                                                    // Build Graph Inputs
                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                                    #define VFX_SRP_VARYINGS Varyings
                                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                    #endif
                                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                    {
                                                                        VertexDescriptionInputs output;
                                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                        output.ObjectSpaceNormal = input.normalOS;
                                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                        output.ObjectSpacePosition = input.positionOS;

                                                                        return output;
                                                                    }
                                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                    {
                                                                        SurfaceDescriptionInputs output;
                                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                    #endif



                                                                        // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                                                                        float3 unnormalizedNormalWS = input.normalWS;
                                                                        const float renormFactor = 1.0 / length(unnormalizedNormalWS);


                                                                        output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph


                                                                        output.WorldSpacePosition = input.positionWS;
                                                                        output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
                                                                        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                    #else
                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                    #endif
                                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                            return output;
                                                                    }

                                                                    // --------------------------------------------------
                                                                    // Main

                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

                                                                    // --------------------------------------------------
                                                                    // Visual Effect Vertex Invocations
                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                    #endif

                                                                    ENDHLSL
                                                                    }
    }
        SubShader
                                                                    {
                                                                        Tags
                                                                        {
                                                                            "RenderPipeline" = "UniversalPipeline"
                                                                            "RenderType" = "Transparent"
                                                                            "UniversalMaterialType" = "Lit"
                                                                            "Queue" = "Transparent"
                                                                            "ShaderGraphShader" = "true"
                                                                            "ShaderGraphTargetId" = "UniversalLitSubTarget"
                                                                        }
                                                                        Pass
                                                                        {
                                                                            Name "Universal Forward"
                                                                            Tags
                                                                            {
                                                                                "LightMode" = "UniversalForward"
                                                                            }

                                                                        // Render State
                                                                        Cull Back
                                                                        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                                                                        ZTest LEqual
                                                                        ZWrite Off

                                                                        // Debug
                                                                        // <None>

                                                                        // --------------------------------------------------
                                                                        // Pass

                                                                        HLSLPROGRAM

                                                                        // Pragmas
                                                                        #pragma target 2.0
                                                                        #pragma only_renderers gles gles3 glcore d3d11
                                                                        #pragma multi_compile_instancing
                                                                        #pragma multi_compile_fog
                                                                        #pragma instancing_options renderinglayer
                                                                        #pragma vertex vert
                                                                        #pragma fragment frag

                                                                        // DotsInstancingOptions: <None>
                                                                        // HybridV1InjectedBuiltinProperties: <None>

                                                                        // Keywords
                                                                        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
                                                                        #pragma multi_compile _ LIGHTMAP_ON
                                                                        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
                                                                        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                                                                        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
                                                                        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
                                                                        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
                                                                        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
                                                                        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
                                                                        #pragma multi_compile_fragment _ _SHADOWS_SOFT
                                                                        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
                                                                        #pragma multi_compile _ SHADOWS_SHADOWMASK
                                                                        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
                                                                        #pragma multi_compile_fragment _ _LIGHT_LAYERS
                                                                        #pragma multi_compile_fragment _ DEBUG_DISPLAY
                                                                        #pragma multi_compile_fragment _ _LIGHT_COOKIES
                                                                        #pragma multi_compile _ _CLUSTERED_RENDERING
                                                                        // GraphKeywords: <None>

                                                                        // Defines

                                                                        #define _NORMALMAP 1
                                                                        #define _NORMAL_DROPOFF_TS 1
                                                                        #define ATTRIBUTES_NEED_NORMAL
                                                                        #define ATTRIBUTES_NEED_TANGENT
                                                                        #define ATTRIBUTES_NEED_TEXCOORD1
                                                                        #define ATTRIBUTES_NEED_TEXCOORD2
                                                                        #define VARYINGS_NEED_POSITION_WS
                                                                        #define VARYINGS_NEED_NORMAL_WS
                                                                        #define VARYINGS_NEED_TANGENT_WS
                                                                        #define VARYINGS_NEED_VIEWDIRECTION_WS
                                                                        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                                                        #define VARYINGS_NEED_SHADOW_COORD
                                                                        #define FEATURES_GRAPH_VERTEX
                                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                        #define SHADERPASS SHADERPASS_FORWARD
                                                                        #define _FOG_FRAGMENT 1
                                                                        #define _SURFACE_TYPE_TRANSPARENT 1
                                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                        // custom interpolator pre-include
                                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                        // Includes
                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                        // --------------------------------------------------
                                                                        // Structs and Packing

                                                                        // custom interpolators pre packing
                                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                        struct Attributes
                                                                        {
                                                                             float3 positionOS : POSITION;
                                                                             float3 normalOS : NORMAL;
                                                                             float4 tangentOS : TANGENT;
                                                                             float4 uv1 : TEXCOORD1;
                                                                             float4 uv2 : TEXCOORD2;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                                            #endif
                                                                        };
                                                                        struct Varyings
                                                                        {
                                                                             float4 positionCS : SV_POSITION;
                                                                             float3 positionWS;
                                                                             float3 normalWS;
                                                                             float4 tangentWS;
                                                                             float3 viewDirectionWS;
                                                                            #if defined(LIGHTMAP_ON)
                                                                             float2 staticLightmapUV;
                                                                            #endif
                                                                            #if defined(DYNAMICLIGHTMAP_ON)
                                                                             float2 dynamicLightmapUV;
                                                                            #endif
                                                                            #if !defined(LIGHTMAP_ON)
                                                                             float3 sh;
                                                                            #endif
                                                                             float4 fogFactorAndVertexLight;
                                                                            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                                                                             float4 shadowCoord;
                                                                            #endif
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                            #endif
                                                                        };
                                                                        struct SurfaceDescriptionInputs
                                                                        {
                                                                             float3 WorldSpaceNormal;
                                                                             float3 TangentSpaceNormal;
                                                                             float3 WorldSpacePosition;
                                                                             float3 AbsoluteWorldSpacePosition;
                                                                             float4 ScreenPosition;
                                                                        };
                                                                        struct VertexDescriptionInputs
                                                                        {
                                                                             float3 ObjectSpaceNormal;
                                                                             float3 ObjectSpaceTangent;
                                                                             float3 ObjectSpacePosition;
                                                                        };
                                                                        struct PackedVaryings
                                                                        {
                                                                             float4 positionCS : SV_POSITION;
                                                                             float3 interp0 : INTERP0;
                                                                             float3 interp1 : INTERP1;
                                                                             float4 interp2 : INTERP2;
                                                                             float3 interp3 : INTERP3;
                                                                             float2 interp4 : INTERP4;
                                                                             float2 interp5 : INTERP5;
                                                                             float3 interp6 : INTERP6;
                                                                             float4 interp7 : INTERP7;
                                                                             float4 interp8 : INTERP8;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                            #endif
                                                                        };

                                                                        PackedVaryings PackVaryings(Varyings input)
                                                                        {
                                                                            PackedVaryings output;
                                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                                            output.positionCS = input.positionCS;
                                                                            output.interp0.xyz = input.positionWS;
                                                                            output.interp1.xyz = input.normalWS;
                                                                            output.interp2.xyzw = input.tangentWS;
                                                                            output.interp3.xyz = input.viewDirectionWS;
                                                                            #if defined(LIGHTMAP_ON)
                                                                            output.interp4.xy = input.staticLightmapUV;
                                                                            #endif
                                                                            #if defined(DYNAMICLIGHTMAP_ON)
                                                                            output.interp5.xy = input.dynamicLightmapUV;
                                                                            #endif
                                                                            #if !defined(LIGHTMAP_ON)
                                                                            output.interp6.xyz = input.sh;
                                                                            #endif
                                                                            output.interp7.xyzw = input.fogFactorAndVertexLight;
                                                                            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                                                                            output.interp8.xyzw = input.shadowCoord;
                                                                            #endif
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                            output.instanceID = input.instanceID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                            output.cullFace = input.cullFace;
                                                                            #endif
                                                                            return output;
                                                                        }

                                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                                        {
                                                                            Varyings output;
                                                                            output.positionCS = input.positionCS;
                                                                            output.positionWS = input.interp0.xyz;
                                                                            output.normalWS = input.interp1.xyz;
                                                                            output.tangentWS = input.interp2.xyzw;
                                                                            output.viewDirectionWS = input.interp3.xyz;
                                                                            #if defined(LIGHTMAP_ON)
                                                                            output.staticLightmapUV = input.interp4.xy;
                                                                            #endif
                                                                            #if defined(DYNAMICLIGHTMAP_ON)
                                                                            output.dynamicLightmapUV = input.interp5.xy;
                                                                            #endif
                                                                            #if !defined(LIGHTMAP_ON)
                                                                            output.sh = input.interp6.xyz;
                                                                            #endif
                                                                            output.fogFactorAndVertexLight = input.interp7.xyzw;
                                                                            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                                                                            output.shadowCoord = input.interp8.xyzw;
                                                                            #endif
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                            output.instanceID = input.instanceID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                            output.cullFace = input.cullFace;
                                                                            #endif
                                                                            return output;
                                                                        }


                                                                        // --------------------------------------------------
                                                                        // Graph

                                                                        // Graph Properties
                                                                        CBUFFER_START(UnityPerMaterial)
                                                                        float _size;
                                                                        float4 _front_TexelSize;
                                                                        float4 _side_TexelSize;
                                                                        float _Alpha;
                                                                        float _CircleSize;
                                                                        float4 _Position;
                                                                        float _CircleSmoothnes;
                                                                        CBUFFER_END

                                                                            // Object and Global properties
                                                                            SAMPLER(SamplerState_Linear_Repeat);
                                                                            TEXTURE2D(_front);
                                                                            SAMPLER(sampler_front);
                                                                            TEXTURE2D(_side);
                                                                            SAMPLER(sampler_side);

                                                                            // Graph Includes
                                                                            // GraphIncludes: <None>

                                                                            // -- Property used by ScenePickingPass
                                                                            #ifdef SCENEPICKINGPASS
                                                                            float4 _SelectionID;
                                                                            #endif

                                                                            // -- Properties used by SceneSelectionPass
                                                                            #ifdef SCENESELECTIONPASS
                                                                            int _ObjectId;
                                                                            int _PassValue;
                                                                            #endif

                                                                            // Graph Functions

                                                                            void Unity_Absolute_float(float In, out float Out)
                                                                            {
                                                                                Out = abs(In);
                                                                            }

                                                                            void Unity_Comparison_Greater_float(float A, float B, out float Out)
                                                                            {
                                                                                Out = A > B ? 1 : 0;
                                                                            }

                                                                            void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                                                            {
                                                                                Out = A * B;
                                                                            }

                                                                            void Unity_Rotate_Degrees_float(float2 UV, float2 Center, float Rotation, out float2 Out)
                                                                            {
                                                                                //rotation matrix
                                                                                Rotation = Rotation * (3.1415926f / 180.0f);
                                                                                UV -= Center;
                                                                                float s = sin(Rotation);
                                                                                float c = cos(Rotation);

                                                                                //center rotation matrix
                                                                                float2x2 rMatrix = float2x2(c, -s, s, c);
                                                                                rMatrix *= 0.5;
                                                                                rMatrix += 0.5;
                                                                                rMatrix = rMatrix * 2 - 1;

                                                                                //multiply the UVs by the rotation matrix
                                                                                UV.xy = mul(UV.xy, rMatrix);
                                                                                UV += Center;

                                                                                Out = UV;
                                                                            }

                                                                            void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
                                                                            {
                                                                                Out = Predicate ? True : False;
                                                                            }

                                                                            void Unity_Remap_float4(float4 In, float2 InMinMax, float2 OutMinMax, out float4 Out)
                                                                            {
                                                                                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                                            }

                                                                            void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                                                            {
                                                                                Out = A + B;
                                                                            }

                                                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                            {
                                                                                Out = UV * Tiling + Offset;
                                                                            }

                                                                            void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                                                            {
                                                                                Out = A - B;
                                                                            }

                                                                            void Unity_Divide_float(float A, float B, out float Out)
                                                                            {
                                                                                Out = A / B;
                                                                            }

                                                                            void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                            {
                                                                                Out = A * B;
                                                                            }

                                                                            void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                                                            {
                                                                                Out = A / B;
                                                                            }

                                                                            void Unity_Length_float2(float2 In, out float Out)
                                                                            {
                                                                                Out = length(In);
                                                                            }

                                                                            void Unity_OneMinus_float(float In, out float Out)
                                                                            {
                                                                                Out = 1 - In;
                                                                            }

                                                                            void Unity_Saturate_float(float In, out float Out)
                                                                            {
                                                                                Out = saturate(In);
                                                                            }

                                                                            void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                                                            {
                                                                                Out = smoothstep(Edge1, Edge2, In);
                                                                            }

                                                                            // Custom interpolators pre vertex
                                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                            // Graph Vertex
                                                                            struct VertexDescription
                                                                            {
                                                                                float3 Position;
                                                                                float3 Normal;
                                                                                float3 Tangent;
                                                                            };

                                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                            {
                                                                                VertexDescription description = (VertexDescription)0;
                                                                                description.Position = IN.ObjectSpacePosition;
                                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                                return description;
                                                                            }

                                                                            // Custom interpolators, pre surface
                                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                            {
                                                                            return output;
                                                                            }
                                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                            #endif

                                                                            // Graph Pixel
                                                                            struct SurfaceDescription
                                                                            {
                                                                                float3 BaseColor;
                                                                                float3 NormalTS;
                                                                                float3 Emission;
                                                                                float Metallic;
                                                                                float Smoothness;
                                                                                float Occlusion;
                                                                                float Alpha;
                                                                            };

                                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                            {
                                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                                float _Split_e3c2fdf12dbc4838a8bd514815889da8_R_1 = IN.WorldSpaceNormal[0];
                                                                                float _Split_e3c2fdf12dbc4838a8bd514815889da8_G_2 = IN.WorldSpaceNormal[1];
                                                                                float _Split_e3c2fdf12dbc4838a8bd514815889da8_B_3 = IN.WorldSpaceNormal[2];
                                                                                float _Split_e3c2fdf12dbc4838a8bd514815889da8_A_4 = 0;
                                                                                float _Absolute_54fb81dd1c194d60b704c9f81498ffc9_Out_1;
                                                                                Unity_Absolute_float(_Split_e3c2fdf12dbc4838a8bd514815889da8_R_1, _Absolute_54fb81dd1c194d60b704c9f81498ffc9_Out_1);
                                                                                float _Comparison_6e7dfe17f5834279863585dd909d6b85_Out_2;
                                                                                Unity_Comparison_Greater_float(_Absolute_54fb81dd1c194d60b704c9f81498ffc9_Out_1, 0.5, _Comparison_6e7dfe17f5834279863585dd909d6b85_Out_2);
                                                                                UnityTexture2D _Property_95f1b87d5b974a7e8e84e0e2062aec06_Out_0 = UnityBuildTexture2DStructNoScale(_side);
                                                                                float _Split_091acb0967a542d5a282773762d4fcea_R_1 = IN.AbsoluteWorldSpacePosition[0];
                                                                                float _Split_091acb0967a542d5a282773762d4fcea_G_2 = IN.AbsoluteWorldSpacePosition[1];
                                                                                float _Split_091acb0967a542d5a282773762d4fcea_B_3 = IN.AbsoluteWorldSpacePosition[2];
                                                                                float _Split_091acb0967a542d5a282773762d4fcea_A_4 = 0;
                                                                                float2 _Vector2_9cb3ee01611c48a1bcef7c9c847c8fa7_Out_0 = float2(_Split_091acb0967a542d5a282773762d4fcea_G_2, _Split_091acb0967a542d5a282773762d4fcea_B_3);
                                                                                float _Property_0ad1939b470a44f8be3e74a775ca3ed3_Out_0 = _size;
                                                                                float _Float_620d3ee1a57d48f98f837d44647977bc_Out_0 = _Property_0ad1939b470a44f8be3e74a775ca3ed3_Out_0;
                                                                                float2 _Multiply_6d7b5b0483d6477385ad7919aa9270ba_Out_2;
                                                                                Unity_Multiply_float2_float2(_Vector2_9cb3ee01611c48a1bcef7c9c847c8fa7_Out_0, (_Float_620d3ee1a57d48f98f837d44647977bc_Out_0.xx), _Multiply_6d7b5b0483d6477385ad7919aa9270ba_Out_2);
                                                                                float2 _Rotate_6bb4154ca8ad4704846be74d0292cc2f_Out_3;
                                                                                Unity_Rotate_Degrees_float(_Multiply_6d7b5b0483d6477385ad7919aa9270ba_Out_2, float2 (0.5, 0.5), -90, _Rotate_6bb4154ca8ad4704846be74d0292cc2f_Out_3);
                                                                                float4 _SampleTexture2D_2fd545645ee448609b600edb51209aaa_RGBA_0 = SAMPLE_TEXTURE2D(_Property_95f1b87d5b974a7e8e84e0e2062aec06_Out_0.tex, _Property_95f1b87d5b974a7e8e84e0e2062aec06_Out_0.samplerstate, _Property_95f1b87d5b974a7e8e84e0e2062aec06_Out_0.GetTransformedUV(_Rotate_6bb4154ca8ad4704846be74d0292cc2f_Out_3));
                                                                                float _SampleTexture2D_2fd545645ee448609b600edb51209aaa_R_4 = _SampleTexture2D_2fd545645ee448609b600edb51209aaa_RGBA_0.r;
                                                                                float _SampleTexture2D_2fd545645ee448609b600edb51209aaa_G_5 = _SampleTexture2D_2fd545645ee448609b600edb51209aaa_RGBA_0.g;
                                                                                float _SampleTexture2D_2fd545645ee448609b600edb51209aaa_B_6 = _SampleTexture2D_2fd545645ee448609b600edb51209aaa_RGBA_0.b;
                                                                                float _SampleTexture2D_2fd545645ee448609b600edb51209aaa_A_7 = _SampleTexture2D_2fd545645ee448609b600edb51209aaa_RGBA_0.a;
                                                                                float _Split_19ff8587983246ac85c970e145e7295e_R_1 = IN.WorldSpaceNormal[0];
                                                                                float _Split_19ff8587983246ac85c970e145e7295e_G_2 = IN.WorldSpaceNormal[1];
                                                                                float _Split_19ff8587983246ac85c970e145e7295e_B_3 = IN.WorldSpaceNormal[2];
                                                                                float _Split_19ff8587983246ac85c970e145e7295e_A_4 = 0;
                                                                                float _Absolute_317391fafaa84374beca803aa565632c_Out_1;
                                                                                Unity_Absolute_float(_Split_19ff8587983246ac85c970e145e7295e_G_2, _Absolute_317391fafaa84374beca803aa565632c_Out_1);
                                                                                float _Comparison_08509dcd8b844663a8b9a254806453e0_Out_2;
                                                                                Unity_Comparison_Greater_float(_Absolute_317391fafaa84374beca803aa565632c_Out_1, 0.5, _Comparison_08509dcd8b844663a8b9a254806453e0_Out_2);
                                                                                UnityTexture2D _Property_d862f312261a47fc87211c138e9e2d65_Out_0 = UnityBuildTexture2DStructNoScale(_side);
                                                                                float _Split_33dfc647fa994b33bac6870687224f37_R_1 = IN.AbsoluteWorldSpacePosition[0];
                                                                                float _Split_33dfc647fa994b33bac6870687224f37_G_2 = IN.AbsoluteWorldSpacePosition[1];
                                                                                float _Split_33dfc647fa994b33bac6870687224f37_B_3 = IN.AbsoluteWorldSpacePosition[2];
                                                                                float _Split_33dfc647fa994b33bac6870687224f37_A_4 = 0;
                                                                                float2 _Vector2_5fb462bf0b6f4a18ac68e33ab02ca2de_Out_0 = float2(_Split_33dfc647fa994b33bac6870687224f37_R_1, _Split_33dfc647fa994b33bac6870687224f37_B_3);
                                                                                float _Property_03059c193ea74dd8b388680b85f07648_Out_0 = _size;
                                                                                float _Float_9d01c34c368948508ad404d5536aca12_Out_0 = _Property_03059c193ea74dd8b388680b85f07648_Out_0;
                                                                                float2 _Multiply_18516a081d504359bcad3aa790750518_Out_2;
                                                                                Unity_Multiply_float2_float2(_Vector2_5fb462bf0b6f4a18ac68e33ab02ca2de_Out_0, (_Float_9d01c34c368948508ad404d5536aca12_Out_0.xx), _Multiply_18516a081d504359bcad3aa790750518_Out_2);
                                                                                float4 _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_RGBA_0 = SAMPLE_TEXTURE2D(_Property_d862f312261a47fc87211c138e9e2d65_Out_0.tex, _Property_d862f312261a47fc87211c138e9e2d65_Out_0.samplerstate, _Property_d862f312261a47fc87211c138e9e2d65_Out_0.GetTransformedUV(_Multiply_18516a081d504359bcad3aa790750518_Out_2));
                                                                                float _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_R_4 = _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_RGBA_0.r;
                                                                                float _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_G_5 = _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_RGBA_0.g;
                                                                                float _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_B_6 = _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_RGBA_0.b;
                                                                                float _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_A_7 = _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_RGBA_0.a;
                                                                                UnityTexture2D _Property_3a54904fa5c74bbeb60261b8a76a189a_Out_0 = UnityBuildTexture2DStructNoScale(_front);
                                                                                float _Split_c79f25e24b934932b5cad363a3977e09_R_1 = IN.AbsoluteWorldSpacePosition[0];
                                                                                float _Split_c79f25e24b934932b5cad363a3977e09_G_2 = IN.AbsoluteWorldSpacePosition[1];
                                                                                float _Split_c79f25e24b934932b5cad363a3977e09_B_3 = IN.AbsoluteWorldSpacePosition[2];
                                                                                float _Split_c79f25e24b934932b5cad363a3977e09_A_4 = 0;
                                                                                float2 _Vector2_8457483515df467abc99f05f2c2f6398_Out_0 = float2(_Split_c79f25e24b934932b5cad363a3977e09_R_1, _Split_c79f25e24b934932b5cad363a3977e09_G_2);
                                                                                float _Property_fc91ea867aa4477485726d431d8da229_Out_0 = _size;
                                                                                float _Float_7e1bc66811ba41edb7a1f6e6df7f1d37_Out_0 = _Property_fc91ea867aa4477485726d431d8da229_Out_0;
                                                                                float2 _Multiply_b8fc0cf2c6414beabf7bce2b9ff68cb8_Out_2;
                                                                                Unity_Multiply_float2_float2(_Vector2_8457483515df467abc99f05f2c2f6398_Out_0, (_Float_7e1bc66811ba41edb7a1f6e6df7f1d37_Out_0.xx), _Multiply_b8fc0cf2c6414beabf7bce2b9ff68cb8_Out_2);
                                                                                float4 _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_RGBA_0 = SAMPLE_TEXTURE2D(_Property_3a54904fa5c74bbeb60261b8a76a189a_Out_0.tex, _Property_3a54904fa5c74bbeb60261b8a76a189a_Out_0.samplerstate, _Property_3a54904fa5c74bbeb60261b8a76a189a_Out_0.GetTransformedUV(_Multiply_b8fc0cf2c6414beabf7bce2b9ff68cb8_Out_2));
                                                                                float _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_R_4 = _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_RGBA_0.r;
                                                                                float _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_G_5 = _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_RGBA_0.g;
                                                                                float _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_B_6 = _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_RGBA_0.b;
                                                                                float _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_A_7 = _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_RGBA_0.a;
                                                                                float4 _Branch_09c1cdaea5f54a1d86615c158f30696f_Out_3;
                                                                                Unity_Branch_float4(_Comparison_08509dcd8b844663a8b9a254806453e0_Out_2, _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_RGBA_0, _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_RGBA_0, _Branch_09c1cdaea5f54a1d86615c158f30696f_Out_3);
                                                                                float4 _Branch_33ebb3d9ed944f64b6d69749f158256c_Out_3;
                                                                                Unity_Branch_float4(_Comparison_6e7dfe17f5834279863585dd909d6b85_Out_2, _SampleTexture2D_2fd545645ee448609b600edb51209aaa_RGBA_0, _Branch_09c1cdaea5f54a1d86615c158f30696f_Out_3, _Branch_33ebb3d9ed944f64b6d69749f158256c_Out_3);
                                                                                float _Property_94721ec2508f4046b88413c6bd4e982e_Out_0 = _CircleSmoothnes;
                                                                                float4 _ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                                                                float4 _Property_fd84b0cc463c44558e196f2b6699bb15_Out_0 = _Position;
                                                                                float4 _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3;
                                                                                Unity_Remap_float4(_Property_fd84b0cc463c44558e196f2b6699bb15_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3);
                                                                                float4 _Add_4b02f63dcd7e45e188328b812f76fa99_Out_2;
                                                                                Unity_Add_float4(_ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0, _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3, _Add_4b02f63dcd7e45e188328b812f76fa99_Out_2);
                                                                                float2 _TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3;
                                                                                Unity_TilingAndOffset_float((_ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0.xy), float2 (1, 1), (_Add_4b02f63dcd7e45e188328b812f76fa99_Out_2.xy), _TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3);
                                                                                float2 _Multiply_177cb9485e70424c8b113020b5fa561e_Out_2;
                                                                                Unity_Multiply_float2_float2(_TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3, float2(2, 2), _Multiply_177cb9485e70424c8b113020b5fa561e_Out_2);
                                                                                float2 _Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2;
                                                                                Unity_Subtract_float2(_Multiply_177cb9485e70424c8b113020b5fa561e_Out_2, float2(1, 1), _Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2);
                                                                                float _Divide_0183d4739fe2443987608ab3169a13d9_Out_2;
                                                                                Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_0183d4739fe2443987608ab3169a13d9_Out_2);
                                                                                float _Property_817685bafbc74ff594205cd2bbec6848_Out_0 = _CircleSize;
                                                                                float _Multiply_3046c926d1e34dce9c8963423a59249d_Out_2;
                                                                                Unity_Multiply_float_float(_Divide_0183d4739fe2443987608ab3169a13d9_Out_2, _Property_817685bafbc74ff594205cd2bbec6848_Out_0, _Multiply_3046c926d1e34dce9c8963423a59249d_Out_2);
                                                                                float2 _Vector2_fea5299f99e247c4ade509c5e8082e2d_Out_0 = float2(_Multiply_3046c926d1e34dce9c8963423a59249d_Out_2, _Property_817685bafbc74ff594205cd2bbec6848_Out_0);
                                                                                float2 _Divide_15271b15b3774cec9b09b48583a269d4_Out_2;
                                                                                Unity_Divide_float2(_Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2, _Vector2_fea5299f99e247c4ade509c5e8082e2d_Out_0, _Divide_15271b15b3774cec9b09b48583a269d4_Out_2);
                                                                                float _Length_8cc50efaa80e489482f7f21fa7901007_Out_1;
                                                                                Unity_Length_float2(_Divide_15271b15b3774cec9b09b48583a269d4_Out_2, _Length_8cc50efaa80e489482f7f21fa7901007_Out_1);
                                                                                float _OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1;
                                                                                Unity_OneMinus_float(_Length_8cc50efaa80e489482f7f21fa7901007_Out_1, _OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1);
                                                                                float _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1;
                                                                                Unity_Saturate_float(_OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1, _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1);
                                                                                float _Smoothstep_d81123febc5349c78b41d5023455b828_Out_3;
                                                                                Unity_Smoothstep_float(0, _Property_94721ec2508f4046b88413c6bd4e982e_Out_0, _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1, _Smoothstep_d81123febc5349c78b41d5023455b828_Out_3);
                                                                                float _Property_84f7f817f25348a3bec32f2049267d9d_Out_0 = _Alpha;
                                                                                float _Multiply_288a1c15da154ed2b2f4093423b86332_Out_2;
                                                                                Unity_Multiply_float_float(_Smoothstep_d81123febc5349c78b41d5023455b828_Out_3, _Property_84f7f817f25348a3bec32f2049267d9d_Out_0, _Multiply_288a1c15da154ed2b2f4093423b86332_Out_2);
                                                                                float _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1;
                                                                                Unity_OneMinus_float(_Multiply_288a1c15da154ed2b2f4093423b86332_Out_2, _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1);
                                                                                surface.BaseColor = (_Branch_33ebb3d9ed944f64b6d69749f158256c_Out_3.xyz);
                                                                                surface.NormalTS = IN.TangentSpaceNormal;
                                                                                surface.Emission = float3(0, 0, 0);
                                                                                surface.Metallic = 0;
                                                                                surface.Smoothness = 0.5;
                                                                                surface.Occlusion = 1;
                                                                                surface.Alpha = _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1;
                                                                                return surface;
                                                                            }

                                                                            // --------------------------------------------------
                                                                            // Build Graph Inputs
                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                                            #define VFX_SRP_VARYINGS Varyings
                                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                            #endif
                                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                            {
                                                                                VertexDescriptionInputs output;
                                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                output.ObjectSpacePosition = input.positionOS;

                                                                                return output;
                                                                            }
                                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                            {
                                                                                SurfaceDescriptionInputs output;
                                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                            #endif



                                                                                // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                                                                                float3 unnormalizedNormalWS = input.normalWS;
                                                                                const float renormFactor = 1.0 / length(unnormalizedNormalWS);


                                                                                output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
                                                                                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                                                                                output.WorldSpacePosition = input.positionWS;
                                                                                output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
                                                                                output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                            #else
                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                            #endif
                                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                    return output;
                                                                            }

                                                                            // --------------------------------------------------
                                                                            // Main

                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

                                                                            // --------------------------------------------------
                                                                            // Visual Effect Vertex Invocations
                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                            #endif

                                                                            ENDHLSL
                                                                            }
                                                                            Pass
                                                                            {
                                                                                Name "ShadowCaster"
                                                                                Tags
                                                                                {
                                                                                    "LightMode" = "ShadowCaster"
                                                                                }

                                                                                // Render State
                                                                                Cull Back
                                                                                ZTest LEqual
                                                                                ZWrite On
                                                                                ColorMask 0

                                                                                // Debug
                                                                                // <None>

                                                                                // --------------------------------------------------
                                                                                // Pass

                                                                                HLSLPROGRAM

                                                                                // Pragmas
                                                                                #pragma target 2.0
                                                                                #pragma only_renderers gles gles3 glcore d3d11
                                                                                #pragma multi_compile_instancing
                                                                                #pragma vertex vert
                                                                                #pragma fragment frag

                                                                                // DotsInstancingOptions: <None>
                                                                                // HybridV1InjectedBuiltinProperties: <None>

                                                                                // Keywords
                                                                                #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
                                                                                // GraphKeywords: <None>

                                                                                // Defines

                                                                                #define _NORMALMAP 1
                                                                                #define _NORMAL_DROPOFF_TS 1
                                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                                #define VARYINGS_NEED_POSITION_WS
                                                                                #define VARYINGS_NEED_NORMAL_WS
                                                                                #define FEATURES_GRAPH_VERTEX
                                                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                #define SHADERPASS SHADERPASS_SHADOWCASTER
                                                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                // custom interpolator pre-include
                                                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                // Includes
                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                // --------------------------------------------------
                                                                                // Structs and Packing

                                                                                // custom interpolators pre packing
                                                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                struct Attributes
                                                                                {
                                                                                     float3 positionOS : POSITION;
                                                                                     float3 normalOS : NORMAL;
                                                                                     float4 tangentOS : TANGENT;
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                                                    #endif
                                                                                };
                                                                                struct Varyings
                                                                                {
                                                                                     float4 positionCS : SV_POSITION;
                                                                                     float3 positionWS;
                                                                                     float3 normalWS;
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                    #endif
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                    #endif
                                                                                };
                                                                                struct SurfaceDescriptionInputs
                                                                                {
                                                                                     float3 WorldSpacePosition;
                                                                                     float4 ScreenPosition;
                                                                                };
                                                                                struct VertexDescriptionInputs
                                                                                {
                                                                                     float3 ObjectSpaceNormal;
                                                                                     float3 ObjectSpaceTangent;
                                                                                     float3 ObjectSpacePosition;
                                                                                };
                                                                                struct PackedVaryings
                                                                                {
                                                                                     float4 positionCS : SV_POSITION;
                                                                                     float3 interp0 : INTERP0;
                                                                                     float3 interp1 : INTERP1;
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                    #endif
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                    #endif
                                                                                };

                                                                                PackedVaryings PackVaryings(Varyings input)
                                                                                {
                                                                                    PackedVaryings output;
                                                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                                                    output.positionCS = input.positionCS;
                                                                                    output.interp0.xyz = input.positionWS;
                                                                                    output.interp1.xyz = input.normalWS;
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                    output.instanceID = input.instanceID;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                    #endif
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                    output.cullFace = input.cullFace;
                                                                                    #endif
                                                                                    return output;
                                                                                }

                                                                                Varyings UnpackVaryings(PackedVaryings input)
                                                                                {
                                                                                    Varyings output;
                                                                                    output.positionCS = input.positionCS;
                                                                                    output.positionWS = input.interp0.xyz;
                                                                                    output.normalWS = input.interp1.xyz;
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                    output.instanceID = input.instanceID;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                    #endif
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                    output.cullFace = input.cullFace;
                                                                                    #endif
                                                                                    return output;
                                                                                }


                                                                                // --------------------------------------------------
                                                                                // Graph

                                                                                // Graph Properties
                                                                                CBUFFER_START(UnityPerMaterial)
                                                                                float _size;
                                                                                float4 _front_TexelSize;
                                                                                float4 _side_TexelSize;
                                                                                float _Alpha;
                                                                                float _CircleSize;
                                                                                float4 _Position;
                                                                                float _CircleSmoothnes;
                                                                                CBUFFER_END

                                                                                    // Object and Global properties
                                                                                    SAMPLER(SamplerState_Linear_Repeat);
                                                                                    TEXTURE2D(_front);
                                                                                    SAMPLER(sampler_front);
                                                                                    TEXTURE2D(_side);
                                                                                    SAMPLER(sampler_side);

                                                                                    // Graph Includes
                                                                                    // GraphIncludes: <None>

                                                                                    // -- Property used by ScenePickingPass
                                                                                    #ifdef SCENEPICKINGPASS
                                                                                    float4 _SelectionID;
                                                                                    #endif

                                                                                    // -- Properties used by SceneSelectionPass
                                                                                    #ifdef SCENESELECTIONPASS
                                                                                    int _ObjectId;
                                                                                    int _PassValue;
                                                                                    #endif

                                                                                    // Graph Functions

                                                                                    void Unity_Remap_float4(float4 In, float2 InMinMax, float2 OutMinMax, out float4 Out)
                                                                                    {
                                                                                        Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                                                    }

                                                                                    void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                                                                    {
                                                                                        Out = A + B;
                                                                                    }

                                                                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                                    {
                                                                                        Out = UV * Tiling + Offset;
                                                                                    }

                                                                                    void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                                                                    {
                                                                                        Out = A * B;
                                                                                    }

                                                                                    void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                                                                    {
                                                                                        Out = A - B;
                                                                                    }

                                                                                    void Unity_Divide_float(float A, float B, out float Out)
                                                                                    {
                                                                                        Out = A / B;
                                                                                    }

                                                                                    void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                                    {
                                                                                        Out = A * B;
                                                                                    }

                                                                                    void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                                                                    {
                                                                                        Out = A / B;
                                                                                    }

                                                                                    void Unity_Length_float2(float2 In, out float Out)
                                                                                    {
                                                                                        Out = length(In);
                                                                                    }

                                                                                    void Unity_OneMinus_float(float In, out float Out)
                                                                                    {
                                                                                        Out = 1 - In;
                                                                                    }

                                                                                    void Unity_Saturate_float(float In, out float Out)
                                                                                    {
                                                                                        Out = saturate(In);
                                                                                    }

                                                                                    void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                                                                    {
                                                                                        Out = smoothstep(Edge1, Edge2, In);
                                                                                    }

                                                                                    // Custom interpolators pre vertex
                                                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                    // Graph Vertex
                                                                                    struct VertexDescription
                                                                                    {
                                                                                        float3 Position;
                                                                                        float3 Normal;
                                                                                        float3 Tangent;
                                                                                    };

                                                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                    {
                                                                                        VertexDescription description = (VertexDescription)0;
                                                                                        description.Position = IN.ObjectSpacePosition;
                                                                                        description.Normal = IN.ObjectSpaceNormal;
                                                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                                                        return description;
                                                                                    }

                                                                                    // Custom interpolators, pre surface
                                                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                    {
                                                                                    return output;
                                                                                    }
                                                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                    #endif

                                                                                    // Graph Pixel
                                                                                    struct SurfaceDescription
                                                                                    {
                                                                                        float Alpha;
                                                                                    };

                                                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                    {
                                                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                                                        float _Property_94721ec2508f4046b88413c6bd4e982e_Out_0 = _CircleSmoothnes;
                                                                                        float4 _ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                                                                        float4 _Property_fd84b0cc463c44558e196f2b6699bb15_Out_0 = _Position;
                                                                                        float4 _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3;
                                                                                        Unity_Remap_float4(_Property_fd84b0cc463c44558e196f2b6699bb15_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3);
                                                                                        float4 _Add_4b02f63dcd7e45e188328b812f76fa99_Out_2;
                                                                                        Unity_Add_float4(_ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0, _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3, _Add_4b02f63dcd7e45e188328b812f76fa99_Out_2);
                                                                                        float2 _TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3;
                                                                                        Unity_TilingAndOffset_float((_ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0.xy), float2 (1, 1), (_Add_4b02f63dcd7e45e188328b812f76fa99_Out_2.xy), _TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3);
                                                                                        float2 _Multiply_177cb9485e70424c8b113020b5fa561e_Out_2;
                                                                                        Unity_Multiply_float2_float2(_TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3, float2(2, 2), _Multiply_177cb9485e70424c8b113020b5fa561e_Out_2);
                                                                                        float2 _Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2;
                                                                                        Unity_Subtract_float2(_Multiply_177cb9485e70424c8b113020b5fa561e_Out_2, float2(1, 1), _Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2);
                                                                                        float _Divide_0183d4739fe2443987608ab3169a13d9_Out_2;
                                                                                        Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_0183d4739fe2443987608ab3169a13d9_Out_2);
                                                                                        float _Property_817685bafbc74ff594205cd2bbec6848_Out_0 = _CircleSize;
                                                                                        float _Multiply_3046c926d1e34dce9c8963423a59249d_Out_2;
                                                                                        Unity_Multiply_float_float(_Divide_0183d4739fe2443987608ab3169a13d9_Out_2, _Property_817685bafbc74ff594205cd2bbec6848_Out_0, _Multiply_3046c926d1e34dce9c8963423a59249d_Out_2);
                                                                                        float2 _Vector2_fea5299f99e247c4ade509c5e8082e2d_Out_0 = float2(_Multiply_3046c926d1e34dce9c8963423a59249d_Out_2, _Property_817685bafbc74ff594205cd2bbec6848_Out_0);
                                                                                        float2 _Divide_15271b15b3774cec9b09b48583a269d4_Out_2;
                                                                                        Unity_Divide_float2(_Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2, _Vector2_fea5299f99e247c4ade509c5e8082e2d_Out_0, _Divide_15271b15b3774cec9b09b48583a269d4_Out_2);
                                                                                        float _Length_8cc50efaa80e489482f7f21fa7901007_Out_1;
                                                                                        Unity_Length_float2(_Divide_15271b15b3774cec9b09b48583a269d4_Out_2, _Length_8cc50efaa80e489482f7f21fa7901007_Out_1);
                                                                                        float _OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1;
                                                                                        Unity_OneMinus_float(_Length_8cc50efaa80e489482f7f21fa7901007_Out_1, _OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1);
                                                                                        float _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1;
                                                                                        Unity_Saturate_float(_OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1, _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1);
                                                                                        float _Smoothstep_d81123febc5349c78b41d5023455b828_Out_3;
                                                                                        Unity_Smoothstep_float(0, _Property_94721ec2508f4046b88413c6bd4e982e_Out_0, _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1, _Smoothstep_d81123febc5349c78b41d5023455b828_Out_3);
                                                                                        float _Property_84f7f817f25348a3bec32f2049267d9d_Out_0 = _Alpha;
                                                                                        float _Multiply_288a1c15da154ed2b2f4093423b86332_Out_2;
                                                                                        Unity_Multiply_float_float(_Smoothstep_d81123febc5349c78b41d5023455b828_Out_3, _Property_84f7f817f25348a3bec32f2049267d9d_Out_0, _Multiply_288a1c15da154ed2b2f4093423b86332_Out_2);
                                                                                        float _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1;
                                                                                        Unity_OneMinus_float(_Multiply_288a1c15da154ed2b2f4093423b86332_Out_2, _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1);
                                                                                        surface.Alpha = _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1;
                                                                                        return surface;
                                                                                    }

                                                                                    // --------------------------------------------------
                                                                                    // Build Graph Inputs
                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                                                    #define VFX_SRP_VARYINGS Varyings
                                                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                    #endif
                                                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                    {
                                                                                        VertexDescriptionInputs output;
                                                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                        output.ObjectSpaceNormal = input.normalOS;
                                                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                        output.ObjectSpacePosition = input.positionOS;

                                                                                        return output;
                                                                                    }
                                                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                    {
                                                                                        SurfaceDescriptionInputs output;
                                                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                    #endif







                                                                                        output.WorldSpacePosition = input.positionWS;
                                                                                        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                    #else
                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                    #endif
                                                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                            return output;
                                                                                    }

                                                                                    // --------------------------------------------------
                                                                                    // Main

                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

                                                                                    // --------------------------------------------------
                                                                                    // Visual Effect Vertex Invocations
                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                    #endif

                                                                                    ENDHLSL
                                                                                    }
                                                                                    Pass
                                                                                    {
                                                                                        Name "DepthNormals"
                                                                                        Tags
                                                                                        {
                                                                                            "LightMode" = "DepthNormals"
                                                                                        }

                                                                                        // Render State
                                                                                        Cull Back
                                                                                        ZTest LEqual
                                                                                        ZWrite On

                                                                                        // Debug
                                                                                        // <None>

                                                                                        // --------------------------------------------------
                                                                                        // Pass

                                                                                        HLSLPROGRAM

                                                                                        // Pragmas
                                                                                        #pragma target 2.0
                                                                                        #pragma only_renderers gles gles3 glcore d3d11
                                                                                        #pragma multi_compile_instancing
                                                                                        #pragma vertex vert
                                                                                        #pragma fragment frag

                                                                                        // DotsInstancingOptions: <None>
                                                                                        // HybridV1InjectedBuiltinProperties: <None>

                                                                                        // Keywords
                                                                                        // PassKeywords: <None>
                                                                                        // GraphKeywords: <None>

                                                                                        // Defines

                                                                                        #define _NORMALMAP 1
                                                                                        #define _NORMAL_DROPOFF_TS 1
                                                                                        #define ATTRIBUTES_NEED_NORMAL
                                                                                        #define ATTRIBUTES_NEED_TANGENT
                                                                                        #define ATTRIBUTES_NEED_TEXCOORD1
                                                                                        #define VARYINGS_NEED_POSITION_WS
                                                                                        #define VARYINGS_NEED_NORMAL_WS
                                                                                        #define VARYINGS_NEED_TANGENT_WS
                                                                                        #define FEATURES_GRAPH_VERTEX
                                                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                        #define SHADERPASS SHADERPASS_DEPTHNORMALS
                                                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                        // custom interpolator pre-include
                                                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                        // Includes
                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                        // --------------------------------------------------
                                                                                        // Structs and Packing

                                                                                        // custom interpolators pre packing
                                                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                        struct Attributes
                                                                                        {
                                                                                             float3 positionOS : POSITION;
                                                                                             float3 normalOS : NORMAL;
                                                                                             float4 tangentOS : TANGENT;
                                                                                             float4 uv1 : TEXCOORD1;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                                                            #endif
                                                                                        };
                                                                                        struct Varyings
                                                                                        {
                                                                                             float4 positionCS : SV_POSITION;
                                                                                             float3 positionWS;
                                                                                             float3 normalWS;
                                                                                             float4 tangentWS;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                            #endif
                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                            #endif
                                                                                        };
                                                                                        struct SurfaceDescriptionInputs
                                                                                        {
                                                                                             float3 TangentSpaceNormal;
                                                                                             float3 WorldSpacePosition;
                                                                                             float4 ScreenPosition;
                                                                                        };
                                                                                        struct VertexDescriptionInputs
                                                                                        {
                                                                                             float3 ObjectSpaceNormal;
                                                                                             float3 ObjectSpaceTangent;
                                                                                             float3 ObjectSpacePosition;
                                                                                        };
                                                                                        struct PackedVaryings
                                                                                        {
                                                                                             float4 positionCS : SV_POSITION;
                                                                                             float3 interp0 : INTERP0;
                                                                                             float3 interp1 : INTERP1;
                                                                                             float4 interp2 : INTERP2;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                            #endif
                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                            #endif
                                                                                        };

                                                                                        PackedVaryings PackVaryings(Varyings input)
                                                                                        {
                                                                                            PackedVaryings output;
                                                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                                                            output.positionCS = input.positionCS;
                                                                                            output.interp0.xyz = input.positionWS;
                                                                                            output.interp1.xyz = input.normalWS;
                                                                                            output.interp2.xyzw = input.tangentWS;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                            output.instanceID = input.instanceID;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                            #endif
                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                            output.cullFace = input.cullFace;
                                                                                            #endif
                                                                                            return output;
                                                                                        }

                                                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                                                        {
                                                                                            Varyings output;
                                                                                            output.positionCS = input.positionCS;
                                                                                            output.positionWS = input.interp0.xyz;
                                                                                            output.normalWS = input.interp1.xyz;
                                                                                            output.tangentWS = input.interp2.xyzw;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                            output.instanceID = input.instanceID;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                            #endif
                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                            output.cullFace = input.cullFace;
                                                                                            #endif
                                                                                            return output;
                                                                                        }


                                                                                        // --------------------------------------------------
                                                                                        // Graph

                                                                                        // Graph Properties
                                                                                        CBUFFER_START(UnityPerMaterial)
                                                                                        float _size;
                                                                                        float4 _front_TexelSize;
                                                                                        float4 _side_TexelSize;
                                                                                        float _Alpha;
                                                                                        float _CircleSize;
                                                                                        float4 _Position;
                                                                                        float _CircleSmoothnes;
                                                                                        CBUFFER_END

                                                                                            // Object and Global properties
                                                                                            SAMPLER(SamplerState_Linear_Repeat);
                                                                                            TEXTURE2D(_front);
                                                                                            SAMPLER(sampler_front);
                                                                                            TEXTURE2D(_side);
                                                                                            SAMPLER(sampler_side);

                                                                                            // Graph Includes
                                                                                            // GraphIncludes: <None>

                                                                                            // -- Property used by ScenePickingPass
                                                                                            #ifdef SCENEPICKINGPASS
                                                                                            float4 _SelectionID;
                                                                                            #endif

                                                                                            // -- Properties used by SceneSelectionPass
                                                                                            #ifdef SCENESELECTIONPASS
                                                                                            int _ObjectId;
                                                                                            int _PassValue;
                                                                                            #endif

                                                                                            // Graph Functions

                                                                                            void Unity_Remap_float4(float4 In, float2 InMinMax, float2 OutMinMax, out float4 Out)
                                                                                            {
                                                                                                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                                                            }

                                                                                            void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                                                                            {
                                                                                                Out = A + B;
                                                                                            }

                                                                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                                            {
                                                                                                Out = UV * Tiling + Offset;
                                                                                            }

                                                                                            void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                                                                            {
                                                                                                Out = A * B;
                                                                                            }

                                                                                            void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                                                                            {
                                                                                                Out = A - B;
                                                                                            }

                                                                                            void Unity_Divide_float(float A, float B, out float Out)
                                                                                            {
                                                                                                Out = A / B;
                                                                                            }

                                                                                            void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                                            {
                                                                                                Out = A * B;
                                                                                            }

                                                                                            void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                                                                            {
                                                                                                Out = A / B;
                                                                                            }

                                                                                            void Unity_Length_float2(float2 In, out float Out)
                                                                                            {
                                                                                                Out = length(In);
                                                                                            }

                                                                                            void Unity_OneMinus_float(float In, out float Out)
                                                                                            {
                                                                                                Out = 1 - In;
                                                                                            }

                                                                                            void Unity_Saturate_float(float In, out float Out)
                                                                                            {
                                                                                                Out = saturate(In);
                                                                                            }

                                                                                            void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                                                                            {
                                                                                                Out = smoothstep(Edge1, Edge2, In);
                                                                                            }

                                                                                            // Custom interpolators pre vertex
                                                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                            // Graph Vertex
                                                                                            struct VertexDescription
                                                                                            {
                                                                                                float3 Position;
                                                                                                float3 Normal;
                                                                                                float3 Tangent;
                                                                                            };

                                                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                            {
                                                                                                VertexDescription description = (VertexDescription)0;
                                                                                                description.Position = IN.ObjectSpacePosition;
                                                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                                                return description;
                                                                                            }

                                                                                            // Custom interpolators, pre surface
                                                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                            {
                                                                                            return output;
                                                                                            }
                                                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                            #endif

                                                                                            // Graph Pixel
                                                                                            struct SurfaceDescription
                                                                                            {
                                                                                                float3 NormalTS;
                                                                                                float Alpha;
                                                                                            };

                                                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                            {
                                                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                float _Property_94721ec2508f4046b88413c6bd4e982e_Out_0 = _CircleSmoothnes;
                                                                                                float4 _ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                                                                                float4 _Property_fd84b0cc463c44558e196f2b6699bb15_Out_0 = _Position;
                                                                                                float4 _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3;
                                                                                                Unity_Remap_float4(_Property_fd84b0cc463c44558e196f2b6699bb15_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3);
                                                                                                float4 _Add_4b02f63dcd7e45e188328b812f76fa99_Out_2;
                                                                                                Unity_Add_float4(_ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0, _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3, _Add_4b02f63dcd7e45e188328b812f76fa99_Out_2);
                                                                                                float2 _TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3;
                                                                                                Unity_TilingAndOffset_float((_ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0.xy), float2 (1, 1), (_Add_4b02f63dcd7e45e188328b812f76fa99_Out_2.xy), _TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3);
                                                                                                float2 _Multiply_177cb9485e70424c8b113020b5fa561e_Out_2;
                                                                                                Unity_Multiply_float2_float2(_TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3, float2(2, 2), _Multiply_177cb9485e70424c8b113020b5fa561e_Out_2);
                                                                                                float2 _Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2;
                                                                                                Unity_Subtract_float2(_Multiply_177cb9485e70424c8b113020b5fa561e_Out_2, float2(1, 1), _Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2);
                                                                                                float _Divide_0183d4739fe2443987608ab3169a13d9_Out_2;
                                                                                                Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_0183d4739fe2443987608ab3169a13d9_Out_2);
                                                                                                float _Property_817685bafbc74ff594205cd2bbec6848_Out_0 = _CircleSize;
                                                                                                float _Multiply_3046c926d1e34dce9c8963423a59249d_Out_2;
                                                                                                Unity_Multiply_float_float(_Divide_0183d4739fe2443987608ab3169a13d9_Out_2, _Property_817685bafbc74ff594205cd2bbec6848_Out_0, _Multiply_3046c926d1e34dce9c8963423a59249d_Out_2);
                                                                                                float2 _Vector2_fea5299f99e247c4ade509c5e8082e2d_Out_0 = float2(_Multiply_3046c926d1e34dce9c8963423a59249d_Out_2, _Property_817685bafbc74ff594205cd2bbec6848_Out_0);
                                                                                                float2 _Divide_15271b15b3774cec9b09b48583a269d4_Out_2;
                                                                                                Unity_Divide_float2(_Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2, _Vector2_fea5299f99e247c4ade509c5e8082e2d_Out_0, _Divide_15271b15b3774cec9b09b48583a269d4_Out_2);
                                                                                                float _Length_8cc50efaa80e489482f7f21fa7901007_Out_1;
                                                                                                Unity_Length_float2(_Divide_15271b15b3774cec9b09b48583a269d4_Out_2, _Length_8cc50efaa80e489482f7f21fa7901007_Out_1);
                                                                                                float _OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1;
                                                                                                Unity_OneMinus_float(_Length_8cc50efaa80e489482f7f21fa7901007_Out_1, _OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1);
                                                                                                float _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1;
                                                                                                Unity_Saturate_float(_OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1, _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1);
                                                                                                float _Smoothstep_d81123febc5349c78b41d5023455b828_Out_3;
                                                                                                Unity_Smoothstep_float(0, _Property_94721ec2508f4046b88413c6bd4e982e_Out_0, _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1, _Smoothstep_d81123febc5349c78b41d5023455b828_Out_3);
                                                                                                float _Property_84f7f817f25348a3bec32f2049267d9d_Out_0 = _Alpha;
                                                                                                float _Multiply_288a1c15da154ed2b2f4093423b86332_Out_2;
                                                                                                Unity_Multiply_float_float(_Smoothstep_d81123febc5349c78b41d5023455b828_Out_3, _Property_84f7f817f25348a3bec32f2049267d9d_Out_0, _Multiply_288a1c15da154ed2b2f4093423b86332_Out_2);
                                                                                                float _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1;
                                                                                                Unity_OneMinus_float(_Multiply_288a1c15da154ed2b2f4093423b86332_Out_2, _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1);
                                                                                                surface.NormalTS = IN.TangentSpaceNormal;
                                                                                                surface.Alpha = _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1;
                                                                                                return surface;
                                                                                            }

                                                                                            // --------------------------------------------------
                                                                                            // Build Graph Inputs
                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                                                            #define VFX_SRP_VARYINGS Varyings
                                                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                            #endif
                                                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                            {
                                                                                                VertexDescriptionInputs output;
                                                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                                output.ObjectSpacePosition = input.positionOS;

                                                                                                return output;
                                                                                            }
                                                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                            {
                                                                                                SurfaceDescriptionInputs output;
                                                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                            #endif





                                                                                                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                                                                                                output.WorldSpacePosition = input.positionWS;
                                                                                                output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                            #else
                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                            #endif
                                                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                    return output;
                                                                                            }

                                                                                            // --------------------------------------------------
                                                                                            // Main

                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

                                                                                            // --------------------------------------------------
                                                                                            // Visual Effect Vertex Invocations
                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                            #endif

                                                                                            ENDHLSL
                                                                                            }
                                                                                            Pass
                                                                                            {
                                                                                                Name "Meta"
                                                                                                Tags
                                                                                                {
                                                                                                    "LightMode" = "Meta"
                                                                                                }

                                                                                                // Render State
                                                                                                Cull Off

                                                                                                // Debug
                                                                                                // <None>

                                                                                                // --------------------------------------------------
                                                                                                // Pass

                                                                                                HLSLPROGRAM

                                                                                                // Pragmas
                                                                                                #pragma target 2.0
                                                                                                #pragma only_renderers gles gles3 glcore d3d11
                                                                                                #pragma vertex vert
                                                                                                #pragma fragment frag

                                                                                                // DotsInstancingOptions: <None>
                                                                                                // HybridV1InjectedBuiltinProperties: <None>

                                                                                                // Keywords
                                                                                                #pragma shader_feature _ EDITOR_VISUALIZATION
                                                                                                // GraphKeywords: <None>

                                                                                                // Defines

                                                                                                #define _NORMALMAP 1
                                                                                                #define _NORMAL_DROPOFF_TS 1
                                                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                                                #define ATTRIBUTES_NEED_TEXCOORD0
                                                                                                #define ATTRIBUTES_NEED_TEXCOORD1
                                                                                                #define ATTRIBUTES_NEED_TEXCOORD2
                                                                                                #define VARYINGS_NEED_POSITION_WS
                                                                                                #define VARYINGS_NEED_NORMAL_WS
                                                                                                #define VARYINGS_NEED_TEXCOORD0
                                                                                                #define VARYINGS_NEED_TEXCOORD1
                                                                                                #define VARYINGS_NEED_TEXCOORD2
                                                                                                #define FEATURES_GRAPH_VERTEX
                                                                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                                #define SHADERPASS SHADERPASS_META
                                                                                                #define _FOG_FRAGMENT 1
                                                                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                                // custom interpolator pre-include
                                                                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                                // Includes
                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                                // --------------------------------------------------
                                                                                                // Structs and Packing

                                                                                                // custom interpolators pre packing
                                                                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                                struct Attributes
                                                                                                {
                                                                                                     float3 positionOS : POSITION;
                                                                                                     float3 normalOS : NORMAL;
                                                                                                     float4 tangentOS : TANGENT;
                                                                                                     float4 uv0 : TEXCOORD0;
                                                                                                     float4 uv1 : TEXCOORD1;
                                                                                                     float4 uv2 : TEXCOORD2;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                                                                    #endif
                                                                                                };
                                                                                                struct Varyings
                                                                                                {
                                                                                                     float4 positionCS : SV_POSITION;
                                                                                                     float3 positionWS;
                                                                                                     float3 normalWS;
                                                                                                     float4 texCoord0;
                                                                                                     float4 texCoord1;
                                                                                                     float4 texCoord2;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                    #endif
                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                    #endif
                                                                                                };
                                                                                                struct SurfaceDescriptionInputs
                                                                                                {
                                                                                                     float3 WorldSpaceNormal;
                                                                                                     float3 WorldSpacePosition;
                                                                                                     float3 AbsoluteWorldSpacePosition;
                                                                                                     float4 ScreenPosition;
                                                                                                };
                                                                                                struct VertexDescriptionInputs
                                                                                                {
                                                                                                     float3 ObjectSpaceNormal;
                                                                                                     float3 ObjectSpaceTangent;
                                                                                                     float3 ObjectSpacePosition;
                                                                                                };
                                                                                                struct PackedVaryings
                                                                                                {
                                                                                                     float4 positionCS : SV_POSITION;
                                                                                                     float3 interp0 : INTERP0;
                                                                                                     float3 interp1 : INTERP1;
                                                                                                     float4 interp2 : INTERP2;
                                                                                                     float4 interp3 : INTERP3;
                                                                                                     float4 interp4 : INTERP4;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                    #endif
                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                    #endif
                                                                                                };

                                                                                                PackedVaryings PackVaryings(Varyings input)
                                                                                                {
                                                                                                    PackedVaryings output;
                                                                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                                                                    output.positionCS = input.positionCS;
                                                                                                    output.interp0.xyz = input.positionWS;
                                                                                                    output.interp1.xyz = input.normalWS;
                                                                                                    output.interp2.xyzw = input.texCoord0;
                                                                                                    output.interp3.xyzw = input.texCoord1;
                                                                                                    output.interp4.xyzw = input.texCoord2;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                    output.instanceID = input.instanceID;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                    #endif
                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                    output.cullFace = input.cullFace;
                                                                                                    #endif
                                                                                                    return output;
                                                                                                }

                                                                                                Varyings UnpackVaryings(PackedVaryings input)
                                                                                                {
                                                                                                    Varyings output;
                                                                                                    output.positionCS = input.positionCS;
                                                                                                    output.positionWS = input.interp0.xyz;
                                                                                                    output.normalWS = input.interp1.xyz;
                                                                                                    output.texCoord0 = input.interp2.xyzw;
                                                                                                    output.texCoord1 = input.interp3.xyzw;
                                                                                                    output.texCoord2 = input.interp4.xyzw;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                    output.instanceID = input.instanceID;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                    #endif
                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                    output.cullFace = input.cullFace;
                                                                                                    #endif
                                                                                                    return output;
                                                                                                }


                                                                                                // --------------------------------------------------
                                                                                                // Graph

                                                                                                // Graph Properties
                                                                                                CBUFFER_START(UnityPerMaterial)
                                                                                                float _size;
                                                                                                float4 _front_TexelSize;
                                                                                                float4 _side_TexelSize;
                                                                                                float _Alpha;
                                                                                                float _CircleSize;
                                                                                                float4 _Position;
                                                                                                float _CircleSmoothnes;
                                                                                                CBUFFER_END

                                                                                                    // Object and Global properties
                                                                                                    SAMPLER(SamplerState_Linear_Repeat);
                                                                                                    TEXTURE2D(_front);
                                                                                                    SAMPLER(sampler_front);
                                                                                                    TEXTURE2D(_side);
                                                                                                    SAMPLER(sampler_side);

                                                                                                    // Graph Includes
                                                                                                    // GraphIncludes: <None>

                                                                                                    // -- Property used by ScenePickingPass
                                                                                                    #ifdef SCENEPICKINGPASS
                                                                                                    float4 _SelectionID;
                                                                                                    #endif

                                                                                                    // -- Properties used by SceneSelectionPass
                                                                                                    #ifdef SCENESELECTIONPASS
                                                                                                    int _ObjectId;
                                                                                                    int _PassValue;
                                                                                                    #endif

                                                                                                    // Graph Functions

                                                                                                    void Unity_Absolute_float(float In, out float Out)
                                                                                                    {
                                                                                                        Out = abs(In);
                                                                                                    }

                                                                                                    void Unity_Comparison_Greater_float(float A, float B, out float Out)
                                                                                                    {
                                                                                                        Out = A > B ? 1 : 0;
                                                                                                    }

                                                                                                    void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                                                                                    {
                                                                                                        Out = A * B;
                                                                                                    }

                                                                                                    void Unity_Rotate_Degrees_float(float2 UV, float2 Center, float Rotation, out float2 Out)
                                                                                                    {
                                                                                                        //rotation matrix
                                                                                                        Rotation = Rotation * (3.1415926f / 180.0f);
                                                                                                        UV -= Center;
                                                                                                        float s = sin(Rotation);
                                                                                                        float c = cos(Rotation);

                                                                                                        //center rotation matrix
                                                                                                        float2x2 rMatrix = float2x2(c, -s, s, c);
                                                                                                        rMatrix *= 0.5;
                                                                                                        rMatrix += 0.5;
                                                                                                        rMatrix = rMatrix * 2 - 1;

                                                                                                        //multiply the UVs by the rotation matrix
                                                                                                        UV.xy = mul(UV.xy, rMatrix);
                                                                                                        UV += Center;

                                                                                                        Out = UV;
                                                                                                    }

                                                                                                    void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
                                                                                                    {
                                                                                                        Out = Predicate ? True : False;
                                                                                                    }

                                                                                                    void Unity_Remap_float4(float4 In, float2 InMinMax, float2 OutMinMax, out float4 Out)
                                                                                                    {
                                                                                                        Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                                                                    }

                                                                                                    void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                                                                                    {
                                                                                                        Out = A + B;
                                                                                                    }

                                                                                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                                                    {
                                                                                                        Out = UV * Tiling + Offset;
                                                                                                    }

                                                                                                    void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                                                                                    {
                                                                                                        Out = A - B;
                                                                                                    }

                                                                                                    void Unity_Divide_float(float A, float B, out float Out)
                                                                                                    {
                                                                                                        Out = A / B;
                                                                                                    }

                                                                                                    void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                                                    {
                                                                                                        Out = A * B;
                                                                                                    }

                                                                                                    void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                                                                                    {
                                                                                                        Out = A / B;
                                                                                                    }

                                                                                                    void Unity_Length_float2(float2 In, out float Out)
                                                                                                    {
                                                                                                        Out = length(In);
                                                                                                    }

                                                                                                    void Unity_OneMinus_float(float In, out float Out)
                                                                                                    {
                                                                                                        Out = 1 - In;
                                                                                                    }

                                                                                                    void Unity_Saturate_float(float In, out float Out)
                                                                                                    {
                                                                                                        Out = saturate(In);
                                                                                                    }

                                                                                                    void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                                                                                    {
                                                                                                        Out = smoothstep(Edge1, Edge2, In);
                                                                                                    }

                                                                                                    // Custom interpolators pre vertex
                                                                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                                    // Graph Vertex
                                                                                                    struct VertexDescription
                                                                                                    {
                                                                                                        float3 Position;
                                                                                                        float3 Normal;
                                                                                                        float3 Tangent;
                                                                                                    };

                                                                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                                    {
                                                                                                        VertexDescription description = (VertexDescription)0;
                                                                                                        description.Position = IN.ObjectSpacePosition;
                                                                                                        description.Normal = IN.ObjectSpaceNormal;
                                                                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                                                                        return description;
                                                                                                    }

                                                                                                    // Custom interpolators, pre surface
                                                                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                                    {
                                                                                                    return output;
                                                                                                    }
                                                                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                                    #endif

                                                                                                    // Graph Pixel
                                                                                                    struct SurfaceDescription
                                                                                                    {
                                                                                                        float3 BaseColor;
                                                                                                        float3 Emission;
                                                                                                        float Alpha;
                                                                                                    };

                                                                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                                    {
                                                                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                        float _Split_e3c2fdf12dbc4838a8bd514815889da8_R_1 = IN.WorldSpaceNormal[0];
                                                                                                        float _Split_e3c2fdf12dbc4838a8bd514815889da8_G_2 = IN.WorldSpaceNormal[1];
                                                                                                        float _Split_e3c2fdf12dbc4838a8bd514815889da8_B_3 = IN.WorldSpaceNormal[2];
                                                                                                        float _Split_e3c2fdf12dbc4838a8bd514815889da8_A_4 = 0;
                                                                                                        float _Absolute_54fb81dd1c194d60b704c9f81498ffc9_Out_1;
                                                                                                        Unity_Absolute_float(_Split_e3c2fdf12dbc4838a8bd514815889da8_R_1, _Absolute_54fb81dd1c194d60b704c9f81498ffc9_Out_1);
                                                                                                        float _Comparison_6e7dfe17f5834279863585dd909d6b85_Out_2;
                                                                                                        Unity_Comparison_Greater_float(_Absolute_54fb81dd1c194d60b704c9f81498ffc9_Out_1, 0.5, _Comparison_6e7dfe17f5834279863585dd909d6b85_Out_2);
                                                                                                        UnityTexture2D _Property_95f1b87d5b974a7e8e84e0e2062aec06_Out_0 = UnityBuildTexture2DStructNoScale(_side);
                                                                                                        float _Split_091acb0967a542d5a282773762d4fcea_R_1 = IN.AbsoluteWorldSpacePosition[0];
                                                                                                        float _Split_091acb0967a542d5a282773762d4fcea_G_2 = IN.AbsoluteWorldSpacePosition[1];
                                                                                                        float _Split_091acb0967a542d5a282773762d4fcea_B_3 = IN.AbsoluteWorldSpacePosition[2];
                                                                                                        float _Split_091acb0967a542d5a282773762d4fcea_A_4 = 0;
                                                                                                        float2 _Vector2_9cb3ee01611c48a1bcef7c9c847c8fa7_Out_0 = float2(_Split_091acb0967a542d5a282773762d4fcea_G_2, _Split_091acb0967a542d5a282773762d4fcea_B_3);
                                                                                                        float _Property_0ad1939b470a44f8be3e74a775ca3ed3_Out_0 = _size;
                                                                                                        float _Float_620d3ee1a57d48f98f837d44647977bc_Out_0 = _Property_0ad1939b470a44f8be3e74a775ca3ed3_Out_0;
                                                                                                        float2 _Multiply_6d7b5b0483d6477385ad7919aa9270ba_Out_2;
                                                                                                        Unity_Multiply_float2_float2(_Vector2_9cb3ee01611c48a1bcef7c9c847c8fa7_Out_0, (_Float_620d3ee1a57d48f98f837d44647977bc_Out_0.xx), _Multiply_6d7b5b0483d6477385ad7919aa9270ba_Out_2);
                                                                                                        float2 _Rotate_6bb4154ca8ad4704846be74d0292cc2f_Out_3;
                                                                                                        Unity_Rotate_Degrees_float(_Multiply_6d7b5b0483d6477385ad7919aa9270ba_Out_2, float2 (0.5, 0.5), -90, _Rotate_6bb4154ca8ad4704846be74d0292cc2f_Out_3);
                                                                                                        float4 _SampleTexture2D_2fd545645ee448609b600edb51209aaa_RGBA_0 = SAMPLE_TEXTURE2D(_Property_95f1b87d5b974a7e8e84e0e2062aec06_Out_0.tex, _Property_95f1b87d5b974a7e8e84e0e2062aec06_Out_0.samplerstate, _Property_95f1b87d5b974a7e8e84e0e2062aec06_Out_0.GetTransformedUV(_Rotate_6bb4154ca8ad4704846be74d0292cc2f_Out_3));
                                                                                                        float _SampleTexture2D_2fd545645ee448609b600edb51209aaa_R_4 = _SampleTexture2D_2fd545645ee448609b600edb51209aaa_RGBA_0.r;
                                                                                                        float _SampleTexture2D_2fd545645ee448609b600edb51209aaa_G_5 = _SampleTexture2D_2fd545645ee448609b600edb51209aaa_RGBA_0.g;
                                                                                                        float _SampleTexture2D_2fd545645ee448609b600edb51209aaa_B_6 = _SampleTexture2D_2fd545645ee448609b600edb51209aaa_RGBA_0.b;
                                                                                                        float _SampleTexture2D_2fd545645ee448609b600edb51209aaa_A_7 = _SampleTexture2D_2fd545645ee448609b600edb51209aaa_RGBA_0.a;
                                                                                                        float _Split_19ff8587983246ac85c970e145e7295e_R_1 = IN.WorldSpaceNormal[0];
                                                                                                        float _Split_19ff8587983246ac85c970e145e7295e_G_2 = IN.WorldSpaceNormal[1];
                                                                                                        float _Split_19ff8587983246ac85c970e145e7295e_B_3 = IN.WorldSpaceNormal[2];
                                                                                                        float _Split_19ff8587983246ac85c970e145e7295e_A_4 = 0;
                                                                                                        float _Absolute_317391fafaa84374beca803aa565632c_Out_1;
                                                                                                        Unity_Absolute_float(_Split_19ff8587983246ac85c970e145e7295e_G_2, _Absolute_317391fafaa84374beca803aa565632c_Out_1);
                                                                                                        float _Comparison_08509dcd8b844663a8b9a254806453e0_Out_2;
                                                                                                        Unity_Comparison_Greater_float(_Absolute_317391fafaa84374beca803aa565632c_Out_1, 0.5, _Comparison_08509dcd8b844663a8b9a254806453e0_Out_2);
                                                                                                        UnityTexture2D _Property_d862f312261a47fc87211c138e9e2d65_Out_0 = UnityBuildTexture2DStructNoScale(_side);
                                                                                                        float _Split_33dfc647fa994b33bac6870687224f37_R_1 = IN.AbsoluteWorldSpacePosition[0];
                                                                                                        float _Split_33dfc647fa994b33bac6870687224f37_G_2 = IN.AbsoluteWorldSpacePosition[1];
                                                                                                        float _Split_33dfc647fa994b33bac6870687224f37_B_3 = IN.AbsoluteWorldSpacePosition[2];
                                                                                                        float _Split_33dfc647fa994b33bac6870687224f37_A_4 = 0;
                                                                                                        float2 _Vector2_5fb462bf0b6f4a18ac68e33ab02ca2de_Out_0 = float2(_Split_33dfc647fa994b33bac6870687224f37_R_1, _Split_33dfc647fa994b33bac6870687224f37_B_3);
                                                                                                        float _Property_03059c193ea74dd8b388680b85f07648_Out_0 = _size;
                                                                                                        float _Float_9d01c34c368948508ad404d5536aca12_Out_0 = _Property_03059c193ea74dd8b388680b85f07648_Out_0;
                                                                                                        float2 _Multiply_18516a081d504359bcad3aa790750518_Out_2;
                                                                                                        Unity_Multiply_float2_float2(_Vector2_5fb462bf0b6f4a18ac68e33ab02ca2de_Out_0, (_Float_9d01c34c368948508ad404d5536aca12_Out_0.xx), _Multiply_18516a081d504359bcad3aa790750518_Out_2);
                                                                                                        float4 _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_RGBA_0 = SAMPLE_TEXTURE2D(_Property_d862f312261a47fc87211c138e9e2d65_Out_0.tex, _Property_d862f312261a47fc87211c138e9e2d65_Out_0.samplerstate, _Property_d862f312261a47fc87211c138e9e2d65_Out_0.GetTransformedUV(_Multiply_18516a081d504359bcad3aa790750518_Out_2));
                                                                                                        float _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_R_4 = _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_RGBA_0.r;
                                                                                                        float _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_G_5 = _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_RGBA_0.g;
                                                                                                        float _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_B_6 = _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_RGBA_0.b;
                                                                                                        float _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_A_7 = _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_RGBA_0.a;
                                                                                                        UnityTexture2D _Property_3a54904fa5c74bbeb60261b8a76a189a_Out_0 = UnityBuildTexture2DStructNoScale(_front);
                                                                                                        float _Split_c79f25e24b934932b5cad363a3977e09_R_1 = IN.AbsoluteWorldSpacePosition[0];
                                                                                                        float _Split_c79f25e24b934932b5cad363a3977e09_G_2 = IN.AbsoluteWorldSpacePosition[1];
                                                                                                        float _Split_c79f25e24b934932b5cad363a3977e09_B_3 = IN.AbsoluteWorldSpacePosition[2];
                                                                                                        float _Split_c79f25e24b934932b5cad363a3977e09_A_4 = 0;
                                                                                                        float2 _Vector2_8457483515df467abc99f05f2c2f6398_Out_0 = float2(_Split_c79f25e24b934932b5cad363a3977e09_R_1, _Split_c79f25e24b934932b5cad363a3977e09_G_2);
                                                                                                        float _Property_fc91ea867aa4477485726d431d8da229_Out_0 = _size;
                                                                                                        float _Float_7e1bc66811ba41edb7a1f6e6df7f1d37_Out_0 = _Property_fc91ea867aa4477485726d431d8da229_Out_0;
                                                                                                        float2 _Multiply_b8fc0cf2c6414beabf7bce2b9ff68cb8_Out_2;
                                                                                                        Unity_Multiply_float2_float2(_Vector2_8457483515df467abc99f05f2c2f6398_Out_0, (_Float_7e1bc66811ba41edb7a1f6e6df7f1d37_Out_0.xx), _Multiply_b8fc0cf2c6414beabf7bce2b9ff68cb8_Out_2);
                                                                                                        float4 _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_RGBA_0 = SAMPLE_TEXTURE2D(_Property_3a54904fa5c74bbeb60261b8a76a189a_Out_0.tex, _Property_3a54904fa5c74bbeb60261b8a76a189a_Out_0.samplerstate, _Property_3a54904fa5c74bbeb60261b8a76a189a_Out_0.GetTransformedUV(_Multiply_b8fc0cf2c6414beabf7bce2b9ff68cb8_Out_2));
                                                                                                        float _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_R_4 = _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_RGBA_0.r;
                                                                                                        float _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_G_5 = _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_RGBA_0.g;
                                                                                                        float _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_B_6 = _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_RGBA_0.b;
                                                                                                        float _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_A_7 = _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_RGBA_0.a;
                                                                                                        float4 _Branch_09c1cdaea5f54a1d86615c158f30696f_Out_3;
                                                                                                        Unity_Branch_float4(_Comparison_08509dcd8b844663a8b9a254806453e0_Out_2, _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_RGBA_0, _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_RGBA_0, _Branch_09c1cdaea5f54a1d86615c158f30696f_Out_3);
                                                                                                        float4 _Branch_33ebb3d9ed944f64b6d69749f158256c_Out_3;
                                                                                                        Unity_Branch_float4(_Comparison_6e7dfe17f5834279863585dd909d6b85_Out_2, _SampleTexture2D_2fd545645ee448609b600edb51209aaa_RGBA_0, _Branch_09c1cdaea5f54a1d86615c158f30696f_Out_3, _Branch_33ebb3d9ed944f64b6d69749f158256c_Out_3);
                                                                                                        float _Property_94721ec2508f4046b88413c6bd4e982e_Out_0 = _CircleSmoothnes;
                                                                                                        float4 _ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                                                                                        float4 _Property_fd84b0cc463c44558e196f2b6699bb15_Out_0 = _Position;
                                                                                                        float4 _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3;
                                                                                                        Unity_Remap_float4(_Property_fd84b0cc463c44558e196f2b6699bb15_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3);
                                                                                                        float4 _Add_4b02f63dcd7e45e188328b812f76fa99_Out_2;
                                                                                                        Unity_Add_float4(_ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0, _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3, _Add_4b02f63dcd7e45e188328b812f76fa99_Out_2);
                                                                                                        float2 _TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3;
                                                                                                        Unity_TilingAndOffset_float((_ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0.xy), float2 (1, 1), (_Add_4b02f63dcd7e45e188328b812f76fa99_Out_2.xy), _TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3);
                                                                                                        float2 _Multiply_177cb9485e70424c8b113020b5fa561e_Out_2;
                                                                                                        Unity_Multiply_float2_float2(_TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3, float2(2, 2), _Multiply_177cb9485e70424c8b113020b5fa561e_Out_2);
                                                                                                        float2 _Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2;
                                                                                                        Unity_Subtract_float2(_Multiply_177cb9485e70424c8b113020b5fa561e_Out_2, float2(1, 1), _Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2);
                                                                                                        float _Divide_0183d4739fe2443987608ab3169a13d9_Out_2;
                                                                                                        Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_0183d4739fe2443987608ab3169a13d9_Out_2);
                                                                                                        float _Property_817685bafbc74ff594205cd2bbec6848_Out_0 = _CircleSize;
                                                                                                        float _Multiply_3046c926d1e34dce9c8963423a59249d_Out_2;
                                                                                                        Unity_Multiply_float_float(_Divide_0183d4739fe2443987608ab3169a13d9_Out_2, _Property_817685bafbc74ff594205cd2bbec6848_Out_0, _Multiply_3046c926d1e34dce9c8963423a59249d_Out_2);
                                                                                                        float2 _Vector2_fea5299f99e247c4ade509c5e8082e2d_Out_0 = float2(_Multiply_3046c926d1e34dce9c8963423a59249d_Out_2, _Property_817685bafbc74ff594205cd2bbec6848_Out_0);
                                                                                                        float2 _Divide_15271b15b3774cec9b09b48583a269d4_Out_2;
                                                                                                        Unity_Divide_float2(_Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2, _Vector2_fea5299f99e247c4ade509c5e8082e2d_Out_0, _Divide_15271b15b3774cec9b09b48583a269d4_Out_2);
                                                                                                        float _Length_8cc50efaa80e489482f7f21fa7901007_Out_1;
                                                                                                        Unity_Length_float2(_Divide_15271b15b3774cec9b09b48583a269d4_Out_2, _Length_8cc50efaa80e489482f7f21fa7901007_Out_1);
                                                                                                        float _OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1;
                                                                                                        Unity_OneMinus_float(_Length_8cc50efaa80e489482f7f21fa7901007_Out_1, _OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1);
                                                                                                        float _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1;
                                                                                                        Unity_Saturate_float(_OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1, _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1);
                                                                                                        float _Smoothstep_d81123febc5349c78b41d5023455b828_Out_3;
                                                                                                        Unity_Smoothstep_float(0, _Property_94721ec2508f4046b88413c6bd4e982e_Out_0, _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1, _Smoothstep_d81123febc5349c78b41d5023455b828_Out_3);
                                                                                                        float _Property_84f7f817f25348a3bec32f2049267d9d_Out_0 = _Alpha;
                                                                                                        float _Multiply_288a1c15da154ed2b2f4093423b86332_Out_2;
                                                                                                        Unity_Multiply_float_float(_Smoothstep_d81123febc5349c78b41d5023455b828_Out_3, _Property_84f7f817f25348a3bec32f2049267d9d_Out_0, _Multiply_288a1c15da154ed2b2f4093423b86332_Out_2);
                                                                                                        float _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1;
                                                                                                        Unity_OneMinus_float(_Multiply_288a1c15da154ed2b2f4093423b86332_Out_2, _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1);
                                                                                                        surface.BaseColor = (_Branch_33ebb3d9ed944f64b6d69749f158256c_Out_3.xyz);
                                                                                                        surface.Emission = float3(0, 0, 0);
                                                                                                        surface.Alpha = _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1;
                                                                                                        return surface;
                                                                                                    }

                                                                                                    // --------------------------------------------------
                                                                                                    // Build Graph Inputs
                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                                                                    #define VFX_SRP_VARYINGS Varyings
                                                                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                                    #endif
                                                                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                                    {
                                                                                                        VertexDescriptionInputs output;
                                                                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                        output.ObjectSpaceNormal = input.normalOS;
                                                                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                                        output.ObjectSpacePosition = input.positionOS;

                                                                                                        return output;
                                                                                                    }
                                                                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                                    {
                                                                                                        SurfaceDescriptionInputs output;
                                                                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                                    #endif



                                                                                                        // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                                                                                                        float3 unnormalizedNormalWS = input.normalWS;
                                                                                                        const float renormFactor = 1.0 / length(unnormalizedNormalWS);


                                                                                                        output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph


                                                                                                        output.WorldSpacePosition = input.positionWS;
                                                                                                        output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
                                                                                                        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                                    #else
                                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                                    #endif
                                                                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                            return output;
                                                                                                    }

                                                                                                    // --------------------------------------------------
                                                                                                    // Main

                                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

                                                                                                    // --------------------------------------------------
                                                                                                    // Visual Effect Vertex Invocations
                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                                    #endif

                                                                                                    ENDHLSL
                                                                                                    }
                                                                                                    Pass
                                                                                                    {
                                                                                                        Name "SceneSelectionPass"
                                                                                                        Tags
                                                                                                        {
                                                                                                            "LightMode" = "SceneSelectionPass"
                                                                                                        }

                                                                                                        // Render State
                                                                                                        Cull Off

                                                                                                        // Debug
                                                                                                        // <None>

                                                                                                        // --------------------------------------------------
                                                                                                        // Pass

                                                                                                        HLSLPROGRAM

                                                                                                        // Pragmas
                                                                                                        #pragma target 2.0
                                                                                                        #pragma only_renderers gles gles3 glcore d3d11
                                                                                                        #pragma multi_compile_instancing
                                                                                                        #pragma vertex vert
                                                                                                        #pragma fragment frag

                                                                                                        // DotsInstancingOptions: <None>
                                                                                                        // HybridV1InjectedBuiltinProperties: <None>

                                                                                                        // Keywords
                                                                                                        // PassKeywords: <None>
                                                                                                        // GraphKeywords: <None>

                                                                                                        // Defines

                                                                                                        #define _NORMALMAP 1
                                                                                                        #define _NORMAL_DROPOFF_TS 1
                                                                                                        #define ATTRIBUTES_NEED_NORMAL
                                                                                                        #define ATTRIBUTES_NEED_TANGENT
                                                                                                        #define VARYINGS_NEED_POSITION_WS
                                                                                                        #define FEATURES_GRAPH_VERTEX
                                                                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                                        #define SHADERPASS SHADERPASS_DEPTHONLY
                                                                                                        #define SCENESELECTIONPASS 1
                                                                                                        #define ALPHA_CLIP_THRESHOLD 1
                                                                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                                        // custom interpolator pre-include
                                                                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                                        // Includes
                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                                        // --------------------------------------------------
                                                                                                        // Structs and Packing

                                                                                                        // custom interpolators pre packing
                                                                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                                        struct Attributes
                                                                                                        {
                                                                                                             float3 positionOS : POSITION;
                                                                                                             float3 normalOS : NORMAL;
                                                                                                             float4 tangentOS : TANGENT;
                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                                                                            #endif
                                                                                                        };
                                                                                                        struct Varyings
                                                                                                        {
                                                                                                             float4 positionCS : SV_POSITION;
                                                                                                             float3 positionWS;
                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                            #endif
                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                            #endif
                                                                                                        };
                                                                                                        struct SurfaceDescriptionInputs
                                                                                                        {
                                                                                                             float3 WorldSpacePosition;
                                                                                                             float4 ScreenPosition;
                                                                                                        };
                                                                                                        struct VertexDescriptionInputs
                                                                                                        {
                                                                                                             float3 ObjectSpaceNormal;
                                                                                                             float3 ObjectSpaceTangent;
                                                                                                             float3 ObjectSpacePosition;
                                                                                                        };
                                                                                                        struct PackedVaryings
                                                                                                        {
                                                                                                             float4 positionCS : SV_POSITION;
                                                                                                             float3 interp0 : INTERP0;
                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                            #endif
                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                            #endif
                                                                                                        };

                                                                                                        PackedVaryings PackVaryings(Varyings input)
                                                                                                        {
                                                                                                            PackedVaryings output;
                                                                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                                                                            output.positionCS = input.positionCS;
                                                                                                            output.interp0.xyz = input.positionWS;
                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                            output.instanceID = input.instanceID;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                            #endif
                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                            output.cullFace = input.cullFace;
                                                                                                            #endif
                                                                                                            return output;
                                                                                                        }

                                                                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                                                                        {
                                                                                                            Varyings output;
                                                                                                            output.positionCS = input.positionCS;
                                                                                                            output.positionWS = input.interp0.xyz;
                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                            output.instanceID = input.instanceID;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                            #endif
                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                            output.cullFace = input.cullFace;
                                                                                                            #endif
                                                                                                            return output;
                                                                                                        }


                                                                                                        // --------------------------------------------------
                                                                                                        // Graph

                                                                                                        // Graph Properties
                                                                                                        CBUFFER_START(UnityPerMaterial)
                                                                                                        float _size;
                                                                                                        float4 _front_TexelSize;
                                                                                                        float4 _side_TexelSize;
                                                                                                        float _Alpha;
                                                                                                        float _CircleSize;
                                                                                                        float4 _Position;
                                                                                                        float _CircleSmoothnes;
                                                                                                        CBUFFER_END

                                                                                                            // Object and Global properties
                                                                                                            SAMPLER(SamplerState_Linear_Repeat);
                                                                                                            TEXTURE2D(_front);
                                                                                                            SAMPLER(sampler_front);
                                                                                                            TEXTURE2D(_side);
                                                                                                            SAMPLER(sampler_side);

                                                                                                            // Graph Includes
                                                                                                            // GraphIncludes: <None>

                                                                                                            // -- Property used by ScenePickingPass
                                                                                                            #ifdef SCENEPICKINGPASS
                                                                                                            float4 _SelectionID;
                                                                                                            #endif

                                                                                                            // -- Properties used by SceneSelectionPass
                                                                                                            #ifdef SCENESELECTIONPASS
                                                                                                            int _ObjectId;
                                                                                                            int _PassValue;
                                                                                                            #endif

                                                                                                            // Graph Functions

                                                                                                            void Unity_Remap_float4(float4 In, float2 InMinMax, float2 OutMinMax, out float4 Out)
                                                                                                            {
                                                                                                                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                                                                            }

                                                                                                            void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                                                                                            {
                                                                                                                Out = A + B;
                                                                                                            }

                                                                                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                                                            {
                                                                                                                Out = UV * Tiling + Offset;
                                                                                                            }

                                                                                                            void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                                                                                            {
                                                                                                                Out = A * B;
                                                                                                            }

                                                                                                            void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                                                                                            {
                                                                                                                Out = A - B;
                                                                                                            }

                                                                                                            void Unity_Divide_float(float A, float B, out float Out)
                                                                                                            {
                                                                                                                Out = A / B;
                                                                                                            }

                                                                                                            void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                                                            {
                                                                                                                Out = A * B;
                                                                                                            }

                                                                                                            void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                                                                                            {
                                                                                                                Out = A / B;
                                                                                                            }

                                                                                                            void Unity_Length_float2(float2 In, out float Out)
                                                                                                            {
                                                                                                                Out = length(In);
                                                                                                            }

                                                                                                            void Unity_OneMinus_float(float In, out float Out)
                                                                                                            {
                                                                                                                Out = 1 - In;
                                                                                                            }

                                                                                                            void Unity_Saturate_float(float In, out float Out)
                                                                                                            {
                                                                                                                Out = saturate(In);
                                                                                                            }

                                                                                                            void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                                                                                            {
                                                                                                                Out = smoothstep(Edge1, Edge2, In);
                                                                                                            }

                                                                                                            // Custom interpolators pre vertex
                                                                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                                            // Graph Vertex
                                                                                                            struct VertexDescription
                                                                                                            {
                                                                                                                float3 Position;
                                                                                                                float3 Normal;
                                                                                                                float3 Tangent;
                                                                                                            };

                                                                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                                            {
                                                                                                                VertexDescription description = (VertexDescription)0;
                                                                                                                description.Position = IN.ObjectSpacePosition;
                                                                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                                                                return description;
                                                                                                            }

                                                                                                            // Custom interpolators, pre surface
                                                                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                                            {
                                                                                                            return output;
                                                                                                            }
                                                                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                                            #endif

                                                                                                            // Graph Pixel
                                                                                                            struct SurfaceDescription
                                                                                                            {
                                                                                                                float Alpha;
                                                                                                            };

                                                                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                                            {
                                                                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                                float _Property_94721ec2508f4046b88413c6bd4e982e_Out_0 = _CircleSmoothnes;
                                                                                                                float4 _ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                                                                                                float4 _Property_fd84b0cc463c44558e196f2b6699bb15_Out_0 = _Position;
                                                                                                                float4 _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3;
                                                                                                                Unity_Remap_float4(_Property_fd84b0cc463c44558e196f2b6699bb15_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3);
                                                                                                                float4 _Add_4b02f63dcd7e45e188328b812f76fa99_Out_2;
                                                                                                                Unity_Add_float4(_ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0, _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3, _Add_4b02f63dcd7e45e188328b812f76fa99_Out_2);
                                                                                                                float2 _TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3;
                                                                                                                Unity_TilingAndOffset_float((_ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0.xy), float2 (1, 1), (_Add_4b02f63dcd7e45e188328b812f76fa99_Out_2.xy), _TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3);
                                                                                                                float2 _Multiply_177cb9485e70424c8b113020b5fa561e_Out_2;
                                                                                                                Unity_Multiply_float2_float2(_TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3, float2(2, 2), _Multiply_177cb9485e70424c8b113020b5fa561e_Out_2);
                                                                                                                float2 _Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2;
                                                                                                                Unity_Subtract_float2(_Multiply_177cb9485e70424c8b113020b5fa561e_Out_2, float2(1, 1), _Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2);
                                                                                                                float _Divide_0183d4739fe2443987608ab3169a13d9_Out_2;
                                                                                                                Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_0183d4739fe2443987608ab3169a13d9_Out_2);
                                                                                                                float _Property_817685bafbc74ff594205cd2bbec6848_Out_0 = _CircleSize;
                                                                                                                float _Multiply_3046c926d1e34dce9c8963423a59249d_Out_2;
                                                                                                                Unity_Multiply_float_float(_Divide_0183d4739fe2443987608ab3169a13d9_Out_2, _Property_817685bafbc74ff594205cd2bbec6848_Out_0, _Multiply_3046c926d1e34dce9c8963423a59249d_Out_2);
                                                                                                                float2 _Vector2_fea5299f99e247c4ade509c5e8082e2d_Out_0 = float2(_Multiply_3046c926d1e34dce9c8963423a59249d_Out_2, _Property_817685bafbc74ff594205cd2bbec6848_Out_0);
                                                                                                                float2 _Divide_15271b15b3774cec9b09b48583a269d4_Out_2;
                                                                                                                Unity_Divide_float2(_Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2, _Vector2_fea5299f99e247c4ade509c5e8082e2d_Out_0, _Divide_15271b15b3774cec9b09b48583a269d4_Out_2);
                                                                                                                float _Length_8cc50efaa80e489482f7f21fa7901007_Out_1;
                                                                                                                Unity_Length_float2(_Divide_15271b15b3774cec9b09b48583a269d4_Out_2, _Length_8cc50efaa80e489482f7f21fa7901007_Out_1);
                                                                                                                float _OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1;
                                                                                                                Unity_OneMinus_float(_Length_8cc50efaa80e489482f7f21fa7901007_Out_1, _OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1);
                                                                                                                float _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1;
                                                                                                                Unity_Saturate_float(_OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1, _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1);
                                                                                                                float _Smoothstep_d81123febc5349c78b41d5023455b828_Out_3;
                                                                                                                Unity_Smoothstep_float(0, _Property_94721ec2508f4046b88413c6bd4e982e_Out_0, _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1, _Smoothstep_d81123febc5349c78b41d5023455b828_Out_3);
                                                                                                                float _Property_84f7f817f25348a3bec32f2049267d9d_Out_0 = _Alpha;
                                                                                                                float _Multiply_288a1c15da154ed2b2f4093423b86332_Out_2;
                                                                                                                Unity_Multiply_float_float(_Smoothstep_d81123febc5349c78b41d5023455b828_Out_3, _Property_84f7f817f25348a3bec32f2049267d9d_Out_0, _Multiply_288a1c15da154ed2b2f4093423b86332_Out_2);
                                                                                                                float _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1;
                                                                                                                Unity_OneMinus_float(_Multiply_288a1c15da154ed2b2f4093423b86332_Out_2, _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1);
                                                                                                                surface.Alpha = _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1;
                                                                                                                return surface;
                                                                                                            }

                                                                                                            // --------------------------------------------------
                                                                                                            // Build Graph Inputs
                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                                                                            #define VFX_SRP_VARYINGS Varyings
                                                                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                                            #endif
                                                                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                                            {
                                                                                                                VertexDescriptionInputs output;
                                                                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                                                output.ObjectSpacePosition = input.positionOS;

                                                                                                                return output;
                                                                                                            }
                                                                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                                            {
                                                                                                                SurfaceDescriptionInputs output;
                                                                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                                            #endif







                                                                                                                output.WorldSpacePosition = input.positionWS;
                                                                                                                output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                                            #else
                                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                                            #endif
                                                                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                                    return output;
                                                                                                            }

                                                                                                            // --------------------------------------------------
                                                                                                            // Main

                                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

                                                                                                            // --------------------------------------------------
                                                                                                            // Visual Effect Vertex Invocations
                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                                            #endif

                                                                                                            ENDHLSL
                                                                                                            }
                                                                                                            Pass
                                                                                                            {
                                                                                                                Name "ScenePickingPass"
                                                                                                                Tags
                                                                                                                {
                                                                                                                    "LightMode" = "Picking"
                                                                                                                }

                                                                                                                // Render State
                                                                                                                Cull Back

                                                                                                                // Debug
                                                                                                                // <None>

                                                                                                                // --------------------------------------------------
                                                                                                                // Pass

                                                                                                                HLSLPROGRAM

                                                                                                                // Pragmas
                                                                                                                #pragma target 2.0
                                                                                                                #pragma only_renderers gles gles3 glcore d3d11
                                                                                                                #pragma multi_compile_instancing
                                                                                                                #pragma vertex vert
                                                                                                                #pragma fragment frag

                                                                                                                // DotsInstancingOptions: <None>
                                                                                                                // HybridV1InjectedBuiltinProperties: <None>

                                                                                                                // Keywords
                                                                                                                // PassKeywords: <None>
                                                                                                                // GraphKeywords: <None>

                                                                                                                // Defines

                                                                                                                #define _NORMALMAP 1
                                                                                                                #define _NORMAL_DROPOFF_TS 1
                                                                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                                                                #define VARYINGS_NEED_POSITION_WS
                                                                                                                #define FEATURES_GRAPH_VERTEX
                                                                                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                                                #define SHADERPASS SHADERPASS_DEPTHONLY
                                                                                                                #define SCENEPICKINGPASS 1
                                                                                                                #define ALPHA_CLIP_THRESHOLD 1
                                                                                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                                                // custom interpolator pre-include
                                                                                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                                                // Includes
                                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                                                // --------------------------------------------------
                                                                                                                // Structs and Packing

                                                                                                                // custom interpolators pre packing
                                                                                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                                                struct Attributes
                                                                                                                {
                                                                                                                     float3 positionOS : POSITION;
                                                                                                                     float3 normalOS : NORMAL;
                                                                                                                     float4 tangentOS : TANGENT;
                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                                                                                    #endif
                                                                                                                };
                                                                                                                struct Varyings
                                                                                                                {
                                                                                                                     float4 positionCS : SV_POSITION;
                                                                                                                     float3 positionWS;
                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                                    #endif
                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                                    #endif
                                                                                                                };
                                                                                                                struct SurfaceDescriptionInputs
                                                                                                                {
                                                                                                                     float3 WorldSpacePosition;
                                                                                                                     float4 ScreenPosition;
                                                                                                                };
                                                                                                                struct VertexDescriptionInputs
                                                                                                                {
                                                                                                                     float3 ObjectSpaceNormal;
                                                                                                                     float3 ObjectSpaceTangent;
                                                                                                                     float3 ObjectSpacePosition;
                                                                                                                };
                                                                                                                struct PackedVaryings
                                                                                                                {
                                                                                                                     float4 positionCS : SV_POSITION;
                                                                                                                     float3 interp0 : INTERP0;
                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                                    #endif
                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                                    #endif
                                                                                                                };

                                                                                                                PackedVaryings PackVaryings(Varyings input)
                                                                                                                {
                                                                                                                    PackedVaryings output;
                                                                                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                                                                                    output.positionCS = input.positionCS;
                                                                                                                    output.interp0.xyz = input.positionWS;
                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                    output.instanceID = input.instanceID;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                                    #endif
                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                    output.cullFace = input.cullFace;
                                                                                                                    #endif
                                                                                                                    return output;
                                                                                                                }

                                                                                                                Varyings UnpackVaryings(PackedVaryings input)
                                                                                                                {
                                                                                                                    Varyings output;
                                                                                                                    output.positionCS = input.positionCS;
                                                                                                                    output.positionWS = input.interp0.xyz;
                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                    output.instanceID = input.instanceID;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                                    #endif
                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                    output.cullFace = input.cullFace;
                                                                                                                    #endif
                                                                                                                    return output;
                                                                                                                }


                                                                                                                // --------------------------------------------------
                                                                                                                // Graph

                                                                                                                // Graph Properties
                                                                                                                CBUFFER_START(UnityPerMaterial)
                                                                                                                float _size;
                                                                                                                float4 _front_TexelSize;
                                                                                                                float4 _side_TexelSize;
                                                                                                                float _Alpha;
                                                                                                                float _CircleSize;
                                                                                                                float4 _Position;
                                                                                                                float _CircleSmoothnes;
                                                                                                                CBUFFER_END

                                                                                                                    // Object and Global properties
                                                                                                                    SAMPLER(SamplerState_Linear_Repeat);
                                                                                                                    TEXTURE2D(_front);
                                                                                                                    SAMPLER(sampler_front);
                                                                                                                    TEXTURE2D(_side);
                                                                                                                    SAMPLER(sampler_side);

                                                                                                                    // Graph Includes
                                                                                                                    // GraphIncludes: <None>

                                                                                                                    // -- Property used by ScenePickingPass
                                                                                                                    #ifdef SCENEPICKINGPASS
                                                                                                                    float4 _SelectionID;
                                                                                                                    #endif

                                                                                                                    // -- Properties used by SceneSelectionPass
                                                                                                                    #ifdef SCENESELECTIONPASS
                                                                                                                    int _ObjectId;
                                                                                                                    int _PassValue;
                                                                                                                    #endif

                                                                                                                    // Graph Functions

                                                                                                                    void Unity_Remap_float4(float4 In, float2 InMinMax, float2 OutMinMax, out float4 Out)
                                                                                                                    {
                                                                                                                        Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                                                                                    }

                                                                                                                    void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                                                                                                    {
                                                                                                                        Out = A + B;
                                                                                                                    }

                                                                                                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                                                                    {
                                                                                                                        Out = UV * Tiling + Offset;
                                                                                                                    }

                                                                                                                    void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                                                                                                    {
                                                                                                                        Out = A * B;
                                                                                                                    }

                                                                                                                    void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                                                                                                    {
                                                                                                                        Out = A - B;
                                                                                                                    }

                                                                                                                    void Unity_Divide_float(float A, float B, out float Out)
                                                                                                                    {
                                                                                                                        Out = A / B;
                                                                                                                    }

                                                                                                                    void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                                                                    {
                                                                                                                        Out = A * B;
                                                                                                                    }

                                                                                                                    void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                                                                                                    {
                                                                                                                        Out = A / B;
                                                                                                                    }

                                                                                                                    void Unity_Length_float2(float2 In, out float Out)
                                                                                                                    {
                                                                                                                        Out = length(In);
                                                                                                                    }

                                                                                                                    void Unity_OneMinus_float(float In, out float Out)
                                                                                                                    {
                                                                                                                        Out = 1 - In;
                                                                                                                    }

                                                                                                                    void Unity_Saturate_float(float In, out float Out)
                                                                                                                    {
                                                                                                                        Out = saturate(In);
                                                                                                                    }

                                                                                                                    void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                                                                                                    {
                                                                                                                        Out = smoothstep(Edge1, Edge2, In);
                                                                                                                    }

                                                                                                                    // Custom interpolators pre vertex
                                                                                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                                                    // Graph Vertex
                                                                                                                    struct VertexDescription
                                                                                                                    {
                                                                                                                        float3 Position;
                                                                                                                        float3 Normal;
                                                                                                                        float3 Tangent;
                                                                                                                    };

                                                                                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                                                    {
                                                                                                                        VertexDescription description = (VertexDescription)0;
                                                                                                                        description.Position = IN.ObjectSpacePosition;
                                                                                                                        description.Normal = IN.ObjectSpaceNormal;
                                                                                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                                                                                        return description;
                                                                                                                    }

                                                                                                                    // Custom interpolators, pre surface
                                                                                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                                                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                                                    {
                                                                                                                    return output;
                                                                                                                    }
                                                                                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                                                    #endif

                                                                                                                    // Graph Pixel
                                                                                                                    struct SurfaceDescription
                                                                                                                    {
                                                                                                                        float Alpha;
                                                                                                                    };

                                                                                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                                                    {
                                                                                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                                        float _Property_94721ec2508f4046b88413c6bd4e982e_Out_0 = _CircleSmoothnes;
                                                                                                                        float4 _ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                                                                                                        float4 _Property_fd84b0cc463c44558e196f2b6699bb15_Out_0 = _Position;
                                                                                                                        float4 _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3;
                                                                                                                        Unity_Remap_float4(_Property_fd84b0cc463c44558e196f2b6699bb15_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3);
                                                                                                                        float4 _Add_4b02f63dcd7e45e188328b812f76fa99_Out_2;
                                                                                                                        Unity_Add_float4(_ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0, _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3, _Add_4b02f63dcd7e45e188328b812f76fa99_Out_2);
                                                                                                                        float2 _TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3;
                                                                                                                        Unity_TilingAndOffset_float((_ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0.xy), float2 (1, 1), (_Add_4b02f63dcd7e45e188328b812f76fa99_Out_2.xy), _TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3);
                                                                                                                        float2 _Multiply_177cb9485e70424c8b113020b5fa561e_Out_2;
                                                                                                                        Unity_Multiply_float2_float2(_TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3, float2(2, 2), _Multiply_177cb9485e70424c8b113020b5fa561e_Out_2);
                                                                                                                        float2 _Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2;
                                                                                                                        Unity_Subtract_float2(_Multiply_177cb9485e70424c8b113020b5fa561e_Out_2, float2(1, 1), _Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2);
                                                                                                                        float _Divide_0183d4739fe2443987608ab3169a13d9_Out_2;
                                                                                                                        Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_0183d4739fe2443987608ab3169a13d9_Out_2);
                                                                                                                        float _Property_817685bafbc74ff594205cd2bbec6848_Out_0 = _CircleSize;
                                                                                                                        float _Multiply_3046c926d1e34dce9c8963423a59249d_Out_2;
                                                                                                                        Unity_Multiply_float_float(_Divide_0183d4739fe2443987608ab3169a13d9_Out_2, _Property_817685bafbc74ff594205cd2bbec6848_Out_0, _Multiply_3046c926d1e34dce9c8963423a59249d_Out_2);
                                                                                                                        float2 _Vector2_fea5299f99e247c4ade509c5e8082e2d_Out_0 = float2(_Multiply_3046c926d1e34dce9c8963423a59249d_Out_2, _Property_817685bafbc74ff594205cd2bbec6848_Out_0);
                                                                                                                        float2 _Divide_15271b15b3774cec9b09b48583a269d4_Out_2;
                                                                                                                        Unity_Divide_float2(_Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2, _Vector2_fea5299f99e247c4ade509c5e8082e2d_Out_0, _Divide_15271b15b3774cec9b09b48583a269d4_Out_2);
                                                                                                                        float _Length_8cc50efaa80e489482f7f21fa7901007_Out_1;
                                                                                                                        Unity_Length_float2(_Divide_15271b15b3774cec9b09b48583a269d4_Out_2, _Length_8cc50efaa80e489482f7f21fa7901007_Out_1);
                                                                                                                        float _OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1;
                                                                                                                        Unity_OneMinus_float(_Length_8cc50efaa80e489482f7f21fa7901007_Out_1, _OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1);
                                                                                                                        float _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1;
                                                                                                                        Unity_Saturate_float(_OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1, _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1);
                                                                                                                        float _Smoothstep_d81123febc5349c78b41d5023455b828_Out_3;
                                                                                                                        Unity_Smoothstep_float(0, _Property_94721ec2508f4046b88413c6bd4e982e_Out_0, _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1, _Smoothstep_d81123febc5349c78b41d5023455b828_Out_3);
                                                                                                                        float _Property_84f7f817f25348a3bec32f2049267d9d_Out_0 = _Alpha;
                                                                                                                        float _Multiply_288a1c15da154ed2b2f4093423b86332_Out_2;
                                                                                                                        Unity_Multiply_float_float(_Smoothstep_d81123febc5349c78b41d5023455b828_Out_3, _Property_84f7f817f25348a3bec32f2049267d9d_Out_0, _Multiply_288a1c15da154ed2b2f4093423b86332_Out_2);
                                                                                                                        float _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1;
                                                                                                                        Unity_OneMinus_float(_Multiply_288a1c15da154ed2b2f4093423b86332_Out_2, _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1);
                                                                                                                        surface.Alpha = _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1;
                                                                                                                        return surface;
                                                                                                                    }

                                                                                                                    // --------------------------------------------------
                                                                                                                    // Build Graph Inputs
                                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                                                                                    #define VFX_SRP_VARYINGS Varyings
                                                                                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                                                    #endif
                                                                                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                                                    {
                                                                                                                        VertexDescriptionInputs output;
                                                                                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                                        output.ObjectSpaceNormal = input.normalOS;
                                                                                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                                                        output.ObjectSpacePosition = input.positionOS;

                                                                                                                        return output;
                                                                                                                    }
                                                                                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                                                    {
                                                                                                                        SurfaceDescriptionInputs output;
                                                                                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                                                    #endif







                                                                                                                        output.WorldSpacePosition = input.positionWS;
                                                                                                                        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                                                    #else
                                                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                                                    #endif
                                                                                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                                            return output;
                                                                                                                    }

                                                                                                                    // --------------------------------------------------
                                                                                                                    // Main

                                                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

                                                                                                                    // --------------------------------------------------
                                                                                                                    // Visual Effect Vertex Invocations
                                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                                                    #endif

                                                                                                                    ENDHLSL
                                                                                                                    }
                                                                                                                    Pass
                                                                                                                    {
                                                                                                                        // Name: <None>
                                                                                                                        Tags
                                                                                                                        {
                                                                                                                            "LightMode" = "Universal2D"
                                                                                                                        }

                                                                                                                        // Render State
                                                                                                                        Cull Back
                                                                                                                        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                                                                                                                        ZTest LEqual
                                                                                                                        ZWrite Off

                                                                                                                        // Debug
                                                                                                                        // <None>

                                                                                                                        // --------------------------------------------------
                                                                                                                        // Pass

                                                                                                                        HLSLPROGRAM

                                                                                                                        // Pragmas
                                                                                                                        #pragma target 2.0
                                                                                                                        #pragma only_renderers gles gles3 glcore d3d11
                                                                                                                        #pragma multi_compile_instancing
                                                                                                                        #pragma vertex vert
                                                                                                                        #pragma fragment frag

                                                                                                                        // DotsInstancingOptions: <None>
                                                                                                                        // HybridV1InjectedBuiltinProperties: <None>

                                                                                                                        // Keywords
                                                                                                                        // PassKeywords: <None>
                                                                                                                        // GraphKeywords: <None>

                                                                                                                        // Defines

                                                                                                                        #define _NORMALMAP 1
                                                                                                                        #define _NORMAL_DROPOFF_TS 1
                                                                                                                        #define ATTRIBUTES_NEED_NORMAL
                                                                                                                        #define ATTRIBUTES_NEED_TANGENT
                                                                                                                        #define VARYINGS_NEED_POSITION_WS
                                                                                                                        #define VARYINGS_NEED_NORMAL_WS
                                                                                                                        #define FEATURES_GRAPH_VERTEX
                                                                                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                                                        #define SHADERPASS SHADERPASS_2D
                                                                                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                                                        // custom interpolator pre-include
                                                                                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                                                        // Includes
                                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                                                        // --------------------------------------------------
                                                                                                                        // Structs and Packing

                                                                                                                        // custom interpolators pre packing
                                                                                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                                                        struct Attributes
                                                                                                                        {
                                                                                                                             float3 positionOS : POSITION;
                                                                                                                             float3 normalOS : NORMAL;
                                                                                                                             float4 tangentOS : TANGENT;
                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                                                                                            #endif
                                                                                                                        };
                                                                                                                        struct Varyings
                                                                                                                        {
                                                                                                                             float4 positionCS : SV_POSITION;
                                                                                                                             float3 positionWS;
                                                                                                                             float3 normalWS;
                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                                            #endif
                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                                            #endif
                                                                                                                        };
                                                                                                                        struct SurfaceDescriptionInputs
                                                                                                                        {
                                                                                                                             float3 WorldSpaceNormal;
                                                                                                                             float3 WorldSpacePosition;
                                                                                                                             float3 AbsoluteWorldSpacePosition;
                                                                                                                             float4 ScreenPosition;
                                                                                                                        };
                                                                                                                        struct VertexDescriptionInputs
                                                                                                                        {
                                                                                                                             float3 ObjectSpaceNormal;
                                                                                                                             float3 ObjectSpaceTangent;
                                                                                                                             float3 ObjectSpacePosition;
                                                                                                                        };
                                                                                                                        struct PackedVaryings
                                                                                                                        {
                                                                                                                             float4 positionCS : SV_POSITION;
                                                                                                                             float3 interp0 : INTERP0;
                                                                                                                             float3 interp1 : INTERP1;
                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                                            #endif
                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                                            #endif
                                                                                                                        };

                                                                                                                        PackedVaryings PackVaryings(Varyings input)
                                                                                                                        {
                                                                                                                            PackedVaryings output;
                                                                                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                                                                                            output.positionCS = input.positionCS;
                                                                                                                            output.interp0.xyz = input.positionWS;
                                                                                                                            output.interp1.xyz = input.normalWS;
                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                            output.instanceID = input.instanceID;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                                            #endif
                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                            output.cullFace = input.cullFace;
                                                                                                                            #endif
                                                                                                                            return output;
                                                                                                                        }

                                                                                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                                                                                        {
                                                                                                                            Varyings output;
                                                                                                                            output.positionCS = input.positionCS;
                                                                                                                            output.positionWS = input.interp0.xyz;
                                                                                                                            output.normalWS = input.interp1.xyz;
                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                            output.instanceID = input.instanceID;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                                            #endif
                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                            output.cullFace = input.cullFace;
                                                                                                                            #endif
                                                                                                                            return output;
                                                                                                                        }


                                                                                                                        // --------------------------------------------------
                                                                                                                        // Graph

                                                                                                                        // Graph Properties
                                                                                                                        CBUFFER_START(UnityPerMaterial)
                                                                                                                        float _size;
                                                                                                                        float4 _front_TexelSize;
                                                                                                                        float4 _side_TexelSize;
                                                                                                                        float _Alpha;
                                                                                                                        float _CircleSize;
                                                                                                                        float4 _Position;
                                                                                                                        float _CircleSmoothnes;
                                                                                                                        CBUFFER_END

                                                                                                                            // Object and Global properties
                                                                                                                            SAMPLER(SamplerState_Linear_Repeat);
                                                                                                                            TEXTURE2D(_front);
                                                                                                                            SAMPLER(sampler_front);
                                                                                                                            TEXTURE2D(_side);
                                                                                                                            SAMPLER(sampler_side);

                                                                                                                            // Graph Includes
                                                                                                                            // GraphIncludes: <None>

                                                                                                                            // -- Property used by ScenePickingPass
                                                                                                                            #ifdef SCENEPICKINGPASS
                                                                                                                            float4 _SelectionID;
                                                                                                                            #endif

                                                                                                                            // -- Properties used by SceneSelectionPass
                                                                                                                            #ifdef SCENESELECTIONPASS
                                                                                                                            int _ObjectId;
                                                                                                                            int _PassValue;
                                                                                                                            #endif

                                                                                                                            // Graph Functions

                                                                                                                            void Unity_Absolute_float(float In, out float Out)
                                                                                                                            {
                                                                                                                                Out = abs(In);
                                                                                                                            }

                                                                                                                            void Unity_Comparison_Greater_float(float A, float B, out float Out)
                                                                                                                            {
                                                                                                                                Out = A > B ? 1 : 0;
                                                                                                                            }

                                                                                                                            void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                                                                                                            {
                                                                                                                                Out = A * B;
                                                                                                                            }

                                                                                                                            void Unity_Rotate_Degrees_float(float2 UV, float2 Center, float Rotation, out float2 Out)
                                                                                                                            {
                                                                                                                                //rotation matrix
                                                                                                                                Rotation = Rotation * (3.1415926f / 180.0f);
                                                                                                                                UV -= Center;
                                                                                                                                float s = sin(Rotation);
                                                                                                                                float c = cos(Rotation);

                                                                                                                                //center rotation matrix
                                                                                                                                float2x2 rMatrix = float2x2(c, -s, s, c);
                                                                                                                                rMatrix *= 0.5;
                                                                                                                                rMatrix += 0.5;
                                                                                                                                rMatrix = rMatrix * 2 - 1;

                                                                                                                                //multiply the UVs by the rotation matrix
                                                                                                                                UV.xy = mul(UV.xy, rMatrix);
                                                                                                                                UV += Center;

                                                                                                                                Out = UV;
                                                                                                                            }

                                                                                                                            void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
                                                                                                                            {
                                                                                                                                Out = Predicate ? True : False;
                                                                                                                            }

                                                                                                                            void Unity_Remap_float4(float4 In, float2 InMinMax, float2 OutMinMax, out float4 Out)
                                                                                                                            {
                                                                                                                                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                                                                                            }

                                                                                                                            void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                                                                                                            {
                                                                                                                                Out = A + B;
                                                                                                                            }

                                                                                                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                                                                            {
                                                                                                                                Out = UV * Tiling + Offset;
                                                                                                                            }

                                                                                                                            void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                                                                                                            {
                                                                                                                                Out = A - B;
                                                                                                                            }

                                                                                                                            void Unity_Divide_float(float A, float B, out float Out)
                                                                                                                            {
                                                                                                                                Out = A / B;
                                                                                                                            }

                                                                                                                            void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                                                                            {
                                                                                                                                Out = A * B;
                                                                                                                            }

                                                                                                                            void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                                                                                                            {
                                                                                                                                Out = A / B;
                                                                                                                            }

                                                                                                                            void Unity_Length_float2(float2 In, out float Out)
                                                                                                                            {
                                                                                                                                Out = length(In);
                                                                                                                            }

                                                                                                                            void Unity_OneMinus_float(float In, out float Out)
                                                                                                                            {
                                                                                                                                Out = 1 - In;
                                                                                                                            }

                                                                                                                            void Unity_Saturate_float(float In, out float Out)
                                                                                                                            {
                                                                                                                                Out = saturate(In);
                                                                                                                            }

                                                                                                                            void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                                                                                                            {
                                                                                                                                Out = smoothstep(Edge1, Edge2, In);
                                                                                                                            }

                                                                                                                            // Custom interpolators pre vertex
                                                                                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                                                            // Graph Vertex
                                                                                                                            struct VertexDescription
                                                                                                                            {
                                                                                                                                float3 Position;
                                                                                                                                float3 Normal;
                                                                                                                                float3 Tangent;
                                                                                                                            };

                                                                                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                                                            {
                                                                                                                                VertexDescription description = (VertexDescription)0;
                                                                                                                                description.Position = IN.ObjectSpacePosition;
                                                                                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                                                                                return description;
                                                                                                                            }

                                                                                                                            // Custom interpolators, pre surface
                                                                                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                                                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                                                            {
                                                                                                                            return output;
                                                                                                                            }
                                                                                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                                                            #endif

                                                                                                                            // Graph Pixel
                                                                                                                            struct SurfaceDescription
                                                                                                                            {
                                                                                                                                float3 BaseColor;
                                                                                                                                float Alpha;
                                                                                                                            };

                                                                                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                                                            {
                                                                                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                                                float _Split_e3c2fdf12dbc4838a8bd514815889da8_R_1 = IN.WorldSpaceNormal[0];
                                                                                                                                float _Split_e3c2fdf12dbc4838a8bd514815889da8_G_2 = IN.WorldSpaceNormal[1];
                                                                                                                                float _Split_e3c2fdf12dbc4838a8bd514815889da8_B_3 = IN.WorldSpaceNormal[2];
                                                                                                                                float _Split_e3c2fdf12dbc4838a8bd514815889da8_A_4 = 0;
                                                                                                                                float _Absolute_54fb81dd1c194d60b704c9f81498ffc9_Out_1;
                                                                                                                                Unity_Absolute_float(_Split_e3c2fdf12dbc4838a8bd514815889da8_R_1, _Absolute_54fb81dd1c194d60b704c9f81498ffc9_Out_1);
                                                                                                                                float _Comparison_6e7dfe17f5834279863585dd909d6b85_Out_2;
                                                                                                                                Unity_Comparison_Greater_float(_Absolute_54fb81dd1c194d60b704c9f81498ffc9_Out_1, 0.5, _Comparison_6e7dfe17f5834279863585dd909d6b85_Out_2);
                                                                                                                                UnityTexture2D _Property_95f1b87d5b974a7e8e84e0e2062aec06_Out_0 = UnityBuildTexture2DStructNoScale(_side);
                                                                                                                                float _Split_091acb0967a542d5a282773762d4fcea_R_1 = IN.AbsoluteWorldSpacePosition[0];
                                                                                                                                float _Split_091acb0967a542d5a282773762d4fcea_G_2 = IN.AbsoluteWorldSpacePosition[1];
                                                                                                                                float _Split_091acb0967a542d5a282773762d4fcea_B_3 = IN.AbsoluteWorldSpacePosition[2];
                                                                                                                                float _Split_091acb0967a542d5a282773762d4fcea_A_4 = 0;
                                                                                                                                float2 _Vector2_9cb3ee01611c48a1bcef7c9c847c8fa7_Out_0 = float2(_Split_091acb0967a542d5a282773762d4fcea_G_2, _Split_091acb0967a542d5a282773762d4fcea_B_3);
                                                                                                                                float _Property_0ad1939b470a44f8be3e74a775ca3ed3_Out_0 = _size;
                                                                                                                                float _Float_620d3ee1a57d48f98f837d44647977bc_Out_0 = _Property_0ad1939b470a44f8be3e74a775ca3ed3_Out_0;
                                                                                                                                float2 _Multiply_6d7b5b0483d6477385ad7919aa9270ba_Out_2;
                                                                                                                                Unity_Multiply_float2_float2(_Vector2_9cb3ee01611c48a1bcef7c9c847c8fa7_Out_0, (_Float_620d3ee1a57d48f98f837d44647977bc_Out_0.xx), _Multiply_6d7b5b0483d6477385ad7919aa9270ba_Out_2);
                                                                                                                                float2 _Rotate_6bb4154ca8ad4704846be74d0292cc2f_Out_3;
                                                                                                                                Unity_Rotate_Degrees_float(_Multiply_6d7b5b0483d6477385ad7919aa9270ba_Out_2, float2 (0.5, 0.5), -90, _Rotate_6bb4154ca8ad4704846be74d0292cc2f_Out_3);
                                                                                                                                float4 _SampleTexture2D_2fd545645ee448609b600edb51209aaa_RGBA_0 = SAMPLE_TEXTURE2D(_Property_95f1b87d5b974a7e8e84e0e2062aec06_Out_0.tex, _Property_95f1b87d5b974a7e8e84e0e2062aec06_Out_0.samplerstate, _Property_95f1b87d5b974a7e8e84e0e2062aec06_Out_0.GetTransformedUV(_Rotate_6bb4154ca8ad4704846be74d0292cc2f_Out_3));
                                                                                                                                float _SampleTexture2D_2fd545645ee448609b600edb51209aaa_R_4 = _SampleTexture2D_2fd545645ee448609b600edb51209aaa_RGBA_0.r;
                                                                                                                                float _SampleTexture2D_2fd545645ee448609b600edb51209aaa_G_5 = _SampleTexture2D_2fd545645ee448609b600edb51209aaa_RGBA_0.g;
                                                                                                                                float _SampleTexture2D_2fd545645ee448609b600edb51209aaa_B_6 = _SampleTexture2D_2fd545645ee448609b600edb51209aaa_RGBA_0.b;
                                                                                                                                float _SampleTexture2D_2fd545645ee448609b600edb51209aaa_A_7 = _SampleTexture2D_2fd545645ee448609b600edb51209aaa_RGBA_0.a;
                                                                                                                                float _Split_19ff8587983246ac85c970e145e7295e_R_1 = IN.WorldSpaceNormal[0];
                                                                                                                                float _Split_19ff8587983246ac85c970e145e7295e_G_2 = IN.WorldSpaceNormal[1];
                                                                                                                                float _Split_19ff8587983246ac85c970e145e7295e_B_3 = IN.WorldSpaceNormal[2];
                                                                                                                                float _Split_19ff8587983246ac85c970e145e7295e_A_4 = 0;
                                                                                                                                float _Absolute_317391fafaa84374beca803aa565632c_Out_1;
                                                                                                                                Unity_Absolute_float(_Split_19ff8587983246ac85c970e145e7295e_G_2, _Absolute_317391fafaa84374beca803aa565632c_Out_1);
                                                                                                                                float _Comparison_08509dcd8b844663a8b9a254806453e0_Out_2;
                                                                                                                                Unity_Comparison_Greater_float(_Absolute_317391fafaa84374beca803aa565632c_Out_1, 0.5, _Comparison_08509dcd8b844663a8b9a254806453e0_Out_2);
                                                                                                                                UnityTexture2D _Property_d862f312261a47fc87211c138e9e2d65_Out_0 = UnityBuildTexture2DStructNoScale(_side);
                                                                                                                                float _Split_33dfc647fa994b33bac6870687224f37_R_1 = IN.AbsoluteWorldSpacePosition[0];
                                                                                                                                float _Split_33dfc647fa994b33bac6870687224f37_G_2 = IN.AbsoluteWorldSpacePosition[1];
                                                                                                                                float _Split_33dfc647fa994b33bac6870687224f37_B_3 = IN.AbsoluteWorldSpacePosition[2];
                                                                                                                                float _Split_33dfc647fa994b33bac6870687224f37_A_4 = 0;
                                                                                                                                float2 _Vector2_5fb462bf0b6f4a18ac68e33ab02ca2de_Out_0 = float2(_Split_33dfc647fa994b33bac6870687224f37_R_1, _Split_33dfc647fa994b33bac6870687224f37_B_3);
                                                                                                                                float _Property_03059c193ea74dd8b388680b85f07648_Out_0 = _size;
                                                                                                                                float _Float_9d01c34c368948508ad404d5536aca12_Out_0 = _Property_03059c193ea74dd8b388680b85f07648_Out_0;
                                                                                                                                float2 _Multiply_18516a081d504359bcad3aa790750518_Out_2;
                                                                                                                                Unity_Multiply_float2_float2(_Vector2_5fb462bf0b6f4a18ac68e33ab02ca2de_Out_0, (_Float_9d01c34c368948508ad404d5536aca12_Out_0.xx), _Multiply_18516a081d504359bcad3aa790750518_Out_2);
                                                                                                                                float4 _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_RGBA_0 = SAMPLE_TEXTURE2D(_Property_d862f312261a47fc87211c138e9e2d65_Out_0.tex, _Property_d862f312261a47fc87211c138e9e2d65_Out_0.samplerstate, _Property_d862f312261a47fc87211c138e9e2d65_Out_0.GetTransformedUV(_Multiply_18516a081d504359bcad3aa790750518_Out_2));
                                                                                                                                float _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_R_4 = _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_RGBA_0.r;
                                                                                                                                float _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_G_5 = _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_RGBA_0.g;
                                                                                                                                float _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_B_6 = _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_RGBA_0.b;
                                                                                                                                float _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_A_7 = _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_RGBA_0.a;
                                                                                                                                UnityTexture2D _Property_3a54904fa5c74bbeb60261b8a76a189a_Out_0 = UnityBuildTexture2DStructNoScale(_front);
                                                                                                                                float _Split_c79f25e24b934932b5cad363a3977e09_R_1 = IN.AbsoluteWorldSpacePosition[0];
                                                                                                                                float _Split_c79f25e24b934932b5cad363a3977e09_G_2 = IN.AbsoluteWorldSpacePosition[1];
                                                                                                                                float _Split_c79f25e24b934932b5cad363a3977e09_B_3 = IN.AbsoluteWorldSpacePosition[2];
                                                                                                                                float _Split_c79f25e24b934932b5cad363a3977e09_A_4 = 0;
                                                                                                                                float2 _Vector2_8457483515df467abc99f05f2c2f6398_Out_0 = float2(_Split_c79f25e24b934932b5cad363a3977e09_R_1, _Split_c79f25e24b934932b5cad363a3977e09_G_2);
                                                                                                                                float _Property_fc91ea867aa4477485726d431d8da229_Out_0 = _size;
                                                                                                                                float _Float_7e1bc66811ba41edb7a1f6e6df7f1d37_Out_0 = _Property_fc91ea867aa4477485726d431d8da229_Out_0;
                                                                                                                                float2 _Multiply_b8fc0cf2c6414beabf7bce2b9ff68cb8_Out_2;
                                                                                                                                Unity_Multiply_float2_float2(_Vector2_8457483515df467abc99f05f2c2f6398_Out_0, (_Float_7e1bc66811ba41edb7a1f6e6df7f1d37_Out_0.xx), _Multiply_b8fc0cf2c6414beabf7bce2b9ff68cb8_Out_2);
                                                                                                                                float4 _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_RGBA_0 = SAMPLE_TEXTURE2D(_Property_3a54904fa5c74bbeb60261b8a76a189a_Out_0.tex, _Property_3a54904fa5c74bbeb60261b8a76a189a_Out_0.samplerstate, _Property_3a54904fa5c74bbeb60261b8a76a189a_Out_0.GetTransformedUV(_Multiply_b8fc0cf2c6414beabf7bce2b9ff68cb8_Out_2));
                                                                                                                                float _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_R_4 = _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_RGBA_0.r;
                                                                                                                                float _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_G_5 = _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_RGBA_0.g;
                                                                                                                                float _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_B_6 = _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_RGBA_0.b;
                                                                                                                                float _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_A_7 = _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_RGBA_0.a;
                                                                                                                                float4 _Branch_09c1cdaea5f54a1d86615c158f30696f_Out_3;
                                                                                                                                Unity_Branch_float4(_Comparison_08509dcd8b844663a8b9a254806453e0_Out_2, _SampleTexture2D_e094b2b1bc144f228b83171db25fa378_RGBA_0, _SampleTexture2D_1f4765788bf9411f9490f7a3f8a2824f_RGBA_0, _Branch_09c1cdaea5f54a1d86615c158f30696f_Out_3);
                                                                                                                                float4 _Branch_33ebb3d9ed944f64b6d69749f158256c_Out_3;
                                                                                                                                Unity_Branch_float4(_Comparison_6e7dfe17f5834279863585dd909d6b85_Out_2, _SampleTexture2D_2fd545645ee448609b600edb51209aaa_RGBA_0, _Branch_09c1cdaea5f54a1d86615c158f30696f_Out_3, _Branch_33ebb3d9ed944f64b6d69749f158256c_Out_3);
                                                                                                                                float _Property_94721ec2508f4046b88413c6bd4e982e_Out_0 = _CircleSmoothnes;
                                                                                                                                float4 _ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                                                                                                                float4 _Property_fd84b0cc463c44558e196f2b6699bb15_Out_0 = _Position;
                                                                                                                                float4 _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3;
                                                                                                                                Unity_Remap_float4(_Property_fd84b0cc463c44558e196f2b6699bb15_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3);
                                                                                                                                float4 _Add_4b02f63dcd7e45e188328b812f76fa99_Out_2;
                                                                                                                                Unity_Add_float4(_ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0, _Remap_af564979169e47bfa3d2acdccd3ba951_Out_3, _Add_4b02f63dcd7e45e188328b812f76fa99_Out_2);
                                                                                                                                float2 _TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3;
                                                                                                                                Unity_TilingAndOffset_float((_ScreenPosition_e9131ba5acba4e44aded81fbd678643b_Out_0.xy), float2 (1, 1), (_Add_4b02f63dcd7e45e188328b812f76fa99_Out_2.xy), _TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3);
                                                                                                                                float2 _Multiply_177cb9485e70424c8b113020b5fa561e_Out_2;
                                                                                                                                Unity_Multiply_float2_float2(_TilingAndOffset_13993905274c4778b0fd1c14bc0b93e1_Out_3, float2(2, 2), _Multiply_177cb9485e70424c8b113020b5fa561e_Out_2);
                                                                                                                                float2 _Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2;
                                                                                                                                Unity_Subtract_float2(_Multiply_177cb9485e70424c8b113020b5fa561e_Out_2, float2(1, 1), _Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2);
                                                                                                                                float _Divide_0183d4739fe2443987608ab3169a13d9_Out_2;
                                                                                                                                Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_0183d4739fe2443987608ab3169a13d9_Out_2);
                                                                                                                                float _Property_817685bafbc74ff594205cd2bbec6848_Out_0 = _CircleSize;
                                                                                                                                float _Multiply_3046c926d1e34dce9c8963423a59249d_Out_2;
                                                                                                                                Unity_Multiply_float_float(_Divide_0183d4739fe2443987608ab3169a13d9_Out_2, _Property_817685bafbc74ff594205cd2bbec6848_Out_0, _Multiply_3046c926d1e34dce9c8963423a59249d_Out_2);
                                                                                                                                float2 _Vector2_fea5299f99e247c4ade509c5e8082e2d_Out_0 = float2(_Multiply_3046c926d1e34dce9c8963423a59249d_Out_2, _Property_817685bafbc74ff594205cd2bbec6848_Out_0);
                                                                                                                                float2 _Divide_15271b15b3774cec9b09b48583a269d4_Out_2;
                                                                                                                                Unity_Divide_float2(_Subtract_5690f0e8c7614d3d8ba27843da982498_Out_2, _Vector2_fea5299f99e247c4ade509c5e8082e2d_Out_0, _Divide_15271b15b3774cec9b09b48583a269d4_Out_2);
                                                                                                                                float _Length_8cc50efaa80e489482f7f21fa7901007_Out_1;
                                                                                                                                Unity_Length_float2(_Divide_15271b15b3774cec9b09b48583a269d4_Out_2, _Length_8cc50efaa80e489482f7f21fa7901007_Out_1);
                                                                                                                                float _OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1;
                                                                                                                                Unity_OneMinus_float(_Length_8cc50efaa80e489482f7f21fa7901007_Out_1, _OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1);
                                                                                                                                float _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1;
                                                                                                                                Unity_Saturate_float(_OneMinus_ebca0897851646db9a75876ded22c9e4_Out_1, _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1);
                                                                                                                                float _Smoothstep_d81123febc5349c78b41d5023455b828_Out_3;
                                                                                                                                Unity_Smoothstep_float(0, _Property_94721ec2508f4046b88413c6bd4e982e_Out_0, _Saturate_1bd609c8cae648fb9d51cfc6275ff2f8_Out_1, _Smoothstep_d81123febc5349c78b41d5023455b828_Out_3);
                                                                                                                                float _Property_84f7f817f25348a3bec32f2049267d9d_Out_0 = _Alpha;
                                                                                                                                float _Multiply_288a1c15da154ed2b2f4093423b86332_Out_2;
                                                                                                                                Unity_Multiply_float_float(_Smoothstep_d81123febc5349c78b41d5023455b828_Out_3, _Property_84f7f817f25348a3bec32f2049267d9d_Out_0, _Multiply_288a1c15da154ed2b2f4093423b86332_Out_2);
                                                                                                                                float _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1;
                                                                                                                                Unity_OneMinus_float(_Multiply_288a1c15da154ed2b2f4093423b86332_Out_2, _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1);
                                                                                                                                surface.BaseColor = (_Branch_33ebb3d9ed944f64b6d69749f158256c_Out_3.xyz);
                                                                                                                                surface.Alpha = _OneMinus_6588b12988ca453e957b33bf4a437aa5_Out_1;
                                                                                                                                return surface;
                                                                                                                            }

                                                                                                                            // --------------------------------------------------
                                                                                                                            // Build Graph Inputs
                                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                                                                                            #define VFX_SRP_VARYINGS Varyings
                                                                                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                                                            #endif
                                                                                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                                                            {
                                                                                                                                VertexDescriptionInputs output;
                                                                                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                                                                output.ObjectSpacePosition = input.positionOS;

                                                                                                                                return output;
                                                                                                                            }
                                                                                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                                                            {
                                                                                                                                SurfaceDescriptionInputs output;
                                                                                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                                                            #endif



                                                                                                                                // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                                                                                                                                float3 unnormalizedNormalWS = input.normalWS;
                                                                                                                                const float renormFactor = 1.0 / length(unnormalizedNormalWS);


                                                                                                                                output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph


                                                                                                                                output.WorldSpacePosition = input.positionWS;
                                                                                                                                output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
                                                                                                                                output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                                                            #else
                                                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                                                            #endif
                                                                                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                                                    return output;
                                                                                                                            }

                                                                                                                            // --------------------------------------------------
                                                                                                                            // Main

                                                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

                                                                                                                            // --------------------------------------------------
                                                                                                                            // Visual Effect Vertex Invocations
                                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                                                            #endif

                                                                                                                            ENDHLSL
                                                                                                                            }
                                                                    }
                                                                        CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
                                                                                                                                CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
                                                                                                                                FallBack "Hidden/Shader Graph/FallbackError"
}