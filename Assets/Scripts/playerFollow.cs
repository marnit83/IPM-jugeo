using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class playerFollow : MonoBehaviour
{
    [SerializeField]
    private Transform player;
    [SerializeField]
    private Vector3 cam1Offset;
    [SerializeField]
    private Vector3 cam2Offset;


    public cameraSwitcher cameraSwitch;

    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        float zAxis = player.position.z;
        float xAxis = player.position.x;

        Vector3 cam1Mov = new Vector3(xAxis, 0, 0);
        Vector3 cam2Mov = new Vector3(0, 0, zAxis);

        if (cameraSwitch.camara1)
        {
            cameraSwitch.vCam1.transform.position = player.position - cam1Offset;
        }
        else
        {
            cameraSwitch.vCam2.transform.position = player.position - cam2Offset;
        }
    }
}
