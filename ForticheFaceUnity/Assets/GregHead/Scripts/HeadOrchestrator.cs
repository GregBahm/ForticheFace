using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HeadOrchestrator : MonoBehaviour
{
    [SerializeField]
    private SkinnedMeshRenderer headMesh;
    public SkinnedMeshRenderer HeadMesh => headMesh;

    private FaceExpressionController faceExpression;
    private BlinkController blink;
    private EyeGazeController eyeGaze;
    private LipFlapController lipFlap;
    private BodyMotionController bodyMotion;

    private void Start()
    {
        faceExpression = GetComponent<FaceExpressionController>();
        blink = GetComponent<BlinkController>();
        eyeGaze = GetComponent<EyeGazeController>();
        lipFlap = GetComponent<LipFlapController>();
        bodyMotion = GetComponent<BodyMotionController>();
    }

    private void Update()
    {
        faceExpression.DoUpdate(); // Needs to go first because it stomps all other blends
        bodyMotion.DoUpdate();
        blink.DoUpdate();
        eyeGaze.DoUpdate();
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
