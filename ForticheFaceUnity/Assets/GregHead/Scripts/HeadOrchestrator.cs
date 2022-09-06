using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HeadOrchestrator : MonoBehaviour
{
    [SerializeField]
    private SkinnedMeshRenderer headMesh;
    public SkinnedMeshRenderer HeadMesh => headMesh;

    private UIScripts uiScripts;
    private FaceExpressionController faceExpression;
    private BlinkController blink;
    private EyeGazeController eyeGaze;
    private LipFlapController lipFlap;
    private BodyMotionController bodyMotion;

    private void Start()
    {
        uiScripts = GetComponent<UIScripts>();
        faceExpression = GetComponent<FaceExpressionController>();
        blink = GetComponent<BlinkController>();
        eyeGaze = GetComponent<EyeGazeController>();
        lipFlap = GetComponent<LipFlapController>();
        bodyMotion = GetComponent<BodyMotionController>();
    }

    private void Update()
    {
        if (uiScripts.isActiveAndEnabled)
            uiScripts.DoUpdate();
        if(faceExpression.isActiveAndEnabled)
            faceExpression.DoUpdate(); // Needs to go first because it stomps all other blends
        if(bodyMotion.isActiveAndEnabled)
            bodyMotion.DoUpdate();
        if(blink.isActiveAndEnabled && faceExpression.CurrentExpression == FaceExpressionController.Expression.Default)
            blink.DoUpdate();
        if(eyeGaze.isActiveAndEnabled)
            eyeGaze.DoUpdate();
        if(lipFlap.isActiveAndEnabled)
            lipFlap.DoUpdate();
    }

    public int GetBlendIndex(string blendName)
    {
        Mesh mesh = headMesh.sharedMesh;
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
