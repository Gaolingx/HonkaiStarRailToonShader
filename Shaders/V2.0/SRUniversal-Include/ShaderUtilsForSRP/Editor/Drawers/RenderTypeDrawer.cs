using System;
using System.Linq;
using JetBrains.Annotations;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

namespace Stalo.ShaderUtils.Editor.Drawers
{
    [PublicAPI, Obsolete]
    internal class RenderTypeDrawer : MaterialPropertyDrawer
    {
        private enum RenderType
        {
            Opaque = 0,
            AlphaTest = 1,
            Transparent = 2
        }

        private readonly string m_ZWritePropName;
        private readonly string m_RenderQueueOffsetPropName;

        public RenderTypeDrawer(string zWritePropName, string renderQueueOffsetPropName)
        {
            m_ZWritePropName = zWritePropName;
            m_RenderQueueOffsetPropName = renderQueueOffsetPropName;
        }

        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return EditorGUIUtility.singleLineHeight * 2 + EditorGUIUtility.standardVerticalSpacing;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor)
        {
            if (prop.type != MaterialProperty.PropType.Float)
            {
                Debug.LogErrorFormat("The type of {0} should be Float.", prop.name);
                return;
            }

            MaterialProperty renderQueueOffsetProp = FindProperty(editor, m_RenderQueueOffsetPropName);

            if (renderQueueOffsetProp.type != MaterialProperty.PropType.Float)
            {
                Debug.LogErrorFormat("The type of {0} should be Float.", renderQueueOffsetProp.name);
                return;
            }

            bool changed = false;

            position.height = EditorGUIUtility.singleLineHeight;
            changed |= DrawRenderTypeField(position, prop, label);

            position.y = position.yMax + EditorGUIUtility.standardVerticalSpacing;
            changed |= DrawRenderQueueOffsetField(position, renderQueueOffsetProp, renderQueueOffsetProp.displayName);

            if (changed)
            {
                ConfigRenderType(prop);
            }
        }

        private bool DrawRenderTypeField(Rect position, MaterialProperty prop, string label)
        {
            EditorGUI.BeginChangeCheck();
            RenderType renderType = (RenderType)(int)prop.floatValue;

            using (new MemberValueScope<bool>(() => EditorGUI.showMixedValue, prop.hasMixedValue))
            using (new MemberValueScope<float>(() => EditorGUIUtility.labelWidth, 0))
            {
#if UNITY_2022_1_OR_NEWER
                MaterialEditor.BeginProperty(position, prop);
#endif

                renderType = (RenderType)EditorGUI.EnumPopup(position, label, renderType);

#if UNITY_2022_1_OR_NEWER
                MaterialEditor.EndProperty();
#endif
            }

            if (EditorGUI.EndChangeCheck())
            {
                prop.floatValue = (int)renderType;
                return true;
            }

            return false;
        }

        private bool DrawRenderQueueOffsetField(Rect position, MaterialProperty prop, string label)
        {
            EditorGUI.BeginChangeCheck();
            int renderQueueOffset = (int)prop.floatValue;

            using (new MemberValueScope<bool>(() => EditorGUI.showMixedValue, prop.hasMixedValue))
            {
#if UNITY_2022_1_OR_NEWER
                MaterialEditor.BeginProperty(position, prop);
#endif

                renderQueueOffset = EditorGUI.DelayedIntField(position, label, renderQueueOffset);

#if UNITY_2022_1_OR_NEWER
                MaterialEditor.EndProperty();
#endif
            }

            if (EditorGUI.EndChangeCheck())
            {
                prop.floatValue = renderQueueOffset;
                return true;
            }

            return false;
        }

        public override void Apply(MaterialProperty prop)
        {
            base.Apply(prop);

            if (prop.type != MaterialProperty.PropType.Float)
            {
                Debug.LogErrorFormat("The type of {0} should be Float.", prop.name);
                return;
            }

            ConfigRenderType(prop);
        }

        private void ConfigRenderType(MaterialProperty prop)
        {
            RenderType renderType = (RenderType)(int)prop.floatValue;

            foreach (Material material in prop.targets.Cast<Material>())
            {
                int renderQueueOffset = (int)material.GetFloat(m_RenderQueueOffsetPropName);

                switch (renderType)
                {
                    case RenderType.Opaque:
                    {
                        int renderQueue = (int)RenderQueue.Geometry;
                        material.renderQueue = renderQueue + renderQueueOffset;

                        material.SetOverrideTag("RenderType", "Opaque");
                        material.SetFloat(m_ZWritePropName, 1);

                        material.EnableKeyword(prop.name.ToUpperInvariant() + "_OPAQUE");
                        material.DisableKeyword(prop.name.ToUpperInvariant() + "_ALPHA_TEST");
                        material.DisableKeyword(prop.name.ToUpperInvariant() + "_TRANSPARENT");
                        break;
                    }

                    case RenderType.AlphaTest:
                    {
                        int renderQueue = (int)RenderQueue.AlphaTest;
                        material.renderQueue = renderQueue + renderQueueOffset;

                        material.SetOverrideTag("RenderType", "TransparentCutout");
                        material.SetFloat(m_ZWritePropName, 1);

                        material.DisableKeyword(prop.name.ToUpperInvariant() + "_OPAQUE");
                        material.EnableKeyword(prop.name.ToUpperInvariant() + "_ALPHA_TEST");
                        material.DisableKeyword(prop.name.ToUpperInvariant() + "_TRANSPARENT");
                        break;
                    }

                    case RenderType.Transparent:
                    {
                        int renderQueue = (int)RenderQueue.Transparent;
                        material.renderQueue = renderQueue + renderQueueOffset;

                        material.SetOverrideTag("RenderType", "Transparent");
                        material.SetFloat(m_ZWritePropName, 0);

                        material.DisableKeyword(prop.name.ToUpperInvariant() + "_OPAQUE");
                        material.DisableKeyword(prop.name.ToUpperInvariant() + "_ALPHA_TEST");
                        material.EnableKeyword(prop.name.ToUpperInvariant() + "_TRANSPARENT");
                        break;
                    }

                    default:
                        throw new NotImplementedException();
                }
            }
        }

        private static MaterialProperty FindProperty(MaterialEditor editor, string propName)
        {
            return MaterialEditor.GetMaterialProperty(editor.targets, propName);
        }
    }
}
