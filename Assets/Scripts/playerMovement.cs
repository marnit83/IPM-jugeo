using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class playerMovement : MonoBehaviour
{
    [SerializeField]
    private InputAction moveLeft;
    [SerializeField]
    private InputAction moveRight;
    [SerializeField]
    private cameraSwitcher cameraSwitch;

    private float moveDirection;

    public Rigidbody playerRB;
    private bool isGrounded;
    public float moveSpeed;
    public float jumpForce;

    // Start is called before the first frame update
    private void OnEnable()
    {
        moveLeft.Enable();
        moveRight.Enable();
    }

    private void OnDisable()
    {
        moveLeft.Disable();
        moveRight.Disable();
    }

    void Start()
    {
        //moveLeft.performed += _ => moveLeftFunc();
        //moveRight.performed += _ => moveRightFunc();
    }

    // Update is called once per frame
    void Update()
    {
        moveDirection = Input.GetAxis("Horizontal");

        if (isGrounded && Input.GetKey("w"))
        {
            playerRB.AddForce(0, jumpForce, 0, ForceMode.Acceleration);
            isGrounded = false;
        }

        if (cameraSwitch.camara1)
        {
            playerRB.velocity = new Vector3(moveDirection * moveSpeed, playerRB.velocity.y, 0);
        }
        else
        {
            playerRB.velocity = new Vector3(0, playerRB.velocity.y, -moveDirection * moveSpeed);
        }
        
       
    }
    private void moveLeftFunc()
    {
        Vector3 unidadMovx = new Vector3(-1, 0, 0);
        Vector3 unidadMovz = new Vector3(0, 0, -1);
        if (cameraSwitch.camara1)
        {
            transform.position += unidadMovx;
        }
        else
        {
            transform.position += unidadMovz;
        }
    }

    private void moveRightFunc()
    {
        Vector3 unidadMovx = new Vector3(1, 0, 0);
        Vector3 unidadMovz = new Vector3(0, 0, 1);
        if (cameraSwitch.camara1)
        {
            transform.position += unidadMovx;
        }
        else
        {
            transform.position += unidadMovz;
        }
    }

    private void OnCollisionStay()
    {
        isGrounded = true;
    }
}
