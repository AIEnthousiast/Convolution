import processing.video.*;

Capture video;
PImage mirror;
//float[][] kernel = {{1f/9,1f/9,1f/9},{1f/9,1f/9,1f/9},{1f/9,1f/9,1f/9}};
float [][] kernel = {{0,1,0},{1,-4,1},{0,1,0}};
PImage convolution;
PImage greyscale;
PImage treshold;
final float sigma = 1;


void setup()
{
  size(1280,480);
  
  video = new Capture(this,640,480);
  
  //kernel = generateGauss(3,sigma);
  
  video.start();
  
 
  
}


float[][] generateGauss(int size,float sigma)
{
  float[][] gauss = new float[size][size];
  for (int i=0; i <size ;i++)
  {
    
    for (int j=0;j<size; j++)
    {
      int shiftedx = size/2 - i;
      int shiftedy = size/2 - j;
      
      gauss[i][j] = 1f/(2 * PI * sigma * sigma) * exp(-(shiftedx*shiftedx + shiftedy*shiftedy)/(2 * sigma * sigma));
    }
  }
  
  return gauss;
}

PImage applyGreyscale(PImage image)
{
 PImage greyscale = createImage(image.width,image.height,RGB);
 
 image.loadPixels();
 greyscale.loadPixels();
 
 for (int i=0; i < image.height;i++)
 {
   for (int j=0; j < image.width; j++)
   {
     int b = int(brightness(image.pixels[i*image.width + j]));
     greyscale.pixels[i*image.width + j] = color(b,b,b);
   }
 }
 
 
 greyscale.updatePixels();
 
 return greyscale;
  
}

PImage applyTreshold(PImage image, int treshold)
{
  PImage tresh = createImage(image.width,image.height,RGB);
 
 image.loadPixels();
 tresh.loadPixels();
 
 for (int i=0; i < image.height;i++)
 {
   for (int j=0; j < image.width; j++)
   {
     int b = int(brightness(image.pixels[i*image.width + j]));
     if (b > treshold)
     {
       b = 255; 
     }
     else
     {
      b = 0; 
     }
     tresh.pixels[i*image.width + j] = color(b,b,b);
   }
 }
 
 
 tresh.updatePixels();
 
 return tresh;
  
}


PImage applyConvolution(PImage image, float[][] kernel)
{
  
 PImage convolutedImg = createImage(image.width,image.height,RGB);
 
 convolutedImg.loadPixels();
 image.loadPixels();
 for (int i=0; i < image.height;i++)
 {
    for (int j =0 ; j < image.width; j++)
    {
        color out = color(0,0,0);
        
        float r = 0.0;
        float g = 0.0;
        float b = 0.0;
        
        for (int k = 0; k < kernel.length;k++)
        {
          for (int l=0; l < kernel[0].length ; l++)
          {
            
            //Logical position respective to (i,j)
            int shiftedx = kernel.length / 2  - k;
            int shiftedy = kernel[0].length / 2  - l;
            
            if (i + shiftedx > 0 && i + shiftedx <image.height)
            {
               if (j + shiftedy > 0 && j + shiftedy < image.width)
               {
                  color actualPixel = image.pixels[(i + shiftedx) * image.width + j + shiftedy];
                  float coef = kernel[k][l];
                  //out = color(red(out) + red(actualPixel) * coef , green(out) + green(actualPixel) * coef, blue(out) + blue(actualPixel) * coef);
                  r += red(actualPixel) * coef;
                  g +=  green(actualPixel) * coef;
                  b += blue(actualPixel) * coef;
            
               }
               
            }
            
          }
        }
        
        
        convolutedImg.pixels[i * image.width + j] = color(r,g,b);
    }
 }
 
 
 convolutedImg.updatePixels();
 return convolutedImg;
}




PImage getMirrorImage(PImage image)
{
  PImage mirror = createImage(image.width,image.height,RGB);
  
  image.loadPixels();
  mirror.loadPixels();
  
  for (int i=0;i<image.height;i++)
  {
    for (int j=0;j<image.width;j++)
    {
      mirror.pixels[i * image.width + j] = image.pixels[i * image.width + image.width - j - 1];
    }
  }
  
  
  mirror.updatePixels();
  
  return mirror;
}




void captureEvent(Capture video)
{
   video.read(); 
}



void draw()
{
  mirror = getMirrorImage(video);
  //mirror = video;
  greyscale = applyGreyscale(mirror);
  //treshold = applyTreshold(mirror, 140);
  
  convolution = applyConvolution(greyscale,kernel);
  //convolution = applyTreshold(greyscale,240);
  //convolution = applyConvolution(mirror,kernel);
  convolution = applyTreshold(convolution,5);
  
  image(greyscale,0,0);
  //image(convolution,640,0);
  //image(greyscale,640,0);
  image(convolution,640,0);
  
}
