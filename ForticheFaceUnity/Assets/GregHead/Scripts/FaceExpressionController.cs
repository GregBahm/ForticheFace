using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FaceExpressionController : MonoBehaviour
{
    [SerializeField]
    private float snap;
    [SerializeField]
    private float decay;

    [SerializeField]
    private Expression currentExpression;
    public Expression CurrentExpression { get => currentExpression; set => currentExpression = value; }

    [SerializeField]
    private SkinnedMeshRenderer confidentSmileTarget;
    [SerializeField]
    private SkinnedMeshRenderer genuineSmileTarget;
    [SerializeField]
    private SkinnedMeshRenderer mildSurpriseTarget;
    [SerializeField]
    private SkinnedMeshRenderer attentiveTarget;
    [SerializeField]
    private SkinnedMeshRenderer poutTarget;
    [SerializeField]
    private SkinnedMeshRenderer shockTarget;

    private HeadOrchestrator faceMain;

    private Dictionary<Expression, ExpressionMap> table;

    private MomentumManager[] currentValues;

    private void Start()
    {
        keyControls = GetKeyControls();
        faceMain = GetComponent<HeadOrchestrator>();
        currentValues = new MomentumManager[faceMain.HeadMesh.sharedMesh.blendShapeCount];
        for (int i = 0; i < currentValues.Length; i++)
        {
            currentValues[i] = new MomentumManager();
        }

        table = new Dictionary<Expression, ExpressionMap>();
        table.Add(Expression.Default, new ExpressionMap(faceMain.HeadMesh));
        table.Add(Expression.ConfidentSmile, new ExpressionMap(confidentSmileTarget));
        table.Add(Expression.GenuineSmile, new ExpressionMap(genuineSmileTarget));
        table.Add(Expression.Attentive, new ExpressionMap(attentiveTarget));
        table.Add(Expression.MildSurprise, new ExpressionMap(mildSurpriseTarget));
        table.Add(Expression.Pout, new ExpressionMap(poutTarget));
        table.Add(Expression.Shock, new ExpressionMap(shockTarget));
    }

    private KeyCode[] GetKeyControls()
    {
        return new KeyCode[]
        {
            KeyCode.Keypad0,
            KeyCode.Keypad1,
            KeyCode.Keypad2,
            KeyCode.Keypad3,
            KeyCode.Keypad4,
            KeyCode.Keypad4,
            KeyCode.Keypad5,
            KeyCode.Keypad6,
            KeyCode.Keypad7,
            KeyCode.Keypad8,
            KeyCode.Keypad9,
        };
    }

    public void DoUpdate()
    {
        LookForNumpress();
        table[currentExpression].Set(currentValues, snap, decay);

        for (int i = 0; i < currentValues.Length; i++)
        {
            faceMain.HeadMesh.SetBlendShapeWeight(i, currentValues[i].CurrentValue);
        }
    }
    private KeyCode[] keyControls;


    private void LookForNumpress()
    {
        for (int i = 0; i < keyControls.Length; i++)
        {
            if(Input.GetKeyDown(keyControls[i]))
            {
                Expression expressionTarget = (Expression)(i % table.Count);
                if (currentExpression == expressionTarget)
                    currentExpression = Expression.Default;
                else
                    currentExpression = expressionTarget;
                break;
            }
        }
    }

    public enum Expression
    {
        Default,
        ConfidentSmile,
        GenuineSmile, 
        Attentive, 
        MildSurprise,
        Pout, 
        Shock,
    }

    private class ExpressionMap
    {
        private float[] values;
        
        public ExpressionMap(SkinnedMeshRenderer renderer)
        {
            values = new float[renderer.sharedMesh.blendShapeCount];
            for (int i = 0; i < values.Length; i++)
            {
                values[i] = renderer.GetBlendShapeWeight(i);
            }
        }

        public void Set(MomentumManager[] currentValues, float snap, float decay)
        {
            for (int i = 0; i < values.Length; i++)
            {
                currentValues[i].Update(values[i], snap, decay);
            }
        }
    }

    private class MomentumManager
    {
        public float CurrentValue { get; set; }
        public float Momentum { get; set; }

        public void Update(float target, float snap, float decay)
        {
            float diff = target - CurrentValue;
            diff *= snap;
            Momentum += diff;
            Momentum *= decay;
            CurrentValue += Momentum;
        }
    }
}
