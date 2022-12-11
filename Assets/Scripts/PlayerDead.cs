using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class PlayerDead : MonoBehaviour
{
    [SerializeField] private Animator fadeAnimator;
    [SerializeField] private AudioSource audioSource;
    [SerializeField] private AudioClip deathSound;

    void OnCollisionEnter(Collision collision) //Cuando entra en colision con algo hace cosas
    {
        Debug.Log("Colision con algo");

        if (collision.gameObject.tag == "Enemy") //cuando la colision coincide con el objeto con tag 'Enemy', se va a la escena Game Over
        {
            audioSource.PlayOneShot(deathSound);
            GetComponent<playerMovement>().enabled = false;
            StartCoroutine("esperar");

            SceneManager.LoadScene("GameOver");
        }
    }


    public IEnumerator esperar()
    {
        fadeAnimator.Play("FadeOut");
        yield return new WaitForSeconds(1.5f);
        SceneManager.LoadScene("GameOver");
    }

}
