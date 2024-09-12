using UnityEngine;

public class BodyMotionController : MonoBehaviour
{
    [SerializeField]
    private Transform headBone;
    [SerializeField]
    private Transform hololensCamera;

    [SerializeField]
    private float smoothing;

    [SerializeField]
    private float rotationSensitivity;
    private Vector3 mouseStart;
    private Quaternion headStart;

    private void Start()
    {
        
    }

    public void DoUpdate()
    {
        if(Input.GetMouseButtonDown(0))
        {
            mouseStart = Input.mousePosition;
            headStart = hololensCamera.rotation;
        }
        if (Input.GetMouseButton(0))
        {
            Vector3 dragDelta = Input.mousePosition - mouseStart;
            Vector3 euler = headStart.eulerAngles;
            euler += new Vector3(-dragDelta.y, dragDelta.x, 0) * rotationSensitivity;
            hololensCamera.rotation = Quaternion.Euler(euler);

        }
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
