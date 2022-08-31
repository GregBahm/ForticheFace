using UnityEngine;

public class BodyMotionController : MonoBehaviour
{
    [SerializeField]
    private Transform headBone;
    [SerializeField]
    private Transform hololensCamera;

    private void Start()
    {
        
    }

    public void DoUpdate()
    {
        headBone.rotation = hololensCamera.rotation;
    }
}
