using System;
using System.IO;
using System.Text;
using UnityEditor;
using UnityEditor.ProjectWindowCallback;
using UnityEngine;
using Object = UnityEngine.Object;

namespace Stalo.ShaderUtils.Editor
{
    public static class ShaderExtensions
    {
        private class OnNameEditEnd : EndNameEditAction
        {
            public override void Action(int instanceId, string pathName, string resourceFile)
            {
                if (!pathName.EndsWith(".shader"))
                {
                    pathName += ".shader";
                }

                var lineEnding = ShaderUtilSettings.GetLineEnding();
                var encoding = ShaderUtilSettings.GetEncoding();
                var template = AssetDatabase.LoadAssetAtPath<TextAsset>("Packages/com.stalomeow.srp-shader-utils/Editor/Templates/UnlitShaderURP.txt").text;
                template = template.Replace("\r\n", "\n");

                var sb = new StringBuilder();
                sb.AppendFormat("Shader \"{0}{1}\"{2}", ShaderUtilSettings.ShaderNamePrefix, Path.GetFileNameWithoutExtension(pathName), lineEnding);

                string[] lines = template.Split(new[] { '\r', '\n' }, StringSplitOptions.None);
                Array.ForEach(lines, line => sb.Append(line).Append(lineEnding));

                File.WriteAllText(pathName, sb.ToString(), encoding);

                AssetDatabase.ImportAsset(pathName);
                ProjectWindowUtil.ShowCreatedAsset(AssetDatabase.LoadAssetAtPath<Object>(pathName));
            }
        }

        [MenuItem("Assets/Create/Shader/Unlit Shader (URP)")]
        private static void CreateUnlitShaderForURP()
        {
            CreateUnlitShaderForURP(EditorFileUtility.GetNewFilePathBySelection("NewUnlitShader"));
        }

        public static void CreateUnlitShaderForURP(string pathName)
        {
            ProjectWindowUtil.StartNameEditingIfProjectWindowExists(
                0,
                ScriptableObject.CreateInstance<OnNameEditEnd>(),
                pathName,
                AssetPreview.GetMiniTypeThumbnail(typeof(Shader)),
                null);
        }
    }
}
