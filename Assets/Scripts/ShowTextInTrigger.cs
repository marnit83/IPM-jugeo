using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShowTextInTrigger : MonoBehaviour
{
    public GameObject PanelToShow;
    // Start is called before the first frame update
    void Start()
    {
        PanelToShow.SetActive(false);
    }
    void OnTriggerStay()
    {
        PanelToShow.SetActive(true);
    }
    private void OnTriggerExit(Collider other)
    {
        PanelToShow.SetActive(false);
    }
}
