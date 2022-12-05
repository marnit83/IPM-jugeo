using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerSteps : MonoBehaviour
{
    public AudioSource footSteps;
    public CharacterController controller;

    void Update()
    {
        if ((Input.GetKey(KeyCode.A) || Input.GetKey(KeyCode.D)) && controller.isGrounded)
        {
            footSteps.enabled = true;
        }
        else
        {
            footSteps.enabled = false;
        }
    }
}