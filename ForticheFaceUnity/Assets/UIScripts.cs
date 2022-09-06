using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class UIScripts : MonoBehaviour
{
    [SerializeField]
    private FaceUiPanel eyePanel;

    [SerializeField]
    private FaceUiPanel puppetPanel;

    [SerializeField]
    private ExpressionUiTarget[] expressionTargets;

    private EyeGazeController eyeGazeController;

    private FaceExpressionController faceExpression;

    private void Start()
    {
        eyeGazeController = GetComponent<EyeGazeController>();
        faceExpression = GetComponent<FaceExpressionController>();
    }

    public void DoUpdate()
    {
        eyeGazeController.LeftRight = eyePanel.CursorX;
        eyeGazeController.UpDown = eyePanel.CursorY;

        ExpressionUiTarget closestTarget = GetClosestTarget();
        faceExpression.CurrentExpression = closestTarget.Expression;
    }

    private ExpressionUiTarget GetClosestTarget()
    {
        ExpressionUiTarget closest = null;
        float minDist = float.MaxValue;
        foreach (ExpressionUiTarget item in expressionTargets)
        {
            float dist = (puppetPanel.Cursor.anchoredPosition - item.AnchorPos).magnitude;
            if(dist < minDist)
            {
                closest = item;
                minDist = dist;
            }
        }
        return closest;
    }
}
