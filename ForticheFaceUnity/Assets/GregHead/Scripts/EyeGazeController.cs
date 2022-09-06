using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

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

    public float LeftRight { get => leftRight; set => leftRight = value; }

    [Range(-1, 1)]
    [SerializeField]
    private float upDown;
    public float UpDown { get => upDown; set => upDown = value; }

    [SerializeField]
    private Material mat;

    [SerializeField]
    private Camera avatarCamera;

    [SerializeField]
    private Transform headJoint;

    private HeadOrchestrator headMain;

    private EyeBlendPair lookUp;
    private EyeBlendPair lookDown;
    private EyeBlendPair lookLeft;
    private EyeBlendPair lookRight;

    private float finalLeftRightTarget;
    private float finalUpDownTarget;

    private float finalLeftRight;
    private float finalUpDown;

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
        //DriveFromMouse();
        SetHeadOffsets();
        UpdateFinalValues();
        UpdateEyeGazeVisuals();
    }

    private void UpdateFinalValues()
    {
        finalLeftRightTarget = leftRight + headHorizontalOffset;
        finalUpDownTarget = upDown + headVerticalOffset;

        finalLeftRight = Mathf.Lerp(finalLeftRight, finalLeftRightTarget, Time.deltaTime * 25);
        finalUpDown = Mathf.Lerp(finalUpDown, finalUpDownTarget, Time.deltaTime * 25);
    }

    private void UpdateEyeGazeVisuals()
    {
        SetEyeTransforms();
        SetEyeBlendShapes();
        SetMat();
    }

    float headVerticalOffset;
    float headHorizontalOffset;

    float GetAngle(float baseAngle, float divisor)
    {
        if (baseAngle > 180)
            baseAngle = -360 + baseAngle;
        return baseAngle / divisor;
    }

    private void SetHeadOffsets()
    {
        float headX = headJoint.rotation.eulerAngles.x;
        float headY = headJoint.rotation.eulerAngles.y;

        headVerticalOffset = GetAngle(headX, maxUpEyeAngle);
        headHorizontalOffset = GetAngle(headY, maxHorizontalEyeAngle);
    }

    private void DriveFromMouse()
    {
        if (Mouse.current.rightButton.IsPressed())
        {
            Vector2 screenPos = Mouse.current.position.ReadValue();
            Vector3 viewportPos = avatarCamera.ScreenToViewportPoint(screenPos);
            leftRight = (viewportPos.x - .5f) * 2;
            upDown = (viewportPos.y - .5f) * 2;
        }
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
        mat.SetFloat("_UpDown", finalUpDown);
        mat.SetFloat("_LeftRight", finalLeftRight);
    }

    private void SetEyeTransforms()
    {
        float horizontalAngle = maxHorizontalEyeAngle * finalLeftRight;
        float verticalAngle = finalUpDown * maxUpEyeAngle;
        Quaternion rot = Quaternion.Euler(-verticalAngle, -horizontalAngle, 0);
        leftEye.localRotation = rot;
        rightEye.localRotation = rot;
    }

    private void SetEyeBlendShapes()
    {
        float leftWeight = Mathf.Max(-finalLeftRight, 0);
        float rightWeight = Mathf.Max(finalLeftRight, 0);
        float upWeight = Mathf.Max(finalUpDown, 0);
        float downWeight = Mathf.Max(-finalUpDown, 0);

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
