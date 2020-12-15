using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace TestHooksNamespace
{
    public class TestHooksClass
    {
        public TestHooksClass()
        { }

public void TestHooksMethod(string xmlSource)
{
    // Compose a string that consists of three lines.
    string lines = string.Format("DateTime: {0}, XMLSource: {1}", DateTime.Now.ToString(), xmlSource);
    // Write the string to a file.
    try
    {
        using (System.IO.StreamWriter file = new System.IO.StreamWriter(Properties.Settings.Default.EventFile, true))
        {
            file.WriteLine(lines);
        }

    }
    // Catch Exception
    catch (Exception ex)
    {
        using (System.IO.StreamWriter file = new System.IO.StreamWriter(Properties.Settings.Default.ErrorFile, true))
        {
            file.WriteLine(ex.Message);
        }
    }
}
    }
}
