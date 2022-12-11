using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObjectMovingOnTriggerEnter : MonoBehaviour
{
    [Header("Puntos por los que pasa el objeto(pueden ser objetos vacios o mayas)")]
    public Transform[] waypoints; //array para los waypoints por los que pasa el enemigo
    [Header("Objeto que se va a mover")]
    public GameObject objetoSube;
    [Header("Velocidad a la que e mueve el objeto")]
    public int speed; // velocidad 

    private int waypointIndex; //a que waypoint irá el enemigo, sirve para ver a cual va a ir 
    private float dist; //seguimiento de la distancia entre enemigo y waypoint

    //float posicionInicial;
    //float posicion;
    // Start is called before the first frame update
    void Start()
    {
        //posicionInicial = objetoSube.transform.position;
        //posicion = objetoSube.transform.position;
        waypointIndex = 0;
        //objetoSube.transform.LookAt(waypoints[waypointIndex].position);
    }

    // Update is called once per frame
    void Update()
    {

        
    }
    void OnTriggerStay()
    {
        ////********////
        //comprobar distancia entre enemigo y y waypoint
        dist = Vector3.Distance(objetoSube.transform.position, waypoints[waypointIndex].position);

        if (dist < 0.2f) //cuando la distancia entre el waypoint sea menor que un punto, se cambia el waypoint
        {
            IncreaseIndex();
        }
        Patrol();
    }

    void Patrol()
    {
        objetoSube.transform.position = Vector3.MoveTowards(objetoSube.transform.position , waypoints[waypointIndex].transform.position,  speed * Time.deltaTime); //movimiento
    }
    void IncreaseIndex()//gestor del indice para recorrer el array de waypoints
    {
        waypointIndex++;
        if (waypointIndex >= waypoints.Length)  //una vez se sale del array, se inicia de nuevo
        {
            waypointIndex = 0;
        }
        //objetoSube.transform.LookAt(waypoints[waypointIndex].position); //el enemigo mira al waypoint siempre

    }

}
