using System;
using JetBrains.Annotations;
using UnityEditor;
using UnityEngine;
using Object = UnityEngine.Object;

namespace Stalo.ShaderUtils.Editor.Drawers
{
    [PublicAPI, Obsolete("Use Enum instead.")]
    internal class ToggleEnumDrawer : MaterialPropertyDrawer
    {
        private readonly string m_Keyword;
        private readonly int m_OnValue;
        private readonly int m_OffValue;

        // 不能用 int 当参数，数字必须用 float
        public ToggleEnumDrawer(string keyword, float onValue, float offValue)
        {
            m_Keyword = keyword;
            m_OnValue = (int)onValue;
            m_OffValue = (int)offValue;
        }

        public ToggleEnumDrawer(float onValue, float offValue) : this(null, onValue, offValue) { }

        public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor)
        {
            MaterialEditor.BeginProperty(position, prop);

            using (new MemberValueScope<bool>(() => EditorGUI.showMixedValue, prop.hasMixedValue))
            {
                if (prop.type is MaterialProperty.PropType.Float or MaterialProperty.PropType.Range)
                {
                    EditorGUI.BeginChangeCheck();
                    bool toggleValue = EditorGUI.Toggle(position, label, (int)prop.floatValue == m_OnValue);

                    if (EditorGUI.EndChangeCheck())
                    {
                        prop.floatValue = toggleValue ? m_OnValue : m_OffValue;
                        SetKeyword(prop, m_Keyword, toggleValue);
                    }
                }
                else if (prop.type is MaterialProperty.PropType.Int)
                {
                    EditorGUI.BeginChangeCheck();
                    bool toggleValue = EditorGUI.Toggle(position, label, prop.intValue == m_OnValue);

                    if (EditorGUI.EndChangeCheck())
                    {
                        prop.intValue = toggleValue ? m_OnValue : m_OffValue;
                        SetKeyword(prop, m_Keyword, toggleValue);
                    }
                }
                else
                {
                    Debug.LogErrorFormat("The type of {0} should be Float/Range/Int.", prop.name);
                }
            }

            MaterialEditor.EndProperty();
        }

        public override void Apply(MaterialProperty prop)
        {
            base.Apply(prop);

            if (prop.type is MaterialProperty.PropType.Float or MaterialProperty.PropType.Range)
            {
                SetKeyword(prop, m_Keyword, (int)prop.floatValue == m_OnValue);
            }
            else if (prop.type is MaterialProperty.PropType.Int)
            {
                SetKeyword(prop, m_Keyword, prop.intValue == m_OnValue);
            }
        }

        private static void SetKeyword(MaterialProperty prop, string keyword, bool on)
        {
            if (string.IsNullOrEmpty(keyword))
            {
                return;
            }

            Object[] targets = prop.targets;

            for (int i = 0; i < targets.Length; i++)
            {
                var material = (Material)targets[i];

                if (on)
                {
                    material.EnableKeyword(keyword);
                }
                else
                {
                    material.DisableKeyword(keyword);
                }
            }
        }
    }
}
