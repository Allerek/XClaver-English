//--------------------------------------------------------------------------------------
// File: Pick.fx
//
// The effect file for the Pick sample.  
// 
// Copyright (c) Microsoft Corporation. All rights reserved.
//--------------------------------------------------------------------------------------


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
// This shader computes standard transform and lighting
//--------------------------------------------------------------------------------------
VS_OUTPUT RenderSceneVS( float4 vPos: POSITION, float2 vTexCoord0 : TEXCOORD, float4 ColorVert : COLOR0 )
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

PS_OUTPUT RenderBasicScenePS( VS_OUTPUT In ) : COLOR
{

	PS_OUTPUT Output;
	
	float4 MeshColor = tex2D(MeshTextureSampler, In.TextureUV);
	Output.RGBColor = MeshColor;
	
	Output.RGBColor.rgb *= g_mColorValue;
	Output.RGBColor.rgb *= 1.1;
	Output.RGBColor.a *= g_mAlphaValue;
	
	return Output;
}


PS_OUTPUT RenderAvatarScenePS( VS_OUTPUT In ) : COLOR
{

	PS_OUTPUT Output;
	
	In.TextureUV.y += 0.2;
	
	float4 MeshColor = tex2D(MeshTextureSampler, In.TextureUV);
	
	Output.RGBColor = MeshColor;
	
	if( In.TextureUV.y > 1.0 ) {
		Output.RGBColor.a = 0;
	}
	
	Output.RGBColor.rgb *= g_mColorValue;
	Output.RGBColor.a *= g_mAlphaValue;
	
	return Output;
}

//--------------------------------------------------------------------------------------
// This shader outputs the pixel's color by modulating the texture's
// color with diffuse material color
//--------------------------------------------------------------------------------------

PS_OUTPUT RenderBlendScenePS( VS_OUTPUT In ) : COLOR
{ 
	PS_OUTPUT Output;	
   
   // Sample the color map, to find out what we're blending
   float4 MeshColor = tex2D(MeshTextureSampler, In.TextureUV);
   float4 OverlayColor = tex2D(OverlayTextureSampler, In.TextureUV.xy);

   if( g_bCoverTexture == 1.0 )
   {
		Output.RGBColor.r = lerp( OverlayColor.r, MeshColor.r, g_mBlendFactor);
		Output.RGBColor.g = lerp( OverlayColor.g, MeshColor.g, g_mBlendFactor);
		Output.RGBColor.b = lerp( OverlayColor.b, MeshColor.b, g_mBlendFactor);
		Output.RGBColor.a = lerp( OverlayColor.a, MeshColor.a, g_mBlendFactor);
	}
	else
	{
		Output.RGBColor = MeshColor;
	}

   Output.RGBColor.rgb *= g_mColorValue;
   Output.RGBColor.a *= g_mAlphaValue;
   
   return Output;
}


//--------------------------------------------------------------------------------------
// Renders scene 
//--------------------------------------------------------------------------------------
technique RenderCover
{
    pass P0
    {          
        VertexShader = compile vs_2_0 RenderSceneVS();
        PixelShader  = compile ps_2_0 RenderBasicScenePS(); 
    }
}

technique RenderTextureBlend
{
	pass P0
	{
		VertexShader = compile vs_2_0 RenderSceneVS();
		PixelShader  = compile ps_2_0 RenderBlendScenePS();
	}
}

technique RenderAvatarIcon
{
	pass P0
	{
		VertexShader = compile vs_2_0 RenderSceneVS();
		PixelShader  = compile ps_2_0 RenderAvatarScenePS();
	}
}