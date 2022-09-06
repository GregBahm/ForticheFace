using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AvatarCameraController : MonoBehaviour
{
    [SerializeField]
    bool doIntro;
    [SerializeField]
    float speed;
    void Start()
    {
        
    }

    void Update()
    {
        if(doIntro)
        {
            transform.rotation = Quaternion.Lerp(transform.rotation, Quaternion.identity, Time.deltaTime * speed);
        }
        else
        {
            transform.rotation = Quaternion.LookRotation(Vector3.left);
        }
    }
}
