using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class PlayerDead : MonoBehaviour
{
   
    void OnCollisionEnter(Collision collision) //Cuando entra en colision con algo hace cosas
    {
        if (collision.gameObject.tag == "Enemy") //cuando la colision coincide con el objeto con tag 'Enemy', se va a la escena Game Over
        {
            //Debug.Log("Do something here");
            SceneManager.LoadScene("GameOver");
        }
    }
      
    
}
