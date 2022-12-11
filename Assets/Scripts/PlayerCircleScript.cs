using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;

public class PlayerCircleScript : MonoBehaviour
{
    public static int PosID = Shader.PropertyToID("_Position"); //atributos del shader para coger posicion del jugador
    public static int SizeID = Shader.PropertyToID("_CircleSize"); //atributos del shader para coger tamaño del círculo
    //public static int Alpha = Shader.PropertyToID("_AlphaMine");

    public Material WallMaterial;
    public Camera Camera; //para la pos del circulo
   
    public LayerMask Mask; 
    /*void Start()
    {
        WallMaterial.SetFloat(SizeID, 0);
    }*/

    void Update()
    {
        var dir = Camera.transform.position - transform.position;

        var ray = new Ray(transform.position, dir.normalized); //rayo que comprueba pos

        if (Physics.Raycast(ray, 100, Mask))
        {
            WallMaterial.SetFloat(SizeID, 1);
           // WallMaterial.SetFloat(Alpha, 0);
        }
        else
        {
             WallMaterial.SetFloat(SizeID, 0);
            //WallMaterial.SetFloat(Alpha, 1);
        }

       
        var view = Camera.WorldToViewportPoint(transform.position);

        WallMaterial.SetVector(PosID, view); //comprobar si estamos delante o detrás del muro
    }
}
