using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BlinkController : MonoBehaviour
{
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

    private HeadOrchestrator headMain;

    private void Start()
    {
        headMain = GetComponent<HeadOrchestrator>();
        leftBlinkIndex = headMain.GetBlendIndex("Eye_Closed_Left");
        rightBlinkIndex = headMain.GetBlendIndex("Eye_Closed_Right");
    }

    public void DoUpdate()
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

        headMain.HeadMesh.SetBlendShapeWeight(leftBlinkIndex, blinkProg * 100);
        headMain.HeadMesh.SetBlendShapeWeight(rightBlinkIndex, blinkProg * 100);
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
}
