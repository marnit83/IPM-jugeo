using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class dragObject : MonoBehaviour
{
    // Start is called before the first frame update
    private Vector3 mouseOffset;
    private float mouseZCoord;
    public bool drag;

    [SerializeField] private AudioSource audioSource;
    [SerializeField] private AudioClip draglessAudio;
    [SerializeField] private AudioClip mouseUpAudio;

    //RESET
    public bool reset = true;
    private Vector3 posInicial;
    private Quaternion rotInicial;

    [Header("Drag")]
    public float maxForce = 3;
    //variables para alinear el cubo
    private int ejeX;
    private float ejeY;
    private int ejeZ;
    private Vector3 alinearCam1;
    private Vector3 alinearCam2;
    private Vector3 nullVelocity = new Vector3(0,0,0);

    [Header("Color")]
    //variables para el cambio de color
    //public Color initialColor;
    //public Color mouseOverColor;
    //public Texture texturaInicial;
   // public Texture texturaMouseOver;
    public Material materialInicial;
    public Material materialMouseOver;


    private bool mouseOver = false;
    Renderer playerRenderer;
    
    [Header("Variables externas")]
    [SerializeField]
    private cameraSwitcher cameraSwitcher;
    [SerializeField]
    private Rigidbody obstacleRb;
    

    private void Start()
    {
        posInicial = transform.position;
        rotInicial = transform.rotation;

        ejeZ = (int)posInicial.z;
        ejeX = (int)posInicial.x;

        playerRenderer = this.GetComponent<Renderer>();
        obstacleRb = this.GetComponent<Rigidbody>();
    }
    private void Update()
    {
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

        if (transform.position.y < -20)
        {
            transform.position = posInicial;
            obstacleRb.velocity = nullVelocity;
        }
    }

    private void OnCollisionEnter(Collision collision)
    {
        if(collision.gameObject.tag == "Finish")
        {
            reset = false;
        }
    }

    private void OnMouseEnter()
    {
        mouseOver = true;
       // playerRenderer.material.SetColor("_Color", mouseOverColor); 
        //playerRenderer.material.SetTexture("_MainTex", texturaMouseOver);/////////////////
        playerRenderer.GetComponent<MeshRenderer>().material = materialMouseOver;/////////////////////

        //Debug.Log("OnMouseEnter");
    }

    private void OnMouseExit()
    {
        mouseOver = false;
       // playerRenderer.material.SetColor("_Color", initialColor);
       // playerRenderer.material.SetTexture("_MainTex", texturaInicial); //////////////////
        playerRenderer.GetComponent<MeshRenderer>().material = materialInicial;/////////////////////


    }

    private void OnMouseDown()
    {
        mouseZCoord = Camera.main.WorldToScreenPoint(gameObject.transform.position).z;
        audioSource.PlayOneShot(draglessAudio);

    }

    private void OnMouseUp()
    {
       // playerRenderer.material.SetColor("_Color", initialColor);
        //playerRenderer.material.SetTexture("_MainTex", texturaInicial);//////////////
        playerRenderer.GetComponent<MeshRenderer>().material = materialInicial;/////////////////////


        obstacleRb.detectCollisions = true;
        audioSource.PlayOneShot(mouseUpAudio);

    }

    void OnMouseDrag()
    {
        if (reset)
        {
            //playerRenderer.material.SetColor("_Color", mouseOverColor); 
            //playerRenderer.material.SetTexture("_MainTex", texturaMouseOver);/////////
            playerRenderer.GetComponent<MeshRenderer>().material = materialMouseOver;/////////////////////


            if (drag)
            {
                if (cameraSwitcher.camara1)
                {
                    obstacleRb.AddForce(-mouseOffset.x * 10 / obstacleRb.mass, 0, 0, ForceMode.Force);
                }
                else
                {
                    obstacleRb.AddForce(0, 0, -mouseOffset.z * 10 / obstacleRb.mass, ForceMode.Force);
                }
            }
            else
            {
                obstacleRb.detectCollisions = false;
                transform.position = GetMouseWorldPos() + mouseOffset;
            }
        }
        //Debug.Log(mouseOffset);
    }

    private Vector3 GetMouseWorldPos()
    {
        Vector3 mousePoint = Input.mousePosition;
        mousePoint.z = mouseZCoord;

        return Camera.main.ScreenToWorldPoint(mousePoint);
    }


    void OnReset()
    {
        if (reset)
        {
            Debug.Log("OnReset");
            transform.position = posInicial;
            transform.rotation = rotInicial;
            obstacleRb.velocity = Vector3.zero;
            obstacleRb.angularVelocity = Vector3.zero;
        }
    }
}
