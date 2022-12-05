using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Llave : MonoBehaviour
{
    public Image icono;
    public GameObject text;
   

    private int conf = 0;
    private bool pickupPressed = false;

    [SerializeField]
    public float RotationSpeed = 10;

    void Update()
    {
        /*transform.Rotate(Vector3.up, RotationSpeed * Time.deltaTime, Space.World);
        if (Input.GetKeyDown(0KeyCode.E) && conf==1)
        {
            text.SetActive(false);
            icono.enabled = true;
            Destroy(gameObject);
        }*/
        //Debug.Log(pickupPressed);
       PickUp();
       }

    private void OnTriggerEnter(Collider other)
    {
        if(other.gameObject.tag == "Player")
        {
            text.SetActive(true);
            conf = 1;
        }
        //StartCoroutine(coger());


    }

    private void OnTriggerExit(Collider other)
    {
        text.SetActive(false);
        if (other.gameObject.tag == "Player") {
            conf = 0;
        }
           
    }

    private void OnPickUp()
    {
       // Debug.Log("OnPickUp");
        if(conf==1) pickupPressed = true;

    }
    

    void PickUp() {
        //Debug.Log("PickUp");

        transform.Rotate(Vector3.up, RotationSpeed * Time.deltaTime, Space.World);
        if (pickupPressed == true && conf == 1)
        {
            text.SetActive(false);
            icono.enabled = true;
            Destroy(gameObject);
            pickupPressed = false;
           // Debug.Log("PickUp del if");

        }
    }
    
}
//unity log build windows