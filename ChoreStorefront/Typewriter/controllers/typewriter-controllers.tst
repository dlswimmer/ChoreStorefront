// @ts-ignore
import * as enums from '../enums';
${
    Template(Settings settings)
    {
        settings.IncludeProject("ChoreStorefront");        
    }

    // =================================== SHARED LOGIC -- PLEASE KEEP IN SYNC WITH typewriter-definitions.tst and typewriter-controllers.tst and typewriter-master.tst
    private const string IncludeEnumAttribute = "TsEnumModule";

    string DocCommentFormatted(Property p) {
        var dc = p.DocComment;
        if (dc == null) {
            return string.Empty;
        }

        return @"/**
        * " + dc.Summary + @"
        */";
    }


    // =================================== CONTROLLER LOGIC:
    
    IEnumerable<Method> GetMethods(Class cls) {
        return cls.Methods.Where(m=>m.Attributes.Any(a=> a.Name=="HttpGet") && !m.Attributes.Any(a=> a.Name=="TsIgnore"));
    }
    
    IEnumerable<Method> PostMethods(Class cls) {
        return cls.Methods.Where(m=>m.Attributes.Any(a=> a.Name=="HttpPost") && !m.Attributes.Any(a=> a.Name=="TsIgnore"));
    }

       
    string GetType(Parameter p) {

        return GetType(p.Type);
    }

    string GetType(Type t) {
    
        if (t.IsEnum && t.Attributes.Any(a => a.Name ==IncludeEnumAttribute)) {

            return "enums." + t.ToString();

        }
        

        if (t.OriginalName.StartsWith("IDictionary") && t.TypeArguments.Count==2) {

            var keyType = t.TypeArguments[0];
            var valueType = t.TypeArguments[1];

            var keyTypeStr = keyType.IsEnum ? "string" : keyType.ToString();

            return "{ [key: " + keyTypeStr +"]: " + GetType(valueType) +"; }";
        }

        if (t.IsPrimitive && !t.GetType().Name.StartsWith("IDictionary")) {
            return t.ToString();
        }
        
        if (t.TypeParameters.Any() && t.Name.Contains("<")) {
            var typeParams = t.TypeArguments.Select(m=>GetType(m));


            return "models." + t.Name.Substring(0, t.Name.IndexOf("<")) + "<" + string.Join(",", typeParams) + ">";
            //name += c.TypeParameters.ToString();

        }

        return (t.IsEnumerable ? "readonly " : "") + "models." + t.ToString();
    }
    
    string GetType(Method p) {

        var t = p.Attributes.FirstOrDefault(m=>m.Name=="TsType" || m.Name=="ResponseType");

        if (t!=null) {
            return GetType(t.Arguments[0].TypeValue);
        }
        if ( p.Type.Name=="Task")
        {
            return "void";
        }
        return (p.Type.IsPrimitive && !p.Type.OriginalName.StartsWith("IDictionary")) || p.Type.Name=="void" ? p.Type.ToString() : GetType(p.Type);
    }
    
    Parameter[] ControllerFilterParameters(Method method) {

        return method.Parameters.Where(m=>m.Type.Name!="CancellationToken").ToArray();

    }

    string ControllerPostParameters(Method method) {
    
        var ps = ControllerFilterParameters(method).Where(m=>!m.Type.IsPrimitive).ToArray();
      
        if (ps.Length==0) {
            return "";
        }
        if (ps.Length==1) {
            return ", " + ps[0].name;                            
        }

        return ", {" + string.Join(", ", ps.Select(p=>p.name)) + "}";
        
    }
    
    string postUrl(Method m) {
    
        var ps = ControllerFilterParameters(m);
      
        if (ps.Length==1 && ps[0].name=="id") {
            return "'" + m.name + "/' + id";
        }

        if (ps.Length>=1 && ps.Any(p=>p.Type.IsPrimitive)) {
            return getUrl(m);
        }

        return "'" + m.name + "/'";

    }

        
    string getUrl(Method m) {
    
        var ps = ControllerFilterParameters(m);
      
        if (ps.Length==1 && ps[0].name=="id") {
            return "'" + m.name + "/' + id";
        }
        
        //if (ps.Length==1 && !ps[0].Type.IsPrimitive) {
        //    return  "'" + m.name + "/?" + string.Join(" + \'&",  ps[0].Type.Properties.Select(p=> p.name + "=' + " + (p.Type.name=="string" ? "encodeURIComponent(" + ps[0].name + "." + p.name + ")" : ps[0].name + "." + p.name)));
        //}

        if (ps.Length==0) {
            return "'" + m.name + "/'";
        }
        return "'" + m.name + "/?" + string.Join(" + \'&", ps.Where(m=>m.Type.IsPrimitive).Select(p=> p.name + "=' + " + (p.Type.name=="string" ? "encodeURIComponent(" + p.name + ")" : p.name)));
        
    }


    string nameWithoutController(Class c) {

    var name = c.name.EndsWith("Controller") ? c.name.Substring(0, c.name.Length-10) : c.name;

        var namespac = c.Namespace;

        return name;
    }

    string importFunctions(File file) {
    
        var anyGet = file.Classes.Any(c=>c.Methods.Any(m=>m.Attributes.Any(a=>a.Name=="HttpGet")));
        var anyPost= file.Classes.Any(c=>c.Methods.Any(m=>m.Attributes.Any(a=>a.Name=="HttpPost")));

        if (anyGet) {

            if (anyPost) {
                return "executeGet, executePost";
            }
            return "executeGet";
    
        }
        else if (anyPost) {
            return "executePost";
        }

        return "";

    }
}

import { $importFunctions } from '../http-utils';

$Classes(c=>c.Attributes.Any(a=>a.Name=="TsClassController") && (GetMethods(c).Any() || PostMethods(c).Any()))[


    export const endpointUrl = '/api/$nameWithoutController/';
    
$GetMethods[
    export function $name($ControllerFilterParameters[$name: $GetType][, ]) { return executeGet<$GetType>(endpointUrl + $getUrl); }
    ]

    $PostMethods[
    export function $name($ControllerFilterParameters[$name: $GetType][, ]) { return executePost<$GetType>(endpointUrl + $postUrl$ControllerPostParameters); }
    ]

    
]