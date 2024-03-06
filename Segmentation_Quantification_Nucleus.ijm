//Macro for segmentation of the nuclei using SiR-DNA staining (channel3, 640) and for determination of the signal intensity in channel2 (561)


//choose the folder to save the data
dir = getDirectory("Choose a Directory");
 

name = getTitle(); //get the name of the image
selectWindow(name); //select the window with the name
run("Select All"); 

roiManager("add");

index = indexOf(name, ".", 0); //get the name until the .tif
name = substring(name, 0, index); //name receives the name until .tif
print(name); //print the name in the log to check if the name is correct

run("Split Channels"); //split the 3 channels of the image
 
selectWindow("C3-"+name+".tif"); //select the window with the 3rd channel - Sir-DNA signal
run("Duplicate...", "duplicate"); //duplicate Sir-DNA channel

roiManager("Select", 0);
getDimensions(width, height, channels, slices, frames); //get the information of the Sir-DNA channel stack

roiManager("Deselect"); 
//saveAs("Tiff", dir+name); //save this image in the dir selected in the first line 

roiManager("Save",dir+name+"ROI_crop.zip"); 

roiManager("Deselect");
roiManager("Delete");

//Set min max for channel3 BEGIN
max1 = 0;
for(i=1; i<slices; i++){ 
	setSlice(i);
	getMinAndMax(min, max);
	if(max > max1){
		max1 = max;
	}
}
//Set min max for channel3 END

print(max1*0.3);

//run("Gaussian Blur...", "sigma=3 stack");

//Edge preserving filter:

loop = 1;

for (; loop != 0; ) { //Loop Begin

selectWindow("C3-"+name+"-1.tif"); //select DUPLICATE the window with the 3rd channel - Sir-DNA signal

//Dialog 2
	Dialog.create("Set Threshold");
	Dialog.addMessage("Nucleus!");
	Dialog.addNumber("max", max1);
	Dialog.show();
	max1 = Dialog.getNumber();
	//1st dialog

	run("Median...", "radius=3 stack");  //Make a blur using Median filter

saveAs("Tiff", dir+name+"blur"); //Save the blur image

//Thresholding:
//setAutoThreshold("Otsu dark stack");
setThreshold(max1*0.55, 65000);
setOption("BlackBackground", false);

//Note: If used Background=Dark black the fill holes function will see the nucleus as 'the hole' and fill the whole nucleus.
//run("Convert to Mask", "method=Mean background=Dark black");

run("Convert to Mask", "method=Shanbhag background=Dark");  //convert the image to binary mask

//run("Convert to Mask", "method=Mean background=Dark");

saveAs("Tiff", dir+name+"binary"); //Save the binary mask

setForegroundColor(255, 255, 255);

run("Fill Holes", "stack"); //fill holes in the segmented area in the binary mask

saveAs("Tiff", dir+name+"binary+filled_holes"); //Save the binary mask filled


//Segmentation:
run("Analyze Particles...", "size=30-Infinity add stack"); //analyze particles to create one roi for each plane

roiManager("deselect"); //deleselect the roi to save all in a glance
roiManager("Save", dir+name+"ROI_areas_size.zip"); //save all the rois

//Add here the images of each segmented plane to check if it is fine

nrois = roiManager("count");
print("nrois , = ", nrois);


selectWindow("C3-"+name+".tif");
run("Duplicate...", "duplicate"); //duplicate Sir-DNA channel
	
for(i=0; i<nrois; i++){
	selectWindow("C3-"+name+"-1.tif");
	roiManager("select", i);
	run("Add Selection...");
}

run("Flatten", "stack");
run("Make Montage...", "columns="+slices/5+" row="+5+" scale=1");

	//dialog if the nucleus is fine
	Dialog.create("Is it good?");
	Dialog.addNumber("loop", 1);
	Dialog.show();
	loop = Dialog.getNumber();
	print(loop);


if(loop != 0){
	selectWindow(name+"binary+filled_holes.tif"); //select the window with the 3rd channel - Sir-DNA signal
	close(); //close the duplicated channel3
	selectWindow("Montage");
	close(); //close the montage
	selectWindow("C3-"+name+"-1.tif");
	close(); //close the montage
	
	selectWindow("C3-"+name+".tif"); //select the window with the 3rd channel - Sir-DNA signal
	makeRectangle(0, 0, width, height);
	run("Duplicate...", "duplicate"); //duplicate Sir-DNA channel
	roiManager("deselect");
	roiManager("Delete");
}




	
} //Loop END 


selectWindow("C2-"+name+".tif");

saveAs("Tiff", dir+"C2-"+name);

nrois = roiManager("count");
print(nrois);

roiManager("deselect");
roiManager("Measure");

selectWindow("Results");
saveAs("Results", dir+name+"_nucleus_size_statistics.csv");

close("Results")

//Take each ROI and srink it with the size of 1 pixel in order exclude all non nuclear contribution to the intensity measuremens. Save as ROI_areas_intensity. 
for (i = 0; i < nrois; i++) {
		roiManager("select", i);
		run("Enlarge...", "enlarge=-1");
		//run("Enlarge...", "enlarge=+0.5");
		roiManager("Update"); 
	}


roiManager("deselect");
roiManager("Measure");

selectWindow("Results");
saveAs("Results", dir+name+"_nucleus_intensity_statistics.csv");

roiManager("deselect");
roiManager("Save", dir+name+"ROI_areas_intensity.zip");


selectWindow("C2-"+name+".tif");
roiManager("select", 0);
selectWindow("C2-"+name+".tif");
slice_min = getSliceNumber();

roiManager("select", nrois-1);
selectWindow("C2-"+name+".tif");
aqui = getSliceNumber();
print(aqui);
slice_max = getSliceNumber();

for(j=1; j<slice_min; j++){
	Stack.setSlice(j); 	
	makeRectangle(0, 0, width, height);
	run("Set...", "value=0 slice");
	}

for (i = 0; i < nrois; i++) {
		roiManager("select", i);
		run("Make Inverse");
		run("Set...", "value=0 slice");
		j = getSliceNumber();       
	}

for(; j<slices+1; j++){
	Stack.setSlice(j); 
	makeRectangle(0, 0, width, height);
	run("Set...", "value=0 slice");
	}
	
saveAs("Tiff", dir+name+"_Nucleus.tif");
roiManager("Deselect");
roiManager("Delete");
selectWindow("Results");

	


run("Close");
run("Close All");

