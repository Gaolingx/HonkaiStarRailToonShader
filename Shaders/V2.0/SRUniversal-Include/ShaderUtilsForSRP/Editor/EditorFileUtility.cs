using System.IO;
using UnityEditor;
using UnityEngine;

namespace Stalo.ShaderUtils.Editor
{
    internal static class EditorFileUtility
    {
        public static string GetNewFilePathBySelection(string fileName)
        {
            string folder = "Assets";
            Object[] assets = Selection.GetFiltered<Object>(SelectionMode.Assets);

            if (assets.Length > 0)
            {
                string assetPath = AssetDatabase.GetAssetPath(assets[0]);
                folder = AssetDatabase.IsValidFolder(assetPath) ? assetPath : Path.GetDirectoryName(assetPath);
            }

            return folder + "/" + fileName;
        }
    }
}
