using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEditor.ProjectWindowCallback;
using UnityEngine;

namespace Stalo.ShaderUtils.Editor
{
    public static class HLSLExtensions
    {
        private class OnNameEditEnd : EndNameEditAction
        {
            public override void Action(int instanceId, string pathName, string resourceFile)
            {
                if (!pathName.EndsWith(".hlsl"))
                {
                    pathName += ".hlsl";
                }

                var defineName = GetDefineName(Path.GetFileNameWithoutExtension(pathName));
                var lineEnding = ShaderUtilSettings.GetLineEnding();
                var encoding = ShaderUtilSettings.GetEncoding();

                var sb = new StringBuilder();
                sb.AppendFormat("#ifndef {0}_INCLUDED{1}", defineName, lineEnding);
                sb.AppendFormat("#define {0}_INCLUDED{1}", defineName, lineEnding);
                sb.Append(lineEnding);
                sb.AppendFormat("#endif{0}", lineEnding);

                File.WriteAllText(pathName, sb.ToString(), encoding);

                AssetDatabase.ImportAsset(pathName);
                ProjectWindowUtil.ShowCreatedAsset(AssetDatabase.LoadAssetAtPath<Object>(pathName));
            }

            private static string GetDefineName(string fileName)
            {
                string defineName = Regex.Replace(fileName, @"(.)([A-Z][^A-Z])", @"$1_$2");
                defineName = Regex.Replace(defineName, @"([^A-Z_])([A-Z])", @"$1_$2");
                return "_" + defineName.ToUpper();
            }
        }

        [MenuItem("Assets/Create/Shader/HLSL Shader Include")]
        private static void Create()
        {
            Create(EditorFileUtility.GetNewFilePathBySelection("NewHLSLShaderInclude"));
        }

        public static void Create(string pathName)
        {
            ProjectWindowUtil.StartNameEditingIfProjectWindowExists(
                0,
                ScriptableObject.CreateInstance<OnNameEditEnd>(),
                pathName,
                AssetPreview.GetMiniTypeThumbnail(typeof(ShaderInclude)),
                null);
        }
    }
}
