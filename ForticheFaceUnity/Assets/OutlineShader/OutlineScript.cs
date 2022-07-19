using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[RequireComponent(typeof(Camera))]
public class OutlineScript : MonoBehaviour
{
    public Color OutlineColor = Color.white;
    
    public Material OutlineAlphaMat;
    public Material OutlineMat;
    public Material BlurMat;
    private Camera theCamera;
    private CommandBuffer command;

    public MeshRenderer[] StaticObjectsToOutline;
    public SkinnedMeshRenderer[] SkinnedObjectsToOutline;

    private void Start()
    {
        theCamera = GetComponent<Camera>();
        AddOutlineCommandBuffer();
    }

    private void Update()
    {
        OutlineMat.SetColor("_OutlineColor", OutlineColor);
    }

    private void RegisterStaticObjects()
    {
        foreach (MeshRenderer renderer in StaticObjectsToOutline)
        {
            Mesh mesh = renderer.gameObject.GetComponent<MeshFilter>().mesh;
            for (int i = 0; i < mesh.subMeshCount; i++)
            {
                command.DrawRenderer(renderer, OutlineAlphaMat, i);
            }
        }
    }

    private void RegisterSkinnedObjects()
    {
        foreach (SkinnedMeshRenderer renderer in SkinnedObjectsToOutline)
        {
            for (int i = 0; i < renderer.sharedMesh.subMeshCount; i++)
            {
                command.DrawRenderer(renderer, OutlineAlphaMat, i);
            }
        }
    }

    public void AddOutlineCommandBuffer()
    {
        if(command != null)
        {
            theCamera.RemoveCommandBuffer(CameraEvent.AfterForwardAlpha, command);
            command.Release();
        }

        command = new CommandBuffer();
        command.name = "Outline";

        int outlineTextureAlpha = Shader.PropertyToID("_OutlineTextureAlpha");
        int horizontalBlurredTexture = Shader.PropertyToID("_HorizontalBlurredTexture");
        int fullBlurredTexture = Shader.PropertyToID("_FullBlurredTexture");

        command.GetTemporaryRT(outlineTextureAlpha, -1, -1, 0, FilterMode.Bilinear);
        command.GetTemporaryRT(horizontalBlurredTexture, -1, -1, 0, FilterMode.Bilinear);
        command.GetTemporaryRT(fullBlurredTexture, -1, -1, 0, FilterMode.Bilinear);

        RenderTargetIdentifier identifier = new RenderTargetIdentifier(outlineTextureAlpha);
        command.SetRenderTarget(identifier);

        command.ClearRenderTarget(false, true, Color.black);
        RegisterStaticObjects();
        RegisterSkinnedObjects();

        command.SetGlobalVector("_UvKey", new Vector2(1, 0));
        command.Blit(outlineTextureAlpha, horizontalBlurredTexture, BlurMat);
        command.SetGlobalVector("_UvKey", new Vector2(0, 1));
        command.Blit(horizontalBlurredTexture, fullBlurredTexture, BlurMat);

        command.ReleaseTemporaryRT(outlineTextureAlpha);
        command.ReleaseTemporaryRT(horizontalBlurredTexture);
        command.ReleaseTemporaryRT(fullBlurredTexture);

        theCamera.AddCommandBuffer(CameraEvent.AfterForwardAlpha, command);
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination, OutlineMat);
    }
}
