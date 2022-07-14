using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FaceExpressionScript : MonoBehaviour
{
    public float Snap;
    public float Decay;

    public Expression CurrentExpression;

    public SkinnedMeshRenderer BaseFace;

    public SkinnedMeshRenderer SmileTarget;
    public SkinnedMeshRenderer AttentiveTarget;
    public SkinnedMeshRenderer PoutTarget;
    public SkinnedMeshRenderer ShockTarget;

    private Dictionary<Expression, ExpressionMap> table;

    private MomentumManager[] currentValues;

    private void Start()
    {
        currentValues = new MomentumManager[BaseFace.sharedMesh.blendShapeCount];
        for (int i = 0; i < currentValues.Length; i++)
        {
            currentValues[i] = new MomentumManager();
        }

        table = new Dictionary<Expression, ExpressionMap>();
        table.Add(Expression.Default, new ExpressionMap(BaseFace));
        table.Add(Expression.Smile, new ExpressionMap(SmileTarget));
        table.Add(Expression.Attentive, new ExpressionMap(AttentiveTarget));
        table.Add(Expression.Pout, new ExpressionMap(PoutTarget));
        table.Add(Expression.Shock, new ExpressionMap(ShockTarget));
    }

    private void Update()
    {
        table[CurrentExpression].Set(currentValues, Snap, Decay);

        for (int i = 0; i < currentValues.Length; i++)
        {
            BaseFace.SetBlendShapeWeight(i, currentValues[i].CurrentValue);
        }
    }

    public enum Expression
    {
        Default,
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
