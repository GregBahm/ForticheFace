using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EyeGazeController : MonoBehaviour
{
    [SerializeField]
    private Transform leftEye;
    [SerializeField]
    private Transform rightEye;

    [SerializeField]
    private float maxHorizontalEyeAngle;
    [SerializeField]
    private float maxUpEyeAngle;

    [Range(-1, 1)]
    [SerializeField]
    private float leftRight;

    [Range(-1, 1)]
    [SerializeField]
    private float upDown;

    [SerializeField]
    private Material mat;

    private HeadOrchestrator headMain;

    private EyeBlendPair lookUp;
    private EyeBlendPair lookDown;
    private EyeBlendPair lookLeft;
    private EyeBlendPair lookRight;

    private void Start()
    {
        headMain = GetComponent<HeadOrchestrator>();
        lookUp = new EyeBlendPair("Eye_Look_Up_Left","Eye_Look_Up_Right", headMain);
        lookDown = new EyeBlendPair("Eye_Look_Dn_Left", "Eye_Look_Dn_Right", headMain);
        lookLeft = new EyeBlendPair("Eye_Look_In_Left", "Eye_Look_Out_Right", headMain);
        lookRight = new EyeBlendPair("Eye_Look_Out_Left", "Eye_Look_In_Right", headMain);
    }

    public void DoUpdate()
    {
        UpdateEyeGazeVisuals();
    }

    private void UpdateEyeGazeVisuals()
    {
        SetEyeTransforms();
        SetEyeBlendShapes();
        SetMat();
    }

    public void SetGaze(float gazeHeading, float gazePitch)
    {
        leftRight = GetAxis(gazeHeading, maxHorizontalEyeAngle);
        upDown = GetAxis(gazePitch, maxUpEyeAngle);
        UpdateEyeGazeVisuals();
    }

    private float GetAxis(float baseVal, float maxVal)
    {
        if (baseVal > 180)
            baseVal = 360 - baseVal;
        else
            baseVal *= -1;
        float normalizedVal = baseVal / maxVal;
        return Mathf.Clamp(normalizedVal, -1, 1);
    }

    private void SetMat()
    {
        mat.SetFloat("_UpDown", upDown);
        mat.SetFloat("_LeftRight", leftRight);
    }

    private void SetEyeTransforms()
    {
        float horizontalAngle = maxHorizontalEyeAngle * leftRight;
        float verticalAngle = upDown * maxUpEyeAngle;
        Quaternion rot = Quaternion.Euler(-verticalAngle, -horizontalAngle, 0);
        leftEye.localRotation = rot;
        rightEye.localRotation = rot;
    }

    private void SetEyeBlendShapes()
    {
        float leftWeight = Mathf.Max(-leftRight, 0);
        float rightWeight = Mathf.Max(leftRight, 0);
        float upWeight = Mathf.Max(upDown, 0);
        float downWeight = Mathf.Max(-upDown, 0);

        lookLeft.ApplyBlend(leftWeight);
        lookRight.ApplyBlend(rightWeight);
        lookUp.ApplyBlend(upWeight);
        lookDown.ApplyBlend(downWeight);
    }

    private class EyeBlendPair
    {
        private readonly SkinnedMeshRenderer renderer;
        private readonly int left;
        private readonly int right;

        public EyeBlendPair(string leftBlend, string rightBlend, HeadOrchestrator orchestrator)
        {
            renderer = orchestrator.HeadMesh;
            left = orchestrator.GetBlendIndex(leftBlend);
            right = orchestrator.GetBlendIndex(rightBlend);
        }

        public void ApplyBlend(float blendPower)
        {
            renderer.SetBlendShapeWeight(left, blendPower * 100);
            renderer.SetBlendShapeWeight(right, blendPower * 100);
        }
    }
}
