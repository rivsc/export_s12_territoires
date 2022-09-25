def couche_6(textsize, layer_name)
mss_content = <<EOS
@zoom_tableau: 15;
@zoom_terr: 18;

#motorway_label[zoom=@zoom_terr],
#mainroad_label[zoom=@zoom_terr],
#mainroad_label[type='primary'][zoom=@zoom_terr],
#mainroad_label[type='secondary'][zoom=@zoom_terr],
#mainroad_label[type='tertiary'][zoom=@zoom_terr],
#minorroad_label[zoom=@zoom_terr] {
  text-name:'';
  text-face-name:@sans;
  text-placement:line;
  text-size:#{textsize};
  text-fill:#000;
  text-halo-fill:#FFF;
  text-halo-radius:2;
  text-allow-overlap:true;
  text-min-path-length:0.0;
}

##{layer_name} {
   
  // Style territoires sur carte de territoire
  [zoom=@zoom_terr]{
  	text-name:"";
  }
  
  text-name:"";
  line-color:#999;
  line-width:0;
  polygon-opacity:0.2;
  polygon-fill:#F00;
  text-face-name:"DejaVu Sans Bold";
  text-allow-overlap:true;
  text-size:20;
  text-fill:#000;
  text-halo-fill:#FFF;
  text-halo-radius:2;
}
  

##{layer_name},
#land[zoom=@zoom_terr], 
#landuse[zoom=@zoom_terr], 
#metzsablon_general[zoom=@zoom_terr],
#barrier_lines[zoom=@zoom_terr], 
#barrier_points[zoom=@zoom_terr],   
#roads_low[zoom=@zoom_terr], 
#roads_med[zoom=@zoom_terr], 
#roads_high[zoom=@zoom_terr], 
#tunnel[zoom=@zoom_terr], 
#bridge[zoom=@zoom_terr], 
#buildings[zoom=@zoom_terr],
#water[zoom=@zoom_terr],
#water_gen1[zoom=@zoom_terr],
#water_gen0[zoom=@zoom_terr],
#waterway_high[zoom=@zoom_terr],
#waterway_med[zoom=@zoom_terr],
#waterway_low[zoom=@zoom_terr],
#landuse_gen1[zoom=@zoom_terr],
#landuse_gen0[zoom=@zoom_terr],
#land-high.shp[zoom=@zoom_terr],
#land-low.shp[zoom=@zoom_terr],
#land-low.shp[zoom=@zoom_terr],
#buildings[zoom=@zoom_terr]{
    polygon-opacity:0;
    line-opacity:0;
    building-fill-opacity:0;
    ::outline{line-opacity:0;polygon-opacity:0;}
    ::case{ line-opacity:0;polygon-opacity:0;line-width: 16; } 
    ::fill{ line-opacity:0;polygon-opacity:0;line-width: 10; }
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
  
#area_label {
  text-name: "";
  text-halo-radius: 1.5;
  text-face-name:@sans; 
  text-wrap-width:30;
  text-fill: #555;
  text-halo-fill: #fff;
    
  [zoom=@zoom_terr]{
    text-size: 40;
    text-line-spacing:-10;
  }
}

##{layer_name} {
  text-name:"";
  line-color:#999;
  line-width:0;
  polygon-opacity:0;
  polygon-fill:#F00;
  
  text-face-name:"DejaVu Sans Bold";
  text-allow-overlap:true;
  text-size:20;
  text-fill:#000;
  text-halo-fill:#FFF;
  text-halo-radius:2;
}
#housenumbers[zoom=@zoom_terr] {
  ::label {
    text-name: '[addr:housenumber]';
    text-face-name:@sans;
    text-size: #{textsize};   
    text-placement:interior;
    text-min-distance: 1;
    text-wrap-width: 0;
    text-fill: #444;
  }    
}

EOS
end
