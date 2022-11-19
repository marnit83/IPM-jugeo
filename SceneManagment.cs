using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;


public class SceneManagment : MonoBehaviour
{
    public void escenaJuego()
    {
        SceneManager.LoadScene("SampleScene");
    }

   
    public void Salir()
    {
        Application.Quit();
    }
}
