using System;
using JetBrains.Annotations;
using UnityEditor;
using UnityEngine;

namespace Stalo.ShaderUtils.Editor.Drawers
{
    [PublicAPI, Obsolete]
    internal class KeywordFilterDrawer : MaterialPropertyDrawer
    {
        private readonly string m_Keyword;
        private readonly bool m_State;
        private readonly int m_LabelIndent;

        public KeywordFilterDrawer(string keyword) : this(keyword, "On", 0) { }

        public KeywordFilterDrawer(string keyword, string state) : this(keyword, state, 0) { }

        public KeywordFilterDrawer(string keyword, string state, float labelIndent)
        {
            string stateLower = state.ToLower();

            if (stateLower is not ("on" or "off"))
            {
                Debug.LogWarning($"Invalid argument '{state}' in KeywordFilter. Use 'On' or 'Off' instead.");
            }

            m_Keyword = keyword;
            m_State = (stateLower != "off");
            m_LabelIndent = (int)labelIndent;
        }

        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            if (prop.hasMixedValue || MatchKeywordState(editor.target as Material))
            {
                return MaterialEditor.GetDefaultPropertyHeight(prop);
            }

            return 0f;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor)
        {
            if (prop.hasMixedValue || MatchKeywordState(editor.target as Material))
            {
                EditorGUI.indentLevel += m_LabelIndent;
                editor.DefaultShaderProperty(position, prop, label);
                EditorGUI.indentLevel -= m_LabelIndent;
                return;
            }

            // remove useless references
            switch (prop.type)
            {
                case MaterialProperty.PropType.Texture:
                    prop.textureValue = null;
                    break;
            }
        }

        private bool MatchKeywordState(Material material)
        {
            return material.IsKeywordEnabled(m_Keyword) == m_State;
        }
    }
}
