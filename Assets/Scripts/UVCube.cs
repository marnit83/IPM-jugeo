using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UVCube : MonoBehaviour
{
    private MeshFilter mf;
    public float tileSize = 0.25f;


    // Use this for initialization
    void Start()
    {

        ApplyTexture();

    }

    public void ApplyTexture()
    {
        mf = gameObject.GetComponent<MeshFilter>();
        if (mf)
        {
            Mesh mesh = mf.sharedMesh;
            if (mesh)
            {

                Vector2[] uvs = mesh.uv;
                //FRBLUD - Freeblood


                // Front
                //0,0 - 0.125,0 - 0,1 - 0,125,1
                uvs[0] = new Vector2(0f, 0f); //Bottom Left
                uvs[1] = new Vector2(tileSize, 0f); //Bottom Right 
                uvs[2] = new Vector2(0f, 1f); //Top Left
                uvs[3] = new Vector2(tileSize, 1f); // Top Right

                // Up
                uvs[4] = new Vector2(tileSize * 4.001f, 1f);    //Top left
                uvs[5] = new Vector2(tileSize * 5.001f, 1f);    //Top Right
                uvs[8] = new Vector2(tileSize * 4.001f, 0f);    //Bottom Left
                uvs[9] = new Vector2(tileSize * 5.001f, 0f);    //Bottom right

                // Back
                uvs[6] = new Vector2((tileSize * 2.001f), 0f);  //bottom left
                uvs[7] = new Vector2((tileSize * 3.001f), 0f);  //bottom right
                uvs[10] = new Vector2((tileSize * 2.001f), 1f); //top left
                uvs[11] = new Vector2((tileSize * 3.001f), 1f); //top right

                // Down
                uvs[12] = new Vector2(tileSize * 5.001f, 0f);   //bottom left
                uvs[13] = new Vector2(tileSize * 5.001f, 1f);   //top left
                uvs[14] = new Vector2(tileSize * 6.001f, 1f);   //bottom right
                uvs[15] = new Vector2(tileSize * 6.001f, 0f);   //top right

                // Left
                uvs[16] = new Vector2(tileSize * 3.001f, 0f);   //bottom left
                uvs[17] = new Vector2(tileSize * 3.001f, 1f);   //top left
                uvs[18] = new Vector2(tileSize * 4.001f, 1f);   //top right
                uvs[19] = new Vector2(tileSize * 4.001f, 0f);   //bottom right

                // Right
                uvs[20] = new Vector2(tileSize * 1.001f, 0f);   //bottom left
                uvs[21] = new Vector2(tileSize * 1.001f, 1f);   //top left
                uvs[22] = new Vector2(tileSize * 2.001f, 1f);   //top right
                uvs[23] = new Vector2(tileSize * 2.001f, 0f);   //bottom right


               


               
                


                mesh.uv = uvs;


            }
        }
        else
            Debug.Log("No mesh filter attached");

    }
}
