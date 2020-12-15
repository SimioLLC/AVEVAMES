using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using uPLibrary.Networking.M2Mqtt;
using uPLibrary.Networking.M2Mqtt.Messages;

namespace PublishMQTTNamespace
{ 
    public class PublishMQTTClass
    {
        MqttClient _mqttClient;

        public PublishMQTTClass()
        { }

        public void PublishMQTTMethod(string xmlSource)
        {
            // Publish To MQTT
            xmlSource = DateTime.Now.ToOADate().ToString();

            try
            {
                if (_mqttClient == null)
                {
                    _mqttClient = new MqttClient(Properties.Settings.Default.Broker);
                    _mqttClient.Connect(System.Environment.MachineName + "|" + Properties.Settings.Default.Topic);
                }
                byte[] bytes = Encoding.ASCII.GetBytes(xmlSource);
                _mqttClient.Publish(Properties.Settings.Default.Topic, bytes, MqttMsgBase.QOS_LEVEL_EXACTLY_ONCE, true);
            }
            // Catch Exception
            catch(Exception ex)
            {
                using (System.IO.StreamWriter file = new System.IO.StreamWriter(Properties.Settings.Default.ErrorFile, true))
                {
                    file.WriteLine(ex.Message);
                }
            }
        }
    }
}
