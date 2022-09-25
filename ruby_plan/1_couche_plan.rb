def couche_1(layer_name)
	mss_content = <<EOS
	@zoom_tableau: 15;
	@zoom_terr: 18;

	/*
	* Pour l'export de territoire [ZOOM 17 et 18]
	*/
	#motorway_label[zoom=@zoom_terr],
	#mainroad_label[zoom=@zoom_terr],
	#mainroad_label[type='primary'][zoom=@zoom_terr],
	#mainroad_label[type='secondary'][zoom=@zoom_terr],
	#mainroad_label[type='tertiary'][zoom=@zoom_terr],
	#minorroad_label[zoom=@zoom_terr] {
	  text-name:'';
	  text-face-name:@sans;
	}

	/* ecole, parc, ...*/
	#area_label {
	  text-name: "";
	  text-face-name:@sans;
	}
	
	/* Permet d'avoir les routes plus visible */
	#roads_high::outline,
	#roads_low,
	#roads_med,
	#roads_high{
	  line-color:gray;
	  line-width:5;
	  ::case{ line-color:#777;line-width: 16; } 
	  ::fill{ line-color:white;line-width: 10; }

	  [type='motorway'],
	  [type='trunk'],
	  [type='primary'],
	  [type='path'],
	  [type='track'],
	  [type='footway'],
	  [type='steps'],
	  [type='motorway_link'],
	  [type='unclassified'],
	  [type='secondary']{
	  line-color:gray;
	  line-width:5;
	    ::case{ line-color:#777;line-width: 16; } 
	    ::fill{ line-color:white;line-width: 10; }
	  }
	}
EOS
end
