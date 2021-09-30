//--------------------------------------------------------------------------------------
// File: Pick.fx
//
// The effect file for the Pick sample.  
// 
// Copyright (c) Microsoft Corporation. All rights reserved.
//--------------------------------------------------------------------------------------

//--------------------------- BASIC PROPERTIES ------------------------------
// The world transformation
float4x4 World;
 
// The view transformation
float4x4 View;
 
// The projection transformation
float4x4 Projection;
 
// The transpose of the inverse of the world transformation,
// used for transforming the vertex's normal
float4x4 WorldInverseTranspose;

//--------------------------------------------------------------------------------------
// Global variables
//--------------------------------------------------------------------------------------
float4x4 g_mWorldViewProjection;   // World * View * Projection matrix
float g_mAlphaValue;
float g_mColorValue;
float g_mBlendFactor;
float g_bCoverTexture;


texture g_MeshTexture;              // Color texture for mesh
texture g_OverlayTexture;

//--------------------------------------------------------------------------------------
// Texture samplers
//--------------------------------------------------------------------------------------
sampler MeshTextureSampler;
sampler OverlayTextureSampler;


//--------------------------------------------------------------------------------------
// Vertex shader output structure
//--------------------------------------------------------------------------------------
struct VS_OUTPUT
{
    float4 Position   : POSITION;  // vertex position
    float2 TextureUV  : TEXCOORD0;  // vertex texture coords 
    float4 ColorV	  : COLOR0;
};


//--------------------------------------------------------------------------------------
// This shader is used to render vertices for the game cover
//--------------------------------------------------------------------------------------
VS_OUTPUT RenderCoverVS( float4 vPos: POSITION, float2 vTexCoord0 : TEXCOORD, float4 ColorVert : COLOR0 )
{

	VS_OUTPUT Output;	

	Output.ColorV = ColorVert;
	float4 Pos = vPos;
	Output.Position =  mul(Pos,g_mWorldViewProjection);
	Output.TextureUV = vTexCoord0; 
	return Output;    
}

//--------------------------------------------------------------------------------------
// This shader is used to render vertices for the game cover's mirror image
//--------------------------------------------------------------------------------------
VS_OUTPUT RenderMirrorVS( float4 vPos: POSITION, float2 vTexCoord0 : TEXCOORD, float4 ColorVert : COLOR0 )
{

	VS_OUTPUT Output;	

	Output.ColorV = ColorVert;
	float4 Pos = vPos;
	Output.Position =  mul(Pos,g_mWorldViewProjection);
	Output.TextureUV = vTexCoord0; 
	return Output;   
}

//--------------------------------------------------------------------------------------
// This shader is used to render vertices for the game background object
//--------------------------------------------------------------------------------------
VS_OUTPUT RenderGameBkgVS( float4 vPos: POSITION, float2 vTexCoord0 : TEXCOORD, float4 ColorVert : COLOR0 )
{

	VS_OUTPUT Output;	

	Output.ColorV = ColorVert;
	float4 Pos = vPos;
	Output.Position =  mul(Pos,g_mWorldViewProjection);
	Output.TextureUV = vTexCoord0; 
	return Output;
}

//--------------------------------------------------------------------------------------
// Pixel shader output structure
//--------------------------------------------------------------------------------------
struct PS_OUTPUT
{
    float4 RGBColor : COLOR0;  // Pixel color    
};

//--------------------------------------------------------------------------------------
// This shader is used to render pixel for the games cover
//--------------------------------------------------------------------------------------
PS_OUTPUT RenderCoverPS( VS_OUTPUT In ) : COLOR
{
	PS_OUTPUT Output;
	
	float4 MeshColor = tex2D(MeshTextureSampler, In.TextureUV);
	Output.RGBColor = MeshColor;
	
	Output.RGBColor.a	*= g_mAlphaValue;
	Output.RGBColor.rgb *= g_mColorValue;
	
	return Output;
}

//--------------------------------------------------------------------------------------
// This shader is used to render pixel for the game cover's mirror image
//--------------------------------------------------------------------------------------
PS_OUTPUT RenderMirrorPS( VS_OUTPUT In ) : COLOR
{
	PS_OUTPUT Output;
	
	float4 MeshColor = tex2D(MeshTextureSampler, In.TextureUV);
	Output.RGBColor = MeshColor;
	
	Output.RGBColor.a	*= g_mAlphaValue;
	Output.RGBColor.rgb *= g_mColorValue;
	
	return Output;
}

//--------------------------------------------------------------------------------------
// This shader is used to render pixel for the game's background image
//--------------------------------------------------------------------------------------
PS_OUTPUT RenderGameBkgPS( VS_OUTPUT In ) : COLOR
{
	PS_OUTPUT Output;
	
	float4 MeshColor = tex2D(MeshTextureSampler, In.TextureUV);
	Output.RGBColor = MeshColor;
	
	Output.RGBColor.a	*= g_mAlphaValue;
	Output.RGBColor.rgb *= g_mColorValue;
	
	return Output;
}

//--------------------------------------------------------------------------------------
// Render Techniques
//--------------------------------------------------------------------------------------
technique RenderCover
{
    pass P0
    {          
        VertexShader = compile vs_2_0 RenderCoverVS();
        PixelShader  = compile ps_2_0 RenderCoverPS(); 
    }
}

technique RenderMirror
{
	pass P0
	{
		VertexShader = compile vs_2_0 RenderMirrorVS();
		PixelShader  = compile ps_2_0 RenderMirrorPS();
	}
}

technique RenderGameBkg
{
	pass P0
	{
		VertexShader = compile vs_2_0 RenderGameBkgVS();
		PixelShader  = compile ps_2_0 RenderGameBkgPS();
	}
}