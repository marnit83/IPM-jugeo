using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class WinCondition : MonoBehaviour
{

    [SerializeField] private Animator fadeAnimator;
    [SerializeField] private AudioSource audioSource;
    [SerializeField] private AudioClip victorySound;
    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Player")
        {
            audioSource.PlayOneShot(victorySound);
            StartCoroutine("esperar");
        }
        

    }
    public IEnumerator esperar()
    {
        fadeAnimator.Play("FadeIn");
        yield return new WaitForSeconds(1);
        SceneManager.LoadScene("MenuPpl");
    }
}
