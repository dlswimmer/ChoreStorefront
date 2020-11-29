import * as enums from '../enums';

declare global {

namespace models {
${

    private const string IncludeClassAttribute = "TsClassModule";
    private static readonly string[] IgnorePropertyAttribute = {"IgnoreDataMember", "TsIgnore"};
    private const string OptionalMemberPropertyAttribute  = "TsOptionalMember";
    private const string CanBeNullPropertyAttribute  = "CanBeNull";
    private const string IncludeEnumAttribute = "TsEnumModule";

    Template(Settings settings)
    {
        settings.IncludeProject("ChoreStorefront")
        .IncludeProject("ChoreStorefront.Core")
        .IncludeProject("ChoreStorefront.Model")
        .IncludeProject("ChoreStorefront.Api");
        settings.OutputExtension = ".d.ts";
    }
    IEnumerable<Property> GetProperties(Class c) {

        var result = c.Properties.Where(m=>!m.Attributes.Any(a=>IgnorePropertyAttribute.Contains(a.Name)));

        if (c.BaseClass!=null && !c.BaseClass.Attributes.Any(a=>a.Name==IncludeClassAttribute)) {

            result = result.Concat(GetProperties(c.BaseClass));

        }


        return result;
    }

    IEnumerable<Property> GetProperties(Interface c) {

        var result = c.Properties.Where(m=>!m.Attributes.Any(a=>IgnorePropertyAttribute.Contains(a.Name)));

        return result;
    }

    bool IncludeClass(Class c) {

        return c.Attributes.Any(a => a.Name==IncludeClassAttribute);
        //var c2 = c;

        //while (c2!=null) {
        //    if (c2.Attributes.Any(a => a.Name==IncludeClassAttribute)) {
        //        return true;
         //   }
        //    c2 = c2.BaseClass;

        //    if (c2 !=null && c2.Name=="DefaultCommandResult") {
        //        return false;
        //    }
        //}

        //return false;
    }

    string ClassNameWithExtends(Class c) {
        var name = c.Name;

        if (c.TypeParameters.Any()) {
            name += c.TypeParameters.ToString();

        }

        var extends = new List<string>();
        if (c.BaseClass!=null && c.BaseClass.Attributes.Any(a=>a.Name==IncludeClassAttribute)) {
            var s  = c.BaseClass.Name;

            if (c.BaseClass.TypeParameters.Any()) {
                s += c.BaseClass.TypeArguments.ToString();
            }
            extends.Add(s);


        }

        foreach (var i in c.Interfaces.Where(m=>m.Attributes.Any(a=>a.Name==IncludeClassAttribute))) {


            if (!i.TypeParameters.Any()) {
                var s  = i.Name;
                extends.Add(s);

                //s += i.TypeParameters.ToString();
            }

        }

        if (extends.Any()) {
            name += " extends " + string.Join(", ", extends);
        }

        return name;
    }


    string ClassNameWithExtends(Interface c) {
        var name = c.Name;

        if (c.TypeParameters.Any()) {
            name += c.TypeParameters.ToString();

        }

        var extends = new List<string>();

        foreach (var i in c.Interfaces.Where(m=>m.Attributes.Any(a=>a.Name==IncludeClassAttribute))) {


            if (!i.TypeParameters.Any()) {
                 var s  = i.Name;

                //s += i.TypeParameters.ToString();
            extends.Add(s);

            }

        }

        if (extends.Any()) {
            name += " extends " + string.Join(", ", extends);
        }

        return name;
    }


    string BaseClassNotIncludedWarning(Class c) {

        if (c.BaseClass!=null && !c.BaseClass.Attributes.Any(a=>a.Name==IncludeClassAttribute)) {
            return "// WARNING: Base Class " + c.BaseClass.Name + " not marked with " + IncludeClassAttribute + " - so including base class properties inline instead of extending base class.\n// You should really decorate the " + c.BaseClass.Name + " class with the " + IncludeClassAttribute + " attribute.";
        }

        return "";
    }


	string PropertyName(Property p) {

        var name = p.name;

        //var cls = p.Parent as Class;

        //if (cls!=null && cls.Attributes.Any(m=>m.Name=="JsonObject" && m.Value.Contains("CamelCaseNamingStrategy"))) {
            //name = p.name;
        //}
		var isOptional = p.Type.IsNullable || p.Attributes.Any(a => a.Name==OptionalMemberPropertyAttribute || a.Name==CanBeNullPropertyAttribute);

		if (isOptional) {

			return name + '?';
		}

        if (p.Parent is Class c) {
            var baseClass = c.BaseClass;

            if (baseClass!=null) {
                var baseProperty = baseClass.Properties.FirstOrDefault(m=>m.Name==p.Name);
                if (baseProperty!=null) {
                    return PropertyName(baseProperty);
                }
            }
        }
		return name;


	}

    string EnumType(Property p) {


        var constAttribute = p.Attributes.FirstOrDefault(m=>m.Name=="TsConstant");

        if (constAttribute!=null) {

            return "enums." + constAttribute.Value;
        }


        if (!p.Type.Attributes.Any(a=>a.Name=="JsonConverter" && a.Value.Contains("StringEnumConverter")))
        {
            var parentClass = p.Parent as Class;

            var baseClass = parentClass?.BaseClass;

            if (baseClass!=null) {
                var baseProperty = baseClass.Properties.FirstOrDefault(m=>m.Name==p.Name);

                if (baseProperty!=null) {
                    return EnumType(baseProperty);
                }
            }
        }
         if (p.Type.IsEnumerable) {		
            return "readonly enums." + p.Type.ToString();
        }
        
        return "enums." + p.Type.ToString();

    }
	string PropertyType(Property p) {


        var type = p.Attributes.FirstOrDefault(m=>m.Name=="TsType");

        if (type!=null) {
            return GetType(type.Arguments[0].TypeValue);
        }

        
        if (p.Type.IsEnum && p.Type.Attributes.Any(a => a.Name ==IncludeEnumAttribute)) {

            return EnumType(p);

        }

        if (p.Type.IsEnumerable && p.Type.TypeArguments.Count==1) {
            var t = p.Type.TypeArguments[0];

            if (t.IsEnum && t.Attributes.Any(a => a.Name ==IncludeEnumAttribute)) {
                return EnumType(p);
                //return "enums." + type.ToString();

            }

        }
        
        return GetType(p.Type);


	}

    
	string GetType(Type type) {



        if ((type.OriginalName.StartsWith("Dictionary") || type.OriginalName.StartsWith("IReadOnlyDictionary")) && type.TypeArguments.Count==2) {

            var keyType = type.TypeArguments[0];
            var valueType = type.TypeArguments[1];

            var keyTypeStr = keyType.IsEnum ? "number" : keyType.ToString();

            return "{ [key: " + keyTypeStr +"]: " + valueType.ToString() +"; }";
        }

        if (type.ToString()=="Date") {
            return "string";
        }

        if (type.ToString()=="Date[]") {
            return "readonly string[]";
        }
        
        if (type.OriginalName.StartsWith("IReadOnlyCollection") && type.TypeArguments.Count==1) {

            var keyType = type.TypeArguments[0];
            
            return "readonly " + keyType + "[]";
        }
        
        if ((type.IsEnumerable) && !type.OriginalName.StartsWith("Dictionary") && (type.BaseClass==null || !type.BaseClass.Name.StartsWith("Dictionary"))) {
		
            return "readonly " + type.ToString();

        }

        //var isOptional = p.Type.IsNullable || p.Attributes.Any(a => a.Name==OptionalMemberPropertyAttribute || a.Name==CanBeNullPropertyAttribute);

        //if (isOptional) {
		    //return p.Type.ToString() + " | null";
        //}
        //return "Test: " + type.OriginalName;

		return type.ToString();


	}

	string DisplayValuePropertyType(Property p) {


        if (p.Type.Name=="string") {
            return "{ display: string }";
        }

        if (p.Type.IsPrimitive) {
            return "{ display: string; value: " + PropertyType(p) + "; }";
        }

		return p.Type.ToString();

	}


    string DocCommentFormatted(Item i) {

        var dc = (i as Class)?.DocComment ?? (i as Interface)?.DocComment ?? (i as Property)?.DocComment ?? (i as Constant)?.DocComment;

        var summary = string.Empty;
        if (dc != null) {
            summary = dc.Summary;
        }

        if (i is Property p && p.Type.IsDate) {

            var kindAttrib = p.Attributes.FirstOrDefault(a=>a.Name=="DateTimeKind");

            if (kindAttrib!=null) {
                if (!string.IsNullOrEmpty(summary)) {
                    summary+="\n";
                }

                if (kindAttrib.Value=="System.DateTimeKind.Utc") {
                    summary += "DateTime in UTC";
                }
                else if (kindAttrib.Value=="System.DateTimeKind.Local") {
                    summary += "DateTime in PST";
                }
            }
        }

        if (!string.IsNullOrEmpty(summary)) {
        return @"/**
        * " + summary + @"
        */";
        }
        return null;
    }

}



    $Classes(c => IncludeClass(c) && !c.Attributes.Any(a=>a.Name=="SerializeDisplayValue") && c.Name!="DefaultCommandResult")[
        $DocCommentFormatted
    export interface $ClassNameWithExtends {

        $GetProperties()[
        $DocCommentFormatted
        $PropertyName: $PropertyType;
    ]
	}

    $NestedClasses(c => c.Attributes.Any(a => a.Name==IncludeClassAttribute))[
        $DocCommentFormatted
    export interface $ClassNameWithExtends {

        $GetProperties()[
        $DocCommentFormatted
        $PropertyName: $PropertyType;
    ]
	}
    ]
	]

    $Classes(c => c.Attributes.Any(a => a.Name==IncludeClassAttribute) && c.Attributes.Any(a=>a.Name=="SerializeDisplayValue"))[
        $DocCommentFormatted
    export interface $ClassNameWithExtends {

        $GetProperties()[
        $DocCommentFormatted
        $PropertyName: $DisplayValuePropertyType
    ]
	}
	]

    $Interfaces(c => c.Attributes.Any(a => a.Name==IncludeClassAttribute) )[
        $DocCommentFormatted
    export interface $ClassNameWithExtends {
        $GetProperties()[
        $DocCommentFormatted
        $PropertyName: $PropertyType;
    ]
	}
	]


}
}