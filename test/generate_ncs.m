% Requires Ueli's Neuralynx stuff from http://www.urut.ch/new/serendipity/index.php?/pages/nlxtomatlab.html

sample_frequency = 32000*ones(1, 128);
timestamps = 0:512*10^6/sample_frequency(1):512*10^6/sample_frequency(1)*127;
channel_numbers = ones(1, 128);
number_valid_samples = ones(1, 128)*512;
samples = reshape(-32768:32767, 512, 128);

header = {};
header{1} = ['######## Neuralynx'];     %this is REQUIRED as header prefix
header{2} = ['Test File'];

Mat2NlxCSC('TestFile.ncs', 0, 1, 1, 128, ones(1, 6), timestamps, channel_numbers, sample_frequency, number_valid_samples, samples, header')