using RestSharp;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using System.ServiceProcess;
using System.Text;
using System.Threading.Tasks;
using System.Net;
using System.Xml;
using System.Configuration.Install;
using System.Web.UI.WebControls;

namespace RunSimioPortalExperiment
{
    class Program : ServiceBase
    {
        private static string _token;
        private static ICredentials _credentials;
        private static bool _useDefaultCredentials;
        private static Uri _url;

        static void Main(string[] args)
        {
            if (!Environment.UserInteractive)
            {
                // running as service
                using (var service = new Program())
                    ServiceBase.Run(service);
            }
            else
            {
                using (var service = new Program())
                {
                    // running as console app
                    service.OnStart(args);
                    Console.WriteLine("Hit any key to stop...");
                    do { } while (Console.ReadLine() != "q");
                    service.OnStop();
                }

            }
        }
        protected override void OnStart(string[] args)
        {
            ShutdownHost();

            // Start Watcher  
            runPortalExperimentMoninitorAndPublishResults();

            FileSystemWatcher watcher = new FileSystemWatcher();
            watcher.Path = Path.GetDirectoryName(Properties.Settings.Default.EventFile);
            watcher.Filter = Path.GetFileName(Properties.Settings.Default.EventFile);
            watcher.Changed += watcher_Changed;
            watcher.EnableRaisingEvents = true;
            base.OnStart(args);

            logStatus("Service Started", Properties.Settings.Default.ClearStatusBeforeEachRun);
        }

        private void ShutdownHost()
        {

        }

        protected override void OnStop()
        {
            ShutdownHost();
            base.OnStop();
        }

        static void watcher_Changed(object sender, FileSystemEventArgs e)
        {
            try
            {
                runPortalExperimentMoninitorAndPublishResults();
            }
            catch (Exception ex)
            {
                logStatus(ex.Message);
            }
        }

        private static void runPortalExperimentMoninitorAndPublishResults()
        {
            if (System.IO.File.Exists(Properties.Settings.Default.EventFile))
            {
                try
                {
                    if (Uri.TryCreate(Properties.Settings.Default.URL, UriKind.Absolute, out _url) == false)
                    {
                        throw new Exception("URL Setting in an invalid format");
                    }

                    // Delete Status
                    if (Properties.Settings.Default.DeleteStatusBeforeEachRun)
                    {
                        DeleteStatus();
                    }

                    logStatus("Deleting Event File", Properties.Settings.Default.ClearStatusBeforeEachRun);
                    File.Delete(Properties.Settings.Default.EventFile);

                    if (String.IsNullOrWhiteSpace(Properties.Settings.Default.AuthenticationType) == false && Properties.Settings.Default.AuthenticationType.ToLower() != "none")
                    {
                        logStatus("Set Credentials");
                        setCredentials();
                    }

                    logStatus("Obtain Bearer Token");
                    obtainBearerToken();

                    logStatus("Find Experiment Ids");
                    Int32[] returnInt32 = findExperimentIds();
                    Int32 experimentRunId = returnInt32[0];
                    Int32 experimentId = returnInt32[1];
                    logStatus("ExperimentRunId:" + experimentRunId.ToString() + "|ExperimentId:" + experimentId.ToString());

                    logStatus("Start Experiment Run");
                    startExpimentRun(experimentRunId, experimentId);

                    experimentRunId = findExperimentResults(experimentId);

                    logStatus("Publish Results");
                    publishResults(experimentRunId);

                    logStatus("Success");
                }
                catch (Exception ex)
                {
                    logStatus(ex.Message);
                }
            }
        }

