smsspam.f:"smsspamcollection"
smsspam.b:"http://archive.ics.uci.edu/ml/machine-learning-databases/00228/"
-1"downloading sms spam data set";
.util.download[smsspam.b;;".zip";"unzip -n"] smsspam.f;
smsspam.t:flip `class`text!("S*";"\t")0: `:SMSSpamCollection
