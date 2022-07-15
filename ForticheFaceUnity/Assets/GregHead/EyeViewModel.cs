using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EyeViewModel : MonoBehaviour
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
    private float maxUpEyeAngle;

    [Range(-1, 1)]
    [SerializeField]
    private float leftRight;

    [Range(-1, 1)]
    [SerializeField]
    private float upDown;

    [SerializeField]
    private Material mat;

    private EyeBlendPair lookUp;
    private EyeBlendPair lookDown;
    private EyeBlendPair lookLeft;
    private EyeBlendPair lookRight;

    private void Start()
    {
        lookUp = new EyeBlendPair(GetBlendIndex("Eye_Look_Up_Left"), GetBlendIndex("Eye_Look_Up_Right"));
        lookDown = new EyeBlendPair(GetBlendIndex("Eye_Look_Dn_Left"), GetBlendIndex("Eye_Look_Dn_Right"));
        lookLeft = new EyeBlendPair(GetBlendIndex("Eye_Look_In_Left"), GetBlendIndex("Eye_Look_Out_Right"));
        lookRight = new EyeBlendPair(GetBlendIndex("Eye_Look_Out_Left"), GetBlendIndex("Eye_Look_In_Right"));
    }

    private void Update()
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

        lookLeft.ApplyBlend(headRenderer, leftWeight);
        lookRight.ApplyBlend(headRenderer, rightWeight);
        lookUp.ApplyBlend(headRenderer, upWeight);
        lookDown.ApplyBlend(headRenderer, downWeight);
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

    private class EyeBlendPair
    {
        public int Left { get; }
        public int Right { get; }
        public EyeBlendPair(int left, int right)
        {
            Left = left;
            Right = right;
        }

        public void ApplyBlend(SkinnedMeshRenderer renderer, float blendPower)
        {
            renderer.SetBlendShapeWeight(Left, blendPower * 100);
            renderer.SetBlendShapeWeight(Right, blendPower * 100);
        }
    }
}
