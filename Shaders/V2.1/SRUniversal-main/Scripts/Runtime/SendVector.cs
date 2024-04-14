using System.Collections.Generic;
using System.Linq;
using UnityEngine;

//为了在编辑模式下生效
[ExecuteInEditMode]
public class SendVector : MonoBehaviour
{
    public static SendVector Instance = null;

    [SerializeField] private Transform HeadReference;
    [SerializeField] private Transform HeadRightReference;
    [SerializeField] private Transform HeadForwardReference;
    private List<Material> _materials;
    private static readonly int HeadForwardID = Shader.PropertyToID("_HeadForward");
    private static readonly int HeadRightID = Shader.PropertyToID("_HeadRight");
    private bool needSend;

    public void InitComponent()
    {
        Instance = this;
    }

    private void Start()
    {
        InitComponent();
        GetMaterialsByReference();
    }

    public void GetMaterialsByReference()
    {

        SkinnedMeshRenderer[] skinnedMeshRenderers = GetComponentsInChildren<SkinnedMeshRenderer>();

        if (skinnedMeshRenderers != null)
        {
            _materials = new List<Material>();
            foreach (var skinnedMeshRenderer in skinnedMeshRenderers)
            {
                foreach (var material in skinnedMeshRenderer.materials)
                {
                    _materials.Add(material);
                }
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