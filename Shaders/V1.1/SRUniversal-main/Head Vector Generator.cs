using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.UIElements;

public class HeadVectorGenerator : MonoBehaviour
{
    public Transform HeadBoneTransform;
    public Transform HeadForwardTransform;
    public Transform HeadRightTransform;

    private Renderer[] allRenders;

    private int HeadForwardID = Shader.PropertyToID("_HeadForward");
    private int HeadRightID = Shader.PropertyToID("_HeadRight");

#if UNITY_EDITOR
    /// <summary>
    /// Called when the script is loaded or a value is changed in the
    /// inspector (Called in the editor only).
    /// </summary>
    void OnValidate()
    {
        LateUpdate();
    }
#endif

    private void LateUpdate()
    {
        if (allRenders == null)
        {
            allRenders = GetComponentsInChildren<Renderer>(true);
        }

        for (int i = 0; i < allRenders.Length; i++)
        {
            Renderer r = allRenders[i];
            foreach (Material mat in r.sharedMaterials)
            {
                if (mat.shader.name == "Unlit/SRUniversal")
                {
                    mat.SetVector(HeadForwardID, HeadForwardTransform.position - HeadBoneTransform.position);
                    mat.SetVector(HeadRightID, HeadRightTransform.position - HeadBoneTransform.position);
                }
            }
        }
    }
}
