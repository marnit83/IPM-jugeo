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

    private bool isJumping;

   /* private Vector3 LocalPosition;
    private Vector3 GloabalPosition;
    private void Start()
    {
        LocalPosition = gameObject.GetComponent<Transform>().position;
        GloabalPosition = gameObject.transform.position;
    }*/
    private void Awake()
    {
        controller = GetComponent<CharacterController>();
    }

    bool IsGrounded()
    {
        return groundedPlayer = controller.isGrounded;
    }

    void Update()
    {
        movementHorizontal();
        movementJump();
        /* LocalPosition = gameObject.GetComponent<Transform>().position;
         GloabalPosition = gameObject.transform.position;
         Debug.Log(" Posicion Local : " + LocalPosition);
         Debug.Log(" Posicion Global : " + GloabalPosition);
        */
        // Debug.Log("Is Grounded" + controller.isGrounded );
        //Debug.Log("Jump : " + jumpPressed);
    }

    void movementHorizontal()
    {
        float horizontalSpped = Input.GetAxisRaw("Horizontal") * speed; //Si pulsa A, devuelve -1, pulsar D = 1   
        Vector3 xMove = new Vector3(horizontalSpped, 0, 0);
        Vector3 zMove = new Vector3(0, 0, -horizontalSpped);
        if (cameraManager.camara1)
        {
            controller.Move((xMove + playerVelocity) * Time.deltaTime);

            ////////******************/////////
            if (Input.GetKeyDown(KeyCode.A))
            { //girar al personaje para que mire en la direccion izda
                transform.LookAt(transform.position + Vector3.left);
            }
            else if (Input.GetKeyDown(KeyCode.D))
            {
                transform.LookAt(transform.position + Vector3.right);
            }
            ////////******************/////////
        }
        else
        {
            controller.Move((zMove + playerVelocity) * Time.deltaTime);
            ////////******************/////////
            if (Input.GetKeyDown(KeyCode.A))
            { //girar al personaje para que mire en la direccion izda
                transform.LookAt(transform.position + Vector3.forward);
            }
            else if (Input.GetKeyDown(KeyCode.D))
            {
                transform.LookAt(transform.position + Vector3.back);
            }
            ////////******************/////////
        }
    }

    void movementJump()
    {
        groundedPlayer = controller.isGrounded;
        if (groundedPlayer)
        {
            playerVelocity.y = 0.0f;
        }

        if (jumpPressed && controller.isGrounded)
        {
            //Debug.Log("salta");
            playerVelocity.y += Mathf.Sqrt(jumpForce * -gravityValue);
            jumpPressed = false;
        }
        playerVelocity.y += gravityValue * Time.deltaTime;
    }

    void OnJump()
    {
        //Debug.Log("OnJump");
        if (controller.velocity.y > -0.2 && controller.velocity.y < 0.2)
        {
            jumpPressed = true;
        }
    }


}