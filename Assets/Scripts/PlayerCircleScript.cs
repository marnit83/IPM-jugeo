using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;

public class PlayerCircleScript : MonoBehaviour
{
    public static int PosID = Shader.PropertyToID("_Position"); //atributos del shader para coger posicion del jugador
    public static int SizeID = Shader.PropertyToID("_CircleSize"); //atributos del shader para coger tamaño del círculo


    public Material WallMaterial;
    public Camera Camera; //para la pos del circulo
    //public Camera Camera2; //para la pos del circulo
   // public cameraSwitcher cameraSwitch;

    public LayerMask Mask; 


    void Update()
    {
        var dir = Camera.transform.position - transform.position;
        //var dir2 = Camera2.transform.position - transform.position;

        var ray = new Ray(transform.position, dir.normalized); //rayo que comprueba pos
        //var ray2 = new Ray(transform.position, dir2.normalized);

        if (Physics.Raycast(ray, 3000, Mask))
        {
            WallMaterial.SetFloat(SizeID, 1);
        }
        else
        {
            WallMaterial.SetFloat(SizeID, 0);
        }

       /* if (Physics.Raycast(ray2, 3000, Mask))
        {
            WallMaterial.SetFloat(SizeID, 1);
        }
        else
        {
            WallMaterial.SetFloat(SizeID, 0);
        }
       */
        var view = Camera.WorldToViewportPoint(transform.position);
        //var view2 = Camera2.WorldToViewportPoint(transform.position);

        WallMaterial.SetVector(PosID, view); //comprobar si estamos delante o detrás del muro
       // WallMaterial.SetVector(PosID, view2);
    }
}
