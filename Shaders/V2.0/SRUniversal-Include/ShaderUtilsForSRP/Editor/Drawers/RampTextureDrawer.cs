using JetBrains.Annotations;
using UnityEditor;
using UnityEngine;

namespace Stalo.ShaderUtils.Editor.Drawers
{
    [PublicAPI]
    internal class RampTextureDrawer : MaterialPropertyDrawer
    {
        public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor)
        {
#if UNITY_2022_1_OR_NEWER
            MaterialEditor.BeginProperty(position, prop);
#endif

            using (new MemberValueScope<bool>(() => EditorGUI.showMixedValue, prop.hasMixedValue))
            using (new MemberValueScope<float>(() => EditorGUIUtility.labelWidth, 0))
            {
                position.height = EditorGUIUtility.singleLineHeight;

                EditorGUI.BeginChangeCheck();
                Rect rampRect = EditorGUI.PrefixLabel(position, label);
                Texture2D ramp = (Texture2D)EditorGUI.ObjectField(rampRect, prop.textureValue, typeof(Texture2D), false);

                if (EditorGUI.EndChangeCheck())
                {
                    prop.textureValue = ramp;
                }

                if (!prop.hasMixedValue && ramp)
                {
                    Rect previewRect = new(rampRect.x + 1, rampRect.y + 1, rampRect.width - 20, rampRect.height - 2);
                    EditorGUI.DrawPreviewTexture(previewRect, ramp);
                }

                // NoScaleOffset
            }

#if UNITY_2022_1_OR_NEWER
            MaterialEditor.EndProperty();
#endif
        }
    }
}
