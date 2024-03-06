

experiment = " "; //choose experiment name ex02...

bleach_mean_488 = newArray(); //insert vector with 488 bleaching over time

getDimensions(width, height, channels, slices, frames);

Table.create(experiment);

for (frame = 1; frame<frames+1; frame = frame +1){


//reading the filter detection from matlab and makin the x, y, z and A vectors

//run("Table... ", "open=/scratch/Gustavo/aqui_34.txt");

x = newArray(500);
y = newArray(500);
z = newArray(500);
A = newArray(500);
//selectWindow("newName");



//selectWindow(experiment);
Table.set(frame+"_488", frame-1, frame);
Table.set(frame+"_560", frame-1, frame);
Table.set(frame+"_642", frame-1, frame);

path_txt = "/scratch/Gustavo/notch_det/"+experiment+"/";

//import csv as Results
for(l = 0; l < 4; l=l+1){
	if(l==0){
		run("Table... ", "open="+path_txt+"x_pos_"+frame+".txt");
		Table.rename("x_pos_"+frame+".txt", "Results");
	}
	if(l==1){
		run("Table... ", "open="+path_txt+"y_pos_"+frame+".txt");
		Table.rename("y_pos_"+frame+".txt", "Results");
	}
	if(l==2){
		run("Table... ", "open="+path_txt+"z_pos_"+frame+".txt");
		Table.rename("z_pos_"+frame+".txt", "Results");
	}
	if(l==3){
		run("Table... ", "open="+path_txt+"A_pos_"+frame+".txt");
		Table.rename("A_pos_"+frame+".txt", "Results");
	}
	a = String.getResultsHeadings;
	j = 0; 
	i=0;
	while(i<lengthOf(a)){
		i = indexOf(a, ",");	
		//print(i);
		if(i<0){
			i = lengthOf(a);
		}
		num = substring(a, 0, i);
		//print(num);
		if(l==0){
			x[j] = parseFloat(num);	
		}
		if(l==1){
			y[j] = parseFloat(num);	
		}
		if(l==2){
			z[j] = parseFloat(num);	
		}
		if(l==3){
			A[j] = parseFloat(num);	
		}
		//print(x_pos[j]);
		j = j + 1;
		//print(a);
		//print(lengthOf(a)+" "+i);
		if(i<lengthOf(a)){
			a = substring(a, i+1, lengthOf(a));
		}	
	}

	//print(j);
}

positions = j;

j=0;

//print(x[0]);
//print(y[0]);
//print(z[0]);
//print(A[0]);


//reading the filter detection from matlab and makin the x, y, z and A vectors



real_list = newArray(300);

real = 0;
j = 0;
adding = 0;
dx_560 = -5;
dy_560 = 0;

dx = 0;
dy = 0;

length_filter = 5;
length_measure = 3;

ch_filter = 2;
ch_measure = 1;
ch_642 = 3;

channel = 1;
integral = 0;
integral_560 = 0;
integral_642 = 0;


sum = newArray(60);
sum_560 = newArray(60);
sum_642 = newArray(60);

for(i = 0; i<positions; i=i+1){
	Stack.setFrame(frame);
	Stack.setChannel(ch_filter);
	Stack.setSlice(z[i]);
	makeRectangle(x[i]-length_filter-dx_560, y[i]-length_filter-dy_560, 2*length_filter, 2*length_filter);
	
	getRawStatistics(nPixels, mean, min, max, std, histogram);
	
	if(mean>100){ //if needed, add here other conditions to filter detections
//	if((mean<105 && std > 1) || (min < 102 && mean < 110) || (min < 98.7 && mean > 110 && std > 8) || (std>8 && max>122 && mean<115) || (max > 180 && mean > 120 && std > 8)){
		Stack.setChannel(ch_measure);
		makeRectangle(x[i]-length_measure-dx, y[i]-length_measure-dy, 2*length_measure, 2*length_measure);
		getStatistics(area, mean, min, max, std, histogram);
		
		if(mean > bleach_mean_488[frame-1]){ //filter for 488 intensity
			
		//Stack.setFrame(frame);
		real = real + 1;
		real_list[j] = i;
		j = j+1;
		integral = 0;
		integral_560 = 0;
		integral_642 = 0;
		
		
		Roi.setPosition(channel, z[i], frame);
		roiManager("Add");
		
		for(j=-1; j<2; j=j+1){
			Stack.setSlice(z[i]+j);
			//run("Add...", "value="+adding+" slice");
			for(h = 0; h<length_measure*2; h=h+1){
				for(r = 0; r<length_measure*2; r=r+1){
					value_raw = getPixel(round(x[i]-length_measure-dx + h), round(y[i]-length_measure-dy + r)); //488
					integral = integral + value_raw;
					if(value_raw<400){
						setPixel(round(x[i]-length_measure-dx + h), round(y[i]-length_measure-dy + r), value_raw+adding);
					}
				}
			}
		}
		sum[real-1] = integral;
		//run("Measure");
		//print("z = "+z[i]);
		

		
		//for 560
		Stack.setChannel(ch_filter);
		for(j=-1; j<2; j=j+1){
			Stack.setSlice(z[i]+j);
			//run("Add...", "value="+adding+" slice");
			for(h = 0; h<length_measure*2; h=h+1){
				for(r = 0; r<length_measure*2; r=r+1){
					value_raw_560 = getPixel(round(x[i]-length_measure-dx_560 + h), round(y[i]-length_measure-dy_560 + r)); //488
					integral_560 = integral_560 + value_raw_560;
					if(value_raw_560<400){
						setPixel(round(x[i]-length_measure-dx_560 + h), round(y[i]-length_measure-dy_560 + r), value_raw_560+adding);
					}
				}
			}
		}
		sum_560[real-1] = integral_560;
		
		Stack.setChannel(ch_642);
		for(j=-1; j<2; j=j+1){
			Stack.setSlice(z[i]+j);
			//run("Add...", "value="+adding+" slice");
			for(h = 0; h<length_measure*2; h=h+1){
				for(r = 0; r<length_measure*2; r=r+1){
					value_raw_642 = getPixel(round(x[i]-length_measure-dx + h), round(y[i]-length_measure-dy + r)); //488
					integral_642 = integral_642 + value_raw_642;
					if(value_raw_642<400){
						setPixel(round(x[i]-length_measure-dx + h), round(y[i]-length_measure-dy + r), value_raw_642+adding);
					}
				}
			}
		}
		sum_642[real-1] = integral_642;
		
		}
	}
	
	Table.setColumn(frame+"_488", sum);
	Table.setColumn(frame+"_560", sum_560);
	Table.setColumn(frame+"_642", sum_642);
	

// filter for not being inside DMS53 mean less than 150 
	
}


print("spots "+real);

}

save_path = ; //add path to save ex: /scratch/Gustavo/notch_det/ROI/

roiManager("Deselect");
roiManager("Save", save_path+experiment+"_RoiSet.zip");

roiManager("Deselect");
//roiManager("Delete");

selectWindow(experiment);
run("Text...", save_path+experiment+".csv");