        private static void setCredentials()
        {
            //
            // Resolve values to objects where necessary
            //
             var cache = new CredentialCache();
            _credentials = null;

            if (Properties.Settings.Default.AuthenticationType.ToLower() == "currentuser")
            {
                // Not sure if we need both lines, but we'll do it anyway
                _useDefaultCredentials = true;
                _credentials = CredentialCache.DefaultCredentials;
            }
            else if (String.IsNullOrWhiteSpace(Properties.Settings.Default.UserName) == false)
            {
                _credentials = cache;
                var rootUrl = new Uri(_url.GetLeftPart(UriPartial.Authority));
                if (String.IsNullOrWhiteSpace(Properties.Settings.Default.Domain) == false)
                    cache.Add(rootUrl, Properties.Settings.Default.AuthenticationType, new NetworkCredential(Properties.Settings.Default.UserName, Properties.Settings.Default.Password ?? String.Empty));
                else
                    cache.Add(rootUrl, Properties.Settings.Default.AuthenticationType, new NetworkCredential(Properties.Settings.Default.UserName, Properties.Settings.Default.Password ?? String.Empty, Properties.Settings.Default.Domain));
            }
        }

        private static void obtainBearerToken()
        {
            var client = new RestClient(_url + "/api/RequestToken");
            client.Timeout = -1;
            var request = new RestRequest(Method.POST);
            if (String.IsNullOrWhiteSpace(Properties.Settings.Default.AuthenticationType) == false && Properties.Settings.Default.AuthenticationType.ToLower() != "none")
            {
                if (_useDefaultCredentials)
                {
                    request.UseDefaultCredentials = true;
                }
                else
                {
                    client.Authenticator = new RestSharp.Authenticators.NtlmAuthenticator(_credentials);
                }
            }
            request.AddHeader("Content-Type", "application/json");
            request.AddParameter("application/json", "{\n    \"PersonalAccessToken\": \"" + Properties.Settings.Default.PersonalAccessToken + "\",\n    \"Purpose\": \"PublicAPI\"\n}", ParameterType.RequestBody);
            IRestResponse response = client.Execute(request);
            if (response.StatusCode != System.Net.HttpStatusCode.OK)
            {
                if (response.ErrorMessage != null) throw new Exception(response.ErrorMessage);
                else throw new Exception(response.Content);
            }
            var xmlDoc = responseToXML(response.Content);
            XmlNodeList node = xmlDoc.GetElementsByTagName("Token");
            _token = node[0].InnerText;
            logStatus("Bearer Token Received Successfully");
        }

        private static Int32[] findExperimentIds()
        {
            var client = new RestClient(_url + "/api/Query");
            client.Timeout = -1;
            var request = new RestRequest(Method.POST);
            request.AddHeader("Content-Type", "multipart/form-data");
            request.AddHeader("Authorization", "Bearer " + _token);
            if (String.IsNullOrWhiteSpace(Properties.Settings.Default.AuthenticationType) == false && Properties.Settings.Default.AuthenticationType.ToLower() != "none")
            {
                if (_useDefaultCredentials)
                {
                    request.UseDefaultCredentials = true;
                }
                else
                {
                    client.Authenticator = new RestSharp.Authenticators.NtlmAuthenticator(_credentials);
                }
            }
            request.AlwaysMultipartFormData = true;
            request.AddParameter("Type", "GetExperimentRuns");
            request.AddParameter("Query", "{\"ReturnNonOwnedRuns\":false}");
            IRestResponse response = client.Execute(request);
            if (response.StatusCode != System.Net.HttpStatusCode.OK)
            {
                if (response.ErrorMessage != null) throw new Exception(response.ErrorMessage);
                else throw new Exception(response.Content);
            }
            var xmlDoc = responseToXML(response.Content);
            Int32[] returnInt = new int[2];
            var dataNodes = xmlDoc.SelectSingleNode("data");
            foreach (XmlNode itemNodes in dataNodes)
            {
                XmlNodeList projectNode = ((XmlElement)itemNodes).GetElementsByTagName("ProjectName");
                XmlNodeList expRunDescriptionNode = ((XmlElement)itemNodes).GetElementsByTagName("Description");
                XmlNodeList scenarioNamesNode = ((XmlElement)itemNodes).GetElementsByTagName("ScenarioNames");
                if (Properties.Settings.Default.ProjectName == projectNode[0].InnerText &&
                    (Properties.Settings.Default.RunSchedule == true && Properties.Settings.Default.RunSchedulePlanScenarioName == scenarioNamesNode[0].InnerXml) ||
                     (Properties.Settings.Default.RunSchedule == false && Properties.Settings.Default.RunExperimentExptRunDesc == expRunDescriptionNode[0].InnerXml))
                {
                        XmlNodeList idNode = ((XmlElement)itemNodes).GetElementsByTagName("Id");
                        XmlNodeList experimentIdNode = ((XmlElement)itemNodes).GetElementsByTagName("ExperimentId");
                        returnInt[0] = Convert.ToInt32(idNode[0].InnerXml);
                        returnInt[1] = Convert.ToInt32(experimentIdNode[0].InnerXml);
                        break;
                }
            }
            if (returnInt[1] ==0)
            {
                throw new Exception("Experiment Run Cannot Be Found");
            }
            return returnInt;
        }

