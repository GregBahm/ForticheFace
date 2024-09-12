using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

public class FaceUiPanel : MonoBehaviour
{
    [SerializeField]
    private RectTransform cursor;
    public RectTransform Cursor => cursor;

    [SerializeField]
    private float bounds = 200;

    public float CursorX => cursor.anchoredPosition.x / bounds;
    public float CursorY => cursor.anchoredPosition.y / bounds;

    private RectTransform myRec;

    void Start()
    {
        myRec = GetComponent<RectTransform>();
    }

    void Update()
    {
        if(Input.GetMouseButton(0))
        {
            Vector2 relativePos = GetRelativeMousePosition();
            if (GetIsInBounds(relativePos))
            {
                cursor.anchoredPosition = relativePos;
            }
        }
    }

    private bool GetIsInBounds(Vector2 relativePos)
    {
        return Mathf.Abs(relativePos.x) < bounds && Mathf.Abs(relativePos.y) < bounds;
    }

    private Vector2 GetRelativeMousePosition()
    {
        Vector2 mousePos = Input.mousePosition;
        Vector2 relativePos;
        RectTransformUtility.ScreenPointToLocalPointInRectangle(myRec, mousePos, null, out relativePos);
        return relativePos;
    }

}
