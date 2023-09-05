using System;
using System.Runtime.CompilerServices;
using System.Text;
using Unity.Collections.LowLevel.Unsafe;
using UnityEditor;
using UnityEngine;

namespace Stalo.ShaderUtils.Editor
{
    internal static class ShaderUtilSettings
    {
        public enum EOLType
        {
            [InspectorName(@"LF - Unix and macOS (\n)")] LF = 0,
            [InspectorName(@"CR - Classic Mac OS (\r)")] CR = 1,
            [InspectorName(@"CRLF - Windows (\r\n)")] CRLF = 2
        }

        public static bool AddUTF8BOM
        {
            get => GetValue(false);
            set => SetValue(value);
        }

        public static EOLType LineEndingType
        {
            get
            {
#if UNITY_EDITOR_WIN
                return (EOLType)GetValue((int)EOLType.CRLF);
#else
                return (EOLType)GetValue((int)EOLType.LF);
#endif
            }
            set => SetValue((int)value);
        }

        public static string ShaderNamePrefix
        {
            get => GetValue("Unlit/");
            set => SetValue(value);
        }

        public static string GetLineEnding() => LineEndingType switch
        {
            EOLType.LF => "\n",
            EOLType.CR => "\r",
            EOLType.CRLF => "\r\n",
            _ => throw new NotSupportedException()
        };

        public static Encoding GetEncoding() => new UTF8Encoding(AddUTF8BOM);

        private static T GetValue<T>(T defaultValue, [CallerMemberName] string propertyName = null)
        {
            string key = GetPropertyKey(propertyName);

            switch (Type.GetTypeCode(typeof(T)))
            {
                case TypeCode.Int32:
                {
                    int value = EditorPrefs.GetInt(key, UnsafeUtility.As<T, int>(ref defaultValue));
                    return UnsafeUtility.As<int, T>(ref value);
                }

                case TypeCode.Boolean:
                {
                    bool value = EditorPrefs.GetBool(key, UnsafeUtility.As<T, bool>(ref defaultValue));
                    return UnsafeUtility.As<bool, T>(ref value);
                }

                case TypeCode.Single:
                {
                    float value = EditorPrefs.GetFloat(key, UnsafeUtility.As<T, float>(ref defaultValue));
                    return UnsafeUtility.As<float, T>(ref value);
                }

                case TypeCode.String:
                {
                    string value = EditorPrefs.GetString(key, (string)(object)defaultValue);
                    return (T)(object)value;
                }

                default:
                    throw new NotSupportedException();
            }
        }

        private static void SetValue<T>(T value, [CallerMemberName] string propertyName = null)
        {
            string key = GetPropertyKey(propertyName);

            switch (Type.GetTypeCode(typeof(T)))
            {
                case TypeCode.Int32:
                {
                    EditorPrefs.SetInt(key, UnsafeUtility.As<T, int>(ref value));
                    break;
                }

                case TypeCode.Boolean:
                {
                    EditorPrefs.SetBool(key, UnsafeUtility.As<T, bool>(ref value));
                    break;
                }

                case TypeCode.Single:
                {
                    EditorPrefs.SetFloat(key, UnsafeUtility.As<T, float>(ref value));
                    break;
                }

                case TypeCode.String:
                {
                    EditorPrefs.SetString(key, (string)(object)value);
                    break;
                }

                default:
                    throw new NotSupportedException();
            }
        }

        private static string GetPropertyKey(string propertyName) => $"StaloShaderUtilsForSPR_{propertyName}";

        [SettingsProvider]
        private static SettingsProvider SettingsGUI() => new("Preferences/Shader Utils for SRP", SettingsScope.User)
        {
            guiHandler = (string searchContext) =>
            {
                using (new MemberValueScope<float>(() => EditorGUIUtility.labelWidth, 250.0f))
                {
                    GUILayout.BeginHorizontal();
                    GUILayout.Space(10);
                    GUILayout.BeginVertical();
                    GUILayout.Space(15);

                    try
                    {
                        EditorGUILayout.LabelField("Create File Settings", EditorStyles.boldLabel);
                        LineEndingType = (EOLType)EditorGUILayout.EnumPopup("Line Ending", LineEndingType);
                        AddUTF8BOM = EditorGUILayout.Toggle("Add BOM (UTF-8)", AddUTF8BOM);
                        ShaderNamePrefix = EditorGUILayout.DelayedTextField("Shader Name Prefix", ShaderNamePrefix);
                    }
                    finally
                    {
                        GUILayout.EndVertical();
                        GUILayout.EndHorizontal();
                    }
                }
            }
        };
    }
}
