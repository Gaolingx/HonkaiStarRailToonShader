using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[InitializeOnLoad]
public class EnableAssetsPreProcess
{
    [MenuItem("Honkai Star Rail/资产预处理/开启资产预处理", true)]
    public static bool CheckEnablePreProcess()
    {
        return !EditorPrefs.GetBool("EnableAssetsPreProcess", false);
    }

    [MenuItem("Honkai Star Rail/资产预处理/开启资产预处理", false)]
    public static void EnablePreProcess()
    {
        EditorPrefs.SetBool("EnableAssetsPreProcess", true);
    }

    [MenuItem("Honkai Star Rail/资产预处理/关闭资产预处理", true)]
    public static bool CheckDisablePreProcess()
    {
        return EditorPrefs.GetBool("EnableAssetsPreProcess", false);
    }

    [MenuItem("Honkai Star Rail/资产预处理/关闭资产预处理", false)]
    public static void DisablePreProcess()
    {
        EditorPrefs.SetBool("EnableAssetsPreProcess", false);
    }
}
