using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class dragObject : MonoBehaviour
{
    // Start is called before the first frame update
    private Vector3 mouseOffset;
    private float mouseZCoord;
    public float maxForce = 3;

    //variables para alinear el cubo
    private int ejeX;
    private float ejeY;
    private int ejeZ;
    private Vector3 alinearCam1;
    private Vector3 alinearCam2;
    private Vector3 posInicial;
    private Vector3 nullVelocity = new Vector3(0,0,0);

    [SerializeField]
    private cameraSwitcher cameraSwitcher;
    [SerializeField]
    private Rigidbody obstacleRb;

    private void Start()
    {
        posInicial = transform.position;

        ejeZ = (int)posInicial.z;
        ejeX = (int)posInicial.x;
    }
    private void Update()
    {
        alignPosition();
        mouseOffset = gameObject.transform.position - GetMouseWorldPos();
        if(mouseOffset.x > maxForce)
        {
            mouseOffset.x = maxForce;
        }
        if(mouseOffset.x < -maxForce)
        {
            mouseOffset.x = -maxForce;
        }


        if (mouseOffset.z > maxForce)
        {
            mouseOffset.z = maxForce;
        }
        if (mouseOffset.z < -maxForce)
        {
            mouseOffset.z = -maxForce;
        }

        if(transform.position.y < -20)
        {
            transform.position = posInicial;
            obstacleRb.velocity = nullVelocity;
        }
    }

    private void OnMouseDown()
    {
        mouseZCoord = Camera.main.WorldToScreenPoint(gameObject.transform.position).z;
    }

    void OnMouseDrag()
    {
        //transform.position = GetMouseWorldPos() + mouseOffset;
        if (cameraSwitcher.camara1)
        {
            obstacleRb.AddForce(-mouseOffset.x*10 / obstacleRb.mass, 0, 0, ForceMode.Force);
        }
        else
        {
            obstacleRb.AddForce(0, 0, -mouseOffset.z*10 / obstacleRb.mass, ForceMode.Force);
        }

        //Debug.Log(mouseOffset);
    }

    private Vector3 GetMouseWorldPos()
    {
        Vector3 mousePoint = Input.mousePosition;
        mousePoint.z = mouseZCoord;

        return Camera.main.ScreenToWorldPoint(mousePoint);
    }

    void alignPosition()
    {
        ejeY = transform.position.y;
        alinearCam1 = new Vector3(transform.position.x, ejeY, ejeZ);
        alinearCam2 = new Vector3(ejeX, ejeY, transform.position.z);
        //Debug.Log(ejeZ);
        if (cameraSwitcher.camara1)
        {
            transform.position = alinearCam1;
            ejeX = (int)transform.position.x;
        }
        else
        {
            transform.position = alinearCam2;
            ejeZ = (int) transform.position.z;
        }
    }
}
