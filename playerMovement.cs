using UnityEngine;
using System.Collections;
using System.Collections.Generic;

[RequireComponent(typeof(CharacterController))]

public class playerMovement : MonoBehaviour
{
    public CharacterController controller;
    public cameraSwitcher cameraManager;

    //Movimiento horizontal
    public float speed = 40f;

    [Header("Jump")]
    private Vector3 playerVelocity;
    public float jumpForce = 5.0f;
    private bool jumpPressed = false;
    public float gravityValue = -16f;
    private bool groundedPlayer;


    private void Awake()
    {
        controller = GetComponent<CharacterController>();
    }

    void FixedUpdate()
    {
        movementHorizontal();
        movementJump();
    }

    void movementHorizontal()
    {
        float horizontalSpped = Input.GetAxisRaw("Horizontal") * speed; //Si pulsa A, devuelve -1, pulsar D = 1   
        Vector3 xMove = new Vector3(horizontalSpped, 0, 0);
        Vector3 zMove = new Vector3(0, 0, -horizontalSpped);
        if (cameraManager.camara1)
            controller.Move((xMove) * Time.deltaTime);
        else
            controller.Move((zMove) * Time.deltaTime);
    }

    void movementJump()
    {
        groundedPlayer = controller.isGrounded;

        if (groundedPlayer)
        {
            playerVelocity.y = 0.0f;
        }

        if (jumpPressed && groundedPlayer)
        {
            playerVelocity.y += Mathf.Sqrt(jumpForce * -gravityValue);
            jumpPressed = false;
        }

        playerVelocity.y += gravityValue * Time.deltaTime;
        controller.Move(playerVelocity * Time.deltaTime);
    }

    void OnJump()
    {
        if (controller.velocity.y > -0.2 && controller.velocity.y < 0.2)
        {
            jumpPressed = true;
        }
    }
}