        private static void startExpimentRun(Int32 existingExperimentRuntId, Int32 experimentId)
        {
            var client = new RestClient(_url + "/api/Command");
            client.Timeout = -1;
            var request = new RestRequest(Method.POST);
            request.AddHeader("Content-Type", "multipart/form-data");
            request.AddHeader("Authorization", "Bearer " + _token);
            if (String.IsNullOrWhiteSpace(Properties.Settings.Default.AuthenticationType) == false && Properties.Settings.Default.AuthenticationType.ToLower() != "none")
            {
                if (_useDefaultCredentials)
                {
                    request.UseDefaultCredentials = true;
                }
                else
                {
                    client.Authenticator = new RestSharp.Authenticators.NtlmAuthenticator(_credentials);
                }
            }
            request.AlwaysMultipartFormData = true;
            request.AddParameter("Type", "StartExperimentRun");
            if (Properties.Settings.Default.RunSchedule) request.AddParameter("Command", "{\"ExistingExperimentRunId\": " + existingExperimentRuntId.ToString() + ",\"RunPlan\":true,\"RunReplications\":" + Properties.Settings.Default.RunScheduleRiskAnalysis.ToString().ToLower() + "}");
            else request.AddParameter("Command", "{\"Description\": \"" + Properties.Settings.Default.RunExperimentExptRunDesc + "\", \"ExperimentId\": " + experimentId.ToString() + ",\"RunReplications\":true, \"CreateInfo\":{ \"Scenarios\": [{ \"Name\": \"1Worker\", \"ReplicationsRequired\": 10, \"ControlValues\": [{ \"Name\": \"WorkerQty\", \"Value\": 1}]},{ \"Name\": \"2Workers\", \"ReplicationsRequired\": 10, \"ControlValues\": [{ \"Name\": \"WorkerQty\", \"Value\": 2}]}, { \"Name\": \"3Workers\", \"ReplicationsRequired\": 10, \"ControlValues\": [{ \"Name\": \"WorkerQty\", \"Value\": 3}]}, { \"Name\": \"4Workers\", \"ReplicationsRequired\": 10, \"ControlValues\": [{ \"Name\": \"WorkerQty\", \"Value\": 4}]}]}}");
            IRestResponse response = client.Execute(request);   
            if (response.StatusCode != System.Net.HttpStatusCode.OK)
            {
                if (response.ErrorMessage != null) throw new Exception(response.ErrorMessage);
                else throw new Exception(response.Content);
            }
            var xmlDoc = responseToXML(response.Content);
            var successedNode = xmlDoc.SelectSingleNode("data/Succeeded");
            if (successedNode.InnerText.ToLower() == "false")
            {
                var failureMessageNode = xmlDoc.SelectSingleNode("data/FailureMessage");
                throw new Exception(failureMessageNode.InnerText);
            }
        }        

