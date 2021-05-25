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

  jsPsych.pluginAPI.registerPreload('vsl-animate-occlusion', 'stimuli', 'image');

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
        default: [1000,800],
        description: 'Array specifying the width and height of the area that the animation will display in.'
      },
      image_size: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'Image size',
        array: true,
        default: [300,300],
        description: 'Array specifying the width and height of the images to show.'
      },
	  rewards: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'rewards',
        array: true,
        default: [10,25,50,100],
        description: 'Array specifying the rewards for each bandit choice'
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
	var reward = "NA";
    
  var trial_data={};

    // start timer for this trial
    start_time = performance.now();
	
    display_element.innerHTML = "<svg id='jspsych-test-canvas' width=" + trial.canvas_size[0] + " height=" + trial.canvas_size[1] + "></svg>";

    var paper = Snap("#jspsych-test-canvas");
	
  var rect1 = paper.rect(25, 0, 350,350,10);
  rect1.attr({
	  fill: "#ffffff",
	  stroke: "#000",
	  strokeWidth: 5
  });
  
  var rect2 = paper.rect(425, 0, 350,350,10);
  rect2.attr({
	  fill: "#ffffff",
	  stroke: "#000",
	  strokeWidth: 5
  });
  
  var rect3 = paper.rect(25, 400, 350,350,10);
  rect3.attr({
	  fill: "#ffffff",
	  stroke: "#000",
	  strokeWidth: 5
  });
  
  var rect4 = paper.rect(425, 400, 350,350,10);
  rect4.attr({
	  fill: "#ffffff",
	  stroke: "#000",
	  strokeWidth: 5
  });
  
  var imageLocations = {
	  topleft: [50, 25],
	  topright: [450, 25],
	  bottomleft: [50, 425],
	  bottomright: [450, 425],
	  
  };
  
  var scoreBoxLength = 600;
  var scoreBox = paper.rect(900, 50,50,scoreBoxLength);
  scoreBox.attr({
	  fill:'#926239',
	  stroke: "#000",
	  strokeWidth: 5,
  });
  
  var score_index = paper.rect(905, scoreBoxLength+45-trial.cur_score,40,trial.cur_score);
  score_index.attr({
  	  fill:'#368f8b',
  	  stroke: "#000",
  	  strokeWidth: 0,
  });

  
  
  var image1 = paper.image(trial.stimuli[0], imageLocations["topleft"][0], imageLocations["topleft"][1], trial.image_size[0],trial.image_size[1]);
  var image2 = paper.image(trial.stimuli[1], imageLocations["topright"][0], imageLocations["topright"][1], trial.image_size[0],trial.image_size[1]);
  var image3 = paper.image(trial.stimuli[2], imageLocations["bottomleft"][0], imageLocations["bottomleft"][1], trial.image_size[0],trial.image_size[1]);
  var image4 = paper.image(trial.stimuli[3], imageLocations["bottomright"][0], imageLocations["bottomright"][1], trial.image_size[0],trial.image_size[1]);
  
  image1.click(function() {
	image1.unclick();
	image2.unclick();
	image3.unclick();
	image4.unclick();
	  end_time = performance.now();
	  rt = end_time - start_time;
	  rect1.attr({
		  fill: "#00ccff",
		  "fill-opacity": 0.5
	  });
	  choice = trial.stimuli[0];
	  choiceLocation = "pos1";
	  reward = trial.rewards[0];
	  score_index.attr({y: scoreBoxLength+45-(trial.cur_score+reward), height: trial.cur_score+reward})
  	setTimeout(function(){
  		endTrial(choice,choiceLocation,rt,reward);
  	},500);
  });

  image2.click(function() {
	image1.unclick();
	image2.unclick();
	image3.unclick();
	image4.unclick();
	  end_time = performance.now();
	  rt = end_time - start_time;
	  rect2.attr({
		  fill: "#00ccff",
		  "fill-opacity": 0.5
	  });
	  choice = trial.stimuli[1];
	  choiceLocation = "pos2";
	  reward = trial.rewards[1];
	  score_index.attr({y: scoreBoxLength+45-(trial.cur_score+reward), height: trial.cur_score+reward})
  	setTimeout(function(){
  		endTrial(choice,choiceLocation,rt,reward);
  	},500);
  });
  
  image3.click(function() {
	image1.unclick();
	image2.unclick();
	image3.unclick();
	image4.unclick();
	  end_time = performance.now();
	  rt = end_time - start_time;
	  rect3.attr({
		  fill: "#00ccff",
		  "fill-opacity": 0.5
	  });
	  choice = trial.stimuli[2];
	  choiceLocation = "pos3";
	  reward = trial.rewards[2];
	  score_index.attr({y: scoreBoxLength+45-(trial.cur_score+reward), height: trial.cur_score+reward})
  	setTimeout(function(){
  		endTrial(choice,choiceLocation,rt,reward);
  	},500);
  });

  image4.click(function() {
	image1.unclick();
	image2.unclick();
	image3.unclick();
	image4.unclick();
	  end_time = performance.now();
	  rt = end_time - start_time;
	  rect4.attr({
		  fill: "#00ccff",
		  "fill-opacity": 0.5
	  });
	  choice = trial.stimuli[3];
	  choiceLocation = "pos4";
	  reward = trial.rewards[3];
	  score_index.attr({y: scoreBoxLength+45-(trial.cur_score+reward), height: trial.cur_score+reward})
	setTimeout(function(){
		endTrial(choice,choiceLocation,rt,reward);
	},500);
	  
  });


    function endTrial(choice,choiceLocation,rt,reward) {
		

      display_element.innerHTML = '';
	  
	  console.log(reward);

	  
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
		  reward: reward,
		  score_after_trial: trial.cur_score+reward
		
	};
	
	console.log(trial.cur_score+reward)

      jsPsych.finishTrial(trial_data);
	  
    }
  };

  return plugin;
})();
