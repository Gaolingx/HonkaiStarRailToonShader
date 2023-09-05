using System;
using JetBrains.Annotations;
using UnityEditor;

namespace Stalo.ShaderUtils.Editor.Wrappers
{
    [PublicAPI]
    internal class HelpBoxWrapper : MaterialPropertyWrapper
    {
        private readonly MessageType m_MsgType;
        private readonly string m_Message;

        public HelpBoxWrapper(string rawArgs) : base(rawArgs)
        {
            string[] args = rawArgs.Split(',', StringSplitOptions.RemoveEmptyEntries);

            for (int i = 0; i < args.Length; i++)
            {
                args[i] = args[i].Trim();
            }

            m_MsgType = Enum.Parse<MessageType>(args[0]);
            m_Message = string.Join(", ", args[1..]);
        }

        public override void OnWillDrawProperty(MaterialProperty prop, string label, MaterialEditor editor)
        {
            EditorGUILayout.HelpBox(m_Message, m_MsgType);
        }
    }
}
