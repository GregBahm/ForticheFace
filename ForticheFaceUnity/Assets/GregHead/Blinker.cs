using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Blinker : MonoBehaviour
{
    [SerializeField]
    private SkinnedMeshRenderer headRenderer;

    [SerializeField]
    private float blinkSpeed;

    [SerializeField]
    private float timeBetweenBlinks;
    [SerializeField]
    private float blinkRamp;

    private int leftBlinkIndex;
    private int rightBlinkIndex;

    private float blinkProgress;
    private float timeTillNextBlink;

    private void Start()
    {
        leftBlinkIndex = GetBlendIndex("Eye_Closed_Left");
        rightBlinkIndex = GetBlendIndex("Eye_Closed_Right");
    }

    private void Update()
    {
        UpdateBlinkProgress();
        AnimateBlinks();
    }

    private void AnimateBlinks()
    {
        float normalizedBlink = blinkProgress / blinkSpeed;
        normalizedBlink = Mathf.Clamp01(normalizedBlink);
        float blinkProg = Mathf.Abs(normalizedBlink - .5f) * 2;
        blinkProg = 1 - Mathf.Pow(blinkProg, blinkRamp);
        headRenderer.SetBlendShapeWeight(leftBlinkIndex, blinkProg * 100);
        headRenderer.SetBlendShapeWeight(rightBlinkIndex, blinkProg * 100);
    }

    private void UpdateBlinkProgress()
    {
        timeTillNextBlink -= Time.deltaTime;
        if (timeTillNextBlink < 0)
        {
            timeTillNextBlink = timeBetweenBlinks;
            blinkProgress = 0;
        }
        blinkProgress += Time.deltaTime;
    }

    private int GetBlendIndex(string blendName)
    {
        Mesh mesh = headRenderer.sharedMesh;
        for (int i = 0; i < mesh.blendShapeCount; i++)
        {
            string name = mesh.GetBlendShapeName(i);
            if (name.ToLower().Contains(blendName.ToLower()))
            {
                return i;
            }
        }
        throw new InvalidOperationException();
    }
}
