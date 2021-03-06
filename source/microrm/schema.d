module microrm.schema;

import microrm.util;

/++ Create SQL for creating tables if not exists
    Params:
    Types = types of structs which will be a tables
            name of struct -> name of table
            name of field -> name of column
 +/
auto buildSchema(Types...)()
{
    import std.array : appender;
    auto ret = appender!string;
    foreach (T; Types)
    {
        T t;
        static if (is(T == struct))
        {
            ret.put("CREATE TABLE IF NOT EXISTS ");
            ret.put(tableName!T);
            ret.put(" (\n");
            foreach (i, f; t.tupleof)
            {
                fieldToCol!(__traits(identifier, t.tupleof[i]),
                          typeof(f))(ret);
                static if (i != t.tupleof.length-1)
                    ret.put(",\n");
            }
            ret.put(");\n");
        }
        else static assert(0, "not supported non-struct type");
    }
    return ret.data;
}

unittest
{
    static struct Foo
    {
        ulong id;
        float value;
        ulong ts;
    }

    static struct Bar
    {
        ulong id;
        string text;
        ulong ts;
    }

    assert(buildSchema!(Foo, Bar) ==
`CREATE TABLE IF NOT EXISTS Foo (
id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
value REAL,
ts INTEGER NOT NULL);
CREATE TABLE IF NOT EXISTS Bar (
id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
text TEXT,
ts INTEGER NOT NULL);
`);
}