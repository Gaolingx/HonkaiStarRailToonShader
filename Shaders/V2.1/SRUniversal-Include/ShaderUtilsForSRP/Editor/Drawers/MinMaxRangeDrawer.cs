using JetBrains.Annotations;
using UnityEditor;
using UnityEngine;

namespace Stalo.ShaderUtils.Editor.Drawers
{
    [PublicAPI]
    internal class MinMaxRangeDrawer : MaterialPropertyDrawer
    {
        private static readonly GUIContent[] s_SubLabels = { new("Min"), new("Max") };

        private readonly float m_Min;
        private readonly float m_Max;
        private readonly float[] m_ValueArray;

        public MinMaxRangeDrawer(float min, float max)
        {
            m_Min = min;
            m_Max = max;
            m_ValueArray = new float[2];
        }

        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            if (prop.type != MaterialProperty.PropType.Vector)
            {
                return base.GetPropertyHeight(prop, label, editor);
            }

            return EditorGUIUtility.singleLineHeight * 2 + EditorGUIUtility.standardVerticalSpacing;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor)
        {
#if UNITY_2022_1_OR_NEWER
            MaterialEditor.BeginProperty(position, prop);
#endif

            using (new MemberValueScope<bool>(() => EditorGUI.showMixedValue, prop.hasMixedValue))
            using (new MemberValueScope<float>(() => EditorGUIUtility.labelWidth, 0))
            {
                if (prop.type != MaterialProperty.PropType.Vector)
                {
                    EditorGUI.LabelField(position, label, "Not a Vector");
                }
                else
                {
                    Vector4 range = prop.vectorValue;

                    EditorGUI.BeginChangeCheck();

                    position.height = EditorGUIUtility.singleLineHeight;
                    EditorGUI.MinMaxSlider(position, label, ref range.x, ref range.y, m_Min, m_Max);

                    position.y += EditorGUIUtility.singleLineHeight;
                    position.y += EditorGUIUtility.standardVerticalSpacing;
                    position = MaterialEditor.GetRectAfterLabelWidth(position);

                    m_ValueArray[0] = range.x;
                    m_ValueArray[1] = range.y;
                    EditorGUI.MultiFloatField(position, s_SubLabels, m_ValueArray);

                    if (EditorGUI.EndChangeCheck())
                    {
                        range.x = m_ValueArray[0];
                        range.y = m_ValueArray[1];
                        prop.vectorValue = range;
                    }
                }
            }

#if UNITY_2022_1_OR_NEWER
            MaterialEditor.EndProperty();
#endif
        }
    }
}
