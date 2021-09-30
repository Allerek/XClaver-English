

//--------------------------------------------------------------------------------------
// Global variables
//--------------------------------------------------------------------------------------
float g_mAlphaValue;
float2 g_mLeftHand;
float2 g_mRightHand;

//--------------------------------------------------------------------------------------
// Texture samplers
//--------------------------------------------------------------------------------------
sampler MeshTextureSampler;


//--------------------------------------------------------------------------------------
// Vertex shader output structure
//--------------------------------------------------------------------------------------
struct VS_OUTPUT
{
    float4 Position   : POSITION;  // vertex position
    float2 TextureUV  : TEXCOORD0;  // vertex texture coords 
};


//--------------------------------------------------------------------------------------
// This shader computes standard transform and lighting
//--------------------------------------------------------------------------------------
VS_OUTPUT RenderKinectVS( float4 vPos: POSITION, float2 vTexCoord0 : TEXCOORD )
{

	VS_OUTPUT Output;	

	Output.Position =  vPos;
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

PS_OUTPUT RenderKinectColorPS( VS_OUTPUT In ) : COLOR
{

	PS_OUTPUT Output;
	
	float4 MeshColor = tex2D(MeshTextureSampler, In.TextureUV);
	MeshColor.a = g_mAlphaValue;
	Output.RGBColor = MeshColor;
	
	return Output;
}


PS_OUTPUT RenderKinectGreyPS( VS_OUTPUT In ) : COLOR
{

	PS_OUTPUT Output;
	
	float4 MeshColor = tex2D(MeshTextureSampler, In.TextureUV);
	MeshColor = dot(MeshColor.rgb, float3(0.3, 0.59, 0.11)); 
	MeshColor.a = g_mAlphaValue;

	float distance = (( In.TextureUV.x - g_mLeftHand[0] ) * ( In.TextureUV.x - g_mLeftHand[0] )) + ((In.TextureUV.y - g_mLeftHand[1] ) * (In.TextureUV.y - g_mLeftHand[1] ));
	float distance2 = (( In.TextureUV.x - g_mRightHand[0] ) * ( In.TextureUV.x - g_mRightHand[0] )) + ((In.TextureUV.y - g_mRightHand[1] ) * (In.TextureUV.y - g_mRightHand[1] ));

	if( (distance < 0.0049) )// && (distance > 0.0016) )
	{
		float factor = (0.0049 - distance) / 0.00325;
		MeshColor.rgb = 0.25 * factor * factor;
	}
	else if( (distance2 < 0.0049) )// && (distance2 > 0.0016) )
	{
		float factor2 = (0.0049 - distance2) / 0.00325;
		MeshColor.rgb = 0.25 * factor2 * factor2;
	}
	else
	{
		
	}

	Output.RGBColor = MeshColor;
	
	return Output;
}


technique RenderPIP
{
	pass P0
	{
		VertexShader = compile vs_2_0 RenderKinectVS();
		PixelShader = compile ps_2_0 RenderKinectGreyPS();
	}
}