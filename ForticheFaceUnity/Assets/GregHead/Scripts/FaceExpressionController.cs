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
    public Expression CurrentExpression => currentExpression;

    [SerializeField]
    private SkinnedMeshRenderer smugSmileTarget;
    [SerializeField]
    private SkinnedMeshRenderer smileTarget;
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
        faceMain = GetComponent<HeadOrchestrator>();
        currentValues = new MomentumManager[faceMain.HeadMesh.sharedMesh.blendShapeCount];
        for (int i = 0; i < currentValues.Length; i++)
        {
            currentValues[i] = new MomentumManager();
        }

        table = new Dictionary<Expression, ExpressionMap>();
        table.Add(Expression.Default, new ExpressionMap(faceMain.HeadMesh));
        table.Add(Expression.SmugSmile, new ExpressionMap(smugSmileTarget));
        table.Add(Expression.Smile, new ExpressionMap(smileTarget));
        table.Add(Expression.Attentive, new ExpressionMap(attentiveTarget));
        table.Add(Expression.Pout, new ExpressionMap(poutTarget));
        table.Add(Expression.Shock, new ExpressionMap(shockTarget));
    }
    
    public void DoUpdate()
    {
        table[currentExpression].Set(currentValues, snap, decay);

        for (int i = 0; i < currentValues.Length; i++)
        {
            faceMain.HeadMesh.SetBlendShapeWeight(i, currentValues[i].CurrentValue);
        }
    }

    public enum Expression
    {
        Default,
        SmugSmile,
        Smile, 
        Attentive, 
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