        private static Int32 findExperimentResults(Int32 experimentId)
        {
            var client = new RestClient(_url + "/api/Query");
            client.Timeout = -1;
            var request = new RestRequest(Method.POST);
            request.AddHeader("Content-Type", "multipart/form-data");
            request.AddHeader("Authorization", "Bearer " + _token);
            if (String.IsNullOrWhiteSpace(Properties.Settings.Default.AuthenticationType) == false && Properties.Settings.Default.AuthenticationType.ToLower() != "none")
            {
                if (_useDefaultCredentials)
                {
                    request.UseDefaultCredentials = true;
                }
                else
                {
                    client.Authenticator = new RestSharp.Authenticators.NtlmAuthenticator(_credentials);
                }
            }
            request.AlwaysMultipartFormData = true;
            request.AddParameter("Type", "GetExperimentRuns");
            request.AddParameter("Query", "{\"ExperimentId\": " + experimentId.ToString() + ",\"ReturnNonOwnedRuns\":false}");

            Int32 numberOfQueries = 1;
            Int32 experimentRunId = -1;
            do
            {
                logStatus("Get Experiment Results Attempt Number = " + numberOfQueries.ToString());
                IRestResponse response = client.Execute(request);
                if (response.StatusCode != System.Net.HttpStatusCode.OK)
                {
                    if (response.StatusCode == System.Net.HttpStatusCode.Unauthorized)
                    {
                        obtainBearerToken();
                        request = new RestRequest(Method.POST);
                        request.AddHeader("Content-Type", "multipart/form-data");
                        request.AddHeader("Authorization", "Bearer " + _token);
                        request.AlwaysMultipartFormData = true;
                        request.AddParameter("Type", "GetExperimentRuns");
                        request.AddParameter("Query", "{\"ExperimentId\": " + experimentId.ToString() + ",\"ReturnNonOwnedRuns\":false}");
                    }
                    else 
                    {
                        if (response.ErrorMessage != null) throw new Exception(response.ErrorMessage);
                        else throw new Exception(response.Content);
                    }
                }
                else
                {
                    var xmlDoc = responseToXML(response.Content);
                    XmlNodeList runStatusList;
                    if (Properties.Settings.Default.RunSchedule) runStatusList = xmlDoc.SelectNodes("data/items/AdditionalRunsStatus");
                    else runStatusList = xmlDoc.SelectNodes("data/items");
                    var lastRunStatus = runStatusList[runStatusList.Count - 1];
                    int statusInt = Convert.ToInt32(lastRunStatus["Status"].InnerText);
                    // still running
                    if (statusInt < 2) numberOfQueries++;
                    // success
                    else if (statusInt == 2)
                    {
                        experimentRunId = Convert.ToInt32(lastRunStatus["Id"].InnerText);
                        break;
                    }
                    // failure
                    else
                    {
                        throw new Exception(lastRunStatus["StatusMessage"].InnerText);
                    }
                }                
                System.Threading.Thread.Sleep(Properties.Settings.Default.RetryResultsIntervalSeconds * 1000);
            } while (numberOfQueries <= Properties.Settings.Default.RetryResultsMaxAttempts);

            if (numberOfQueries > Properties.Settings.Default.RetryResultsMaxAttempts)
            {
                throw new Exception("Number of Retry Results Max Attemps Reached");
            }

            return experimentRunId;
        }

        private static void publishResults(Int32 experimenRuntId)
        {
            var client = new RestClient(_url + "/api/Command");
            client.Timeout = -1;
            var request = new RestRequest(Method.POST);
            request.AddHeader("Content-Type", "multipart/form-data");
            request.AddHeader("Authorization", "Bearer " + _token);
            if (String.IsNullOrWhiteSpace(Properties.Settings.Default.AuthenticationType) == false && Properties.Settings.Default.AuthenticationType.ToLower() != "none")
            {
                if (_useDefaultCredentials)
                {
                    request.UseDefaultCredentials = true;
                }
                else
                {
                    client.Authenticator = new RestSharp.Authenticators.NtlmAuthenticator(_credentials);
                }
            }
            request.AlwaysMultipartFormData = true;
            if (Properties.Settings.Default.RunSchedule) request.AddParameter("Type", "PublishScenarioPlanResults");
            else request.AddParameter("Type", "PublishExperimentRun");
            request.AddParameter("Command", "{\"ExperimentRunId\": " + experimenRuntId.ToString() + ",\"PublishDescription\": \"" + Properties.Settings.Default.PublishDescription + "\",\"PublishName\": \"" + Properties.Settings.Default.PublishName + "\"}");
            IRestResponse response = client.Execute(request);
            if (response.StatusCode != System.Net.HttpStatusCode.OK)
            {
                if (response.ErrorMessage != null) throw new Exception(response.ErrorMessage);
                else throw new Exception(response.Content);
            }
            else
            {
                var xmlDoc = responseToXML(response.Content);
                var successedNode = xmlDoc.SelectSingleNode("data/Succeeded");
                if (successedNode.InnerText.ToLower() == "false")
                {
                    var failureMessageNode = xmlDoc.SelectSingleNode("data/FailureMessage");
                    throw new Exception(failureMessageNode.InnerText);
                }
            }
        }

