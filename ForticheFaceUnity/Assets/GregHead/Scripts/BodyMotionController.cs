using UnityEngine;

public class BodyMotionController : MonoBehaviour
{
    [SerializeField]
    private Transform headBone;
    [SerializeField]
    private Transform hololensCamera;

    public void DoUpdate()
    {
        headBone.rotation = hololensCamera.rotation;
    }
}
