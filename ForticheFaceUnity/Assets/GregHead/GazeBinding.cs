using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GazeBinding : MonoBehaviour
{
    public Transform HeadSource;
    public Transform GazeSource;
    public EyeViewModel EyeViewModel;

    private Transform relativeTransform;
    private void Start()
    {
        GameObject gazeBindingHelper = new GameObject("Gaze Binding Helper");
        relativeTransform = gazeBindingHelper.transform;
        relativeTransform.SetParent(HeadSource, false);
    }

    private void Update()
    {
        relativeTransform.rotation = GazeSource.rotation;
        float gazeHeading = relativeTransform.localRotation.eulerAngles.y;
        float gazePitch = relativeTransform.localRotation.eulerAngles.x;
        EyeViewModel.SetGaze(gazeHeading, gazePitch);
    }
}
