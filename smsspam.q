smsspam.f:"smsspamcollection"
smsspam.b:"http://archive.ics.uci.edu/ml/machine-learning-databases/"
smsspam.b,:"00228/"
-1"[down]loading sms-spam data set";
.util.download[smsspam.b;;".zip";.util.unzip] smsspam.f;
smsspam.t:flip `class`text!("S*";"\t")0: `:SMSSpamCollection
