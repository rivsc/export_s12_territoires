def couche_4(layer_name)
mss_content = <<EOS


@zoom_tableau: 15;
@zoom_terr: 18;

#land[zoom=@zoom_terr], 
#landuse[zoom=@zoom_terr],
#land-high.shp{
   
    polygon-opacity:0;
   
    }

#motorway_label[zoom=@zoom_terr],
#mainroad_label[zoom=@zoom_terr],
#mainroad_label[type='primary'][zoom=@zoom_terr],
#mainroad_label[type='secondary'][zoom=@zoom_terr],
#mainroad_label[type='tertiary'][zoom=@zoom_terr],
#minorroad_label[zoom=@zoom_terr] {
    text-name:"";
    text-face-name:@sans;
    text-opacity:0;
    text-halo-opacity:0;
    polygon-opacity:0;
    line-opacity:0;
    ::case{ line-opacity:0;line-width: 16; } 
    ::fill{ line-opacity:0;line-width: 10; }
}

  #barrier_lines[zoom=@zoom_terr], 
  #barrier_points[zoom=@zoom_terr],   
  #roads_low[zoom=@zoom_terr], 
    #roads_med[zoom=@zoom_terr], 
    #roads_high[zoom=@zoom_terr], 
      #tunnel[zoom=@zoom_terr], 
      #bridge[zoom=@zoom_terr], 
      #buildings[zoom=@zoom_terr]{
      polygon-opacity:0;
    line-opacity:0;
    ::outline{line-opacity:0;polygon-opacity:0;}
    ::case{ line-opacity:0;polygon-opacity:0;line-width: 16; } 
    ::fill{ line-opacity:0;polygon-opacity:0;line-width: 10; }
    }

#area_label {
  text-name: "[name]";
  text-halo-radius: 1.5;
  text-face-name:@sans; 
  text-wrap-width:30;
  text-fill: #555;
  text-halo-fill: #fff;
     
  [zoom=@zoom_terr]{
    text-size: 40;
  }
}
  #buildings[zoom=@zoom_terr]{
    polygon-opacity:0;
    building-fill-opacity:0;
    line-opacity:0;
  }

##{layer_name} {
    polygon-opacity:0;
}
#motorway_label[oneway!=0][zoom=@zoom_terr],
#mainroad_label[oneway!=0][zoom=@zoom_terr],
#minorroad_label[oneway!=0][zoom=@zoom_terr] {
  marker-opacity:0;
}
#landuse_parking[zoom=@zoom_terr] {
  [type='parking'] {
     point-opacity:0;
  }
}

 
EOS
end
