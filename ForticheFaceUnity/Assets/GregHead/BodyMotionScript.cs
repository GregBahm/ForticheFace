using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BodyMotionScript : MonoBehaviour
{
    [SerializeField]
    private Transform headBone;
    [SerializeField]
    private Transform hololensCamera;

    private void Update()
    {
        headBone.rotation = hololensCamera.rotation;
    }
}
