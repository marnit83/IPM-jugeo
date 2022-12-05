using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class CodigoBorrar : MonoBehaviour
{
    //[SerializeField] private GameObject Character;

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Player")
        {

            SceneManager.LoadScene("MenuPpl");

        }


    }
}





