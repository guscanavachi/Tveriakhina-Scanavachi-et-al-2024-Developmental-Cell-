//FIJI MACRO for synapse and transendocytosis quantification

name = getTitle();

Table.create(name+"profile");

nRois = roiManager("count");

print("count"+nRois);

//Define l slices -> 2*l + 1 is the total z planes
l=2

for (i = 0; i < nRois; i++) {

roiManager("Select", i);
Stack.getPosition(channel, slice, frame);



for (k = 0, n=l; k < 2*l+1; k++, n=n-1) {
selectWindow(name);
Stack.setSlice(slice-n);

print(slice-n);

Stack.setChannel(1);
prof = getProfile();
selectWindow(name+"profile");
Table.setColumn("FI_ch1_"+i+"_"+k, prof)

selectWindow(name);
Stack.setChannel(2);
prof = getProfile();
selectWindow(name+"profile");
Table.setColumn("FI_ch2_"+i+"_"+k, prof)

selectWindow(name);
Stack.setChannel(3);
prof = getProfile();
selectWindow(name+"profile");
Table.setColumn("FI_ch3_"+i+"_"+k, prof)

}

}

selectWindow(name+"profile");


path_to_save = " "; //insert here the path to save
saveAs("Results", path_to_save+name+"profile.csv");


roiManager("Deselect");


roiManager("Save", path_to_save+name+"ROI_list.zip");


roiManager("Deselect");
roiManager("Delete");

run("Close All");
