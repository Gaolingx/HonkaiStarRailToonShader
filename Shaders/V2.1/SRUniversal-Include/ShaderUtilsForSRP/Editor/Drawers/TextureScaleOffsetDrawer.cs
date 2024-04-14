using JetBrains.Annotations;
using UnityEditor;
using UnityEngine;

namespace Stalo.ShaderUtils.Editor.Drawers
{
    [PublicAPI]
    internal class TextureScaleOffsetDrawer : MaterialPropertyDrawer
    {
        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return 2 * EditorGUIUtility.singleLineHeight + EditorGUIUtility.standardVerticalSpacing;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor)
        {
#if UNITY_2022_1_OR_NEWER
            MaterialEditor.BeginProperty(position, prop);
#endif

            using (new MemberValueScope<bool>(() => EditorGUI.showMixedValue, prop.hasMixedValue))
            using (new MemberValueScope<float>(() => EditorGUIUtility.labelWidth, 0))
            {
                EditorGUI.BeginChangeCheck();

                Vector4 value = MaterialEditor.TextureScaleOffsetProperty(position, prop.vectorValue, false);

                if (EditorGUI.EndChangeCheck())
                {
                    prop.vectorValue = value;
                }
            }

#if UNITY_2022_1_OR_NEWER
            MaterialEditor.EndProperty();
#endif
        }
    }
}
