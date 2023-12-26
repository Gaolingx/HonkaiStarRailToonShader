using System.Collections.Generic;
using UnityEngine;

//为了在编辑模式下生效
[ExecuteInEditMode]
public class SendVector : MonoBehaviour
{
    [SerializeField] private Transform HeadReference;
    [SerializeField] private Transform HeadRightReference;
    [SerializeField] private Transform HeadForwardReference;
    private List<Material> _materials;
    private static readonly int HeadForwardID = Shader.PropertyToID("_HeadForward");
    private static readonly int HeadRightID = Shader.PropertyToID("_HeadRight");
    private bool needSend;

    private void Start()
    {
        var skinnedMeshRenderers = GetComponentsInChildren<SkinnedMeshRenderer>();
        _materials = new List<Material>();
        foreach (var skinnedMeshRenderer in skinnedMeshRenderers)
        {
            foreach (var material in skinnedMeshRenderer.sharedMaterials)
            {
                _materials.Add(material);
            }
        }
        OnValidate();
    }

    private void OnValidate()
    {
        needSend = HeadRightReference != null && HeadRightReference != null && HeadForwardReference != null;
    }

    private void LateUpdate()
    {
        if (!needSend) return;
        var position = HeadReference.position;
        var headForward = (HeadForwardReference.position - position).normalized;
        var headRight = (HeadRightReference.position - position).normalized;
        foreach (var material in _materials)
        {
            material.SetVector(HeadForwardID, headForward);
            material.SetVector(HeadRightID, headRight);
        }
    }
}