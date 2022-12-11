using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;


public class puerta : MonoBehaviour
{
    public Image icono;
    public GameObject text; //
    public GameObject text2;
    public GameObject textI;
    private int conf = 0;
    private float posInicialPuerta;

    [SerializeField] private AudioSource audioSource;
    [SerializeField] private AudioClip unlockSound;
    [SerializeField] private AudioClip liftGateSound;

    void Start()
    {
        posInicialPuerta = gameObject.transform.position.y;
    }
    void Update()
    {
        if (conf == 1 && Input.GetKeyDown(KeyCode.E))
        {
            audioSource.PlayOneShot(unlockSound);
            audioSource.PlayOneShot(liftGateSound);
            icono.enabled = false;
            conf = 2;


        }
        if (conf == 2)
        {
            text2.SetActive(true);
            textI.SetActive(false);
            Vector3 newPos = Vector3.up * Time.deltaTime;
            transform.Translate(newPos);
            float pos = gameObject.transform.position.y;
            if (pos > posInicialPuerta + 4f)
            {

                text2.SetActive(false);
                conf = 0;
            }
        }

    }


    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Player")
        {

            if (icono.enabled == true)
            {
                textI.SetActive(true);

                conf = 1;


            }
            else
            {
                text.SetActive(true);
            }
        }


    }
    private void OnTriggerExit(Collider other)
    {
        if (other.gameObject.tag == "Player")
        {
            text.SetActive(false);
            textI.SetActive(false);
        }
    }

    private void subirPuerta()
    {

        text2.SetActive(true);
        textI.SetActive(false);
        Vector3 newPos = Vector3.up * Time.deltaTime;
        transform.Translate(newPos);
        float pos = gameObject.transform.position.y;
        if (pos > posInicialPuerta + 4f)
        {
            icono.enabled = false;
            text2.SetActive(false);
            conf = 0;
        }

    }
}
