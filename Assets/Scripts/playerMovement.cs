using UnityEngine;
using System.Collections;
using System.Collections.Generic;

[RequireComponent(typeof(CharacterController))]

public class playerMovement : MonoBehaviour
{
    public CharacterController controller;
    public cameraSwitcher cameraManager;
    public AudioSource audioSource;
    public AudioClip jumpSound;

    //Movimiento horizontal
    public float speed = 40f;

    [Header("Jump")]
    private Vector3 playerVelocity;
    public float jumpForce = 5.0f;
    private bool jumpPressed = false;
    public float gravityValue = -16f;
    private bool groundedPlayer;

    private bool isJumping;

    private Animator animator;
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
     void Start()
    {
        animator = GetComponent<Animator>();
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
        //Debug.Log(playerVelocity);
    }

    void movementHorizontal()
    {
        float horizontalSpped = Input.GetAxisRaw("Horizontal") * speed; //Si pulsa A, devuelve -1, pulsar D = 1   
        Vector3 xMove = new Vector3(horizontalSpped, 0, 0);
        Vector3 zMove = new Vector3(0, 0, -horizontalSpped);

        //////********///////
        ///Activar idle animation y walking animation
        if (xMove != Vector3.zero || zMove != Vector3.zero)
        {
            animator.SetBool("IsMoving", true);
        }
        else
        {
            animator.SetBool("IsMoving", false);
        }
        //////********///////
        

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
            audioSource.PlayOneShot(jumpSound);
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