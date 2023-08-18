using JetBrains.Annotations;
using UnityEditor;

namespace Stalo.ShaderUtils.Editor.Wrappers
{
    [PublicAPI]
    internal class IndentWrapper : MaterialPropertyWrapper
    {
        private readonly int m_IndentCount;

        public IndentWrapper(string rawArgs) : base(rawArgs)
        {
            m_IndentCount = string.IsNullOrWhiteSpace(rawArgs) ? 1 : int.Parse(rawArgs);
        }

        public override void OnWillDrawProperty(MaterialProperty prop, string label, MaterialEditor editor)
        {
            EditorGUI.indentLevel += m_IndentCount;
        }

        public override void OnDidDrawProperty(MaterialProperty prop, string label, MaterialEditor editor)
        {
            EditorGUI.indentLevel -= m_IndentCount;
        }
    }
}
