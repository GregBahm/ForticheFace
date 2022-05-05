using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HeadScript : MonoBehaviour
{
    [SerializeField]
    private SkinnedMeshRenderer headRenderer;

    [SerializeField]
    private Transform leftEye;
    [SerializeField]
    private Transform rightEye;

    [SerializeField]
    private float maxHorizontalEyeAngle;
    [SerializeField]
    private float maxDownEyeAngle;
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

    private void Update()
    {
        SetEyeTransforms();
        SteEyeBlendShapes();
        SetMat();
    }

    private void SetMat()
    {
        mat.SetFloat("_UpDown", upDown);
        mat.SetFloat("_LeftRight", leftRight);
    }

    private void SetEyeTransforms()
    {
        float horizontalAngle = maxHorizontalEyeAngle * leftRight;
        float verticalAngle = -Mathf.Min(upDown, 0) * maxDownEyeAngle + Mathf.Max(upDown, 0) * maxUpEyeAngle;
        Quaternion rot = Quaternion.Euler(-verticalAngle, -horizontalAngle, 0);
        leftEye.localRotation = rot;
        rightEye.localRotation = rot;
    }

    private void SteEyeBlendShapes()
    {
        float leftWeight = Mathf.Max(-leftRight, 0);
        float rightWeight = Mathf.Max(leftRight, 0);
        float upWeight = Mathf.Max(-upDown, 0);
        float downWeight = Mathf.Max(upDown, 0);
        headRenderer.SetBlendShapeWeight(0, leftWeight * 100);
        headRenderer.SetBlendShapeWeight(1, downWeight * 100);
        headRenderer.SetBlendShapeWeight(2, rightWeight * 100);
        headRenderer.SetBlendShapeWeight(3, upWeight * 100);
    }
}
