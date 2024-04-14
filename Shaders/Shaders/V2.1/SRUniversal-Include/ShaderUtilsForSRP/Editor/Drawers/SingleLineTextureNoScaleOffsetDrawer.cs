using System.Reflection;
using JetBrains.Annotations;
using UnityEditor;
using UnityEngine;

namespace Stalo.ShaderUtils.Editor.Drawers
{
    [PublicAPI]
    internal class SingleLineTextureNoScaleOffsetDrawer : MaterialPropertyDrawer
    {
        private static readonly MethodInfo s_ExtraPropertyAfterTextureMethod = typeof(MaterialEditor)
            .GetMethod("ExtraPropertyAfterTexture", BindingFlags.Instance | BindingFlags.NonPublic);

        private readonly string m_ColorPropName;

        public SingleLineTextureNoScaleOffsetDrawer() : this(null) { }

        public SingleLineTextureNoScaleOffsetDrawer(string colorPropName)
        {
            m_ColorPropName = colorPropName;
        }

        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return EditorGUIUtility.singleLineHeight;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor)
        {
            // using (EditorGUIScopes.LabelWidth())
            {
                editor.TexturePropertyMiniThumbnail(position, prop, label.text, label.tooltip);

                if (string.IsNullOrEmpty(m_ColorPropName))
                {
                    return;
                }

                MaterialProperty colorProp = FindColorProperty(editor);
                Rect colorRect = MaterialEditor.GetRectAfterLabelWidth(position);
                s_ExtraPropertyAfterTextureMethod.Invoke(editor, new object[] { colorRect, colorProp, false });
            }
        }

        private MaterialProperty FindColorProperty(MaterialEditor editor)
        {
            return MaterialEditor.GetMaterialProperty(editor.targets, m_ColorPropName);
        }
    }
}
