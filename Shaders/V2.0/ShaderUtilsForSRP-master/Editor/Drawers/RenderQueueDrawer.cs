using System;
using JetBrains.Annotations;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

namespace Stalo.ShaderUtils.Editor.Drawers
{
    [PublicAPI, Obsolete]
    internal class RenderQueueDrawer : MaterialPropertyDrawer
    {
        public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor)
        {
            using (new EditorGUI.DisabledScope(!SupportedRenderingFeatures.active.editableMaterialRenderQueue))
            {
                editor.RenderQueueField(position);
            }
        }
    }
}
