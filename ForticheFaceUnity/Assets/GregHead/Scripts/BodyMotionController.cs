using UnityEngine;

public class BodyMotionController : MonoBehaviour
{
    [SerializeField]
    private Transform headBone;
    [SerializeField]
    private Transform hololensCamera;

    [SerializeField]
    private float smoothing;

    private void Start()
    {
        
    }

    public void DoUpdate()
    {
        headBone.rotation = Quaternion.Lerp(headBone.rotation, hololensCamera.rotation, smoothing);
    }
}
