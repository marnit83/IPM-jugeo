using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using Cinemachine;

public class cameraSwitcher : MonoBehaviour
{
    [SerializeField]
    private InputAction action;
    // Start is called before the first frame update
    public CinemachineVirtualCamera vCam1;
    public CinemachineVirtualCamera vCam2;
    
    public bool camara1 = true;

    public Animator changeCamera;


    private void Awake()
    {

    }

    private void OnEnable()
    {
        action.Enable();

    }

    private void OnDisable()
    {
        action.Disable();
       
    }

    void Start()
    {
        action.performed += _ => SwitchPriority();
        
    }

    public void SwitchPriority()
    {
        changeCamera.Play("CameraSwap");

        if (camara1)
        {
            vCam1.Priority = 0;
            vCam2.Priority = 1;

            
        }
        else
        {
            vCam1.Priority = 1;
            vCam2.Priority = 0;
        }
        camara1 = !camara1;
        
    }

    ////////////*********************////////////
    /*
    IEnumerator ChangeCamera()
     {
         //Play animation
         //changeCamera.SetTrigger("SwapCurtains");
     }
    */
    ////////////*********************////////////


}
