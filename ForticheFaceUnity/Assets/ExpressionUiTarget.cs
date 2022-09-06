using UnityEngine;

public class ExpressionUiTarget : MonoBehaviour
{
    private RectTransform recTransform;
    public Vector2 AnchorPos => recTransform.anchoredPosition;
    public void Start()
    {
        recTransform = GetComponent<RectTransform>();
    }
    public FaceExpressionController.Expression Expression;
}
