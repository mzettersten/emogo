/**
 * jsPsych plugin bandit task
 *
 * Martin Zettersten
 *
 * documentation: docs.jspsych.org
 *
 */

jsPsych.plugins['explore-choice'] = (function() {

  var plugin = {};

  jsPsych.pluginAPI.registerPreload('explore-choice', 'stimuli', 'image');

  plugin.info = {
    name: 'explore-choice',
    description: '',
    parameters: {
      stimuli: {
        type: jsPsych.plugins.parameterType.IMAGE,
        pretty_name: 'Stimuli',
        default: undefined,
        array: true,
        description: 'A stimulus is a path to an image file.'
      },
      canvas_size: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'Canvas size',
        array: true,
        default: [800,800],
        description: 'Array specifying the width and height of the area that the animation will display in.'
      },
      image_size: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'Image size',
        array: true,
        default: [250,250],
        description: 'Array specifying the width and height of the images to show.'
      },
	  reward_scores: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'reward scores',
        array: true,
        default: [8,16,32,64],
        description: 'Array specifying the rewards for each bandit choice'
      },

    reward_images: {
        type: jsPsych.plugins.parameterType.IMAGE,
        pretty_name: 'reward images',
        array: true,
        default: ["stimuli/stars_2.png","stimuli/stars_4.png","stimuli/stars_6.png","stimuli/stars_8.png"],
        description: 'Array specifying the reward images for each trial'
      },
      instruction: {
        type: jsPsych.plugins.parameterType.STRING,
        pretty_name: 'Instruction',
        array: false,
        default: "",
        description: 'instruction shown to participant'
      },
	  cur_score: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'cur_score',
        array: false,
        default: 1,
        description: 'current score of participant'
      },
    }
  }

  plugin.trial = function(display_element, trial) {
    
    // variable to keep track of timing info and responses
    var start_time = 0;
    var responses = [];
  	var choice = "NA";
 	 var choiceLocation = "NA";
 	 var rt = "NA";
  	var end_time = "NA";
	var reward_score = "NA";
	var reward_index = "NA";
    
  var trial_data={};

    // start timer for this trial
    start_time = performance.now();
	
    display_element.innerHTML = "<svg id='jspsych-test-canvas' width=" + trial.canvas_size[0] + " height=" + trial.canvas_size[1] + "></svg>";

    var paper = Snap("#jspsych-test-canvas");
	
  var rect1 = paper.rect(75, 125, 300,300,10);
  rect1.attr({
	  fill: "#ffffff",
	  stroke: "#000",
	  strokeWidth: 5
  });
  
  var rect2 = paper.rect(425, 125, 300,300,10);
  rect2.attr({
	  fill: "#ffffff",
	  stroke: "#000",
	  strokeWidth: 5
  });
  
  var rect3 = paper.rect(75, 475, 300,300,10);
  rect3.attr({
	  fill: "#ffffff",
	  stroke: "#000",
	  strokeWidth: 5
  });
  
  var rect4 = paper.rect(425, 475, 300,300,10);
  rect4.attr({
	  fill: "#ffffff",
	  stroke: "#000",
	  strokeWidth: 5
  });
  
  var imageLocations = {
	  topleft: [100, 150],
	  topright: [450, 150],
	  bottomleft: [100, 500],
	  bottomright: [450, 500],
	  
  };
  
  var scoreBoxLength = 500;
  var scoreBox = paper.rect(150, 25,scoreBoxLength,30);
  scoreBox.attr({
	  fill:'#926239',
	  stroke: "#000",
	  strokeWidth: 5,
  });
  
  var score_index = paper.rect(155,30,trial.cur_score,20);
  score_index.attr({
  	  fill:'#FFFF00',
  	  stroke: "#000",
  	  strokeWidth: 0,
  });

  var instruction = paper.text(400,95,trial.instruction);
  instruction.attr({
		  "text-anchor": "middle",		  
		  "font-weight": "bold",
		  "font-size": 20
	  });
  
  var image1 = paper.image(trial.stimuli[0], imageLocations["topleft"][0], imageLocations["topleft"][1], trial.image_size[0],trial.image_size[1]);
  var image2 = paper.image(trial.stimuli[1], imageLocations["topright"][0], imageLocations["topright"][1], trial.image_size[0],trial.image_size[1]);
  var image3 = paper.image(trial.stimuli[2], imageLocations["bottomleft"][0], imageLocations["bottomleft"][1], trial.image_size[0],trial.image_size[1]);
  var image4 = paper.image(trial.stimuli[3], imageLocations["bottomright"][0], imageLocations["bottomright"][1], trial.image_size[0],trial.image_size[1]);
  
  image1.click(function() {
		reward_index = 0;
	  rect1.attr({
		  fill: "#00ccff",
		  "fill-opacity": 0.5
	  });
	  choice = trial.stimuli[0];
	  choiceLocation = "pos1";
	  reward_score = trial.reward_scores[0];
	  inputEvent();
  });

  image2.click(function() {
		reward_index = 1;
	  rect2.attr({
		  fill: "#00ccff",
		  "fill-opacity": 0.5
	  });
	  choice = trial.stimuli[1];
	  choiceLocation = "pos2";
	  reward_score = trial.reward_scores[1];
	  inputEvent();
  });
  
  image3.click(function() {
		reward_index = 2;
	  rect3.attr({
		  fill: "#00ccff",
		  "fill-opacity": 0.5
	  });
	  choice = trial.stimuli[2];
	  choiceLocation = "pos3";
	  reward_score = trial.reward_scores[2];
	  inputEvent();
  });

  image4.click(function() {
		reward_index = 3;
	  rect4.attr({
		  fill: "#00ccff",
		  "fill-opacity": 0.5
	  });
	  choice = trial.stimuli[3];
	  choiceLocation = "pos4";
	  reward_score = trial.reward_scores[3];
	  inputEvent();
	  
  });

  function inputEvent() {
  	image1.unclick();
		image2.unclick();
		image3.unclick();
		image4.unclick();

	  end_time = performance.now();
	  rt = end_time - start_time;
	  setTimeout(function(){
	  	endTrial();
	  },500);
  }


    function endTrial() {
		

      display_element.innerHTML = '';

	  
      var trial_data = {
		//"label": trial.label,
		start_time: start_time,
		end_time: end_time,
		stimuli: trial.stimuli,
		image1: trial.stimuli[0],
		image2: trial.stimuli[1],
		image3: trial.stimuli[2],
		 image4: trial.stimuli[3],
		choiceLocation: choiceLocation,
		choiceImage: choice,
		rt: rt,
		  reward_score: reward_score,
		  reward_index: reward_index,
		  reward_image: trial.reward_images[reward_index],
		  score_after_trial: trial.cur_score+reward_score
		
	};
	
	console.log(trial.cur_score+reward_score)

      jsPsych.finishTrial(trial_data);
	  
    }
  };

  return plugin;
})();
