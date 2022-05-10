using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[RequireComponent(typeof(Camera))]
public class OutlineScript : MonoBehaviour
{
    [Range(0,1)]
    public float OutlineHigh = 0.75f;
    [Range(0, 1)]
    public float OutlineLow = 0;

    public Color OutlineColor = Color.white;
    
    public Material OutlineAlphaMat;
    public Material OutlineMat;
    public Material BlurMat;
    private Camera theCamera;
    private CommandBuffer command;

    public GameObject[] ObjectsToOutline;

    private void Start()
    {
        theCamera = GetComponent<Camera>();
        UpdateOutlineTarget(ObjectsToOutline);
    }

    private void Update()
    {
        OutlineMat.SetFloat("_OutlineHigh", OutlineHigh);
        OutlineMat.SetFloat("_OutlineLow", OutlineLow);
        OutlineMat.SetColor("_OutlineColor", OutlineColor);
    }

    public void UpdateOutlineTarget(GameObject[] objectsToOutline)
    {
        if(command != null)
        {
            theCamera.RemoveCommandBuffer(CameraEvent.AfterForwardAlpha, command);
            command.Release();
        }

        command = new CommandBuffer();

        int outlineTextureAlpha = Shader.PropertyToID("_OutlineTextureAlpha");
        int horizontalBlurredTexture = Shader.PropertyToID("_HorizontalBlurredTexture");
        int fullBlurredTexture = Shader.PropertyToID("_FullBlurredTexture");

        command.GetTemporaryRT(outlineTextureAlpha, -1, -1, 0, FilterMode.Bilinear);
        command.GetTemporaryRT(horizontalBlurredTexture, -1, -1, 0, FilterMode.Bilinear);
        command.GetTemporaryRT(fullBlurredTexture, -1, -1, 0, FilterMode.Bilinear);

        RenderTargetIdentifier identifier = new RenderTargetIdentifier(outlineTextureAlpha);
        command.SetRenderTarget(identifier);

        command.ClearRenderTarget(false, true, Color.black);
        foreach (GameObject obj in objectsToOutline)
        {
            Renderer renderer = obj.GetComponent<Renderer>();
            command.DrawRenderer(renderer, OutlineAlphaMat);
        }

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
