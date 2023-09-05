using UnityEditor;

namespace Stalo.ShaderUtils.Editor
{
    public abstract class MaterialPropertyWrapper
    {
        protected MaterialPropertyWrapper(string rawArgs) { }

        public virtual bool CanDrawProperty(MaterialProperty prop, string label, MaterialEditor editor) => true;

        public virtual void OnWillDrawProperty(MaterialProperty prop, string label, MaterialEditor editor) { }

        public virtual void OnDidDrawProperty(MaterialProperty prop, string label, MaterialEditor editor) { }
    }
}
