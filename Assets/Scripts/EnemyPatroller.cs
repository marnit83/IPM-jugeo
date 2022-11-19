using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyPatroller : MonoBehaviour
{
    public Transform[] waypoints; //array para los waypoints por los que pasa el enemigo
    public int speed; // velocidad 

    private int waypointIndex; //a que waypoint irá el enemigo, sirve para ver a cual va a ir 
    private float dist; //seguimiento de la distancia entre enemigo y waypoint

    // Start is called before the first frame update
    void Start()
    {
        waypointIndex = 0;
        transform.LookAt(waypoints[waypointIndex].position);

    }

    // Update is called once per frame
    void Update()
    {
        //comprbar distancia entre enemigo y y waypoint
        dist = Vector3.Distance(transform.position, waypoints[waypointIndex].position);
        if(dist < 1f) //cuando la distancia entre el waypoint sea menor que un punto, se cambia el waypoint
        {
            IncreaseIndex();
        }
        Patrol();
    }

    void Patrol()
    {
        transform.Translate(Vector3.forward * speed * Time.deltaTime); //movimiento
    }

    void IncreaseIndex()//gestor del indice para recorrer el array de waypoints
    {
        waypointIndex++;
        if(waypointIndex >= waypoints.Length)  //una vez se sale del array, se inicia de nuevo
        {
            waypointIndex = 0;
        }
        transform.LookAt(waypoints[waypointIndex].position); //el enemigo mira al waypoint siempre

    }
}
