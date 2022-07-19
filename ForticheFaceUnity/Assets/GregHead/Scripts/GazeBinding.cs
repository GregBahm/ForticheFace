using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GazeBinding : MonoBehaviour
{
    [SerializeField]
    private Transform headSource;
    [SerializeField]
    private Transform gazeSource;
    private EyeGazeController controller;

    private Transform relativeTransform;
    private void Start()
    {
        controller = GetComponent<EyeGazeController>();
        GameObject gazeBindingHelper = new GameObject("Gaze Binding Helper");
        relativeTransform = gazeBindingHelper.transform;
        relativeTransform.SetParent(headSource, false);
    }

    private void Update()
    {
        relativeTransform.rotation = gazeSource.rotation;
        float gazeHeading = relativeTransform.localRotation.eulerAngles.y;
        float gazePitch = relativeTransform.localRotation.eulerAngles.x;
        controller.SetGaze(gazeHeading, gazePitch);
    }
}
