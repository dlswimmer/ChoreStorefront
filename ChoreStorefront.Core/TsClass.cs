using System;
using System.Diagnostics;

namespace ChoreStorefront.Core
{
    // These are hint attributes that are only used by the Typescript Typwriter templates to know which files should be generated
    // https://github.com/frhagn/Typewriter



    /// <summary>
    /// Indicates this class or interface should auto-gen a Typescript interface with TypeWriter
    /// </summary>
    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Interface | AttributeTargets.Struct)]
    //[Conditional("NOT_COMPILED")]
    public class TsClassModuleAttribute : Attribute
    {
        //public TsClassModuleAttribute()
        //{
        //    NamingStrategyType = typeof(CamelCaseNamingStrategy);
        //}
    }

    /// <summary>
    /// Indicates this class or interface should auto-gen a Typescript interface with TypeWriter
    /// </summary>
    [AttributeUsage(AttributeTargets.Class)]
    //[Conditional("NOT_COMPILED")]
    public class TsConstClassModule : Attribute
    {
        //public TsClassModuleAttribute()
        //{
        //    NamingStrategyType = typeof(CamelCaseNamingStrategy);
        //}
    }


    /// <summary>
    /// Indicates this enum should auto-gen a Typescript interface with TypeWriter
    /// </summary>
    [AttributeUsage(AttributeTargets.Enum)]
    //[Conditional("NOT_COMPILED")]
    public class TsEnumModuleAttribute : Attribute
    {
    }

    [AttributeUsage(AttributeTargets.Property)]
    public class TsOptionalMemberAttribute : Attribute
    {
    }


    /// <summary>
    /// Indicates this class should auto-gen a Typescript interface with TypeWriter for a signalr Hub
    /// </summary>
    [AttributeUsage(AttributeTargets.Class)]
    public class TsHub : Attribute
    {
    }

    [AttributeUsage(AttributeTargets.Property)]
    //[Conditional("NOT_COMPILED")]
    public class TsConstantAttribute : Attribute
    {
        public TsConstantAttribute(string value)
        {
            Value = value;
        }

        public string Value { get; set; }
    }

    /// <summary>
    /// Indicates this property should be ignored when dealing with generating Typescript files
    /// </summary>
    [AttributeUsage(AttributeTargets.Property | AttributeTargets.Method)]
    [Conditional("NOT_COMPILED")]
    public class TsTypeAttribute : Attribute
    {
        public Type Type { get; }
        //public string Name { get; }

        //public TsTypeAttribute(string name)
        //{
        //    Name = name;
        //}

        public TsTypeAttribute(Type type)
        {
            Type = type;
        }
    }

    [AttributeUsage(AttributeTargets.Class)]
    public class TsClassControllerAttribute : Attribute
    {
        //public HahTsClassModuleAttribute()
        //{
        //    NamingStrategyType = typeof(CamelCaseNamingStrategy);
        //}
    }
}