        private static XmlDocument responseToXML(string responseContent)
        {
            string resultString;
            var isProbablyJSONObject = false;
            var isXMLResponse = false;
            using (var stream = GenerateStreamFromString(responseContent))
            using (var reader = new StreamReader(stream))
            {
                resultString = reader.ReadToEnd();
            }

            // We are looking for the first non-whitespace character (and are specifically not Trim()ing here
            //  to eliminate memory allocations on potentially large (we think?) strings
            foreach (var theChar in resultString)
            {
                if (Char.IsWhiteSpace(theChar))
                    continue;

                if (theChar == '{')
                {
                    isProbablyJSONObject = true;
                    break;
                }
                else if (theChar == '<')
                {
                    isXMLResponse = true;
                    break;
                }
                else
                {
                    // Any other character?
                    break;
                }
            }

            XmlDocument xmlDoc;
            if (isProbablyJSONObject == false)
            {
                var prefix = "{ items: ";
                var postfix = "}";

                using (var combinedReader = new StringReader(prefix)
                                            .Concat(new StringReader(resultString))
                                            .Concat(new StringReader(postfix)))
                {
                    var settings = new JsonSerializerSettings
                    {
                        Converters = { new Newtonsoft.Json.Converters.XmlNodeConverter() { DeserializeRootElementName = "data" } },
                        DateParseHandling = DateParseHandling.None,
                    };
                    using (var jsonReader = new JsonTextReader(combinedReader) { CloseInput = false, DateParseHandling = DateParseHandling.None })
                    {
                        xmlDoc = JsonSerializer.CreateDefault(settings).Deserialize<XmlDocument>(jsonReader);
                    }
                }
            }
            else
            {
                xmlDoc = Newtonsoft.Json.JsonConvert.DeserializeXmlNode(resultString, "data");
            }

            return xmlDoc;
        }

        public static Stream GenerateStreamFromString(string s)
        {
            var stream = new MemoryStream();
            var writer = new StreamWriter(stream);
            writer.Write(s);
            writer.Flush();
            stream.Position = 0;
            return stream;
        }

        private static void logStatus(string msg, bool clear)
        {
            try
            {
                using (System.IO.StreamWriter file = new System.IO.StreamWriter(Properties.Settings.Default.StatusFile, !clear))
                {
                    msg = System.DateTime.Now.ToString() + "-" + msg; 
                    if (msg.Length > 32000) msg = msg.Substring(0, 32000);
                    file.WriteLine(msg);
                }
            }
            catch { }
        }

        private static void logStatus(string msg)
        {
            logStatus(msg, false);
        }

        private static void DeleteStatus()
        {
            try
            {
                if (System.IO.File.Exists(Properties.Settings.Default.StatusFile))
                {
                    File.Delete(Properties.Settings.Default.StatusFile);
                }
            }
            catch { }
        }
    }

    // Provide the ProjectInstaller class which allows

    // the service to be installed by the Installutil.exe tool
    [System.ComponentModel.RunInstaller(true)]
    public class ProjectInstaller : Installer
    {
        private ServiceProcessInstaller process;
        private ServiceInstaller service;
        public ProjectInstaller()
        {
            process = new ServiceProcessInstaller();
            process.Account = ServiceAccount.LocalSystem;
            service = new ServiceInstaller();
            service.ServiceName = "RunSimioPortalExperiment";
            service.Description = "This Service Will Run, Monitor and Publish a Simio Portal Experiment Based On The Creation Of A File";
            Installers.Add(process);
            Installers.Add(service);
        }
    }
}

