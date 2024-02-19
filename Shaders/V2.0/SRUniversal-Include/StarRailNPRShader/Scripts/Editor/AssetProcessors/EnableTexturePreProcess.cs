using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[InitializeOnLoad]
public class EnableTexturePreProcess
{
    [MenuItem("Honkai Star Rail/资产预处理/开启资产预处理", true)]
    public static bool CheckEnablePreProcess()
    {
        return !EditorPrefs.GetBool("EnableTexturePreProcess", false);
    }

    [MenuItem("Honkai Star Rail/资产预处理/开启资产预处理", false)]
    public static void EnablePreProcess()
    {
        EditorPrefs.SetBool("EnableTexturePreProcess", true);
    }

    [MenuItem("Honkai Star Rail/资产预处理/关闭资产预处理", true)]
    public static bool CheckDisablePreProcess()
    {
        return EditorPrefs.GetBool("EnableTexturePreProcess", false);
    }

    [MenuItem("Honkai Star Rail/资产预处理/关闭资产预处理", false)]
    public static void DisablePreProcess()
    {
        EditorPrefs.SetBool("EnableTexturePreProcess", false);
    }
}
