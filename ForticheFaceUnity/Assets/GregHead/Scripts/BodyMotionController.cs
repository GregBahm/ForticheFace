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
        Quaternion mirroredRot = GetMirrored(hololensCamera.rotation);
        headBone.rotation = Quaternion.Lerp(headBone.rotation, mirroredRot, smoothing);
    }

    private Quaternion GetMirrored(Quaternion baseRot)
    {
        Vector3 eulers = baseRot.eulerAngles;
        Vector3 mirroredEulers = new Vector3(eulers.x, -eulers.y, -eulers.z);
        return Quaternion.Euler(mirroredEulers);
    }
}
